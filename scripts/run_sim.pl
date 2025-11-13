#!/usr/bin/env perl
use strict; use warnings;
use File::Path qw(make_path);
make_path("out/logs");
my $cmd = 'vsim -do sim/run.do > out/logs/rtl.log 2>&1';
print "[run_sim] $cmd\n";
system($cmd) == 0 or die "[run_sim] Simulation failed. See out/logs/rtl.log\n";
print "[run_sim] Done. Log at out/logs/rtl.log\n";
