# Original authors: don
# $Revision$


=pod

=head1 NAME

Pod::POM::View::Restructured - View for Pod::POM that outputs reStructuredText

=head1 SYNOPSIS

    use Pod::POM::View::Restructured;

    my $view = Pod::POM::View::Restructured->new;
    my $parser = Pod::POM->new;
    my $pom = $parser->parse_file("$top_dir/lib/Pod/POM/View/Restructured.pm");
    my $out = $pom->present($view);


=head1 DESCRIPTION


=head1 VERSION

 0.01

=cut

use strict;
use warnings;

package Pod::POM::View::Restructured;

our $VERSION = '0.01';

use base 'Pod::POM::View::Text';

=pod

=head1 METHODS

=head2 C<new()>

=cut

sub new {
    my ($class) = @_;
    my $self = bless {}, ref($class) || $class;
    return $self;
}

sub view_pod {
    my ($self, $node) = @_;

    my $content = ".. highlight:: perl\n\n";
    
    return $content . $node->content()->present($self);
}

sub _generic_head {
    my ($self, $node, $marker, $do_overline) = @_;

    my $title = $node->title()->present($self);
    my $content = $node->content()->present($self);
    
    $title = ' ' if $title eq '';
    my $section_line = $marker x length($title);

    my $section = $title . "\n" . $section_line . "\n\n" . $content;
    if ($do_overline) {
        $section = $section_line . "\n" . $section;
    }
    
    return $section . "\n";
}

sub view_head1 {
    my ($self, $node) = @_;

    return $self->_generic_head($node, '#', 1);
}

sub view_head2 {
    my ($self, $node) = @_;

    return $self->_generic_head($node, '*', 1);
}

sub view_head3 {
    my ($self, $node) = @_;

    return $self->_generic_head($node, '=');
}

sub view_head4 {
    my ($self, $node) = @_;

    return $self->_generic_head($node, '-');
}

sub view_item {
    my ($self, $node) = @_;

    my $title = $node->title()->present($self);
    my $content = $node->content()->present($self);
    
    $title =~ s/\A\s+//;
    $content = ' ' . $content;

    return $content;
}

sub view_verbatim {
    my ($self, $node) = @_;

    my $content = '' . $node;

    return $content . "\n\n";
}

sub view_seq_code {
    my ($self, $text) = @_;

    return '\ ``' . $text . '``\ ';
}

sub view_seq_bold {
    my ($self, $text) = @_;

    $text =~ s/\*/\\*/g;
    $text =~ s/\`/\\`/g;

    return '\ **' . $text . '**\ ';
}

sub view_seq_italic {
    my ($self, $text) = @_;

    $text =~ s/\*/\\*/g;
    $text =~ s/\`/\\`/g;
    
    return '\ *' . $text . '*\ ';
}

sub view_seq_link {
    my ($self, $text) = @_;

    if ($text =~ m{\Ahttps?://}) {
        $text = qq{`$text <$text>`_};
    }
    elsif ($text =~ /::/) {
        my $url = "http://search.cpan.org/search?query=$text&mode=module";
        $text = qq{`$text <$url>`_};
    }
    
    return $text;
}

=pod

=head1 EXAMPLES


=head1 DEPENDENCIES


=head1 AUTHOR

Don Owens <don@owensnet.com>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010 Don Owens <don@owensnet.com>.  All rights reserved.

This is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.  See perlartistic.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.

=head1 SEE ALSO

L<Pod::POM>

reStructuredText: L<http://docutils.sourceforge.net/rst.html>

Sphinx (uses reStructuredText): L<http://sphinx.pocoo.org/>

=cut

1;

# Local Variables: #
# mode: perl #
# tab-width: 4 #
# indent-tabs-mode: nil #
# cperl-indent-level: 4 #
# perl-indent-level: 4 #
# End: #
# vim:set ai si et sta ts=4 sw=4 sts=4:
