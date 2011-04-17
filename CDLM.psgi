#!perl
use strict;
use warnings;

use Encode;
use JSON;
use Plack::Builder;
use Plack::Request;
use Text::Xslate;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use CDLM;
use CDLM::Cache;

builder {
    enable "Plack::Middleware::Static",
        path => qr{^/cdlm/(images|js|css)/}, root => File::Spec->catdir(dirname(__FILE__), 'htdocs');
    sub {
        my $env = shift;
        my $req = Plack::Request->new($env);

        my ($country) = $req->path =~ /cdlm\/track\/(jp|us|uk)/;

        my $response = '';
        if ( $country && $req->path =~ /cdlm\/track\/(jp|us|uk)$/ ) {
            my $tx = Text::Xslate->new(
                path    => [ File::Spec->catdir(dirname(__FILE__), 'template') ],
            );
            $response = $tx->render('index.tx', { country => $country });

        } elsif ( $country && $req->path =~ /\.json$/ ) {
            # XXX get client ip address?
            my $from = 'JP';
            my $rank = CDLM::Cache->new->get_callback(
                $country . '_' . $from,
                sub {
                    CDLM->rank($country, $from);
                },
            ) || [];
            $response = to_json($rank);

        } else {
            return [   404,
                [ 'Content-Type' => 'text/html; charset=utf-8' ],
                [ 'Not Found' ],
            ];
        }

        return [   200,
            [ 'Content-Type' => 'text/html; charset=utf-8' ],
            [ encode_utf8($response) ],
        ];
    };
};
__END__
