module cl.loop;

import std.string;
import std.conv;

version(CompileTime) {
    import pegged.grammar;

    mixin(grammar(import("loopgrammar")));
}
else {
    import cl.loopparser;
}

/*******************************************************************************
 * Compiles loop code into valid D code.
 ******************/

string compile(string code) {
    // Parse the code with Pegged.
    auto o = LoopCode.parse(code).parseTree;

    // Used to make the code readable:
    dstring ind(uint depth) {
        enum bodyIndent = "    ";
        dstring result = "";
        foreach(i; 0 .. depth) result ~= bodyIndent;
        return result;
    }

    dstring loopResult = "result";      // The result of the loop (if needed).

    dstring loopPre = "";               // Anything that happens before the loop.
    dstring loopHeader = "";            // Header of the loop body.
    dstring loopBody = "";              // Working loop body.
    dstring loopFooter = "";            // Footer of the loop body.
    dstring loopPost = "";              // Anything that happens after the loop.

    uint gensym = 0;                    // Used for unique variables.

    uint accMask = 0;                   // Used for the accumulators.
    uint collecting = 0x01;             // For Collect.
    uint counting   = 0x02;             // For Count.
    uint summing    = 0x04;             // For Sum.
    uint maximizing = 0x08;             // For Extremum.
    uint minimizing = 0x10;             // For Extremum.

    // Simple satements that don't interfere with loop structure:
    dstring compileSimpleStat(ref ParseTree decl) {
        dstring value = strip(decl.capture[0]);

        switch(decl.ruleName) {
            case "If":      assert(0, "Nested If's not yet implemented.");
            case "When":    assert(0, "Nested When's not yet implemented.");

            case "Print":   return "writeln(" ~ value ~ ");\n";
            case "Do":      return value ~ ";\n";
            case "Return":  return "return " ~ value ~ ";\n";

            case "Sum":
                 if(accMask & ~summing) assert(0, "Incompatible kinds of Loop value accumulation.");
                 if(!accMask) {
                     accMask |= summing;
                     loopPre ~= ind(1) ~ "typeof(" ~ value ~ ") __summing;\n";
                 }

                 return "__summing += " ~ value ~ ";\n";

            case "Count":
                 if(accMask & ~counting) assert(0, "Incompatible kinds of Loop value accumulation.");
                 if(!accMask) {
                     accMask |= counting;
                     loopPre ~= ind(1) ~ "uint __counting;\n";
                 }

                 return "if(" ~ value ~ ") ++__counting;\n";

            case "Extremum":
                dstring type = value;
                value = strip(decl.capture[1]);

                // TODO

                return "";

            case "Collect":
                 if(accMask & ~collecting) assert(0, "Incompatible kinds of Loop value accumulation.");
                 if(!accMask) {
                     accMask |= collecting;
                     loopPre ~= ind(1) ~ "typeof(" ~ value ~ ")[] __collecting;\n";
                 }

                 return "__collecting ~= " ~ value ~ ";\n";

            default: assert(0, "Unknown statement: " ~ to!string(decl.ruleName));
        }
    }

    // Compiles an initializer.
    void compileInit(ref ParseTree decl) {
        switch(decl.ruleName) {
            case "With":
                 dstring var = strip(decl.capture[0]);
                 dstring value = strip(decl.capture[1]);

                 if(value == "result") loopResult = var;
                 else loopPre ~= ind(1) ~ "auto " ~ var ~ " = " ~ value ~ ";\n";
            break;

            default: assert(0, "Unknown initializer: " ~ to!string(decl.ruleName));
        }
    }

    // Compiles an iterator.
    void compileIterator(ref ParseTree decl) {
        switch(decl.ruleName) {
            case "While":
                 dstring op = decl.capture[0] == "while" ? "!" : "";
                 loopHeader ~= ind(2) ~ "if(" ~ op ~ "(" ~ strip(decl.capture[1]) ~ ")) break;\n";
            break;

            case "Repeat":
                 dstring times = strip(decl.capture[0]);
                 dstring sym = to!dstring(gensym++);
                 loopPre    ~= ind(1) ~ "auto __repeat_" ~ sym ~ " = " ~ times ~ ";\n";
                 loopHeader ~= ind(2) ~ "if(__repeat_" ~ sym ~ " <= 0) break;\n";
                 loopFooter ~= ind(2) ~ "--__repeat_" ~ sym ~ ";\n";
            break;

            case "For":
                 dstring var = strip(decl.capture[0]);
                 auto forVariant = decl.children[1];

                 switch(forVariant.ruleName) {
                     case "In":
                          dstring range = strip(forVariant.capture[0]);

                          loopPre    ~= ind(1) ~ "auto __" ~ var ~ "_index = 0;\n";
                          loopPre    ~= ind(1) ~ "auto __" ~ var ~ "_range = " ~ range ~ ";\n";
                          loopPre    ~= ind(1) ~ "auto __" ~ var ~ "_max = __" ~ var ~"_range.length;\n";

                          loopPre    ~= ind(1) ~ "typeof(__" ~ var ~ "_range.init[0]) " ~ var ~ ";\n";
                          loopHeader ~= ind(2) ~ "if(__" ~ var ~ "_index >= __" ~ var ~ "_max) break;\n";
                          loopHeader ~= ind(2) ~ var ~ " = __" ~ var ~ "_range[__" ~ var ~ "_index];\n";
                          loopFooter ~= ind(2) ~ "++__" ~ var ~ "_index;\n";
                     break;

                     case "From":
                          dstring from = strip(forVariant.capture[0]);
                          dstring inc = forVariant.capture[1] == "above" ? "--" : "++";
                          dstring comp = forVariant.capture[1] == "above" ? "<=" : ">=";
                          dstring to = strip(forVariant.capture[2]);

                          loopPre    ~= ind(1) ~ "auto " ~ var ~ " = " ~ from ~ ";\n";
                          loopHeader ~= ind(2) ~ "if(" ~ var ~ comp ~ to ~ ") break;\n";
                          loopFooter ~= ind(2) ~ inc ~ var ~ ";\n";
                     break;

                     default: assert(0, "Unrecognized For variant: " ~ to!string(forVariant.ruleName));
                 }
            break;

            default: assert(0, "Unknown iterator: " ~ to!string(decl.ruleName));
        }
    }

    // Compiles statements.
    void compileStatement(ref ParseTree decl) {
        switch(decl.ruleName) {
            case "When":
                 dstring op = decl.capture[0] == "unless" ? "!" : "";
                 dstring condition = strip(decl.capture[1]);
                 auto stat = decl.children[1].children[0]; //Always Statement.

                 loopBody ~= ind(2) ~ "if(" ~ op ~ "(" ~ condition ~ ")) {\n";
                 loopBody ~= ind(3) ~ compileSimpleStat(stat);
                 loopBody ~= ind(2) ~ "}\n";
            break;

            case "If":
                 dstring condition = strip(decl.capture[0]);
                 auto then = decl.children[1].children[0]; //Always Statement.

                 bool hasElse = decl.children.length == 3;

                 loopBody ~= ind(2) ~ "if(" ~ condition ~ ") {\n";
                 loopBody ~= ind(3) ~ compileSimpleStat(then);
                 loopBody ~= ind(2) ~ "}\n";

                 if(hasElse) {
                     auto els = decl.children[2].children[0]; //Always statement.
                     loopBody ~= ind(2) ~ "else {\n";
                     loopBody ~= ind(3) ~ compileSimpleStat(els);
                     loopBody ~= ind(2) ~ "}\n";
                 }
            break;

            case "Print":
            case "Do":
            case "Return":
            case "Collect":
            case "Count":
            case "Sum":
            case "Extremum":
                 loopBody ~= ind(2) ~ compileSimpleStat(decl);
            break;
            default: assert(0, "Unknown statement: " ~ to!string(decl.ruleName));
        }
    }

    // Code generation goes here:
    foreach(ref decl; o.children) {
        switch(decl.ruleName) {
            case "Init":      compileInit(decl.children[0]); break;
            case "Iterator":  compileIterator(decl.children[0]); break;
            case "Statement": compileStatement(decl.children[0]); break;
            case "Finally":   loopPost ~= ind(1) ~ strip(decl.capture[0]) ~ ";\n"; break;
            case "Comment":   break; // Nothing to compile.
            default:          assert(0, "Unrecognized Loop statement: " ~ to!string(decl.ruleName));
        }
    }

    // The return value;
    dstring returnValue = "0";

    if(accMask & collecting) returnValue = "__collecting";
    if(accMask & counting)   returnValue = "__counting";
    if(accMask & summing)    returnValue = "__summing";
    if(accMask & maximizing) returnValue = "__maximizing";
    if(accMask & minimizing) returnValue = "__minimizing";

    loopPost ~= ind(1) ~ "return " ~ returnValue ~ ";\n";

    // Delegate and type inference magic:
    dstring result = "auto " ~ loopResult ~ " = (() {\n"
                   ~ loopPre ~ "\n"
                   ~ ind(1) ~ "for(;;) {\n"
                   ~ loopHeader ~ "\n"
                   ~ loopBody ~ "\n"
                   ~ loopFooter
                   ~ ind(1) ~ "}\n"
                   ~ loopPost
                   ~ "})();";

    return to!string(result);
}

/*******************************************************************************
 * Conviniece template to make the use cases neat.
 ******************/

mixin template Loop(string code, bool p = false) {
    enum dcode = compile(code);

    static if(p) pragma(msg, dcode);

    mixin(dcode);
}

unittest {
    import std.stdio;
    auto array0 = [1, 2, 3, 4, 5];

    mixin Loop!q{
        with array1 as result
        for i in array0
        collect i
    };

    assert(array0 == array1);

    mixin Loop!q{
        with array2 as result
        with len = $$array0.length$$
        with foo = 0

        for i from 0 to len
        do $$foo = array0[i]^^2$$
        collect foo
    };

    assert(array2 == [1, 4, 9, 16, 25]);
}