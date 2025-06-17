#!/usr/bin/env raku

use lib 'lib';
use Inline::BASIC;

# Test with debugging
my $interpreter = Inline::BASIC::Interpreter.new;
$interpreter.parse(q:to/END/);
10 PRINT "BEFORE LOOP"
20 FOR I = 5 TO 1
30   PRINT "IN LOOP: I="; I
40 NEXT I
50 PRINT "AFTER LOOP"
60 END
END

# Add some debugging
say "Program lines:";
for $interpreter.program-lines.kv -> $idx, ($num, $stmt) {
    say "  $idx: $num $stmt";
}

$interpreter.run();