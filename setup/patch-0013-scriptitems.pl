#!/usr/bin/perl
use strict;
use warnings;

my $file = '/tmp/lo-patch-src/solenv/bin/modules/installer/scriptitems.pm';
open(my $fh, '<', $file) or die "Cannot open: $!";
my @lines = <$fh>;
close($fh);

# Line 1016 (1-based): replace the single INSTDIR assignment with a
# candidate-testing fallback block.
my $idx = 1015; # 0-based index of line 1016
die "Unexpected content at line 1016: $lines[$idx]"
    unless $lines[$idx] =~ qr/\$instdirdestination = \$ENV\{'INSTDIR'\}/;

my $replacement = <<'PERL';
            # GoOffice fix: $ENV{INSTDIR} can be missing or unusable in some
            # CI environments (observed on GitHub Actions runners where every
            # file then falls back to include-path search and packaging dies
            # with hundreds of "Source for X not found" errors). WORKDIR is
            # validated by the installer itself and instdir is always its
            # sibling, so WORKDIR/../instdir is a safe fallback. Pick the
            # first candidate on which the file actually exists.
            my @gooffice_instdirs;
            push @gooffice_instdirs, $ENV{'INSTDIR'}
                if (defined $ENV{'INSTDIR'} && $ENV{'INSTDIR'} ne "");
            push @gooffice_instdirs, ($ENV{'WORKDIR'} . "/../instdir")
                if (defined $ENV{'WORKDIR'});
            $instdirdestination = $gooffice_instdirs[0] . $installer::globals::separator . $destination
                if (@gooffice_instdirs);
            for my $gooffice_idir (@gooffice_instdirs)
            {
                my $gooffice_cand = $gooffice_idir . $installer::globals::separator . $destination;
                if (-f $gooffice_cand)
                {
                    $instdirdestination = $gooffice_cand;
                    last;
                }
            }
PERL

splice(@lines, $idx, 1, $replacement);

open(my $out, '>', $file) or die "Cannot write: $!";
print $out @lines;
close($out);
print "Patched OK\n";
