import pegged.peg; public import pegged.peg : ParseTree;import std.array, std.algorithm, std.conv, std.typecons;
import pegged.utils.associative;

class GenericLoopCode(TParseTree = ParseTree) if ( isParseTree!TParseTree ) :
    BuiltinRules!(TParseTree).Parser
{
    mixin BuiltinRules!TParseTree;
    mixin Input!TParseTree;
    mixin Output!TParseTree;
    enum grammarName = `LoopCode`;
    enum ruleName = `LoopCode`;
    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        return LoopCode.parse!(pl)(input);
    }
    
    mixin(stringToInputMixin());
    static Output validate(T)(T input) if (is(T == Input) || isSomeString!(T) || is(T == Output))
    {
        return LoopCode.parse!(ParseLevel.validating)(input);
    }
    
    static Output match(T)(T input) if (is(T == Input) || isSomeString!(T) || is(T == Output))
    {
        return LoopCode.parse!(ParseLevel.matching)(input);
    }
    
    static Output fullParse(T)(T input) if (is(T == Input) || isSomeString!(T) || is(T == Output))
    {
        return LoopCode.parse!(ParseLevel.noDecimation)(input);
    }
    
    static Output fullestParse(T)(T input) if (is(T == Input) || isSomeString!(T) || is(T == Output))
    {
        return LoopCode.parse!(ParseLevel.fullest)(input);
    }
    static TParseTree decimateTree(TParseTree p)
    {
        if(p.children.length == 0) return p;
        TParseTree[] filteredChildren;
        foreach(child; p.children)
        {
            child  = decimateTree(child);
            if (child.grammarName == grammarName)
                filteredChildren ~= child;
            else
                filteredChildren ~= child.children;
        }
        p.children = filteredChildren;
        return p;
    }
class LoopCode : SpaceSeq!(ZeroOrMore!(Init),OneOrMore!(SpaceSeq!(OneOrMore!(Iterator),OneOrMore!(Statement))),Option!(Finally))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `LoopCode`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Init : With
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Init`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Iterator : Or!(While,Repeat,For)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Iterator`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Statement : Or!(If,Do,Return,Print,Collect,Count,Sum,Extremum)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Statement`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class With : SpaceSeq!(Drop!(Lit!("with")),Variable,Or!(Drop!(Lit!("=")),Drop!(Lit!("as"))),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `With`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class While : SpaceSeq!(Or!(Lit!("while"),Lit!("until")),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `While`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Repeat : SpaceSeq!(Drop!(Lit!("repeat")),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Repeat`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class For : SpaceSeq!(Drop!(Lit!("for")),Variable,Or!(In,From))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `For`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class In : SpaceSeq!(Or!(Drop!(Lit!("in")),Drop!(Lit!("on")),Drop!(Lit!("across"))),Or!(Variable,String))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `In`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class From : SpaceSeq!(Drop!(Lit!("from")),Expression,Or!(Lit!("to"),Lit!("above"),Lit!("below")),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `From`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class If : SpaceSeq!(Drop!(Lit!("if")),Expression,Statement,ZeroOrMore!(SpaceSeq!(Drop!(Lit!("and")),Statement)),Option!(SpaceSeq!(Drop!(Lit!("else")),Statement,ZeroOrMore!(SpaceSeq!(Drop!(Lit!("and")),Statement)))),Drop!(Option!(Lit!("end"))))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `If`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class When : SpaceSeq!(Or!(Lit!("when"),Lit!("unless")),Expression,Statement,ZeroOrMore!(SpaceSeq!(Drop!(Lit!("and")),Statement)),Drop!(Option!(Lit!("end"))))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `When`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Print : SpaceSeq!(Or!(Drop!(Lit!("printing")),Drop!(Lit!("print"))),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Print`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Do : SpaceSeq!(Or!(Drop!(Lit!("doing")),Drop!(Lit!("do"))),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Do`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Return : SpaceSeq!(Or!(Drop!(Lit!("returning")),Drop!(Lit!("return"))),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Return`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Collect : SpaceSeq!(Or!(Drop!(Lit!("collecting")),Drop!(Lit!("collect"))),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Collect`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Count : SpaceSeq!(Or!(Drop!(Lit!("counting")),Drop!(Lit!("count"))),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Count`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Sum : SpaceSeq!(Or!(Drop!(Lit!("summing")),Drop!(Lit!("sum"))),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Sum`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Extremum : SpaceSeq!(Or!(Or!(Lit!("minimizing"),Lit!("minimize")),Or!(Lit!("maximizing"),Lit!("maximize"))),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Extremum`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Finally : SpaceSeq!(Drop!(Lit!("finally")),Expression)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Finally`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Expression : Or!(Number,String,Variable,DCode)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Expression`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Number : Fuse!(Seq!(Floating,Option!(Or!(Lit!("e"),Lit!("E")))))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Number`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Floating : Fuse!(Seq!(Integer,Option!(Seq!(Lit!("."),Unsigned))))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Floating`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Unsigned : Fuse!(OneOrMore!(Range!('0','9')))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Unsigned`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Integer : Fuse!(Seq!(Option!(Sign),Unsigned))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Integer`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Sign : Or!(Lit!("-"),Lit!("+"))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Sign`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class String : Fuse!(Seq!(DoubleQuote,ZeroOrMore!(Seq!(NegLookAhead!(DoubleQuote),Char)),DoubleQuote))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `String`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Char : Fuse!(Or!(Seq!(BackSlash,Or!(DoubleQuote,Quote,BackSlash,Or!(Lit!("b"),Lit!("f"),Lit!("n"),Lit!("r"),Lit!("t")),Seq!(Range!('0','2'),Range!('0','7'),Range!('0','7')),Seq!(Range!('0','7'),Option!(Range!('0','7'))),Seq!(Lit!("x"),Hex,Hex),Seq!(Lit!("u"),Hex,Hex,Hex,Hex),Seq!(Lit!("U"),Hex,Hex,Hex,Hex,Hex,Hex,Hex,Hex))),Anything))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Char`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Hex : Fuse!(Or!(Range!('0','9'),Range!('a','f'),Range!('A','F')))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Hex`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Variable : Fuse!(Identifier)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Variable`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class DCode : Fuse!(Seq!(Drop!(DEscape),ZeroOrMore!(Seq!(NegLookAhead!(DEscape),Anything)),Drop!(DEscape)))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `DCode`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class DEscape : Lit!("$$")
{
    enum grammarName = `LoopCode`;
    enum ruleName = `DEscape`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Anything : Fuse!(Any)
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Anything`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

class Comment : Fuse!(Seq!(Slash,Slash,ZeroOrMore!(Seq!(NegLookAhead!(Lit!("\n")),Anything)),Lit!("\n")))
{
    enum grammarName = `LoopCode`;
    enum ruleName = `Comment`;

    static Output parse(ParseLevel pl = ParseLevel.parsing)(Input input)
    {
        mixin(okfailMixin());
        
        auto p = typeof(super).parse!(pl)(input);
        static if (pl == ParseLevel.validating)
            p.capture = null;
        static if (pl <= ParseLevel.matching)
            p.children = null;
        static if (pl >= ParseLevel.parsing)
        {
            if (p.success)
            {                                
                static if (pl == ParseLevel.parsing)
                    p.parseTree = decimateTree(p.parseTree);
                
                if (p.grammarName == grammarName || pl >= ParseLevel.noDecimation)
                {
                    p.children = [p];
                }
                
                p.grammarName = grammarName;
                p.ruleName = ruleName;
            }
            else
                return fail(p.parseTree.end,
                            (grammarName~`.`~ruleName ~ ` failure at pos `d ~ to!dstring(p.parseTree.end) ~ (p.capture.length > 0 ? p.capture[1..$] : p.capture)));
        }
                
        return p;
    }    
    mixin(stringToInputMixin());
    
}

}

alias GenericLoopCode!(ParseTree) LoopCode;