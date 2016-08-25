#!/bin/bash

PERL="/usr/bin/perl"
TEST_VERBOSE=0
TEST_FILES="`ls t/*.t`"
TEST_LIBDIRS=
RUN_GUILE_TESTS="./t/scripts/RunGuileTests.pl"

GUILE_WARN_DEPRECATED=no ${PERL} ${TEST_LIBDIRS} ${RUN_GUILE_TESTS} ${TEST_FILES}

