package CDLM::Cache;

use strict;
use warnings;
use Cache::Memcached::Fast;

sub new {
    my $class = shift;
    my $memd = Cache::Memcached::Fast->new({
        servers     => [ { address => 'localhost:11211' } ],
        namespace   => 'cdlm:',
        utf8        => 1,
    });
    return bless { memd => $memd }, $class;
}

sub get {
    my $self = shift;
    my ( $key ) = @_;
    return $self->{memd}->get( $key );
}

sub get_callback {
    my $self = shift;
    my ( $key, $code ) = @_;

    my $data = $self->get( $key );
    unless ( defined $data ) {
        $data = $code->();
        $self->set($key, $data);
    }
    return $data;

}

sub set {
    my $self = shift;
    my ($key, $val, $expire) = @_;

    $self->{memd}->set( $key, $val, $expire);
}

1;
