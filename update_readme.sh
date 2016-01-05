#!/bin/sh

echo "Generating README.md"

echo "# Perl6-Math-Matrix\n\n[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix)\n" >README.md

perl6 --doc=Markdown lib/Math/Matrix.pm6 >>README.md

