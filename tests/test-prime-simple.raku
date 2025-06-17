#!/usr/bin/env raku

use lib 'lib';
use Inline::BASIC;

# Simpler prime test
basic q:to/END/;
10 LET N = 2
20 LET ISPRIME = 1
30 PRINT "N="; N; " ISPRIME="; ISPRIME
40 IF ISPRIME = 1 THEN PRINT N; " IS PRIME"
50 END
END