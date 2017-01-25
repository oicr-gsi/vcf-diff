#!/usr/bin/perl -w

# ================================================================================
# Script of limited use, joins two vcf files into a table for futher analysis in R
# ================================================================================

=head2 SYNOPSIS

 Ideally this script will need vcf files produced with CombineVariants walker. We need
 PRIORITIZE setting used with CombineVariants so that we merge matching variants using
 data from both sources - GATK and Sentieon

=cut

use strict;
use Getopt::Long;
use Data::Dumper;
use constant DEBUG=>0;

my($gatk,$sent);
my $USAGE  = "./call_joiner.pl --gatk [vcf made with gatk] --sentieon [vcf file made with Sentieon]\n";
my $result = GetOptions('gatk=s'          => \$gatk,
                        'sentieon|sent=s' => \$sent); 

($gatk && $sent) or die $USAGE;
my @tools = ("gatk","sentieon");
my @files = ($gatk,$sent);
my %data  = ();
# Read data from files
for (my $t = 0; $t < @tools; $t++) {
 &read_data($tools[$t],$files[$t]); 
}

# Print out the results
print join("\t",qw(Coord Sentieon GATK Type))."\n";
print %data;
foreach my $coord(sort keys %data) {
 foreach my $field('Score','AD1','AD2','DP','GQ') {
   print $coord;
   foreach my $tool(@tools) {
     print "\t".$data{$coord}->{$tool}->{$field};
   }
   print "\t$field\n";
 }
 
}

=head2

 The main function (for reading data)
 we read AD1, AD2, Score, GQ and DP fields

=cut

sub read_data {

 my($tool,$file) = @_;
 my $pipe = "cut -f 1,2,6,10 $file | ";
 open(DATA,"$pipe") or die "Couldn't read from submitted file [$file]";
 while (<DATA>) {
    chomp;
    s/:/\t/g;
    s/,/\t/g;
    s/\t/:/;
    print STDERR "String: ".$_."\n" if DEBUG;
    my @temp = split("\t");
    if (@temp < 7) {next;}
    #if ($temp[0] && $temp[1] && $temp[3] && $temp[4] && $temp[5] && $temp[6]) {
    $data{$temp[0]}->{$tool} = {Score=>$temp[1],
                                AD1  =>$temp[3],
                                AD2  =>$temp[4],
                                DP   =>$temp[5],
                                GQ   =>$temp[6]};
    #}
    print STDERR Dumper(%data) if DEBUG;
    exit if DEBUG;
 }

 close DATA;
}

