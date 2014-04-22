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
SPINDEL_ENV=$5

write_usage() {
  echo ""
  echo "Usage: `basename $0` <input short insertions file> <input tandem duplications file> <output directory> <sample> [<sPindel.env>]"
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

if [ $# -lt 4 ]; then
  echo "wrong number of arguments"
  write_usage
  exit 1
fi

if [ $# -eq 5 ]; then
  configfile=$SPINDEL_ENV
else
  configfile=./sPindel.env
fi

if [ ! -f $configfile ]; then
  echo "$configfile does not exists."
  write_usage
  exit 1
fi
source $configfile

check_file_exists $INPUT_SI
check_file_exists $INPUT_TD

mkdir -p ${OUTDIR}/tmp
if [ $? -ne 0 ]; then
  echo "cannot create directory ${OUTDIR}/tmp"
  write_usage
  exit $?
fi

echo "perl subscript/td_getter_from_si.pl $INPUT_SI ${OUTDIR}/tmp/${SAMPLE}_temp_ref.fa ${OUTDIR}/tmp/${SAMPLE}_temp_contig.fa ${OUTDIR}/tmp/${SAMPLE}_temp_output.tabular $PATH_TO_FASTA > ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed"
perl subscript/td_getter_from_si.pl $INPUT_SI ${OUTDIR}/tmp/${SAMPLE}_temp_ref.fa ${OUTDIR}/tmp/${SAMPLE}_temp_contig.fa ${OUTDIR}/tmp/${SAMPLE}_temp_output.tabular $PATH_TO_FASTA > ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed

echo "perl subscript/td_getter_from_td.pl $INPUT_TD >> ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed"
perl subscript/td_getter_from_td.pl $INPUT_TD >> ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed
check_error $?

# ------------create inhouse data start ---------------------
echo "perl subscript/inhousePad.pl 17 ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed ${SAMPLE} > ${OUTDIR}/${SAMPLE}.inhouse.bed"
perl subscript/inhousePad.pl 17 ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed ${SAMPLE} > ${OUTDIR}/${SAMPLE}.inhouse.bed
check_error $?
# ------------create inhouse data end ---------------------

rm ${OUTDIR}/tmp/${SAMPLE}_SI_TD.bed
rm ${OUTDIR}/tmp/${SAMPLE}_temp_contig.fa
rm ${OUTDIR}/tmp/${SAMPLE}_temp_output.tabular
rm ${OUTDIR}/tmp/${SAMPLE}_temp_ref.fa

