#!/usr/bin/env raku

use lib 'lib';
use Inline::BASIC;

say "=== EXAMPLE 1: Hello World ===";
basic q:to/END/;
10 PRINT "HELLO FROM BASIC!"
20 END
END

say "\n=== EXAMPLE 2: Simple Math ===";
basic q:to/END/;
10 LET A = 10
20 LET B = 20
30 PRINT A; " + "; B; " = "; A + B
40 PRINT A; " * "; B; " = "; A * B
50 END
END

say "\n=== EXAMPLE 3: Countdown ===";
basic q:to/END/;
10 FOR I = 10 TO 1 STEP -1
20   PRINT I; "..."
30 NEXT I
40 PRINT "BLAST OFF!"
50 END
END

say "\n=== EXAMPLE 4: Temperature Conversion ===";
basic q:to/END/;
10 REM CELSIUS TO FAHRENHEIT
20 FOR C = 0 TO 100 STEP 20
30   LET F = C * 9 / 5 + 32
40   PRINT C; "C = "; F; "F"
50 NEXT C
60 END
END

say "\n=== EXAMPLE 5: Multiplication Table ===";
basic q:to/END/;
10 PRINT "MULTIPLICATION TABLE"
20 PRINT "===================="
30 FOR I = 1 TO 10
40   FOR J = 1 TO 10
50     LET P = I * J
60     IF P < 10 THEN PRINT " ";
70     IF P < 100 THEN PRINT " ";
80     PRINT P;
90   NEXT J
100  PRINT
110 NEXT I
120 END
END

say "\n=== EXAMPLE 6: Prime Number Check ===";
basic q:to/END/;
10 REM CHECK IF NUMBERS ARE PRIME
20 FOR N = 2 TO 20
30   LET ISPRIME = 1
40   FOR D = 2 TO N - 1
50     IF N - INT(N / D) * D = 0 THEN ISPRIME = 0
60   NEXT D
70   IF ISPRIME = 1 THEN PRINT N; " IS PRIME"
80 NEXT N
90 END
END

say "\n=== EXAMPLE 7: String Manipulation ===";
basic q:to/END/;
10 LET FIRST$ = "RAKU"
20 LET LAST$ = "BASIC"
30 LET FULL$ = FIRST$ + " LOVES " + LAST$
40 PRINT FULL$
50 PRINT "LENGTH WOULD BE "; 15; " CHARACTERS"
60 END
END

say "\n=== EXAMPLE 8: Using DATA Statements ===";
basic q:to/END/;
10 REM DAYS OF THE WEEK
20 DATA MONDAY, TUESDAY, WEDNESDAY
30 DATA THURSDAY, FRIDAY, SATURDAY, SUNDAY
40 PRINT "DAYS OF THE WEEK:"
50 FOR I = 1 TO 7
60   READ DAY$
70   PRINT I; ". "; DAY$
80 NEXT I
90 END
END