# NAME

Mojolicious::Plugin::UserMessages - Mojolicious Plugin to manage user message(s) qeue(s)

# SYNOPSIS

    # Mojolicious Lite
    plugin 'UserMessages'
    
    # Mojolicious 
    $self->plugin('UserMessages')

    # In your code add some messages to the user
    $self->user_messages( info    => 'Just some information' );
    $self->user_messages( success => 'Operation completed' );

    # In your template get and print the messages
    # The messages will stay in the queue until you show them 
    #  to the user

    %  for my $message ( user_messages->get ) {
       <div><%= $message->{'type'} %> : <%= $message->{'message'} %></div>
    %  }

    # You can also get messages from a specific type
    %  for my $message ( user_messages->get_info ) {
        <div>INFO : <%= $message->{'message'} %></div>
    %  }
     

# DESCRIPTION

[Mojolicous::Plugin::UserMessages](https://metacpan.org/pod/Mojolicous::Plugin::UserMessages) implements a message queue to the user.

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin), [Mojolicious::Lite](https://metacpan.org/pod/Mojolicious::Lite)

# COPYRIGHT & LICENSE

Copyright 2013 Bruno Tavares. All right reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
