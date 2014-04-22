#! /bin/bash

configfile=$1

write_usage() { 
  echo "" 
  echo "Usage: `basename $0` [<sPindel.env>]"
  echo ""
}

if [ $# -lt 1 ]; then
  configfile=./sPindel.env
fi

if [ ! -f $configfile ]; then
  echo "$configfile does not exists."
  write_usage
  exit 1
fi
source $configfile

refGene=db/refGene.txt
knownGene=db/knownGene.txt
ensGene=db/ensGene.txt
sRepeat=db/simpleRepeat.txt

if [ ! -f $refGene ]; then
  echo "$refGene does not exists."
  exit 1
fi
if [ ! -f $knownGene ]; then
  echo "$knownGene does not exists."
  exit 1
fi
if [ ! -f $ensGene ]; then
  echo "$ensGene does not exists."
  exit 1
fi
if [ ! -f $sRepeat ]; then
  echo "$sRepeat does not exists."
  exit 1
fi

perl db/coding_RefSeq.pl $refGene db/refGene.coding.exon.tmp.bed db/refGene.coding.intron.tmp.bed db/refGene.coding.5putr.tmp.bed db/refGene.coding.3putr.tmp.bed

${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.exon.tmp.bed   -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.coding.exon.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.intron.tmp.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.coding.intron.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.5putr.tmp.bed  -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.coding.5putr.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.3putr.tmp.bed  -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.coding.3putr.bed

perl db/noncoding_RefSeq.pl $refGene db/refGene.noncoding.exon.tmp.bed db/refGene.noncoding.intron.tmp.bed

${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.noncoding.exon.tmp.bed   -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.noncoding.exon.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.noncoding.intron.tmp.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.noncoding.intron.bed

perl db/known_gene_format_changer.pl $knownGene | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/gene.known.sort.bed
perl db/ens_gene_format_changer.pl   $ensGene   | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/gene.ens.sort.bed
perl db/s_repeat_format_changer.pl   $sRepeat   | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/gene.repeat.sort.bed

rm db/refGene.coding.exon.tmp.bed
rm db/refGene.coding.intron.tmp.bed 
rm db/refGene.coding.5putr.tmp.bed
rm db/refGene.coding.3putr.tmp.bed 
rm db/refGene.noncoding.exon.tmp.bed 
rm db/refGene.noncoding.intron.tmp.bed 

