package CDLM::Cache;

use strict;
use warnings;

use JSON;
use parent 'Cache::KyotoTycoon';

sub new {
    my $class = shift;
    my %opt = @_;
    my $self = $class->SUPER::new(
        host    => $opt{host} || '127.0.0.1',
        port    => $opt{port} || '1978',
        db      => $opt{db}   || 'CDLM',
    );
    return $self;
}

sub get {
    my $self = shift;
    my ( $key ) = @_;
    my $data = $self->SUPER::get( $key );
    if ( $data ) {
        $data = decode_json($data);
    }
    return $data;
}

sub get_callback {
    my $self = shift;
    my ( $key, $code ) = @_;

    my $data = $self->get( $key );
    unless ( $data ) {
        $data = $code->();
        $data = decode_json($data);
        $self->set($key, $data);
    }
    return $data;

}

sub set {
    my $self = shift;
    my ($key, $val, $expire) = @_;

    $val = encode_json($val);
    $self->SUPER::set( $key, $val, $expire);
}

1;
