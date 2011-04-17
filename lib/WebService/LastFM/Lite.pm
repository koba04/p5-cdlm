package WebService::LastFM::Lite;
use strict;
use warnings;
our $VERSION = '0.01';

use Carp;
use URI;
use JSON;
use LWP::UserAgent;

sub new {
    my ($class, $api_key) = @_;

    my $self = {
        api_key     => $api_key,
        base_uri    => 'http://ws.audioscrobbler.com/2.0/?',
    };
    return bless $self, $class;
}

sub user_top_artists {
    my ($self, $user, $opt) = @_;

    my $method = 'user.gettopartists';
    my $response = $self->_http_request($method, {user => $user}, $opt);

    return $self->_make_response($response->{topartists}->{artist});
}

sub geo_top_artists {
    my ($self, $country, $opt) = @_;

    my $method = 'geo.gettopartists';
    my $response = $self->_http_request($method, {country => $country }, $opt);

    return $self->_make_response($response->{topartists}->{artist});
}

sub geo_top_tracks {
    my ($self, $country, $opt) = @_;

    my $method = 'geo.gettoptracks';
    my $response = $self->_http_request($method, {country => $country }, $opt);

    return $self->_make_response($response->{toptracks}->{track});
}

sub artist_top_tracks {
    my ($self, $artist, $opt) = @_;

    my $method = 'artist.gettoptracks';
    my $response = $self->_http_request($method, {artist => $artist}, $opt);

    return $self->_make_response($response->{toptracks}->{track});
}

sub artist_similar {
    my ($self, $artist, $opt) = @_;

    my $method = 'artist.getSimilar';
    my $response = $self->_http_request($method, {artist => $artist}, $opt);

    # 挙動が他と違うのであわせている
    my $similar_artist = $response->{similarartists}->{artist};
    if ( !ref $similar_artist && $similar_artist eq $artist ) {
        return;
    } else {
        return [ map { $_->{url} = 'http://' . $_->{url}; $_; } @$similar_artist ];
    }

}

sub _http_request {
    my ($self, $method, $param, $opt) = @_;

    $opt = {} if !defined $opt;
    my $uri = URI->new($self->{base_uri});
    $uri->query_form(
        api_key => $self->{api_key},
        method  => $method,
        format  => 'json',
        %$param,
        %$opt,
    );

    my $ua = LWP::UserAgent->new;
    my $res = $ua->get($uri);

    $res->is_success or croak "http request error => [" . $uri->as_string . "]";
    my $res_json = $res->content;
    return decode_json($res_json);
}

sub _make_response {
    my ($self, $res) = @_;

    return if !defined $res;

    if ( ref $res ne 'ARRAY' ) {
        $res = [$res];
    }
    return $res;

}

1;
__END__

=head1 NAME

WebService::LastFM::Lite -

=head1 SYNOPSIS

  my $lastfm = WebService::LastFM::Lite->new('your api key');
  $res = $lastfm->user_top_artists('user name', { limit => 10, page => 1});

=head1 DESCRIPTION

WebService::LastFM::Lite is LastFM API Wrapper Module.
Interface is Simple.

=head1 METHODS

=over

=item user_top_artists

Get Top Artists of User

  my $opt = { limit => 10, page => 2 };
  $res = $lastfm->user_top_artists('user name', $opt); # opt is optional
  print $res->[0]->{name}; # Top Artist Name

=item geo_top_artists

Get Top Artists of Country

  my $opt = { limit => 10, page => 2 };
  $res = $lastfm->geo_top_artists('country'); # opt is optional
  print $res->[0]->{name}; # Top Artist Name

=item artist_top_tracks

Get Top Tracks of Artist

  my $opt = { limit => 10, page => 2 };
  $res = $lastfm->artist_top_tracks('artist'); # opt is optional
  print $res->[0]->{name}; # Top Track of artist

=item artist_similar

Get Similar Artist

  my $opt = { limit => 10 };
  $res = $lastfm->artist_similar('artist'); # opt is optional
  print $res->[0]->{name}; # Most Similar Artist

=back

=head1 AUTHOR

koba04 E<lt>koba0004@gmail.comE<gt>

=head1 SEE ALSO

http://www.lastfm.jp/api/intro

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
