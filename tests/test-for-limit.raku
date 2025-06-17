#!/usr/bin/env raku

use lib 'lib';
use Inline::BASIC;

# Test FOR loop with expression as limit
basic q:to/END/;
10 LET N = 5
20 PRINT "N = "; N
30 PRINT "LOOP FROM 2 TO N-1:"
40 FOR D = 2 TO N - 1
50   PRINT D
60 NEXT D
70 END
END