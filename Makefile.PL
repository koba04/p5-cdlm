use inc::Module::Install;
name 'CDLM';
all_from 'lib/CDLM.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
