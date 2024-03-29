#!/usr/bin/env perl

=head1 NAME

dupes - Report on files with duplicate contents, via SHA1 hash.

=cut

=head1 SYNOPSIS

  dupes [options] directory

  General Options:

   --help      Show the help information for this script.
   --verbose   Show useful debugging information.

=cut


=head1 ABOUT

dupes is a simple script to report upon files that are identical,
recursively.

The process involves calculating the SHA1 hash of the file contents
and reporting on anything collisions we see.

Note that a collision might be caused by a symbolic link, or hardlink,
so blindly deleting duplicates without investigation is almost certainly
a mistake.

=cut

=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut


=head1 LICENSE

Copyright (c) 2013 by Steve Kemp.  All rights reserved.

This script is free software;you can redistribute it and/or modify it under
the same terms as Perl itself.

The LICENSE file contains the full text of the license.

=cut



use strict;
use warnings;

use File::Find;
use Getopt::Long;
use Pod::Usage;


#
#  Parse the arguments
#
my %config = parsedOptions();


#
#  The path to examine.
#
my $path = $ARGV[0] || '.';


#
#  Get the hashing object, dynamically.
#
my $ctx = getHashObject();
my %digest;


#
#  Find files and store the hash of their contents.
#
find( {
       'wanted' => sub {
           if ( -f $_ )
           {
               lstat;
               if ( ( -r _ ) && ( !-l _ ) )
               {
                   $ctx->reset;
                   $ctx->addfile($_);
                   my $md5 = $ctx->hexdigest;
                   if ( exists $digest{ $md5 } )
                   {
                       push @{ $digest{ $md5 }->{ 'dupes' } }, $_;
                   }
                   else
                   {
                       $digest{ $md5 } = { 'file'  => $_,
                                           'dupes' => [] };
                   }
               }
           }
           else
           {
               $config{ 'verbose' } && print "Entering $_\n";
           }
       },
       'no_chdir' => 1
    },
    $path
    );


#
#  Report upon collisions.
#
foreach my $hash ( keys %digest )
{
    my $dupes = $digest{ $hash }->{ 'dupes' };
    my $src   = $digest{ $hash }->{ 'file' };

    if (@$dupes)
    {
        print $src . "\n";
        foreach my $dupe (@$dupes)
        {
            print "\t$dupe\n";
        }
    }
}


#
#  All done.
#
exit(0);


=begin doc

Load one of M<Digest::SHA> and M<Digest::SHA1>, depending on what is available.

=end doc

=cut

sub getHashObject
{
    my $hash = undef;

    foreach my $module (qw! Digest::SHA Digest::SHA1 !)
    {

        # If we succeeded in calculating the hash we're done.
        next if ( defined($hash) );

        # Attempt to load the module
        my $eval = "use $module;";

        ## no critic (Eval)
        eval($eval);
        ## use critic

        if ( !$@ )
        {
            $hash = $module->new;
        }

    }

    if ($hash)
    {
        return ($hash);
    }
    else
    {
        print "Failed to load either DIgest::SHA or Digest::SHA1\n";
        exit(1);
    }
}

=begin doc

Parse the options and return suitable values.

=end doc

=cut

sub parsedOptions
{
    my %vars;

    exit
      if (
           !GetOptions( "help"    => \$vars{ 'help' },
                        "verbose" => \$vars{ 'verbose' } ) );

    pod2usage(1) if ( $vars{ 'help' } );

    return (%vars);

}

