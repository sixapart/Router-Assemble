#!/bin/sh

set -e

cat << HEAD > README.md
[![Build Status](https://travis-ci.org/sixapart/Router-Assemble.svg?branch=master)](https://travis-ci.org/sixapart/Router-Assemble) [![Coverage Status](https://coveralls.io/repos/github/sixapart/Router-Assemble/badge.svg?branch=master)](https://coveralls.io/github/sixapart/Router-Assemble?branch=master)

HEAD

pod2markdown < lib/Router/Assemble.pm >> README.md
