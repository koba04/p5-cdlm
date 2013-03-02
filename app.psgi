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

my $static_version = '0.2';

builder {
    enable "Plack::Middleware::Static",
        path => qr{^/(img|js|css)/}, root => File::Spec->catdir(dirname(__FILE__), 'htdocs');
    sub {
        my $env = shift;
        my $req = Plack::Request->new($env);

        my ($country) = $req->path =~ m{/track/(jp|us|uk)};

        my $response = '';

        my $tx = Text::Xslate->new(
            path    => [ File::Spec->catdir(dirname(__FILE__), 'template') ],
        );
        if ( $req->path eq '/' ) {
            $response = $tx->render('index.tx', { static_version => $static_version });
        } elsif ( $country && $req->path =~ m{/track/(?:jp|us|uk)(?:/(\d{1,2}))?$} ) {
            $response = $tx->render('track.tx', { static_version => $static_version, country => $country, rank => $1 });
        } elsif ( $country && $req->path =~ /\.json$/ ) {
            # XXX get client ip address?
            my $from = 'JP';
            my $rank = CDLM::Cache->new->get_callback(
                $country . '_' . $from,
                sub {
                    CDLM->track($country, $from);
                },
                # 8days
                60 * 60 * 24 * 8,
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
