#! /usr/loca/bin/perl
#$ -S /usr/local/bin/perl
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input  = $ARGV[0];

if (@ARGV != 1){
  print STDERR "[td_getter_from_td.pl]\n";
  print STDERR "wrong number of arguments\n";
  exit 1;
}

open(IN, $input) || die "cannot open $!";
while(<IN>) {
  s/[\r\n]//g;
  my $readline1 = $_;
  next if not ($readline1 =~ /^[0-9]/);
  my @linearr1 = split("\t", $readline1);
       
  my @mutation_size_arr = split(" ", $linearr1[1]);
  my $ins_size = $mutation_size_arr[1];
  
  next if ($ins_size > 300);

  my $readline2 = <IN>;
  chomp($readline2);
  my $contig = $readline2;

  my @id_array = ();
  while(<IN>) {
    s/[\r\n]//g;
    my $readline3 = $_;
    last if ($readline3 =~ /^#/);
   
    my @F3 = split("\t", $readline3);
    if (defined($F3[1]) and $F3[1] =~ /[+-]$/) {
      push @id_array ,substr($F3[5],1,-2);
    }
  }

  my @chr_arr = split(" ", $linearr1[3]);
  my $chr = $chr_arr[1];
  my @spos_arr = split(" ", $linearr1[4]);
  my $spos = $spos_arr[1];
  my $epos = ($spos_arr[1] + $ins_size);
  my @support_arr = split(" ",$linearr1[8]);
  my $support = $support_arr[1];
  my $support_uniq = $linearr1[9];
  my @support_P_arr = split(" ",$linearr1[10]);
  my $support_P = $support_P_arr[1];
  my $support_P_uniq = $linearr1[11];
  my @support_M_arr = split(" ",$linearr1[12]);
  my $support_M = $support_M_arr[1];
  my $support_M_uniq = $linearr1[13];

  print $chr ."\t". $spos ."\t". $epos ."\t". $ins_size ."\t". $support ."\t". $support_uniq ."\t". $support_P ."\t". $support_P_uniq ."\t". $support_M ."\t". $support_M_uniq ."\t". "\t". $contig ."\n"; 

}
close(IN);

