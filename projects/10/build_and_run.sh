#!/bin/sh

check_diff() {
    TARGET="$(basename $1 .xml.compare).xml"
    diff -wq $(dirname $1)/$TARGET $1 > /dev/null 2>&1
    if [ $? = 0 ]; then
        echo "    - $TARGET ✅";
    else
        echo "    - $TARGET ❌";
    fi
}

run_tokenizer_test() {
    ../JackCompiler/.build/debug/JackCompiler --tokenizer $1;
    for f in `ls $1/*T.xml.compare`
    do
        check_diff $f
    done
}

run_parser_test() {
    ../JackCompiler/.build/debug/JackCompiler --parser $1;
    for f in `ls $1/*.xml.compare | grep -v T.xml`
    do
        check_diff $f
    done
}

run_test() {
    echo "  - $1";
    run_tokenizer_test $1;
    run_parser_test $1;
}

echo "Build JackCompiler"
pushd ../JackCompiler > /dev/null
swift build
popd > /dev/null
echo "done."
echo ""

echo "Run test files"

run_test ExpressionLessSquare
run_test Square
run_test ArrayTest

echo ""
