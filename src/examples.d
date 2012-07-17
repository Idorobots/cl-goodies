import std.algorithm;
import std.stdio;
import std.typecons;
import std.random;

import cl.loop;

void main(string[] args) {
    args = args[1 .. $];             // Get rid of the process name.

    mixin Loop!q{
        for arg in args
        print arg
    };

    // TODO
    mixin Loop!(q{
        with ifs as result
        for i from 0 to 100
        if $$ i % 2 == 0 $$
           print i and
           count i
        end
    }, true);

    auto max = 23;
    mixin Loop!q{
        with counts as result
        for i from 0 to max
        count $$ i % 3 == 0 $$
        count $$ i % 5 == 0 $$
    };
    writeln(counts);

    mixin Loop!q{
        with random as result
        for i from 0 to 100
        collect $$uniform(0,100)$$
    };
    writeln(random);

    // TODO
    mixin Loop!(q{
        with stats as result
        for i in random
        counting $$ (i&1) == 0 $$ into evens
        counting $$ (i&1) == 1 $$ into odds
        summing i into total
        maximizing i into max
        minimizing i into min
        finally $$return [min, max, total, evens, odds];$$
    }, true);
    writeln(stats);
}