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
 *
 * TODO Use range interfaces in Iterators.
 * TODO Add type constraints to make error messages more useful.
 * TODO Fix comments.
 * TODO Fix Finally clause to insert stuff at the loopPost.
 * TODO Find a way to make gensym() global.
 ******************/

string compile(string code) {
    // Parse the code with Pegged.
    auto parse = LoopCode.parse(code);

    assert(parse.success, "The code fails to parse.");
    auto o = parse.parseTree;

    // Generates a unique identifier:
    uint __gensym = 0;
    dstring gensym(dstring base = "gensym") {
        return "__" ~ base ~ "_" ~ to!dstring(__gensym++);
    }

    // Used to make the code readable:
    dstring ind(uint depth) {
        enum bodyIndent = "    ";
        dstring result = "";
        foreach(i; 0 .. depth) result ~= bodyIndent;
        return result;
    }

    dstring loopResult = "result";      // The result of the loop (if needed).
//    dstring loopResult = gensym();      // TODO
    dstring loopPre = "";               // Anything that happens before the loop.
    dstring loopHeader = "";            // Header of the loop body.
    dstring loopBody = "";              // Working loop body.
    dstring loopFooter = "";            // Footer of the loop body.
    dstring loopPost = "";              // Anything that happens after the loop.

    uint accMask = 0;                   // Used for the accumulators.

    uint collecting = 0x01;             // For Collect.
    uint counting   = 0x02;             // For Count.
    uint summing    = 0x04;             // For Sum.
    uint maximizing = 0x08;             // For Max.
    uint minimizing = 0x10;             // For Min.

    bool returning = false;             // Flag determining if a return statement has been declared.

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
                 dstring sym = gensym("repeat");

                 loopPre    ~= ind(1) ~ "auto " ~ sym ~ " = " ~ times ~ ";\n";
                 loopHeader ~= ind(2) ~ "if(" ~ sym ~ " <= 0) break;\n";
                 loopFooter ~= ind(2) ~ "--" ~ sym ~ ";\n";
            break;

            case "For":
                 dstring var = strip(decl.capture[0]);
                 auto forVariant = decl.children[1];

                 switch(forVariant.ruleName) {
                     case "From":
                          dstring from = strip(forVariant.capture[0]);
                          dstring inc = forVariant.capture[1] == "above" ? "--" : "++";
                          dstring comp = forVariant.capture[1] == "above" ? " <= " : " >= ";
                          dstring to = strip(forVariant.capture[2]);

                          loopPre    ~= ind(1) ~ "auto " ~ var ~ " = " ~ from ~ ";\n";
                          loopHeader ~= ind(2) ~ "if(" ~ var ~ comp ~ to ~ ") break;\n";
                          loopFooter ~= ind(2) ~ inc ~ var ~ ";\n";
                     break;

                     case "Being":
                     case "In":
                          dstring r = "";

                          if(forVariant.ruleName == "In") {
                              r = strip(forVariant.capture[0]);
                          }
                          else {
                              dstring attribute = strip(forVariant.capture[0]);
                              dstring object = strip(forVariant.capture[1]);
                              r = object ~ "." ~ attribute;
                          }

                          dstring index = gensym(var);
                          dstring range = gensym(var);
                          dstring max = gensym(var);

                          loopPre    ~= ind(1) ~ "auto " ~ index ~ " = 0;\n";
                          loopPre    ~= ind(1) ~ "auto " ~ range ~ " = " ~ r  ~ ";\n";
                          loopPre    ~= ind(1) ~ "auto " ~ max ~ " = " ~ range ~ ".length;\n";

                          loopPre    ~= ind(1) ~ "typeof(" ~ range ~ ".init[0]) " ~ var ~ ";\n";
                          loopHeader ~= ind(2) ~ "if(" ~ index ~ " >= " ~ max ~ ") break;\n";
                          loopHeader ~= ind(2) ~ var ~ " = " ~ range ~ "[" ~ index ~ "];\n";
                          loopFooter ~= ind(2) ~ "++" ~ index ~ ";\n";
                     break;

                     default: assert(0, "Unrecognized For variant: " ~ to!string(forVariant.ruleName));
                 }
            break;

            default: assert(0, "Unknown iterator: " ~ to!string(decl.ruleName));
        }
    }

    // Compiles Accumulator statements:
    void compileAccumulator(ref ParseTree decl, uint depth = 0) {
        auto type = decl.children[0];
        dstring value = strip(type.capture[0]);
        bool hasDest = decl.children.length == 2;
        dstring var = hasDest ? strip(decl.capture[1]) : "__accumulator";

        switch(type.ruleName) {
            case "Sum":
                 if(accMask & ~summing) assert(0, "Incompatible kinds of Loop value accumulation.");
                 if(!accMask) {
                     if(!hasDest) accMask |= summing;
                     loopPre ~= ind(1) ~ "typeof(" ~ value ~ ") " ~ var ~ ";\n";
                 }

                 loopBody ~= ind(depth) ~ var ~ " += " ~ value ~ ";\n";
            break;

            case "Count":
                 if(accMask & ~counting) assert(0, "Incompatible kinds of Loop value accumulation.");
                 if(!accMask) {
                     if(!hasDest) accMask |= counting;
                     loopPre ~= ind(1) ~ "uint " ~ var ~ " = 0;\n";
                 }

                 loopBody ~= ind(depth) ~ "if(" ~ value ~ ") ++" ~ var ~ ";\n";
            break;

            case "Min":
            case "Max":
                uint mask = type.ruleName == "Min" ? minimizing : maximizing;
                dstring op = type.ruleName == "Min" ? " < " : " > ";
                dstring flag = gensym(var);

                if(accMask & ~mask) assert(0, "Incompatible kinds of Loop value occumulation.");
                if(!accMask) {
                    if(!hasDest) accMask |= mask;
                    loopPre ~= ind(1) ~ "bool " ~ flag ~ " = false;\n";
                    loopPre ~= ind(1) ~ "typeof(" ~ value ~ ") " ~ var ~ ";\n";
                }

                loopBody ~= ind(depth) ~ "if(!" ~ flag ~ " || " ~ value ~ op ~ var ~ ") {\n";
                loopBody ~= ind(depth+1) ~ var ~ " = " ~ value ~ ";\n";
                loopBody ~= ind(depth+1) ~ flag ~ " = true;\n";
                loopBody ~= ind(depth) ~ "}\n";

            break;

            case "Collect":
                 if(accMask & ~collecting) assert(0, "Incompatible kinds of Loop value accumulation.");
                 if(!accMask) {
                     if(!hasDest) accMask |= collecting;
                     loopPre ~= ind(1) ~ "typeof(" ~ value ~ ")[] " ~ var ~ ";\n";
                 }

                 loopBody ~= ind(depth) ~ var ~ " ~= " ~ value ~ ";\n";
            break;

            default: assert(0, "Unknown accumulator: " ~ to!string(decl.ruleName));
        }
    }

    // Simple satements that don't interfere with loop structure:
    void compileSimple(ref ParseTree decl, uint depth = 0) {
        dstring value = strip(decl.capture[0]);

        switch(decl.ruleName) {
            case "Print":
                 dstring result = "writeln(" ~ value;

                 foreach(e; decl.capture[1..$])
                     result ~= ", " ~ e;

                 loopBody ~= ind(depth) ~ result ~ ");\n";
            break;

            case "Do":
                 loopBody ~= ind(depth) ~ value ~ ";\n";
            break;

            case "Return":
                 loopBody ~= ind(depth) ~ "return " ~ value ~ ";\n";
            break;

            default: assert(0, "Unknown statement: " ~ to!string(decl.ruleName));
        }
    }

    // Compiles statements.
    void compileStatement(ref ParseTree decl, uint depth = 0) {
        switch(decl.ruleName) {
            case "When":
                 dstring op = decl.capture[0] == "unless" ? "!" : "";
                 dstring condition = strip(decl.capture[1]);
                 auto stat = decl.children[1];

                 loopBody ~= ind(depth) ~ "if(" ~ op ~ "(" ~ condition ~ ")) {\n";
                 compileStatement(stat, depth+1);
                 loopBody ~= ind(depth) ~ "}\n";
            break;

            case "If":
                 dstring condition = strip(decl.capture[0]);
                 auto then = decl.children[1];

                 loopBody ~= ind(depth) ~ "if(" ~ condition ~ ") {\n";
                 compileStatement(then, depth+1);
                 loopBody ~= ind(depth) ~ "}\n";

                 bool hasElse = decl.children.length == 3;

                 if(hasElse) {
                     auto els = decl.children[2];
                     loopBody ~= ind(depth) ~ "else {\n";
                     compileStatement(els, depth+1);
                     loopBody ~= ind(depth) ~ "}\n";
                 }
            break;

            case "Simple":
                 compileSimple(decl.children[0], depth);
            break;

            case "Accumulator":
                 compileAccumulator(decl, depth);
            break;

            case "Statement":
                 compileStatement(decl.children[0], depth);

                 if(decl.children.length != 1)
                     compileStatement(decl.children[1], depth);
            break;

            case "Conditional":
                 compileStatement(decl.children[0], depth);
            break;

            default: assert(0, "Unknown statement: " ~ to!string(decl.ruleName));
        }
    }

    // Code generation starts here:
    foreach(ref decl; o.children) {
        switch(decl.ruleName) {
            case "Init":
                 compileInit(decl.children[0]);
            break;

            case "Iterator":
                 compileIterator(decl.children[0]);
            break;

            case "Statement":
                 compileStatement(decl, 2);
            break;

            case "Finally": // FIXME
                 loopPost ~= ind(1) ~ "return " ~ strip(decl.capture[0]) ~ ";\n";
                 returning = true;
            break;

            case "Comment": // Nothing to compile. // FIXME
            break;

            default: assert(0, "Unrecognized Loop statement: " ~ to!string(decl.ruleName));
        }
    }

    // The return value:
    assert(!(accMask && returning), "Can't return both explicit and implicit values.");

    if(accMask)         loopPost ~= ind(1) ~ "return __accumulator;\n";
    else if(!returning) loopPost ~= ind(1) ~ "return 0xDEAD_BEEF;\n";

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

    static if(p) {
        pragma(msg, dcode);
    }

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