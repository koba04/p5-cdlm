package WebService::YouTube::Lite;
use strict;
use warnings;
our $VERSION = '0.01';

use Carp;
use URI;
use JSON;
use LWP::UserAgent;

sub new {
    my ($class, %opt) = @_;

    # set default value
    my $self = {
        base_uri        => 'http://gdata.youtube.com/feeds/api/videos?',
        base_param      => {
            alt             => $opt{alt}         || 'jsonc',
            restriction     => $opt{from}        || 'JP',
            v               => $opt{v}           || 2,
            max_results     => $opt{max_results} || 10,
            format          => $opt{format}      || 5,
            orderby         => $opt{viewCount}   || 'relevance',
        },
    };
    return bless $self, $class;
}

sub search {
    my $self = shift;
    my %param = @_;

    croak 'Please Set Parameter "q"' unless $param{q};

    my $merge_param = {
        %{ $self->{base_param} },
        %param,
    };
    my $response = $self->_http_request($merge_param);
    my $result;
    if ( $response->{data} && $response->{data}->{items} ) {
        $result = $response->{data}->{items};
    }
    return $result;
}

sub _http_request {
    my ($self, $param) = @_;

    my $uri = URI->new($self->{base_uri});
    $uri->query_form(%$param);

    my $ua = LWP::UserAgent->new;
    my $res = $ua->get($uri);

    croak "http request error => [" . $uri->as_string . "]" if !$res->is_success;
    my $res_json = $res->content;

    return decode_json($res_json);
}

1;
__END__

=head1 NAME

WebService::YouTube::Lite -

=head1 SYNOPSIS

  use WebService::YouTube::Lite;

=head1 DESCRIPTION

WebService::YouTube::Lite is

=head1 AUTHOR

koba04 E<lt>koba0004@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
