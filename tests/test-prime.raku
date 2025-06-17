#!/usr/bin/env raku

use lib 'lib';
use Inline::BASIC;

# Test the prime number logic
basic q:to/END/;
10 REM CHECK IF NUMBERS ARE PRIME
20 FOR N = 2 TO 10
30   PRINT "CHECKING "; N
40   LET ISPRIME = 1
50   FOR D = 2 TO N - 1
60     LET MOD = N - INT(N / D) * D
70     PRINT "  N="; N; " D="; D; " MOD="; MOD
80     IF MOD = 0 THEN ISPRIME = 0
90   NEXT D
100  IF ISPRIME = 1 THEN PRINT N; " IS PRIME"
110 NEXT N
120 END
END