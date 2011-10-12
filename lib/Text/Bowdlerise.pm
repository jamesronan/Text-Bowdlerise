package Text::Bowdlerise;

use strict;
no warnings;

use Scalar::Util;

our $VERSION = '0.01';

=head1 NAME

Text::Bowdlerise - Bowdlerise text. Simples.

=head1 SYNOPSIS

Bowdlerises a (or a list of) text string(s).  Primarily replaces common 
profanity with socially acceptable alternative.  This can of course be extended
or even overriden by way of configuration.

In it's simplest form, a straight forward use to replace the built in common 
elements, looks like this:

    use Text::Bowdlerise;
    my $acceptable_language = Text::Bowdlerise::bowdlerise($profanity);

However, for more control over what is replaced:

    use Text::Bowdlerise;

    my $bowdler = Text::Bowdlerise->new( ignore_defaults => 1 );
    $bowdler->add_rules( 
        'cpan.org' => 'metacpan.org',
        ...
    );
    my $fixed_links = $bowdler->bowdlerise($old_listings);

=cut


my $default_list = {
    arse         => 'bottom',
    arsefuck     => 'bottomlove',
    ass          => 'donkey',
    assfuck      => 'donkeylove',
    cunt         => 'ladypart',
    motherfucker => 'mater-lover',
    fucktard     => 'a complete Dave',
    defuck       => 'make better',
    fuck         => 'ruin',
    piss         => 'unrine',
    shit         => 'faeces',
    tit          => 'breast',
    twat         => 'ladypart',
    unfuck       => 'make nicer',
};


=head1 CONSTRUCTOR

Constructs a new Text::Bowdler object which can be configured how you see fit.

=head2 DWIMery

Can be passed either a string which is operated on using built-in rules, 

OR

a hashref of configuration parameters (one or many of):

=over 

=item ignore_default_list

Tells the Bowdler not to use its built in list.  If this is specified, 
alternate rules should be given.

=item allow_part_replacement

Tells the Bowdler whether to replace matches that are part of other words.
Defaults to 1 (allow). Setting a value of 0 will disable this behaviour,

=item user_rule_list

Used to specify a specific set of replacements.  Supplied as a hashref 
of 'thing to match' => 'replacement text'.

Note that this does not override the default list; This appends to it.  To
remove the built in ruleset specify ignore_default_list => 1 

=item user_rule_file

Use to tell the module to read a rule list file. Supplied as a string file
name; The file must contain a perl hashref in the same format as
rule_list

=back

=cut

sub new {
    my ($self, $params) = @_;

    if (   $params
        && ref $params ne 'HASH'
        && !Scalar::Util::blessed($params) ) 
    {
        return Text::Bowdlerise->new->bowdlerise($params);    
    }

    return bless {
        _prefs => {
            ignore_default_list    => $params->{ignore_default_list}    // 0,
            allow_part_replacement => $params->{allow_part_replacement} // 1,
            user_rule_list         => $params->{user_rule_list}         // {},
            user_rule_file         => $params->{user_rule_file}         // '',
        },
        _rules => buildrules($params),
    } => $self || __PACKAGE__;
}

=head1 METHODS

=head2 bowdlerise

Action method. Actually does the replacements.  Accepts a single string or an
arrayref of strings to perform the replacement upon.

=cut

sub bowdlerise {
    my ($self, $text) = @_;

    if (   !$text
        || ref $text eq 'HASH'
        || Scalar::Util::blessed($text) )
    {
        return;
    }

    # If it's not an arrayref then we'll assume it's a single string, so make 
    # it an arrayref.
    $text = [ $text ] if (ref $text ne 'ARRAY');

    # For the list of text, flick through each one, and apply each rule,
    for my $chunk (@$text) {
        while ( my ( $search, $replacement ) = each %{ $self->{_rules} } ) {
            
            # Do the replacement first with whole words,
            $chunk =~ s{\b\Q$search\E\b}{$replacement}gi;

            # Then with part-word is that is permissable.
            $chunk =~ s{\Q$search\E}{$replacement}gi
                if $self->{_prefs}{allow_part_replacement};
        }
    }

    return (scalar @$text > 1)? $text : shift @$text;
}

=head2 add_rules
    
    In: \%rules (Hash ref of rules to add).

Adds the supplied rules to the rule list.

=cut

sub add_rules {
    my ($self, $newrules) = @_;

    my %rules = %{ $self->{_prefs}{user_rule_list} };
    
    %rules = ( %rules, %$newrules );

    $self->{_prefs}{user_rule_list} = \%rules;
    return $self->{_rules} = buildrules({ user_rule_list => \%rules });
}



# Build up the rules list based on what prefs are passed in.

sub buildrules {
    my ($prefs) = @_;

    return if !$prefs;

    my %rules;

    # If we aren't ignoring the built-in list add those.
    if (!$prefs->{ignore_default_list}) {
        %rules = ( %rules, %$default_list );
    }

    # If we've been supplied a user list, add that:
    if (   $prefs->{user_rule_list}
        && ref $prefs->{user_rule_list} eq 'HASH')
    {
        %rules = ( %rules, %{ $prefs->{user_rule_list} } );
    }

    # Lastly, add the rules in the user_list_file, if one was specified
    if (   $prefs->{user_list_file}
        && -f $prefs->{user_list_file})
    {
        my $user_rules = do $prefs->{user_list_file};
        if (ref $user_rules eq 'HASH') {
            %rules = ( %rules, %$user_rules );
        }
    }

    return \%rules;
}

=head1 AUTHOR

James Ronan, C<< <james at ronanweb.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-bowdlerise at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Bowdlerise>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Bowdlerise


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Bowdlerise>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Bowdlerise>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Bowdlerise>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Bowdlerise/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 James Ronan.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


=cut

1; # End of Text::Bowdlerise
