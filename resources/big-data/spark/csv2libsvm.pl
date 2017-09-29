#!/usr/bin/perl

use strict;
use warnings;

my $src = shift;	# input csv file
my $cont = shift;	# output vw continuous data
my $disc = shift;	# output vw discrete data

my $block = 1000000;  # progress indicator

# parsing file
#------------------------------------------------------------------------------
open(SRC, "<", $src) or die "could not open $src!";
open(CONT, ">", $cont) or die "could not open $cont!";
open(DISC, ">", $disc) or die "could not open $disc!";

# header
my $headerRow = <SRC>;
chomp($headerRow);
$headerRow =~ s/"//g;      # deleting " for the quote option from importation
my @headerElmt = split(",", $headerRow, -1);

# data
my $count = 1;
while (<SRC>) {
  chomp;
  s/"//g;      # deleting " for the quote option from importation
  my @x = split(",", $_, -1);
  my $rowC = $x[4]." ";
  my $rowD = $x[5]." ";
  if ($x[5] == -1) {
    $rowD = "0 ";
  }
  for (my $col = 0; $col <= 3; $col++) {
    $rowC = $rowC.($col+1).":".$x[$col]." ";
    $rowD = $rowD.($col+1).":".$x[$col]." ";
  }
  print CONT "$rowC\n";
  print DISC "$rowD\n";

  $count++;
  if (($count % $block) == 0) {
    print $count."\n";
  }
}

close(SRC);
close(CONT);
close(DISC);

