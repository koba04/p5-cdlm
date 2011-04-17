package CDLM;
use strict;
use warnings;
our $VERSION = '0.01';

use Carp;
use Config::Pit;
use WebService::LastFM::Lite;
use WebService::YouTube::Lite;

sub rank {
    my ($class, $country, $from_country) = @_;

    # country
    my $country_map = {
        'jp'    => 'JAPAN',
        'us'    => 'UNITED STATES',
        'uk'    => 'UNITED KINGDOM',
    };
    my $geo_country = $country_map->{$country} or return; 

    # api key
    my $lastfm_config = pit_get('lastfm.jp', require => {
        api_key => 'your api key',
    });
    croak 'pit_get failed' if !%$lastfm_config;
    my $lastfm_api_key = $lastfm_config->{api_key} or croak "Can't Get api_key";

    my $lastfm = WebService::LastFM::Lite->new($lastfm_api_key);
    my $youtube = WebService::YouTube::Lite->new;

    my $rank = [];
    my $top_tracks = $lastfm->geo_top_tracks($geo_country, { limit => 50});
    my $index = 1;
    for my $track (@$top_tracks) {
        my $video = $youtube->search(q => $track->{artist}->{name} . ' ' . $track->{name}, max_results => 1, from => $from_country);
        push @$rank, { info => $track, video => $video->[0], rank => $index };
        ++$index;
    }
    return $rank;
}

1;
__END__

=head1 NAME

CDLM -

=head1 SYNOPSIS

  use CDLM;

=head1 DESCRIPTION

CDLM is

=head1 AUTHOR

koba04 E<lt>koba0004@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
