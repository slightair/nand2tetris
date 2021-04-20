#!/bin/sh

assemble() { echo "\t- $1.asm" ; ../Assembler/.build/debug/Assembler $1.asm > $1.hack.out ; }

echo "Build Assembler"
pushd ../Assembler > /dev/null
swift build
popd > /dev/null
echo "done."
echo ""

echo "Assemble test files"

assemble add/Add
assemble max/Max
assemble max/MaxL
assemble pong/Pong
assemble pong/PongL
assemble rect/Rect
assemble rect/RectL

echo ""

ruby ../check.rb 06
