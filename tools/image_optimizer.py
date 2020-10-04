#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import numpy
from PIL import Image
from scipy.cluster.vq import kmeans, vq


# -----------------------------------------------------------------------------
# script based on: https://github.com/mzucker/noteshrink
#             and  https://mzucker.github.io/2016/09/20/noteshrink.html
#
# modified by      marcus.trommen@gmx.net / 2019-11-01
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
TARGET_DPI = [ 150 , 150 ]
IMAGE_SIZE_A4_300DPI = [ 2550, 3508 ]
IMAGE_SIZE_A4_200DPI = [ 1700, 2338 ]
IMAGE_SIZE_A4_150DPI = [ 1275, 1754 ]
IMAGE_SIZE_A4_100DPI = [  850, 1169 ]
IMAGE_SIZE_A4_075DPI = [  638,  877 ]
IMAGE_SIZE_A4_INCH   = [  8.5, 11.69 ]
IMAGE_SIZE_A4_MILLIMETER = [ 216, 297 ]


# -----------------------------------------------------------------------------
def quantize(image, bits_per_channel=None):

	'''Reduces the number of bits per channel in the given image.'''

	if bits_per_channel is None:
		bits_per_channel = 6

	assert image.dtype == numpy.uint8

	shift = 8-bits_per_channel
	halfbin = (1 << shift) >> 1

	return ((image.astype(int) >> shift) << shift) + halfbin


# -----------------------------------------------------------------------------
def pack_rgb(rgb):

	'''Packs a 24-bit RGB triples into a single integer,
	works on both arrays and tuples.'''

	orig_shape = None

	if isinstance(rgb, numpy.ndarray):
		assert rgb.shape[-1] == 3
		orig_shape = rgb.shape[:-1]
	else:
		assert len(rgb) == 3
		rgb = numpy.array(rgb)

	rgb = rgb.astype(int).reshape((-1, 3))

	packed = (rgb[:, 0] << 16 |
			  rgb[:, 1] << 8 |
			  rgb[:, 2])

	if orig_shape is None:
		return packed
	else:
		return packed.reshape(orig_shape)


# -----------------------------------------------------------------------------
def unpack_rgb(packed):

	'''Unpacks a single integer or array of integers into one or more
	24-bit RGB values.

	'''

	orig_shape = None

	if isinstance(packed, numpy.ndarray):
		assert packed.dtype == int
		orig_shape = packed.shape
		packed = packed.reshape((-1, 1))

	rgb = ((packed >> 16) & 0xff,
		   (packed >> 8) & 0xff,
		   (packed) & 0xff)

	if orig_shape is None:
		return rgb
	else:
		return numpy.hstack(rgb).reshape(orig_shape + (3,))


# -----------------------------------------------------------------------------
def get_bg_color(image, bits_per_channel=None):

	'''Obtains the background color from an image or array of RGB colors
	by grouping similar colors into bins and finding the most frequent
	one.
	'''

	assert image.shape[-1] == 3

	quantized = quantize(image, bits_per_channel).astype(int)
	packed = pack_rgb(quantized)

	unique, counts = numpy.unique(packed, return_counts=True)

	packed_mode = unique[counts.argmax()]

	return unpack_rgb(packed_mode)


# -----------------------------------------------------------------------------
def rgb_to_sv(rgb):

	'''Convert an RGB image or array of RGB colors to saturation and
	value, returning each one as a separate 32-bit floating point array or
	value.
	'''

	if not isinstance(rgb, numpy.ndarray):
		rgb = numpy.array(rgb)

	axis = len(rgb.shape)-1
	cmax = rgb.max(axis=axis).astype(numpy.float32)
	cmin = rgb.min(axis=axis).astype(numpy.float32)
	delta = cmax - cmin

	saturation = delta.astype(numpy.float32) / cmax.astype(numpy.float32)
	saturation = numpy.where(cmax == 0, 0, saturation)

	value = cmax/255.0

	return saturation, value


# -----------------------------------------------------------------------------
def sample_pixels(img, fraction_of_pixels_to_sample):

	'''Pick a fixed percentage of pixels in the image, returned in random
	order.'''

	pixels = img.reshape((-1, 3))
	num_pixels = pixels.shape[0]
	num_samples = int(num_pixels * fraction_of_pixels_to_sample)

	idx = numpy.arange(num_pixels)
	numpy.random.shuffle(idx)

	return pixels[idx[:num_samples]]


# -----------------------------------------------------------------------------
def get_fg_mask(bg_color
	, samples
	, background_value_threshold
	, background_saturation_threshold):

	'''Determine whether each pixel in a set of samples is foreground by
	comparing it to the background color. A pixel is classified as a
	foreground pixel if either its value or saturation differs from the
	background by a threshold.'''

	s_bg, v_bg = rgb_to_sv(bg_color)
	s_samples, v_samples = rgb_to_sv(samples)

	s_diff = numpy.abs(s_bg - s_samples)
	v_diff = numpy.abs(v_bg - v_samples)

	return ((v_diff >= background_value_threshold) |
			(s_diff >= background_saturation_threshold))


# -----------------------------------------------------------------------------
def get_palette(samples
	, background_value_threshold
	, background_saturation_threshold
	, number_of_colors
	, return_mask=False
	, kmeans_iter=40):

	'''Extract the palette for the set of sampled RGB values. The first
	palette entry is always the background color; the rest are determined
	from foreground pixels by running K-means clustering. Returns the
	palette, as well as a mask corresponding to the foreground pixels.
	'''

	print('  getting palette...')

	bg_color = get_bg_color(samples, 6)

	fg_mask = get_fg_mask(bg_color
		, samples
		, background_value_threshold
		, background_saturation_threshold)

	centers, _ = kmeans(samples[fg_mask].astype(numpy.float32)
		, number_of_colors-1
		, iter=kmeans_iter)

	palette = numpy.vstack((bg_color, centers)).astype(numpy.uint8)

	if not return_mask:
		return palette
		
	return palette, fg_mask


# -----------------------------------------------------------------------------
def apply_palette(img
	, palette
	, background_value_threshold
	, background_saturation_threshold):

	'''Apply the pallete to the given image. The first step is to set all
	background pixels to the background color; then, nearest-neighbor
	matching is used to map each foreground color to the closest one in
	the palette.
	'''

	print('  applying palette...')

	bg_color = palette[0]

	fg_mask = get_fg_mask(bg_color
		, img
		, background_value_threshold
		, background_saturation_threshold)

	orig_shape = img.shape

	pixels = img.reshape((-1, 3))
	fg_mask = fg_mask.flatten()

	num_pixels = pixels.shape[0]

	labels = numpy.zeros(num_pixels, dtype=numpy.uint8)

	labels[fg_mask], _ = vq(pixels[fg_mask], palette)

	return labels.reshape(orig_shape[:-1])


# -----------------------------------------------------------------------------
def save(filename
	, labels
	, palette
	, has_saturated_colors
	, has_white_background):

	'''Save the label/palette pair out as an indexed PNG image.
This optionally saturates the pallete by mapping the smallest color component 
to zero and the largest one to 255, 
and also optionally sets the background color to pure white.
	'''

	print('  saving ', filename)

	if has_saturated_colors:
		palette = palette.astype(numpy.float32)
		pmin = palette.min()
		pmax = palette.max()
		palette = 255 * (palette - pmin)/(pmax-pmin)
		palette = palette.astype(numpy.uint8)

	if has_white_background:
		palette = palette.copy()
		palette[0] = (255, 255, 255)

	output_img = Image.fromarray(labels, 'P')
	output_img.putpalette(palette.flatten())
	output_img.thumbnail(IMAGE_SIZE_A4_150DPI)
	output_img.save(filename, dpi=TARGET_DPI)


# -----------------------------------------------------------------------------
def load(filename):

	'''Load an image with Pillow and convert it to numpy array'''

	try:
		pil_img = Image.open(filename)
	except IOError:
		print('warning: error opening {}\n'.format(filename))
		return None, None

	if pil_img.mode != 'RGB':
		pil_img = pil_img.convert('RGB')

	img = numpy.array(pil_img)

	return img


# -----------------------------------------------------------------------------

def optimize(input_filename
	, fraction_of_pixels_to_sample
	, background_value_threshold
	, background_saturation_threshold
	, number_of_colors
	, has_saturated_colors
	, has_white_background
	, output_filename):
	
	img = load(input_filename)
	if img is None:
		return

	print('opened', input_filename)

	samples = sample_pixels(img, fraction_of_pixels_to_sample)

	palette = get_palette(samples
		, background_value_threshold
		, background_saturation_threshold
		, number_of_colors)

	labels = apply_palette(img
		, palette
		, background_value_threshold
		, background_saturation_threshold)

	save(output_filename
		, labels
		, palette
		, has_saturated_colors
		, has_white_background)

	print('  done\n')
