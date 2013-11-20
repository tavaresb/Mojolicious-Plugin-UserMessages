package Mojolicious::Plugin::UserMessages::Message;

use Carp;
use strict;

our $AUTOLOAD;

sub new {
    my $class = shift;
    my %args  = @_;

    return bless( \%args, $class);
}

sub AUTOLOAD {
    my $self = shift;

    my $method = $AUTOLOAD;
    $method =~ s/.*://;    # strip fully-qualified portion

    return if $method eq 'DESTROY';

    return $self->{$method};
}

1;
