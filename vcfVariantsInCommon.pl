#!/usr/bin/perl

use strict;
use warnings;

my $fileA = $ARGV[0];
my $fileB = $ARGV[1];	# prints from this one

open (FILEA, "$fileA") or die;
open (FILEB, "$fileB") or die;

my %fileAhash;
my $line;
my @fields;

while ($line = <FILEA>)
{
	unless ($line =~ /^#/)
	{
		chomp $line;
		@fields = split(/\t/, $line);

		$fileAhash{"$fields[0]\t$fields[1]\t$fields[3]\t$fields[4]"} = $line;
}
}

while ($line = <FILEB>)
{
	unless ($line =~ /^#/)
	{
		chomp $line;
		@fields = split(/\t/, $line);

		if (exists $fileAhash{"$fields[0]\t$fields[1]\t$fields[3]\t$fields[4]"})
		{
			#print $fileAhash{"$fields[0]\t$fields[1]\t$fields[2]\t$fields[3]"} . "\n";
			print $line . "\n";
		}
	}
}


