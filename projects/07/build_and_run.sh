#!/bin/sh

translate() { echo "\t- $1" ; ../VMTranslator/.build/debug/VMTranslator --without-bootstrap $1 > $1/$(basename $1).asm ; }
run_cpu_emulator() { ../../tools/CPUEmulator.sh $1/$(basename $1).tst ; }
run_test() { translate $1; run_cpu_emulator $1 ; }

echo "Build VMTranslator"
pushd ../VMTranslator > /dev/null
swift build
popd > /dev/null
echo "done."
echo ""

echo "Run test files"

run_test MemoryAccess/BasicTest
run_test MemoryAccess/PointerTest
run_test MemoryAccess/StaticTest
run_test StackArithmetic/SimpleAdd
run_test StackArithmetic/StackTest

echo ""

ruby ../check.rb 07
