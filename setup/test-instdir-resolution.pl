#!/usr/bin/perl
# Simulate the installer's get_Source_Directory_For_Files_From_Includepathlist
# against a fake INSTDIR tree to verify the patched resolution logic.

use strict;
use warnings;
use File::Path qw(make_path remove_tree);

# --- fake environment ---
my $basedir = "/tmp/gooffice-installer-test";
remove_tree($basedir) if -d $basedir;
make_path("$basedir/instdir/program/resource/vi/LC_MESSAGES", "$basedir/workdir") or die "make_path failed";

# fake files
open(my $f1, '>', "$basedir/instdir/program/libabplo.so"); print $f1 "fake"; close $f1;
open(my $f2, '>', "$basedir/instdir/program/resource/vi/LC_MESSAGES/cui.mo"); print $f2 "fake"; close $f2;

$ENV{'INSTDIR'} = "$basedir/instdir";
$ENV{'WORKDIR'} = "$basedir/workdir";

# --- load the patched module ---
use lib "/tmp/lo-patch-src/solenv/bin/modules";
require installer::scriptitems;
# stub globals the module needs
$installer::globals::separator = "/";
$installer::globals::languagepack = 0;
$installer::globals::helppack = 0;
$installer::globals::iswindowsbuild = 0;
$installer::globals::ismacbuild = 0;

# --- fake installer log target (module pushes infolines here) ---
our @logfileinfo;

# Build a fake files array like the .ins entries
my @files = (
    { 'gid' => 'auto_base_lib_abp', 'Name' => 'libabplo.so', 'destination' => 'program/libabplo.so', 'specificlanguage' => '', 'Styles' => 'PACKED' },
    { 'gid' => 'test_mo',           'Name' => 'vi/LC_MESSAGES/cui.mo', 'destination' => 'program/resource/vi/LC_MESSAGES/cui.mo', 'specificlanguage' => '', 'Styles' => 'PACKED' },
    { 'gid' => 'test_missing',      'Name' => 'does-not-exist.so', 'destination' => 'program/does-not-exist.so', 'specificlanguage' => '', 'Styles' => 'PACKED' },
);

my $filesref = \@files;
my $emptydirs = [];
my $emptyvars = {};

# stub logger used inside the function (include_header_into_logfile)
{
    no strict 'refs';
    *installer::logger::include_header_into_logfile = sub { };
}

# Patch-local debug copy of the critical block:
for my $onefile (@files) {
    my $destination = $onefile->{'destination'};
    my $onefilename = $onefile->{'Name'};
    my $instdirdestination;
    if ($destination) {
        my @gooffice_instdirs;
        push @gooffice_instdirs, $ENV{'INSTDIR'}
            if (defined $ENV{'INSTDIR'} && $ENV{'INSTDIR'} ne "");
        push @gooffice_instdirs, ($ENV{'WORKDIR'} . "/../instdir")
            if (defined $ENV{'WORKDIR'});
        $instdirdestination = $gooffice_instdirs[0] . "/" . $destination
            if (@gooffice_instdirs);
        for my $idir (@gooffice_instdirs) {
            my $cand = $idir . "/" . $destination;
            if (-f $cand) { $instdirdestination = $cand; last; }
        }
    }
    my $ok = ($instdirdestination && -f $instdirdestination) ? "RESOLVED" : "NOT-RESOLVED";
    printf "%-28s dest=%-45s => %s (%s)\n", $onefilename, $destination, $ok, ($instdirdestination // 'undef');
}
