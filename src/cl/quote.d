module cl.quote;

// TODO Add comments and strings support.
// TODO Make sure "\"" is ok and has no weird corner cases.
// TODO Speed this up a little.

string unquote(string code) {
    string result = "\"";

    auto i = 0;
    auto len = code.length;

    while(i < len) {
        if(code[i] == 'd') {
            if(i+1 < len && code[i+1] == '{') {
                ++i;

                string mixed = "";
                uint parenCount = 0;

                do {
                    assert(i < len, "End of qasiquote reached while parsing expression.");

                    if(code[i] == '{') ++parenCount;
                    else if(code[i] == '}') --parenCount;

                    mixed ~= code[i++];
                } while(parenCount);

                result ~= "\" ~ to!string(" ~ mixed[1..$-1] ~ ") ~ \"";
                // `mixed' is always wrapped in {}.
            }
        }
        result ~= code[i++];
    }

    return result ~ "\"";
}

// Quasiquate template.
template q(string code, bool printGenerated = false) {
    enum q = unquote(code);

    static if(printGenerated) {
        pragma(msg, q);
    }
}

unittest {
    import std.conv;
    import std.stdio;

    string makeAsserts(T)(T a, T b, string msg = "Assert failure!") {
        return mixin(q!q{
            assert( d{ a } == d{ b });//, d{ msg } ); // FIXME
            assert( d{ b } == d{ a });//, d{ msg } );
        });
    }

    enum a = 23;
    enum b = 23;
    enum msg = "Another statement.";

    enum generated = mixin(q!q{
        if(d{a * b} == 23^^2) {
            d{ makeAsserts(a, b, msg) }
        }
    });

    mixin(generated);
}