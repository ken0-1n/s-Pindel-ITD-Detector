#! /usr/loca/bin/perl
#$ -S /usr/local/bin/perl
#$ -cwd
#$ -e log -o log
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input  = $ARGV[0];
my $fasta36_temp_ref = $ARGV[1];
my $fasta36_temp_contig = $ARGV[2];
my $fasta36_temp_output = $ARGV[3];
my $fasta36 = $ARGV[4]."/fasta36";


if (@ARGV != 5){
  print STDERR "[td_getter_from_si.pl]\n";
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
  
  next if ($ins_size < 10);
 
  # get insert nucleotides
  my @mutation_arr = split(" ", $linearr1[2]);
  my $ins_nucleotides = $mutation_arr[2];
  $ins_nucleotides =~ s/[\"]//g;

  # get duplicated nucleotides
  my $readline2 = <IN>;
  chomp($readline2);
  my $space_index = index($readline2, " ");
  my $right_nucleotides = substr($readline2, ($space_index + $ins_size), $ins_size);
 
  # check align percentage using fasta36
  # ------------ start ----------------------------
  
  open(TMP_REF,">".$fasta36_temp_ref) || die "cannot open $!";
  print TMP_REF ">1\n".$ins_nucleotides."\n"; 
  close(TMP_REF);

  open(TMP_CONTIG,">".$fasta36_temp_contig) || die "cannot open $!";
  print TMP_CONTIG ">1\n".$right_nucleotides."\n"; 
  close(TMP_CONTIG);

  my $ret = system($fasta36 ." -d 1 -b 1 -m 8 ". $fasta36_temp_ref ." ". $fasta36_temp_contig ." > ". $fasta36_temp_output); 
  if ($ret != 0) {
    print STDERR "fasta36. ERROR CODE: ".$ret."\n";
    exit 1;
  }
  
  my $alignmentlen = 0;
  open(TABULAR, $fasta36_temp_output) || die "cannot open $!";
  while(<TABULAR>) {
    next if (/^\#/);
    s/[\r\n]//g;
    my @F = split("\t", $_);
    if ($F[11] > 0) {
      $alignmentlen = $F[3];
      last;
    }
  }
  close(TABULAR);

  my $per_alignment = ($alignmentlen / $ins_size);
  next if ($per_alignment < 0.70);
  
  # ---------- end ---------------------------------
 
  my @id_array = ();
  while(<IN>) {
    s/[\r\n]//g;
    my $readline3 = $_;
    last if ($readline3 =~ /^#/);
    my @F3 = split("\t", $readline3);
    push @id_array ,substr($F3[5],1,-2);
  }

  my @chr_arr = split(" ", $linearr1[3]);
  my $chr = $chr_arr[1];
  my @spos_arr = split(" ", $linearr1[4]);
  my $spos = $spos_arr[1];
  my $epos = ($spos_arr[1] + $ins_size);
  my $left_contig = substr($readline2, 0, $space_index);
  my $right_contig = substr($readline2, ($space_index + $ins_size));
  my @support_arr = split(" ",$linearr1[8]);
  my $support = $support_arr[1];
  my $support_uniq = $linearr1[9];
  my @support_P_arr = split(" ",$linearr1[10]);
  my $support_P = $support_P_arr[1];
  my $support_P_uniq = $linearr1[11];
  my @support_M_arr = split(" ",$linearr1[12]);
  my $support_M = $support_M_arr[1];
  my $support_M_uniq = $linearr1[13];

  my $contig = $left_contig . $ins_nucleotides. $right_contig;

  # add 14.01.21
  # next if ($epos - $spos < 10);
  
  print $chr ."\t". $spos ."\t". $epos ."\t". $ins_size ."\t". $support ."\t". $support_uniq ."\t". $support_P ."\t". $support_P_uniq ."\t". $support_M ."\t". $support_M_uniq ."\t". $ins_nucleotides ."\t". $contig ."\n"; 
  
}
close(IN);

