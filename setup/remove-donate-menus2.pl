#!/usr/bin/perl
use strict;
use warnings;

# Targeted: remove donation/get-involved menu items from menubar files.
# Paths fed via STDIN (one per line) to avoid slow full-tree scans.

my $changed = 0;
while (my $f = <STDIN>) {
    chomp $f;
    next unless -f $f;
    open(my $fh, '<', $f) or next;
    my @lines = <$fh>;
    close($fh);

    my @out;
    my $n = 0;
    for my $line (@lines) {
        if ($line =~ /menu:id="\.uno:(Donation|GetInvolved)"/) {
            $n++;
            next;
        }
        push @out, $line;
    }
    if ($n > 0) {
        open(my $out, '>', $f) or die "write $f: $!";
        print $out @out;
        close($out);
        $changed += $n;
        print "$n removed: $f\n";
    }
}
print "TOTAL removed: $changed\n";
