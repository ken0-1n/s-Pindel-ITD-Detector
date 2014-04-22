#! /usr/loca/bin/perl

use strict;

my $colmun = $ARGV[0];
my $input = $ARGV[1];
my $sample = $ARGV[2];
open(IN, $input) || die "cannot open $!";
while(<IN>) {
  
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $line = $_;

  for( my $i=0 ; $i <= $colmun ; $i++ ) {
    if ($F[$i] eq '') {
      $F[$i] = "---";
    }
  }
  print join("\t", @F[0 .. $#F]) ."\t".$sample."\n";
}
close(IN);

