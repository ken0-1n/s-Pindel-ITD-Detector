#! /usr/local/bin/perl

use strict;
use warnings;

my $inputlist = $ARGV[0];
my $inputinhouse = $ARGV[1];
my $sample_args = $ARGV[2];

my %inhouseHash = ();
my %inhouseRight = ();

open(IN, $inputinhouse) || die "cannot open $!";
while(<IN>) {
    s/[\r\n]//g;
    my @F = split("\t", $_);
    
    my $key = $F[0]."\t".$F[1]."\t".$F[2];
    my $sample = $F[18];
    my $support_p = $F[6];
    my $support_pu = $F[7];
    my $support_m = $F[8];
    my $support_mu = $F[9];
    if ($sample ne $sample_args) { 
        if (exists $inhouseHash{$key}) {
            my $val = $inhouseHash{$key};
            $inhouseHash{$key} = $val.";".$sample."(".$support_p.",".$support_pu.",".$support_m.",".$support_mu.")";
        }
        else {
            $inhouseHash{$key} = $sample."(".$support_p.",".$support_pu.",".$support_m.",".$support_mu.")";
        }
    }
}
close(IN);

open(INL, $inputlist) || die "cannot open $inputlist";
while(<INL>) {

  s/[\r\n]//g;
  my @F = split("\t", $_);
  my $line = $_;
  
  my $key = $F[0]."\t".$F[1]."\t".$F[2];

  if (exists $inhouseHash{$key}) {
      my $val = $inhouseHash{$key};

      my @valarr = split(";", $val);
      my %inhouseHash_sort = ();
      foreach my $inhouse_val (@valarr) {
          $inhouseHash_sort{$inhouse_val} = 1;
          my $cnt = scalar(keys(%inhouseHash_sort));
          last if ($cnt >= 20);
      }
      my $res = "";
      foreach my $tmpres (keys %inhouseHash_sort) {
          $res = $res.";".$tmpres;
      }
      print join("\t",@F[0 .. 20]) ."\t". substr($res,1) ."\n";
  }
  else {
      print join("\t",@F[0 .. 20]) ."\t---\n";
  }
}
close(INL);

