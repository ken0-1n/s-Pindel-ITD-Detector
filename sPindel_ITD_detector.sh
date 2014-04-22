#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -e log
#$ -o log
#$ -l s_vmem=4G,mem_req=4

INPUT_SI=$1
INPUT_TD=$2
OUTDIR=$3
SAMPLE=$4
TARGET_INHOUSE_LIST=$5
SPINDEL_ENV=$6

write_usage() {
  echo ""
  echo "Usage: `basename $0` <input short insertions file> <input tandem duplications file> <output directory> <target inhouse list> [<sPindel.env>]"
  echo ""
}

check_error()  {
  if [ $1 -ne 0 ]; then
    echo "FATAL ERROR: pipeline script"
    echo "ERROR CODE: $1"
    exit $1
  fi
}

check_file_exists() {
  if [ -f $1 ]; then
    echo "$1 exists."
    return
  fi
  echo "$1 does not exists."
  exit 1
}

check_file_exists_usage() {
  if [ -f $1 ]; then
    echo "$1 exists."
    return
  fi
  echo "$1 does not exists."
  write_usage
  exit 1
}

if [ $# -lt 5 ]; then
  echo "wrong number of arguments"
  write_usage
  exit 1
fi

if [ $# -eq 6 ]; then
  configfile=$SPINDEL_ENV
else
  configfile=./sPindel.env
fi

check_file_exists_usage $configfile
source $configfile

check_file_exists_usage $INPUT_SI
check_file_exists_usage $INPUT_TD
check_file_exists_usage $TARGET_INHOUSE_LIST

mkdir -p ${OUTDIR}/tmp
if [ $? -ne 0 ]; then
  echo "cannot create directory ${OUTDIR}/tmp"
  write_usage
  exit $?
fi


check_file_exists db/refGene.coding.exon.bed
check_file_exists db/refGene.coding.intron.bed
check_file_exists db/refGene.coding.5putr.bed
check_file_exists db/refGene.coding.3putr.bed
check_file_exists db/refGene.noncoding.exon.bed
check_file_exists db/refGene.noncoding.intron.bed
check_file_exists db/gene.ens.sort.bed
check_file_exists db/gene.known.sort.bed
check_file_exists db/gene.repeat.sort.bed


echo "perl subscript/td_getter_from_si.pl $INPUT_SI ${OUTDIR}/tmp/${SAMPLE}_temp_ref.fa ${OUTDIR}/tmp/${SAMPLE}_temp_contig.fa ${OUTDIR}/tmp/${SAMPLE}_temp_output.tabular $PATH_TO_FASTA > ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed"
perl subscript/td_getter_from_si.pl $INPUT_SI ${OUTDIR}/tmp/${SAMPLE}_temp_ref.fa ${OUTDIR}/tmp/${SAMPLE}_temp_contig.fa ${OUTDIR}/tmp/${SAMPLE}_temp_output.tabular $PATH_TO_FASTA > ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed
check_error $?

echo "perl subscript/td_getter_from_td.pl $INPUT_TD >> ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed"
perl subscript/td_getter_from_td.pl $INPUT_TD >> ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed
check_error $?

echo "perl subscript/mergeSameData.pl ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed 1  > ${OUTDIR}/tmp/${SAMPLE}.merge1.bed"
perl subscript/mergeSameData.pl ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed 1  > ${OUTDIR}/tmp/${SAMPLE}.merge1.bed
check_error $?

echo "perl subscript/mergeSameData.pl ${OUTDIR}/tmp/${SAMPLE}.merge1.bed 2 > ${OUTDIR}/tmp/${SAMPLE}.merge2.bed"
perl subscript/mergeSameData.pl ${OUTDIR}/tmp/${SAMPLE}.merge1.bed 2 > ${OUTDIR}/tmp/${SAMPLE}.merge2.bed
check_error $?

echo "perl subscript/resultPad.pl 17 ${OUTDIR}/tmp/${SAMPLE}.merge2.bed > ${OUTDIR}/tmp/${SAMPLE}.tmp.bed"
perl subscript/resultPad.pl 17 ${OUTDIR}/tmp/${SAMPLE}.merge2.bed > ${OUTDIR}/tmp/${SAMPLE}.tmp.bed
check_error $?

# ------------ annotation part start ---------------------
echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.coding.exon.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.coding.exon.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.merge.bed
check_error $?

echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.coding.intron.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.coding.intron.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.merge.bed
check_error $?

echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.coding.5putr.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.coding.5putr.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.merge.bed
check_error $?

echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.coding.3putr.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.coding.3putr.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.merge.bed
check_error $?

echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.noncoding.exon.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.noncoding.exon.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.merge.bed
check_error $?

echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.noncoding.intron.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/refGene.noncoding.intron.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.merge.bed
check_error $?

echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/gene.ens.sort.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/gene.ens.sort.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.merge.bed
check_error $?

echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/gene.known.sort.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/gene.known.sort.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.merge.bed
check_error $?

echo "${PATH_TO_BEDTOOLS}/intersectBed -a db/gene.repeat.sort.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.bed"
${PATH_TO_BEDTOOLS}/intersectBed -a db/gene.repeat.sort.bed -b ${OUTDIR}/tmp/${SAMPLE}.tmp.bed -wa > ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.bed
check_error $?
echo "sort -u ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.sort.bed"
sort -u ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.sort.bed
check_error $?
echo "perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.merge.bed"
perl subscript/makeJuncToGene.pl ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.sort.bed > ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.merge.bed
check_error $?

echo "perl subscript/addGeneAnnoPindel.pl ${OUTDIR}/tmp/${SAMPLE}.tmp.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.merge.bed ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.merge.bed ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.merge.bed ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.merge.bed > ${OUTDIR}/tmp/${SAMPLE}.bed"
perl subscript/addGeneAnnoPindel.pl ${OUTDIR}/tmp/${SAMPLE}.tmp.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.merge.bed ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.merge.bed ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.merge.bed ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.merge.bed ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.merge.bed > ${OUTDIR}/tmp/${SAMPLE}.bed
# ------------annotation part end ---------------------

echo -n > ${OUTDIR}/tmp/${SAMPLE}.inhouse.all.bed
cat $TARGET_INHOUSE_LIST | while read line; do
  cat $line >> ${OUTDIR}/tmp/${SAMPLE}.inhouse.all.bed
done

echo "perl subscript/addInhouseAnnoPindel.pl ${OUTDIR}/tmp/${SAMPLE}.bed ${OUTDIR}/tmp/${SAMPLE}.inhouse.all.bed ${SAMPLE} > ${OUTDIR}/${SAMPLE}_sPindel_result.tsv"
perl subscript/addInhouseAnnoPindel.pl ${OUTDIR}/tmp/${SAMPLE}.bed ${OUTDIR}/tmp/${SAMPLE}.inhouse.all.bed ${SAMPLE} > ${OUTDIR}/${SAMPLE}_sPindel_result.tsv

rm ${OUTDIR}/tmp/${SAMPLE}.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.ens.anno.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.known.anno.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.gene.repeat.anno.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}.inhouse.all.bed
rm ${OUTDIR}/tmp/${SAMPLE}.merge1.bed
rm ${OUTDIR}/tmp/${SAMPLE}.merge2.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.3putr.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.5putr.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.exon.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.coding.intron.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.exon.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.anno.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.merge.bed
rm ${OUTDIR}/tmp/${SAMPLE}.refGene.noncoding.intron.sort.bed
rm ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed
rm ${OUTDIR}/tmp/${SAMPLE}.tmp.bed
rm ${OUTDIR}/tmp/${SAMPLE}_temp_contig.fa
rm ${OUTDIR}/tmp/${SAMPLE}_temp_output.tabular
rm ${OUTDIR}/tmp/${SAMPLE}_temp_ref.fa


