#!/usr/bin/perl
use strict;
use warnings;

# GoOffice fork: disable donation/get-involved appeals by flipping schema
# defaults. Line-based editing: find the <prop oor:name="X"> line, then
# replace the next <value>true</value> before </prop>.

my $changed = 0;

sub flip_prop_default {
    my ($path, $propname, $label) = @_;
    open(my $fh, '<', $path) or die "open $path: $!";
    my @lines = <$fh>;
    close($fh);

    my $in_prop = 0;
    my $done = 0;
    for my $i (0 .. $#lines) {
        if (!$in_prop && $lines[$i] =~ /<prop oor:name="\Q$propname\E"/) {
            $in_prop = 1;
            next;
        }
        if ($in_prop) {
            if ($lines[$i] =~ /<value>true<\/value>/) {
                $lines[$i] =~ s/<value>true<\/value>/<value>false<\/value>/;
                $done = 1;
                last;
            }
            if ($lines[$i] =~ /<\/prop>/) {
                last;   # prop ended without a true value - error below
            }
        }
    }
    die "PROP $propname NOT FOUND OR NOT TRUE in $path ($label)\n" unless $done;

    open(my $out, '>', $path) or die "write $path: $!";
    print $out @lines;
    close($out);
    $changed++;
    print "OK: $label\n";
}

my $root = '/tmp/lo-patch-src';

flip_prop_default(
    "$root/officecfg/registry/schema/org/openoffice/Office/Common.xcs",
    'ShowDonation',
    'Common.xcs Misc/ShowDonation true->false (Start Center banner + button)',
);

flip_prop_default(
    "$root/officecfg/registry/schema/org/openoffice/Office/UI/Infobar.xcs",
    'Donate',
    'Infobar.xcs Enabled/Donate true->false (document infobar)',
);

flip_prop_default(
    "$root/officecfg/registry/schema/org/openoffice/Office/UI/Infobar.xcs",
    'GetInvolved',
    'Infobar.xcs Enabled/GetInvolved true->false (document infobar)',
);

print "TOTAL: $changed prop(s) flipped\n";
