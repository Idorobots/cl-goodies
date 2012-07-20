import std.algorithm;
import std.stdio;
import std.typecons;
import std.random;

import cl.loop;

/*******************************************************************************
 * Some Loop Examples
 *
 * NOTE CTFE is still an experimental feature and is really resource-hungry.
 * NOTE Keep that in mind when compiling this file.
 ******************/

void main(string[] args) {
    args = args[1 .. $];             // Get rid of the process name.

    writeln("Iterate args:");
    mixin(Loop!q{
        for arg in args
           print "Hello ", arg, "!"
        end
    });

    auto aa = ["foo" : "bar", "bar" : "foo"];

    writeln("Iterating a hash:");
    writeln(mixin(Loope!q{
        for k being the keys of aa
        for v being the values of aa
        collect k
        collect v
    }));

    writeln("Print and count:");
    writeln(mixin(Loope!q{
        for i from 0 to 20 by $$uniform(1,5)$$
        if $$ i % 6 == 0 $$
            print i and
            count i
        else if $$ i % 3 == 0 $$
            count i
        else
            print "Not %6 nor %3: ", i
    }));

    writeln("Nested stuff:");
    writeln(mixin(Loope!q{
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
    }));

    writeln("Nested loops:");
    mixin(Loop!q{
        with size = 3
        for x from 0 to size
          do $$ mixin(Loop!q{
            for y from 0 to size
              print "x: ", x, " y: ", y
          }); $$
    });

    writeln("Multiple counts:");
    auto var = 23;
    writeln(mixin(Loope!q{
        for i from 0 to var
            count $$ i % 3 == 0 $$
            count $$ i % 5 == 0 $$
    }));

    writeln("Random numbers:");
    auto random = mixin(Loope!q{
        with max = 500
        for i from 0 to max
          collect $$ uniform(0, max) $$
    });

    mixin(Loop!q{
        for i in random
          counting $$ (i&1) == 0 $$ into evens
          counting $$ (i&1) == 1 $$ into odds
          summing i into total
          maximizing i into max
          minimizing i into min
        finally $$ writeln("Stats: ", [min, max, total, evens, odds]) $$
    });

    auto result = mixin(Loope!q{
        initially $$ writeln("Loop test:"); $$

        with isEven = $$ (uint x) => ((x&1) == 0) $$
        with updateAnalysis = $$ // A D function analysing our data.
                                 (uint[] stats) {
                                   static count = 0;
                                   if(count++ % 10 == 0)
                                       writeln("Analysis: ", stats);
                                 } $$

        with max = 500
        with data = $$ // Yo dawg...
                      mixin(Loope!q{
                          for i from 0.0 to max by 1.337
                            collect i
                      }); $$

        for i from 0 to max
        for datum in data
        for r in $$ sort(random) $$

          if $$ isEven(i) $$
            minimize i into minEven and
            maximize i into maxEven and
            unless $$ i % 4 == 0 $$
              sum i into evenNotFoursTotal and
              collect datum into floats
            end
            and sum i into evenTotal
          else
            minimize i into minOdd and
            maximize i into maxOdd and
            when $$ i % 5 == 0 $$
              sum i into fivesTotal and
              collect r into randoms
            end
            and sum i into oddTotal

          do $$ updateAnalysis([minEven, maxEven, minOdd,
                                maxOdd, evenTotal, oddTotal,
                                evenNotFoursTotal]) $$

          finally $$ writeln("Floats: ", floats); $$
          finally $$ writeln("Randoms: ", randoms); $$

          finally $$ return [minEven, maxEven, minOdd,
                             maxOdd, evenTotal, oddTotal,
                             evenNotFoursTotal]; $$
    });
    writeln("Result: ", result);

    writeln("Predicates:");
    writeln(mixin(Loope!q{
        for i in $$[0, 2, 4, 6, 8]$$
        always $$(i & 1) == 0$$
        never $$(i & 1) == 1$$
        thereis $$i > 4$$
    }));
}