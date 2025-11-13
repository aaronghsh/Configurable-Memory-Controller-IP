#!/usr/bin/env perl
use strict; use warnings;
use Text::CSV_XS;
use Template;
use File::Path qw(make_path);

my $log = "out/logs/rtl.log";
open my $fh,'<',$log or die "Cannot open $log: $!";

my ($reads,$writes,$errors) = (0,0,0);
while(<$fh>) {
  $reads++  if /^READ,/;
  $writes++ if /^WRITE,/;
  if (/SUMMARY,READS=(\d+),WRITES=(\d+),ERRORS=(\d+)/) {
    ($reads,$writes,$errors) = ($1,$2,$3);
  }
}
close $fh;

make_path("out/csv","out/reports");
my $csv = Text::CSV_XS->new({binary=>1,eol=>"\n"});
open my $cf,'>',"out/csv/summary.csv" or die $!;
$csv->print($cf, [qw(reads writes errors)]);
$csv->print($cf, [$reads, $writes, $errors]);
close $cf;

my $status = ($errors==0) ? "PASS" : "FAIL";

my $tt = Template->new({INCLUDE_PATH=>'scripts/templates'});
$tt->process('report.tt', { reads=>$reads, writes=>$writes, errors=>$errors, status=>$status },
             'out/reports/report.html') or die $tt->error();

print "[parse_logs] reads=$reads writes=$writes errors=$errors status=$status\n";
print "[parse_logs] CSV: out/csv/summary.csv\n";
print "[parse_logs] HTML: out/reports/report.html\n";
