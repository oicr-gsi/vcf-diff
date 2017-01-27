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
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;


my($gatk,$sent);
my $USAGE  = "./call_joiner.pl --gatk [vcf made with gatk] --sentieon [vcf file made with Sentieon]\n";
my $result = GetOptions('gatk=s'          => \$gatk,
                        'sentieon|sent=s' => \$sent); 



($gatk && $sent) or die $USAGE;
print "Both files are defined: ".$gatk." and ".$sent."\n" if DEBUG;
my @tools = ("gatk","sentieon");
my @files = ($gatk,$sent);

#secretly a hash reference
my $datas;

# Read data from files
print "Starting to read data\n" if DEBUG;
for (my $t = 0; $t < @tools; $t++) {
 my $cur_tool=$tools[$t];
 my $temphash=&read_data($cur_tool,$files[$t]);
 
 while( my ($chrompos, $toolhash) = each %$temphash ) {
  $datas->{$chrompos}->{$cur_tool}=$temphash->{$chrompos}->{$cur_tool};
 }

}

# Print out the results
print join("\t",qw(Coord Sentieon GATK Type))."\n";

my @coord_sorted = sort keys %$datas;
foreach my $coord(@coord_sorted) {

 #assumption here is that the first tool in list has all fields we're interested in
 my ( $t, $f_ref ) = each %$datas->{$coord};

 foreach my $field( sort keys %$f_ref) {
   print $coord;
   foreach my $tool(@tools) {
    if (exists($datas->{$coord}->{$tool})) {
     print "\t".$datas->{$coord}->{$tool}->{$field};
    } 
    else { print "\t"; }
  }
  print "\t$field\n";
 }
}

=head2

 The main function (for reading data)
 we read AD1, AD2, Score, GQ and DP fields

=cut

sub read_data 
{
 my($tool,$file) = @_;
 my $DATA;
 my $data;
 print "Filename: ".$file."\n" if DEBUG;
 if($file =~ m/\.gz$/i)
 {
    $DATA = new IO::Uncompress::Gunzip $file
        or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
    print "Zipped: ".$DATA."\n" if DEBUG;
    $data=&extract_info($tool,$DATA);
 }
 else
 {
    $DATA = IO::File->new($file)
        or die "Couldn't read from submitted file [$file]";
    print "Not zipped: ".$DATA."\n" if DEBUG;
    $data=&extract_info($tool,$DATA);
 }
 return $data;
}

sub extract_info 
{

 my($tool,$file) = @_;
 my $data;
 while (my $line = <$file>)
 {
    chomp $line;
    my @columns = split (/\t/, $line);
    if (@columns < 10 || $columns[0] =~ m/#CHROM/ ) {next;}
    #cutting out the CHROM, POS, QUAL, FORMAT, and sample genotype columns
    my ($chrompos, $qual, $format, $genotype) = ($columns[0].":".$columns[1],$columns[5],$columns[8],$columns[9]);
    #returns hash reference
    my $genotype_hash=&find_info_headings($format,$genotype);
    $data->{$chrompos}->{$tool} = $genotype_hash;
    $data->{$chrompos}->{$tool}->{'Qual'}=$qual;
 }
 #print Dumper(\$data);
 return $data;
}

sub find_info_headings
{
  my($format,$genotype) = @_;
  my @headings = ("AD","DP","GQ","GT","PL");

  my %heads=();
  my @fo_col = split(/:/,$format);
  my @ge_col = split(/:/,$genotype);
 
  #iterate through the format column and pull out the desired headings 
  for (my $i=0; $i<@fo_col; $i++ )
  {
   my ($fo, $ge) = ($fo_col[$i], $ge_col[$i]);
   foreach (@headings)
   {
    if (m/$fo/i)
    {
     
     #if the field has a , | or / as a separator, record them separately
     if ($ge =~ m/[,\/|]{1}/)
     {
      my @tings=split(/[,\/|]{1}/,$ge);
      for (my $j=1; $j<=@tings; $j++)
      {
       $heads{$fo.$j}=$tings[($j-1)];
      }
      
     }
     else
     {
       $heads{$fo}=$ge;
     }
    }
   }
  }

  return \%heads;
}

