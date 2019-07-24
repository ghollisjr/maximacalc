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
but very effective calculator for all kinds of purposes.
