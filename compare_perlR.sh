#!/bin/bash
#set -e -o pipefail

#decompress all vcfs in preparation for perl
module load tabix/0.2.6
find -L . -name "*vcf.gz" -execdir bgzip -d {} +

mkdir compare
#module load vcftools/0.1.14
#PERL5LIB="$PERL5LIB:/oicr/local/sw/vcftools/0.1.14/share/perl/5.10.1"

#find the filenames, get basenames and trim off everything after the first period
names=($(find -L gatk-vcf -name "*.vcf" -execdir basename {} + | perl -ne 'print "$1\n" if /([A-Za-z0-9_]+)/ '))

echo $names

for i in ${names[@]}
do
    gatkfile=$(find -L gatk-vcf -name "${i}*vcf")
    sentfile=$(find -L sentieon -name "${i}*vcf")
    echo "$gatkfile $sentfile" 
    perl vcfVariantsInCommon.pl $gatkfile $sentfile > "compare/in_common.${i}.sentieon.vcf"
    perl vcfVariantsInCommon.pl $sentfile $gatkfile > "compare/in_common.${i}.gatk.vcf"
    perl call_joiner.pl --gatk "compare/in_common.${i}.gatk.vcf" --sentieon "compare/in_common.${i}.sentieon.vcf" > "compare/call_joiner.${i}"
done
