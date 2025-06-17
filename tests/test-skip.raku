#!/usr/bin/env raku

use lib 'lib';
use Inline::BASIC;

# Test skipping a FOR loop
basic q:to/END/;
10 PRINT "BEFORE LOOP"
20 FOR I = 5 TO 1
30   PRINT "IN LOOP: I="; I
40 NEXT I
50 PRINT "AFTER LOOP"
60 END
END