# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl OpenBSD-Pledge.t'

#########################

use strict;
use warnings;

use Fcntl qw( O_RDONLY O_WRONLY );

use Config;
my %sig_num;
@sig_num{ split q{ }, $Config{sig_name} } = split q{ }, $Config{sig_num};

use Test::More;
BEGIN { use_ok('OpenBSD::Pledge') };

#########################
# PLEDGENAMES
#########################

is_deeply [ OpenBSD::Pledge::pledgenames() ], [
    'rpath',  'wpath',   'cpath', 'stdio',    'tmppath', 'dns',
    'inet',   'flock',   'unix',  'id',       'ioctl',   'getpw',
    'proc',   'settime', 'fattr', 'protexec', 'tty',     'sendfd',
    'recvfd', 'exec',    'route', 'mcast',    'vminfo',  'ps',
    'coredump'
], "Expected list of Pledge names";

#########################
# _PLEDGE
#########################

sub xspledge_ok ($$) {
    my ( $name, $code ) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    foreach my $pledge ( q{}, $name ) {
        my $pid = fork // die "Unable to fork for $name: $!";

        if ( !$pid ) {
            OpenBSD::Pledge::_pledge( "abort", undef );    # non fatal
            OpenBSD::Pledge::_pledge( "stdio $pledge", undef ) || die $!;
            $code->();
            exit;
        }

        waitpid $pid, 0;

        if ($pledge) { is $?, 0, "[$name] OK with pledge" }
        else { is $? & 127, $sig_num{ABRT}, "[$name] ABRT without pledge" }

        unlink 'perl.core';
    }
}
xspledge_ok rpath => sub { sysopen my $fh, '/dev/random', O_RDONLY };
xspledge_ok wpath => sub { sysopen my $fh, 'FOO',         O_WRONLY };
xspledge_ok cpath => sub { mkdir q{/} };

#########################
# _PLEDGE with rpath
#########################

eval { OpenBSD::Pledge::_pledge("", {}) };
like $@, qr/not an ARRAY reference/, "Correct error for non arrayref";

{
    my $pid = fork // die "Unable to fork: $!";

    if ( !$pid ) {
        OpenBSD::Pledge::_pledge( "stdio rpath", [ "/tmp", "/usr/bin/perl" ] )
            || die $!;

        -e "/tmp"          or die "# Can't read /tmp";
        -e "/usr"          or die "# Can't read /usr";
        -e "/usr/bin"      or die "# Can't read /usr/bin";
        -e "/usr/bin/perl" or die "# Can't read /usr/bin/perl";

        -e "/usr/bin/awk" and die "# Can't read /usr/bin/awk";
        -e "/usr/local"   and die "# Can read /usr/local";
        -e "/var"         and die "# Can read /var";
        -e "/var/log"     and die "# Can read /var/log";

        exit;
    }

    waitpid $pid, 0;
    is $?, 0, "OK with pledge";
}

#########################
# PLEDGE
#########################
{
    my @calls;
    no warnings 'redefine';
    local *OpenBSD::Pledge::_pledge = sub { push @calls, \@_; return 1 };
    use warnings 'redefine';

    OpenBSD::Pledge::pledge(qw( foo bar foo baz ));
    OpenBSD::Pledge::pledge(qw( foo qux baz quux ), ["/tmp"]);

    is_deeply \@calls, [
        [ "bar baz foo",      undef ],
        [ "baz foo quux qux", ["/tmp"] ],
    ], "Sorted and unique flags";
}

#########################
done_testing;

1; # to shut up critic
