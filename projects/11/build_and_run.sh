#!/bin/sh

compile() {
    echo "  - $1";
    copy_files $1;
    ../JackCompiler/.build/debug/JackCompiler --parser .test/$1;
    ../JackCompiler/.build/debug/JackCompiler .test/$1;
}

copy_files() {
    mkdir -p .test/$1/;
    cp ../../tools/OS/*.vm .test/$1/;
    cp $1/*.jack .test/$1/;
}

echo "Build JackCompiler"
pushd ../JackCompiler > /dev/null
swift build
popd > /dev/null
echo "done."
echo ""

echo "compile jack files"

rm -fr ./.test/*

compile Seven
compile ConvertToBin
compile Square
compile Average
compile Pong
compile ComplexArrays

echo ""
