use v6.d;

unit module Inline::BASIC;

class Interpreter {
    has %.variables;
    has %.line-numbers;
    has @.program-lines;
    has $.current-line is rw = 0;
    has @.gosub-stack;
    has @.for-stack;
    has @.data-values;
    has $.data-pointer is rw = 0;
    has $.running is rw = True;
    
    method parse(Str $code) {
        %.variables = ();
        %.line-numbers = ();
        @.program-lines = ();
        @.gosub-stack = ();
        @.for-stack = ();
        @.data-values = ();
        $.data-pointer = 0;
        
        for $code.lines -> $line {
            next unless $line.trim;
            next unless $line ~~ /^ \s* (\d+) \s+ (.*) $/;
            my $line-num = +$0;
            my $statement = ~$1.trim;
            %.line-numbers{$line-num} = @.program-lines.elems;
            @.program-lines.push: ($line-num, $statement);
        }
        
        @.program-lines = @.program-lines.sort(*[0]);
        
        for @.program-lines.kv -> $idx, ($num, $stmt) {
            %.line-numbers{$num} = $idx;
        }
        
        self!extract-data();
    }
    
    method !extract-data() {
        for @.program-lines -> ($num, $stmt) {
            if $stmt ~~ /^ 'DATA' \s+ (.+) $/ {
                my $data-line = ~$0;
                for $data-line.split(',') -> $value {
                    @.data-values.push: $value.trim;
                }
            }
        }
    }
    
    method run() {
        $.current-line = 0;
        $.running = True;
        
        while $.running && $.current-line < @.program-lines.elems {
            my ($line-num, $statement) = @.program-lines[$.current-line];
            my $old-line = $.current-line;
            self!execute-statement($statement, $line-num);
            if $.current-line == $old-line && $.running {
                $.current-line++;
            }
        }
    }
    
    method !execute-statement(Str $stmt, $line-num) {
        if $stmt ~~ /^ 'PRINT' [\s+ (.+)]? $/ {
            self!execute-print($0 ?? ~$0 !! '');
        }
        elsif $stmt ~~ /^ 'INPUT' \s+ (.+) $/ {
            self!execute-input(~$0);
        }
        elsif $stmt ~~ /^ 'LET' \s+ (.+) $/ {
            self!execute-let(~$0);
        }
        elsif $stmt ~~ /^ (\w+) \s* '=' \s* (.+) $/ {
            self!execute-assignment(~$0, ~$1);
        }
        elsif $stmt ~~ /^ 'GOTO' \s+ (\d+) $/ {
            self!execute-goto(+$0);
        }
        elsif $stmt ~~ /^ 'GOSUB' \s+ (\d+) $/ {
            self!execute-gosub(+$0);
        }
        elsif $stmt ~~ /^ 'RETURN' $/ {
            self!execute-return();
        }
        elsif $stmt ~~ /^ 'IF' \s+ (.+?) \s+ 'THEN' \s+ (.+) $/ {
            self!execute-if(~$0, ~$1);
        }
        elsif $stmt ~~ /^ 'FOR' \s+ (\w+) \s* '=' \s* (.+?) \s+ 'TO' \s+ (.+?) [\s+ 'STEP' \s+ (.+)]? $/ {
            self!execute-for(~$0, ~$1, ~$2, $3 ?? ~$3 !! '1');
        }
        elsif $stmt ~~ /^ 'NEXT' \s+ (\w+) $/ {
            self!execute-next(~$0);
        }
        elsif $stmt ~~ /^ 'END' $/ {
            $.running = False;
        }
        elsif $stmt ~~ /^ 'STOP' $/ {
            $.running = False;
        }
        elsif $stmt ~~ /^ 'REM' / {
            # Comment, do nothing
        }
        elsif $stmt ~~ /^ 'DATA' / {
            # Already processed, do nothing
        }
        elsif $stmt ~~ /^ 'READ' \s+ (.+) $/ {
            self!execute-read(~$0);
        }
        elsif $stmt ~~ /^ 'RESTORE' $/ {
            $.data-pointer = 0;
        }
        elsif $stmt ~~ /^ 'DIM' \s+ (.+) $/ {
            self!execute-dim(~$0);
        }
        else {
            die "?SYNTAX ERROR IN $line-num: Unknown statement '$stmt'";
        }
    }
    
    method !execute-print(Str $args) {
        return say() unless $args;
        
        my @parts;
        my $remaining = $args.trim;
        
        while $remaining {
            # Check for string literal first
            if $remaining ~~ /^ '"' (<-["]>*) '"' (.*)/ {
                my $str = ~$0;
                my $rest = $1 ?? ~$1 !! '';
                # Handle escaped characters in string literals
                $str ~~ s:g/'\\' (.)/$0/;
                @parts.push: $str;
                $remaining = $rest;
            }
            # Check for expression (anything up to a separator or end)
            elsif $remaining ~~ /^ (<-[;,]>+) (.*)/ {
                my $expr = ~$0.trim;
                my $rest = $1 ?? ~$1 !! '';
                # Check if it's a simple string variable
                if $expr ~~ /^ (\w+ '$') $/ {
                    @parts.push: self!get-variable(~$0).Str;
                }
                else {
                    @parts.push: self!evaluate-expression($expr).Str;
                }
                $remaining = $rest;
            }
            else {
                # No pattern matched, check for separators
                if $remaining ~~ /^ ';' \s* (.*)/ {
                    $remaining = $0 ?? ~$0 !! '';
                }
                elsif $remaining ~~ /^ ',' \s* (.*)/ {
                    @parts.push: "\t";
                    $remaining = $0 ?? ~$0 !! '';
                }
                else {
                    # Nothing matched, exit loop
                    last;
                }
            }
        }
        
        print @parts.join('');
        say() unless $args ~~ /';' \s* $/;
    }
    
    method !execute-input(Str $vars) {
        print "? ";
        $*OUT.flush;
        my $input = $*IN.get // '';
        
        my @var-names = $vars.split(',')».trim;
        my @values = $input.split(',')».trim;
        
        for @var-names Z @values -> ($var, $val) {
            if $var ~~ /'$' $/ {
                %.variables{$var} = $val;
            } else {
                %.variables{$var} = +$val;
            }
        }
    }
    
    method !execute-let(Str $assignment) {
        if $assignment ~~ /^ (\w+ '$'?) \s* '=' \s* (.+) $/ {
            self!execute-assignment(~$0, ~$1);
        }
    }
    
    method !execute-assignment(Str $var, Str $expr) {
        if $var ~~ /'$' $/ {
            %.variables{$var} = self!evaluate-string-expression($expr);
        } else {
            %.variables{$var} = self!evaluate-expression($expr);
        }
    }
    
    method !execute-goto($target-line) {
        if %.line-numbers{$target-line}:exists {
            $.current-line = %.line-numbers{$target-line};
        } else {
            die "?UNDEF'D STATEMENT ERROR";
        }
    }
    
    method !execute-gosub($target-line) {
        @.gosub-stack.push: $.current-line;
        self!execute-goto($target-line);
    }
    
    method !execute-return() {
        if @.gosub-stack {
            $.current-line = @.gosub-stack.pop + 1;
        } else {
            die "?RETURN WITHOUT GOSUB ERROR";
        }
    }
    
    method !execute-if(Str $condition, Str $then-part) {
        if self!evaluate-condition($condition) {
            if $then-part ~~ /^ \s* (\d+) \s* $/ {
                self!execute-goto(+$0);
            } else {
                self!execute-statement($then-part, $.current-line);
            }
        }
    }
    
    method !execute-for(Str $var, Str $start, Str $end, Str $step) {
        # Check if we're already in this FOR loop
        if @.for-stack && @.for-stack[*-1]<var> eq $var && @.for-stack[*-1]<line> == $.current-line {
            # We're re-entering the same FOR loop from a NEXT, don't reinitialize
            return;
        }
        
        my $start-val = self!evaluate-expression($start);
        my $end-val = self!evaluate-expression($end);
        my $step-val = self!evaluate-expression($step);
        
        %.variables{$var} = $start-val;
        
        # Check if we should skip the loop entirely
        my $skip = $step-val > 0
            ?? $start-val > $end-val
            !! $start-val < $end-val;
            
        if $skip {
            # Find the matching NEXT and jump past it
            my $for-depth = 1;
            for $.current-line + 1 ..^ @.program-lines.elems -> $idx {
                my ($num, $stmt) = @.program-lines[$idx];
                if $stmt ~~ /^ 'FOR' \s+ (\w+) / {
                    $for-depth++;
                }
                elsif $stmt ~~ /^ 'NEXT' \s+ (\w+) / {
                    if ~$0 eq $var {
                        $for-depth--;
                        if $for-depth == 0 {
                            # Jump to line after NEXT
                            if $idx + 1 < @.program-lines.elems {
                                $.current-line = $idx + 1;
                            } else {
                                # NEXT is last line, just end
                                $.running = False;
                            }
                            return;
                        }
                    }
                }
            }
            die "?FOR WITHOUT NEXT ERROR";
        }
        
        @.for-stack.push: {
            :$var,
            :end($end-val),
            :step($step-val),
            :line($.current-line)
        };
    }
    
    method !execute-next(Str $var) {
        unless @.for-stack && @.for-stack[*-1]<var> eq $var {
            die "?NEXT WITHOUT FOR ERROR";
        }
        
        my $for-info = @.for-stack[*-1];
        
        %.variables{$var} += $for-info<step>;
        
        my $done = $for-info<step> > 0
            ?? %.variables{$var} > $for-info<end>
            !! %.variables{$var} < $for-info<end>;
        
        if $done {
            @.for-stack.pop;
        } else {
            $.current-line = $for-info<line>;
        }
    }
    
    method !execute-read(Str $vars) {
        for $vars.split(',')».trim -> $var {
            if $.data-pointer < @.data-values {
                my $value = @.data-values[$.data-pointer++];
                if $var ~~ /'$' $/ {
                    %.variables{$var} = $value;
                } else {
                    %.variables{$var} = +$value;
                }
            } else {
                die "?OUT OF DATA ERROR";
            }
        }
    }
    
    method !execute-dim(Str $dims) {
        # Simple implementation - just initialize arrays
        for $dims.split(',')».trim -> $dim {
            if $dim ~~ /^ (\w+) \s* '(' \s* (\d+) \s* ')' $/ {
                my $array-name = ~$0;
                my $size = +$1;
                %.variables{$array-name} = [(0) xx ($size + 1)];
            }
        }
    }
    
    method !get-variable(Str $name) {
        %.variables{$name} // ($name ~~ /'$' $/ ?? '' !! 0);
    }
    
    method !evaluate-expression(Str $expr) {
        my $e = $expr.trim;
        
        # Handle functions
        $e ~~ s:g/'RND' \s* '(' \s* ')'/rand()/;
        $e ~~ s:g/'INT' \s* '(' (<-[)]>+) ')'/'floor(' ~ $0 ~ ')'/;
        $e ~~ s:g/'ABS' \s* '(' (<-[)]>+) ')'/'abs(' ~ $0 ~ ')'/;
        
        # Replace variables with their values
        for %.variables.kv -> $name, $value {
            next if $name ~~ /'$' $/;
            $e ~~ s:g/<<$name>>/$value/;
        }
        
        # Evaluate the expression
        use MONKEY-SEE-NO-EVAL;
        try {
            return EVAL $e;
        }
        return 0;
    }
    
    method !evaluate-string-expression(Str $expr) {
        my $e = $expr.trim;
        
        if $e ~~ /^ '"' (.*) '"' $/ {
            return ~$0;
        }
        elsif $e ~~ /^ (\w+ '$') $/ {
            return self!get-variable(~$0);
        }
        else {
            # Handle concatenation with +
            my @parts;
            for $e.split('+')».trim -> $part {
                if $part ~~ /^ '"' (.*) '"' $/ {
                    @parts.push: ~$0;
                }
                elsif $part ~~ /^ (\w+ '$') $/ {
                    @parts.push: self!get-variable(~$0);
                }
                else {
                    @parts.push: $part;
                }
            }
            return @parts.join('');
        }
    }
    
    method !evaluate-condition(Str $cond) {
        my $c = $cond.trim;
        
        # Handle string comparisons
        if $c ~~ /'$'/ {
            if $c ~~ /^ (.+?) \s* '=' \s* (.+) $/ {
                return self!evaluate-string-expression(~$0) eq self!evaluate-string-expression(~$1);
            }
            elsif $c ~~ /^ (.+?) \s* '<>' \s* (.+) $/ {
                return self!evaluate-string-expression(~$0) ne self!evaluate-string-expression(~$1);
            }
        }
        
        # Handle numeric comparisons
        for ('=', '<>', '<=', '>=', '<', '>') -> $op {
            if $c ~~ /^ (.+?) \s* $op \s* (.+) $/ {
                my $left = self!evaluate-expression(~$0);
                my $right = self!evaluate-expression(~$1);
                given $op {
                    when '=' { return $left == $right }
                    when '<>' { return $left != $right }
                    when '<=' { return $left <= $right }
                    when '>=' { return $left >= $right }
                    when '<' { return $left < $right }
                    when '>' { return $left > $right }
                }
            }
        }
        
        # If no operator found, evaluate as boolean
        return self!evaluate-expression($c) != 0;
    }
}

sub basic(Str $code) is export {
    my $interpreter = Interpreter.new;
    $interpreter.parse($code);
    $interpreter.run();
}

=begin pod

=head1 NAME

Inline::BASIC - Classic Line-Numbered BASIC interpreter for Raku

=head1 SYNOPSIS

    use Inline::BASIC;

    basic q:to/END/;
    10 PRINT "HELLO, WORLD!"
    20 FOR I = 1 TO 10
    30   PRINT I
    40 NEXT I
    50 END
    END

=head1 DESCRIPTION

This module provides a Classic Line-Numbered BASIC interpreter for Raku,
supporting the most common BASIC commands and constructs from the 1970s
and 1980s era of computing.

=end pod