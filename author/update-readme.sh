#!/bin/sh

set -e

cat << HEAD > README.md
[![Build Status](https://travis-ci.org/sixapart/Router-Assemble.svg?branch=master)](https://travis-ci.org/sixapart/Router-Assemble)

HEAD

pod2markdown < lib/Router/Assemble.pm >> README.md
