#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];
my $start_or_end_code = $ARGV[1]; # start:1 end:2

my %hash;
open(IN, $input) || die "cannot open $!";
while(<IN>) {

  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $chr   = $F[0];
  my $start = $F[1];
  my $end   = $F[2];
 
  my $key = 0;
  if ($start_or_end_code == 1){
    $key = $chr."\t".$start;
  }
  else { # code:2
    $key = $chr."\t".$end;
  }
  my $line = $_;
   
  if (not exists $hash{$key}) {
    my @array;
    @{$hash{$key}} = @array;
    push (@{$hash{$key}}, $line);
  }
  else {
    push (@{$hash{$key}}, $line);
  }
}

while (my ($aaa, $bbb) = each(%hash)) {

  if (2 <= @{$bbb}) {
    my $printNo = 0;
    my $printNoNum = 0;
    my $i = 0;
    foreach (@{$bbb}) {
      my @F = split("\t", $_);
      my $sclipNum = $F[4];
      if ($sclipNum > $printNoNum) {
        $printNo = $i;
        $printNoNum = $sclipNum;
      }
      $i++;
    }
    $i = 0;
    foreach (@{$bbb}) {
      my @F = split("\t", $_);
      my $sclipNum = $F[4];
      if ($printNo == $i) {
        print $_ . "\n";
      }
      $i++;
    }
  }
  else {
    foreach (@{$bbb}) {
    print $_ . "\n";
    }
  }
}
close(IN);

