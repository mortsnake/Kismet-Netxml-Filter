#!/usr/bin/perl

use strict;
use diagnostics;
use v5.10.1;
use Tie::File;

#sets some important vars
my ($filepath, $fileout);
my $filelinenum = 0;
my $curlinenum = 0;
my @bssids;
my %dupe;
my $starttime = time();

#reads where the file to filter is
if (!@ARGV){
  print "Enter file path to filter: ";
  chomp($filepath = <STDIN>);
  print "Enter output filename: ";
  chomp($fileout = <STDIN>);
}elsif (scalar @ARGV == 1){
  $filepath = $ARGV[0];
  print "Enter output filename: ";
  chomp($fileout = <STDIN>);
}else{
  $filepath = $ARGV[0];
  $fileout = $ARGV[1];
}

#tie::file acts much like 'open' but has the ability to go to specific line #s
tie my @tiefile, 'Tie::File', $filepath or die "Error: $!";

#we will write out the filtered results to this text doc in the same folder as our script
open (my $results, '>', $fileout);

#debugging
#say "Path is: $filepath";

#reads each line from our file, then matches for Beacon regex which is what I want to look at
#increments $filelinenum each time it runs through to keep track of line numbers
#there might be an easier way to do this but idk
foreach my $line (@tiefile){
  #debugging/feature?
  say "Read line $filelinenum";

  #matches regex
  if ($line =~ /\<type\>Beacon\<\/type\>/ || $line =~ /\<type\>Probe Response\<\/type\>/){
    #debugging
    #say "$filelinenum has a matching regex";

    #need to determine how many lines until the <BSSID> line (last line i care about)
    #im sure there's an easier way but this works
    my $bssidcount = 0;
    my $bssidline;
    do{
      $bssidline = $tiefile[$filelinenum+$bssidcount];
      $bssidcount++;
    }until($bssidline =~ /\<BSSID\>.*?\<\/BSSID\>/);

    #$i is $filelinenum - 1 to grab the first line (<type>Beacon</type>)
    for (my $i = 0; $i < $bssidcount; $i++){
      #debugging
      #say "Inside for loop line $curlinenum";
      #commented text below hopefully would print the text to our results file
      print $results ($tiefile[$filelinenum+$i], "\n");
    }
    #gives each entry a nice separator
    print $results "********************\n";
  }
  $filelinenum++;
}

#we finish writing out to FilterResultsX, so we close it but then we
#will run some tests on it
close $results;

print "Wold you like to check for duplicate BSSIDs? ([y]/n) ";
chomp(my $yn = <STDIN>);
my $dupes = 0;

if ($yn eq 'y' || $yn eq ''){
  tie my @restests, 'Tie::File', $fileout or die "Error: $!";
  foreach my $line (@restests){
    if ($line =~ /\<BSSID\>(.*)\<\/BSSID\>/){
      push @bssids, $1;
    }
  }
  foreach my $line (@bssids){
    next unless $dupe{$line}++;
    print "$line is a duplicate BSSID!\n";
    $dupes++;
  }
  my $endtime = time();
  print "Read $filelinenum lines in ", $endtime - $starttime, " seconds with $dupes duplicate entries and output data \nto $fileout\n";
}else{
  my $endtime = time();
  print "Read $filelinenum lines in ", $endtime - $starttime, " seconds with $dupes duplicate entries and output data \nto $fileout\n";
}
