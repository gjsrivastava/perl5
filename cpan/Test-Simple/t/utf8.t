#!/usr/bin/perl -w

BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = '../lib';
    }
}

use strict;
use warnings;

my $have_perlio;
BEGIN {
    # All together so Test::More sees the open discipline
    $have_perlio = eval q[
        require PerlIO;
        binmode *STDOUT, ":encoding(utf8)";
        binmode *STDERR, ":encoding(utf8)";
        require Test::More;
        1;
    ];
}

use Test::More;

if( !$have_perlio ) {
    plan skip_all => "Don't have PerlIO";
}
else {
    plan tests => 5;
}

SKIP: {
    skip( "Need PerlIO for this feature", 3 )
        unless $have_perlio;

    my %handles = (
        output          => \*STDOUT,
        failure_output  => \*STDERR,
        todo_output     => \*STDOUT
    );

    for my $method (keys %handles) {
        my $src = $handles{$method};
        
        my $dest = Test::More->builder->$method;
        
        is_deeply { map { $_ => 1 } PerlIO::get_layers($dest) },
                  { map { $_ => 1 } PerlIO::get_layers($src)  },
                  "layers copied to $method";
    }
}


# Test utf8 is ok.
{
    my $uni = "\x{11e}";
    
    my @warnings;
    local $SIG{__WARN__} = sub {
        push @warnings, @_;
    };

    is( $uni, $uni, "Testing $uni" );
    is_deeply( \@warnings, [] );
}
