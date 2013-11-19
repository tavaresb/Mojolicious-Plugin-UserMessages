package Mojolicious::Plugin::UserMessages;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ($self, $app) = @_;

    my $queue = Mojolicious::Plugin::UserMessages::Queue->new( $app );

    $app->helper( 
        'user_messages' => sub { 
              return Mojolicious::Plugin::UserMessages::Queue->new( $_[0] ); 
    }); 
}

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::UserMessages - Mojolicious Plugin to manage user message(s) qeue(s)

=head1 SYNOPSIS

  ...

=head1 DESCRIPTION

L<Mojolicous::Plugin::UserMessages> implements a message queue to the user.

=cut

package Mojolicious::Plugin::UserMessages::Queue;

use Carp;
our $AUTOLOAD;

sub new {
    my ( $class, $app ) = @_;
    return bless({'app'=>$app}, $class);
}

sub AUTOLOAD {
    my $s = shift;

    my $method = $AUTOLOAD;
    $method =~ s/.*://;    # strip fully-qualified portion

    return if $method eq 'DESTROY';

    if ( $method =~ /^get_(.+)$/i ) {
        my $type = lc( $1 );
        return $s->get( $type );
    }
    if ( $method =~ /^has_(.+)_messages$/i ) {
        my $type = lc( $1 );
        return $s->has_messages_in_queue( $type );
    }

    croak "Unkown method $method\n";
}


sub add {
    my $self    = shift;
    my $type    = shift;
    my $message = shift;
    my %args = @_;

    my $c    = $self->{'app'};

    if ( !$c->session->{'__ui_message_queue'} ) {
        $c->session->{'__ui_message_queue'} = [];
    }

    return if !$message;

    push @{ $c->session->{'__ui_message_queue'} },
        {
        'type'    => $type,
        'args'    => \%args,
        'message' => $message,
        };

    return;
}


sub has_messages {
    my $self = shift;
    my $c    = $self->{'app'};
    if ( !$c->session->{'__ui_message_queue'}
        || scalar( @{ $c->session->{'__ui_message_queue'} } ) == 0 ) {
        return 0;
    }
    return 1;
}

sub get {
    my $self             = shift;
    my $type             = shift;
    my $include_repeated = shift;

    $include_repeated ||= 0;

    my $c = $self->{'app'};

    if ( !$c->session->{'__ui_message_queue'} ) {
        return;
    }

    my @messages  = @{ $c->session->{'__ui_message_queue'} };
    my @to_return = ();
    my @to_keep   = ();

    # by default, do not return repeated messages
    # problem: same tags may have input params, check for repeated msg
    my %repeated;
    my %repeated_msgs;
    for my $m ( @messages ) {
        if ( !$type || $type eq $m->{'type'} ) {

            if ( $include_repeated ) {
                push @to_return, $m;
                next;
            }

            if ( $repeated{$type} && $repeated_msgs{ $m->{'message'} } ) {
                $c->log->debug( 'skipping repeated msg type: '.$m->{'type'} );
                next;
            }

            push @to_return, $m;

            $repeated{$type} = 1;
            $repeated_msgs{ $m->{'message'} } = 1;
            next;
        }
        push @to_keep, $m;
    }

    $c->session->{'__ui_message_queue'} = \@to_keep;

    return \@to_return;
}

sub has_messages_in_queue {
    my $self = shift;
    my $type = shift;

    my $c = $self->{'app'};
    if ( !$c->session->{'__ui_message_queue'} ) {
        return 0;
    }

    my @messages = @{ $c->session->{'__ui_message_queue'} };
    if ( !$type ) {
        return scalar( @messages ) ? 1 : 0;
    }

    for my $m ( @messages ) {
        return 1 if ( $type eq $m->{'type'} );
    }

    return 0;
}

1;
