#!perl

use strict;
use warnings;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
use CDLM;
use CDLM::Cache;
use Data::Dumper;

my $cache = CDLM::Cache->new;
for my $country (qw/jp us uk/) {
    for my $from (qw/JP US UK/) {
        my $rank = CDLM->track($country, $from);
        $cache->set($country. '_' . $from, $rank, 60 * 60 * 24 * 8);
    }
}
