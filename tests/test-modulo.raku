#!/usr/bin/env raku

use lib 'lib';
use Inline::BASIC;

# Test modulo calculation
basic q:to/END/;
10 LET N = 7
20 LET D = 3
30 PRINT "N = "; N; ", D = "; D
40 LET Q = INT(N / D)
50 PRINT "INT(N/D) = "; Q
60 LET MOD = N - Q * D
70 PRINT "N - INT(N/D) * D = "; MOD
80 END
END