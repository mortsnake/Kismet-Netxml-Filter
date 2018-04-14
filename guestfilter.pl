#!/usr/bin/perl

use strict;
use v5.10.1;
use Tie::File;

#sets some important vars
my ($filepath, $isguest;
my $filelinenum = 0;

#reads where the file to filter is
if (!@ARGV){
  print "Enter file path to filter: ";
  chomp($filepath = <STDIN>);
}else{
  $filepath = $ARGV[0];
}

#opens the file to filter
tie my @file, 'Tie::File', $filepath or die "Error: $!";

#an array of common public/free network names to filter out
my @guests = ('xfinitywifi', 'wireless ypsi', 'guest', \
  'public', 'Public', 'free', 'open');
my $found = 0;

foreach my $line (@file){
  #i want to search only unencrypted networks
  if ($line =~ /<encryption>None<\/encryption>/){
    for (my $i = 0; $i < scalar @guests; $i++){
      #checks for a match in the array for each network, case insensitive
      #then writes out to terminal any non-guest
      if ($file[$filelinenum+1] =~ /$guests[$i]/i){
        $isguest = 1;
      }else{
        $isguest = 0;
      }
      if ($isguest == 1){
        last;
      }
    }
    if ($isguest == 0){
      say $file[$filelinenum+1];
      $found++;
    }
  }
  $filelinenum++;
}

say "Total count of non-guest networks: $found";
