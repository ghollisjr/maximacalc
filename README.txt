This project is released to the public domain, and mostly provides an
initialization file "phys.mac" for the open source computer algebra
system Maxima (maxima.sourceforge.net) which provides physics
constants and units so that physics, chemistry or engineering
calculations are more convenient.

The design is simple, so that all units are expressed as some multiple
of the fundamental S. I. unit for that kind of quantity.  To find the
value of a quantity in some particular unit, just divide the quantity
by that unit (with the exception of temperature, for which there are
functions provided).

For conversions between temperatures, there are functions for
converting between Celsius, Fahrenheit, and Kelvins which have
appropriate names like "CtoF", "FtoK", etc.  There is also a handy
function which separates out quantities or numbers into the sum of
quantities which are to be multiplied by a set of different units.
This function is simply called "cou" for the perhaps regrettable name
of "convert other units".  For example, to convert the quantity "5
meters" into feet and inches, you would do "cou(5*_m, [_ft, _in])"
which would return "[16, 616/127]" or the floating point approximation
"[16.0, 4.850...]".  This function can also be used for other clever
purposes, such as getting the binary digits of a number, e.g. "cou(15,
[8, 4, 2, 1])" which would return "[1, 1, 1, 1]".

The bash script "maximacalc.sh" is a launcher script for maxima using
phys.mac which uses the rxvt-unicode terminal to create a bare-bones
but very effective calculator for all kinds of purposes.  Edit the
script with your preferred phys.mac location.

Currencies are available as units named by their lower case ISO 4217
codes, such as "_usd", "_eur" and "_jpy", so "100*_usd/_jpy" gives the
value of 100 U.S. dollars in yen.  The U.S. dollar is the base unit.  The exchange rates are the European Central
Bank's daily reference rates, which "currency.lisp" downloads with
curl and caches in the Maxima user directory for a day; keep
"currency.lisp" in the same directory as "phys.mac" (a symbolic link
to "phys.mac" from elsewhere is fine).  The variable "currency_date"
holds the date of the rates in use, and "update_currencies(true)"
forces a fresh download.  Without a network connection the last
downloaded rates are used.

The function "norminv" is the inverse CDF of the standard normal
distribution, e.g. "norminv(0.975)" returns about 1.96.
