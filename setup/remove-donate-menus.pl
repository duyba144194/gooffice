#!/usr/bin/perl
use strict;
use warnings;
use File::Find;

# Remove donation/get-involved menu items from all LibreOffice menubar files
my $root = '/tmp/lo-patch-src';
my $changed = 0;

find(sub {
    return unless $_ eq 'menubar.xml';
    my $f = $File::Find::name;
    open(my $fh, '<', $_) or return;
    my @lines = <$fh>;
    close($fh);

    my @out;
    my $n = 0;
    for my $line (@lines) {
        # drop whole lines containing the donation or get-involved menu ids
        if ($line =~ /menu:id="\.uno:(Donation|GetInvolved)"/) {
            $n++;
            next;
        }
        push @out, $line;
    }
    if ($n > 0) {
        open(my $out, '>', $_) or die "write $_: $!";
        print $out @out;
        close($out);
        $changed += $n;
        print "Removed $n line(s) from $f\n";
    }
}, $root);

print "TOTAL removed: $changed menu item lines\n";
