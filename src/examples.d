import std.algorithm;
import std.stdio;
import std.typecons;
import std.random;

import cl.loop;

void main(string[] args) {
    args = args[1 .. $];             // Get rid of the process name.

    writeln("Iterate args:");
    mixin Loop!q{
        for arg in args
           print "Hello ", arg, "!"
        end
    };

    writeln("Print and count:");
    mixin Loop!q{
        with ifs as result
        for i from 0 to 20
        if $$ i % 2 == 0 $$
            print i and
            count i
        else if $$ i % 3 == 0 $$
            count i
        else
            print "Not %2 nor %3: ", i
    };
    writeln(ifs);

    writeln("Nested stuff:");
    mixin Loop!q{
        with res as result
        for i from 0 to 10
            when $$ i & 1 $$
                collect i and
                collect i and
                collect i and
                if $$ i % 3 == 0 $$
                    collect 3 and
                    when $$i > 3 $$
                       if true
                          collect 3
                       end
                else
                    collect 5
    };
    writeln(res);

    writeln("Nested loops:");
    mixin Loop!q{
        with loops as result
        with size = 10
        for x from 0 to size do $$
        mixin Loop!q{
               for y from 0 to size
               print "x: ", x, " y: ", y
        } $$
    };
    writeln(loops);

    writeln("Multiple counts:");
    auto max = 23;
    mixin Loop!q{
        with counts as result
        for i from 0 to max
            count $$ i % 3 == 0 $$
            count $$ i % 5 == 0 $$
    };
    writeln(counts);

    writeln("Random numbers:");
    mixin Loop!q{
        with random as result
        for i from 0 to 100
        collect $$uniform(0,100)$$
    };
    writeln(random);

    // // TODO
    // mixin Loop!(q{
    //     with stats as result
    //     for i in random
    //     counting $$ (i&1) == 0 $$ into evens
    //     counting $$ (i&1) == 1 $$ into odds
    //     summing i into total
    //     maximizing i into max
    //     minimizing i into min
    //     finally $$return [min, max, total, evens, odds];$$
    // }, true);
    // writeln(stats);
}