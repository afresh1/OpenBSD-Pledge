# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl OpenBSD-Pledge.t'

#########################

use strict;
use warnings;

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

done_testing;
