#!/usr/bin/env perl
package t_00_load;

use strict;
use warnings 'all';

use Test::More tests => 1;

use lib '../lib';

BEGIN {
    use_ok('Wono::DepApp');
}

#*****************************************************************************
1;
