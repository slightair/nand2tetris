#!/bin/sh

translate_without_bootstrap() { echo "\t- $1" ; ../VMTranslator/.build/debug/VMTranslator --without-bootstrap $1 > $1/$(basename $1).asm; }
translate() { echo "\t- $1" ; ../VMTranslator/.build/debug/VMTranslator $1 > $1/$(basename $1).asm; }
run_cpu_emulator() { ../../tools/CPUEmulator.sh $1/$(basename $1).tst; }
run_test1() { translate_without_bootstrap $1; run_cpu_emulator $1; }
run_test2() { translate $1; run_cpu_emulator $1; }

echo "Build VMTranslator"
pushd ../VMTranslator > /dev/null
swift build
popd > /dev/null
echo "done."
echo ""

echo "Run test files"

run_test1 ProgramFlow/BasicLoop
run_test1 ProgramFlow/FibonacciSeries
run_test1 FunctionCalls/SimpleFunction
run_test2 FunctionCalls/FibonacciElement
run_test2 FunctionCalls/NestedCall
run_test2 FunctionCalls/StaticsTest

echo ""

ruby ../check.rb 08
