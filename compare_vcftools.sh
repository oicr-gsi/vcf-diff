#!/bin/bash
#set -e -o pipefail

#bgzip and index all vcfs in preparation for vcftools
module load tabix/0.2.6
find . -name "*.vcf" -execdir bgzip {} +
find . -name "*.gz" -execdir tabix {} +

mkdir compare
module load vcftools/0.1.14
PERL5LIB="$PERL5LIB:/oicr/local/sw/vcftools/0.1.14/share/perl/5.10.1"

#find the filenames, get basenames and trim off everything after the first period
names=($(find gatk/EX -name "*.gz" -execdir basename {} + | perl -ne 'print "$1\n" if /([A-Za-z0-9_]+)/ '))

for i in ${names[@]}
do
    gatkfile=$(find gatk/EX -name "${i}*gz")
    sentfile=$(find sentieon -name "${i}*gz")
    vcf-compare -g ${gatkfile} ${sentfile} > "compare/vcf-compare.${i}"
done

