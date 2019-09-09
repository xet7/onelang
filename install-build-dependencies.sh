#!/bin/bash

rm -rf CompilerBackend
git clone git@github.com:xet7/onelang_CompilerBackend CompilerBackend

rm -rf generated
git clone git@github.com:xet7/onelang_generated generated

sudo apt-get install -y maven mono-complete
