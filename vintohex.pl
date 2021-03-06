#!/usr/bin/perl -w

#    Copyright (c) 2012, 2013, 2014 p0lar @ m3forum.net
#
#    Redistribution and use in source and binary forms, with or without
#    modification, are permitted provided that the following conditions
#    are met:
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#    3. All advertising materials mentioning features or use of this software
#       must display the following acknowledgement:
#	This product includes software developed by p0lar @ m3forum.net and its
#       contributors
#    4. Neither the name of p0lar @ m3forum.net nor the names of its
#       contributors may be used to endorse or promote products derived from
#       this software without specific prior written permission.
#
#    THIS SOFTWARE IS PROVIDED BY P0LAR @ M3FORUM.NET AND CONTRIBUTORS ``AS IS''
#    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#    ARE DISCLAIMED.  IN NO EVENT SHALL P0LAR @ M3FORUM.NET OR CONTRIBUTORS BE
#    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#    POSSIBILITY OF SUCH DAMAGE.
#
#    NO WARRANTY
#
#    BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
#    FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
#    OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
#    PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
#    OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#    MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
#    TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
#    PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
#    REPAIR OR CORRECTION.
#
#    IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
#    WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
#    REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
#    INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
#    OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
#    TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
#    YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
#    PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
#    POSSIBILITY OF SUCH DAMAGES.
#

use strict;
use bigint;
use Getopt::Long;

use constant {
  DEBUG   => 0,
  HELP    => 0,
  PROGRAM => 'vincoder',
  VERSION => 'v0.1.1',
};

my %config;

# handle command line options
&GetOptions(
  'help|?|h'  => \$config{'help'},
  'vin|v=s'   => \$config{'VIN_input'},
  'bin|b=s'   => \$config{'BIN_input'},
  'debug|d'   => \$config{'debug'},
  'version'   => \$config{'displayVersion'},
);

# Display version or usage information if requested (or implicitly)
&usage if ($config{'help'});
&usage unless (defined($config{'VIN_input'}) || defined($config{'BIN_input'}));
&version if (defined($config{'displayVersion'}));

my (%charArr, %numArr);

# generate character array
for my $i (0..9, "A".."Z") { $charArr{$i} = keys(%charArr) }

# handle VIN -> binary/hexadecimal
if (defined($config{'VIN_input'})) {
  die ("Wrong length to be text VIN.\n") unless (length($config{'VIN_input'}) == 17);
  die ("Improper characters in VIN.\n") unless ($config{'VIN_input'} =~ /^[0-9A-HJ-NPR-Z]{17}$/i);
  print (uc($config{'VIN_input'}) . ' -> ' . &formathex(uc(&VINtoHex($config{'VIN_input'})->as_hex)) . "\n");
}

# handle binary/hexadecimal -> VIN
if (defined($config{'BIN_input'})) {
  $config{'BIN_input'} =~ s/\s+//g;
  die ("Wrong length to be decimal or hexadecimal VIN.\n") unless (length($config{'BIN_input'}) == 13 || 26);
  die ("Improper hexadecimal characters.\n") unless ($config{'BIN_input'} =~ /^[0-9A-F]{26}$/i);
  print (&formathex(uc($config{'BIN_input'})) . ' -> ' . &hexToVIN('0x' . $config{'BIN_input'}) . "\n");
}

#----------------------------
# SUBROUTINES               |
#----------------------------

# simple usage/syntax
sub usage {
  print("\nUsage: " . PROGRAM . " --vin={VIN} --bin={BINARY/HEX} --help --version\n\n");
  exit (1);
}

# display version, then exit.
sub version {
  print (PROGRAM . ' ' . VERSION . "\n");
  exit (0);
}

# simple debug function
sub debug ($) {
  print (@_) if $config{'debug'};
}

# Make the hex output more readable
sub formathex($) {
  my $hexStr = shift();
  my $formatted;
  foreach (my $key = 0; $key < length($hexStr); $key++) {
    $formatted .= (substr($hexStr, $key, 2) . ' ') unless ($key % 2);
  }
  $formatted =~ s/^0x//ig;
  return ($formatted);
}

sub VINtoHex ($) {
  my $VIN = shift();
  my $hex;
  for (my $i = 1; $i <= length($VIN); $i++) {
    $hex += $charArr{substr(uc($VIN), -$i, 1)} * 0x40**($i-1);
  }
  return ($hex);
}

sub hexToVIN ($) {
  my $hex = shift();
  my $VIN;
  my %numArr = reverse(%charArr);
  for (my $i = 0x10; $i >= 0; $i--) {
    my $j = $hex / 0x40**($i);
    $hex -= $j * 0x40**($i);
    $VIN .= ($numArr{$j});
  }
  return (uc($VIN));
}