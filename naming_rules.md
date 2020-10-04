# Naming Rules for Directories and Documents of the Scan Archive


## The Document_ID

General naming format for single documents is the *Document_ID* and looks like:

```
YYYYMMDD_xx
```

Examples:

```
19981103_03 ... the  3rd document on 1998-11-03
20050101_23 ... the 22nd document on 2005-01-01
20200229_01 ... the  1st document on 2020-02-29
```

Die *Document_ID* richtet sich nach dem Kalendertag, an dem das Dokument
als Original erstellt wurde oder dem es zugeordnet werden kann und hat das 
Format `YYYYMMDD_xx`.

Dabei sind die einzelnen Namenskomponenten wie folgt zu interpretieren:

`YYYY` ist die *vierstellige Jahresangabe* (wie z.B. `2020`),

`MM` ist die *zweistellige Monatangabe* (wie z.B. `03` für März oder `11` 
für November),

`DD` ist die *zweistellige Tagesangabe* im Monat (wie z.B. `12` für den 
zwölften Tag im Monat),

`xx` ist die *laufende Nummer* des Dokuments, beginnend bei `01`. Gibt es
an einem Kalendertag mehrere Dokumente, die mit ihrem *Erstelldatum* diesem
Tag zugeordnet werden können, dann wird aufsteigend die jeweils nächste 
freie *ID* gewählt (z.B. `02` oder `37`). Durch das zweistellige Format sind
von `01` bis `99` insgesamt 99 Einzeldokumente einem Kalendertag zuordenbar.
In der Regel sollte dies ausreichen. Sollte in seltenen Fällen diese 
Obergrenze überschritten werden, dann können die überhängigen Dokumente auf
den nächsten Kalendertag übertrag werden, ohne das Namens-Schema aufgeben zu
müssen. Sollte die Obergrenze ständig übertreten werden, so ist es zu 
erwägen, die Namenskonvention auf ein drei- oder vierstelliges Format zu
erweitern.


## Pages of a Document

Derived from the naming convention of a document with a *Document_ID*

```
YYYYMMDD_xx_ppp
```

Examples:

```
19981103_03_001 ... the   1st page of the  3rd document on 1998-11-03
20050101_23_005 ... the   5th page of the 22nd document on 2005-01-01
20200229_01_135 ... the 135th page of the  1st document on 2020-02-29
```


## Rules how to find the Document_ID of a given Documument

	
1.	Dokumente mit aufgedrucktem *Erstelldatum*, wie beispielsweise bei 
	Eingangspost, Verträge, Rechnungen, usw., erhalten dieses Datum, anstatt 
	des Datums, des tatsächlichen Erhalts oder Posteingang.

1.	Manche Dokumente tragen als *Erstelldatum* nur eine Monatsangabe 
	(z.B. "Juni 2020" wie bei Gehaltsauszügen). Dann wird für die *Document_ID* 
	der jeweils *Monatserste* (also z.B. "20200601_xx") herangezogen. 

1.	Manche Dokumente haben als *Erstelldatum* nur eine Jahresangabe (z.B. 
	"2020" wie bei Sozialversicherungsauszügen). Dann wird für die *Document_ID*
	der jeweilige *Jahresanfang* (also der 1. Januar, wie z.B. "20200101_xx")
	herangezogen.

1.	Dokumente, die mit einer Datumsangabe unterzeichnet wurden, sollten dieses
	Datum als *Dokument_ID* erhalten.