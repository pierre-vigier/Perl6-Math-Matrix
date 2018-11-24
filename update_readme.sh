#!/bin/sh

echo "Generating README.md"

echo "[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix)" >README.md

echo "[![Build status](https://ci.appveyor.com/api/projects/status/github/pierre-vigier/Perl6-Math-Matrix?svg=true)](https://ci.appveyor.com/project/pierre-vigier/Perl6-Math-Matrix/branch/master)\n" >>README.md

perl6 --doc=Markdown lib/Math/Matrix.pod >>README.md

