#!/usr/bin/env raku

use lib 'lib';
use Inline::BASIC;

# Fixed prime test - calculate modulo in steps
basic q:to/END/;
10 REM CHECK IF NUMBERS ARE PRIME
20 FOR N = 2 TO 20
30   LET ISPRIME = 1
40   FOR D = 2 TO N - 1
50     LET Q = INT(N / D)
60     LET R = N - Q * D
70     IF R = 0 THEN ISPRIME = 0
80   NEXT D
90   IF ISPRIME = 1 THEN PRINT N; " IS PRIME"
100 NEXT N
110 END
END