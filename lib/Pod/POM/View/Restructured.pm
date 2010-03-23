# Original authors: don
# $Revision$

# Copyright (c) 2010 Don Owens <don@regexguy.com>.  All rights reserved.
#
# This is free software; you can redistribute it and/or modify it under
# the Perl Artistic license.  You should have received a copy of the
# Artistic license with this distribution, in the file named
# "Artistic".  You may also obtain a copy from
# http://regexguy.com/license/Artistic
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.


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

This module outputs reStructuredText that is expected to be used with Sphinx.

=head1 VERSION

 0.01

=cut

use strict;
use warnings;
use Data::Dumper ();

use Pod::POM;

package Pod::POM::View::Restructured;

our $VERSION = '0.01';

use base 'Pod::POM::View::Text';

=pod

=head1 METHODS

=head2 C<new()>

Constructor.

=cut

sub new {
    my ($class) = @_;
    my $self = bless { seen_something => 0, title_set => 0 }, ref($class) || $class;
    return $self;
}

sub convert_file {
    my ($self, $source_path, $title, $dest_file) = @_;

    my $view = Pod::POM::View::Restructured->new;
    my $parser = Pod::POM->new;
    my $pom = $parser->parse_file($source_path);

    $view->{title_set} = 1 if defined($title);
    my $out = $pom->present($view);

    if (defined($title)) {
        my $line = '#' x length($title);
        $out = $line . "\n" . $title . "\n" . $line . "\n\n" . $out;
    }

    if (defined($dest_file) and $dest_file ne '') {
        my $out_fh;
        if (UNIVERSAL::isa($dest_file, 'GLOB')) {
            $out_fh = $dest_file;
        }
        else {
            unless (open($out_fh, '>', $dest_file)) {
                warn "couldn't open output file $dest_file";
                return undef;
            }
        }

        print $out_fh $out;
        close $out_fh;
    }

    return $out;
}

sub view_pod {
    my ($self, $node) = @_;

    my $content = ".. highlight:: perl\n\n";
    
    return $content . $node->content()->present($self);
}

sub _generic_head {
    my ($self, $node, $marker, $do_overline) = @_;

    return scalar($self->_generic_head_multi($node, $marker, $do_overline));
}

sub _generic_head_multi {
    my ($self, $node, $marker, $do_overline) = @_;

    my $title = $node->title()->present($self);
    my $content = $node->content()->present($self);
    
    $title = ' ' if $title eq '';
    my $section_line = $marker x length($title);

    my $section = $title . "\n" . $section_line . "\n\n" . $content;
    if ($do_overline) {
        $section = $section_line . "\n" . $section;
    }

    $section .= "\n";
    
    return wantarray ? ($section, $content, $title) : $section;
}

sub view_head1 {
    my ($self, $node) = @_;

    my ($section, $content, $title) = $self->_generic_head_multi($node, '*', 1);

    unless ($self->{seen_something} or $self->{title_set}) {
        if ($title eq 'NAME') {
            $self->{seen_something} = 1;

            if ($content =~ /\A\s*(\w+(?:::\w+)+)\s+-\s+/s) {
                my $mod_name = $1;
                $self->{module_name} = $mod_name;
                $self->{title_set} = 1;
                
                my $line = '#' x length($mod_name);
                $section = $line . "\n" . $mod_name . "\n" . $line . "\n\n" . $section;
            }
            
            return $section;
        }
    }
    
    $self->{seen_something} = 1;
    return $section;
}

sub view_head2 {
    my ($self, $node) = @_;

    $self->{seen_something} = 1;
    return $self->_generic_head($node, '=');
}

sub view_head3 {
    my ($self, $node) = @_;

    $self->{seen_something} = 1;
    return $self->_generic_head($node, '-');
}

sub view_head4 {
    my ($self, $node) = @_;

    $self->{seen_something} = 1;
    return $self->_generic_head($node, '^');
}

sub view_item {
    my ($self, $node) = @_;

    $self->{seen_something} = 1;

    my $title = $node->title()->present($self);
    my $content = $node->content()->present($self);
    
    $title =~ s/\A\s+//;
    $content = ' ' . $content;

    return $content;
}

sub view_verbatim {
    my ($self, $node) = @_;

    (my $node_part = ' ' . $node) =~ s/\n/\n /g;
    
    my $content = ".. code-block:: perl\n\n" . $node_part;
    

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

B<Document example of setting up sphinx build, generating rst from pod, and building>

B<Build and document example for pod2rst>

B<Build and document use for converting multiple files and creating an index>

E.g.,

 [ { file => $file_path, title => $title, link_name => $link_name ] ]

If no link_name, make up a numbered one.  If no title, try to
guess title from NAME section, otherwise, make up a number.

=head1 DEPENDENCIES

Inherits from Pod::POM::View::Text that comes with the Pod::POM distribution.

=head1 AUTHOR

Don Owens <don@regexguy.com>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010 Don Owens <don@regexguy.com>.  All rights reserved.

This is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.  See perlartistic.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.

=head1 SEE ALSO

L<Pod::POM>

L<Pod::POM::View::HTML>

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
