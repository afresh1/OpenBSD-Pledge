package OpenBSD::Pledge;

use 5.020002;
use strict;
use warnings;

use parent 'Exporter';
our %EXPORT_TAGS = ( 'all' => [ qw( pledge pledgenames ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw( pledge ); ## no critic 'export'

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('OpenBSD::Pledge', $VERSION);

sub pledge {
    my (@flags) = @_;

    my $paths;

    my %seen;
    my $flags = join q{ }, sort grep { !$seen{$_}++ } @flags;

    return _pledge( $flags, $paths );
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

OpenBSD::Pledge - Perl extension for blah blah blah

=head1 SYNOPSIS

  use OpenBSD::Pledge;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for OpenBSD::Pledge, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

Exports L</pledge> by default.

C<:all> will also export L</pledgenames>

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Andrew Fresh, E<lt>afresh1@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Andrew Fresh

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.20.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
