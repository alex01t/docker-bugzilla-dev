# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::P4;

use 5.14.0;
use strict;
use warnings;

use parent qw(Bugzilla::Extension);

use Bugzilla::Util qw(html_quote);

our $VERSION = '0.02';

# See the documentation of Bugzilla::Hook ("perldoc Bugzilla::Hook" 
# in the bugzilla directory) for a list of all available hooks.
sub install_update_db {
    my ($self, $args) = @_;

}

sub enabled {
    return 1;
};

sub _replace_p4_change {
    my $args = shift;
    my $title = $args->{matches}->[0];
    my $id = $args->{matches}->[1];
    $title = html_quote($title);
    $id = html_quote($id);
    return qq{ <a href="http://release.azulsystems.com/cgi-bin/changelist?cl=$id">$title$id</a>};
};
sub _replace_p4_revert_change {
    my $args = shift;
    my $revert = $args->{matches}->[0];
    my $id = $args->{matches}->[1];
    $revert = html_quote($revert);
    $id = html_quote($id);
    return qq{$revert<a href="http://release.azulsystems.com/cgi-bin/changelist?cl=$id">$id</a>};
};
sub _replace_phabracator_diff1 {
    my $args = shift;
    my $id = $args->{matches}->[0];
    $id = html_quote($id);
    return qq{ <a href="http://phabricator.azulsystems.com/$id">$id</a>};
};
sub _replace_phabracator_diff2 {
    my $args = shift;
    my $prefix = $args->{matches}->[0];
    my $id = $args->{matches}->[1];
    $id = html_quote($id);
    return qq{$prefix<a href="http://phabricator.azulsystems.com/$id">$id</a>};
};
sub _replace_more_bug {
    my $args = shift;
    my $title = $args->{matches}->[0];
    my $id = $args->{matches}->[1];
    $title = html_quote($title);
    $id = html_quote($id);
    return qq{ <a href="show_bug.cgi?id=$id">$title$id</a>};
};
sub _replace_p4_difflabels {
    my $args = shift;
    my $title = html_quote($args->{matches}->[0]);
    my $id = html_quote($args->{matches}->[3]);
    return qq{ <a href="http://release.azulsystems.com/cgi-bin/difflabels2?prod=ZVM&branch=dev&lab=zvm-dev-$id">$title$id</a>};
};

sub bug_format_comment {
    my ($self, $args) = @_;
    my $regexes = $args->{'regexes'};
    
    my $p4_change_match         = qr/\b(Change[-: ]|CL\s*|CR\s*|CL\s*#\s*|CR\s*#\s*|rev[- ]*)(\d+)\b/i;
    my $p4_revert_change_match  = qr/\b(revert\s*r*|reverts\s*r*|reverting\s*r*|reverted\s*r*|revert of\s*r*)(\d+)\b/i;
    my $phabricator_diff_match1 = qr/\bhttp:\/\/phabricator.azulsystems.com\/(D\d+)\b/;
    my $phabricator_diff_match2 = qr/(^|[\s,:]+)(D\d+)\b/;
    my $more_bug_match          = qr/\b(bug[: -]*)(\d+)\b/i;
    my $p4_difflabels_match     = qr/\b((zing|zvm)[- ]*(dev)?[- ]*)(\d+)\b/i;
    
    push(@$regexes, { match => $p4_change_match,         replace => \&_replace_p4_change         });
    push(@$regexes, { match => $p4_revert_change_match,  replace => \&_replace_p4_revert_change  });
    push(@$regexes, { match => $phabricator_diff_match1, replace => \&_replace_phabracator_diff1 });
    push(@$regexes, { match => $phabricator_diff_match2, replace => \&_replace_phabracator_diff2 });
    push(@$regexes, { match => $more_bug_match,          replace => \&_replace_more_bug          });
    push(@$regexes, { match => $p4_difflabels_match,     replace => \&_replace_p4_difflabels     });
}

__PACKAGE__->NAME;
