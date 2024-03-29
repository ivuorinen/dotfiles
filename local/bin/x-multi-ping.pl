#!/usr/bin/env perl

=head1 NAME

multi-ping - Multi-protocol ping wrapper

=head1 SYNOPSIS

  multi-ping [--loop|--forever] [--sleep=N]  hostname1 hostname2 .. hostnameN

=cut

=head1 DESCRIPTION

This wrapper script will invoke one of 'ping' or 'ping6', as appropriate,
to test the connectivity of a remote host and your route to it.

=cut

=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut

=head1 LICENSE

Copyright (c) 2013-2014 by Steve Kemp.  All rights reserved.

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

The LICENSE file contains the full text of the license.

=cut


use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;


#
#  Check the dependencies.
#
checkSystem();

#
#  Parse the command-line.
#
my %config = parsedOptions();


#
#  We could parse arguments here, for the moment we will hard-wire
# a timeout of five seconds.
#
my $timeout = 5;


#
# If we didn't get any arguments then we should complain.
#
if ( scalar @ARGV < 1 )
{
    print "Usage: multi-ping hostname1 hostname2 .. hostnameN\n";
    exit(1);
}


#
# Process each hostname specified upon the command-line.
#
# Looping if applicable.
#
do
{
    foreach my $host (@ARGV)
    {
        pingHost($host);
    }

    sleep( $config{ 'sleep' } );

} until ( !$config{ 'loop' } );




=begin doc

Given a hostname lookup both the AAAA & A records. For each result
perform the appropriate ping request.

=end doc

=cut

sub pingHost
{
    my ($hostname) = (@_);

    #
    #  If we've been given an URI then we'll remove the leading-scheme
    # and use the hostname only.
    #
    if ( $hostname =~ m!^([a-z]+:\/\/)([^/]+)/?!i )
    {
        $hostname = $2;

        #
        #  Port might be specified too, drop that if present.
        #
        if ( $hostname =~ /^(.*):([0-9]+)$/ )
        {
            $hostname = $1;
        }
    }

    #
    #  Lookup the IP for the name specified
    #
    my $res = Net::DNS::Resolver->new;

    #
    #  The two types we'll lookup.
    #
    #  NOTE: This shouldn't be required but my laptop resolver seems to
    # struggle with lookups of the type "ANY".  Sigh.
    #
    #
    foreach my $type (qw! A AAAA !)
    {
        my $query = $res->query( $hostname, $type );

        if ($query)
        {
            foreach my $rr ( $query->answer )
            {
                my $ping_binary =
                  $rr->type eq "A"    ? "ping" :
                  $rr->type eq "AAAA" ? "ping6" :
                                        "";
                if ($ping_binary)
                {
                    my $result = system(
                        "$ping_binary -c1 -w$timeout -W$timeout $hostname >/dev/null 2>/dev/null"
                    );

                    print "Host $hostname - " . $rr->address() .
                      ( ( $result == 0 ) ? " - alive" : " - FAILED"  ) . "\n";
                }
            }
        }
        else
        {
            print "WARNING: Failed to resolve $hostname [$type]\n";
        }
    }
}



=begin doc

Test that we have the required perl dependencies present.

=end doc

=cut

sub checkSystem
{
    my $eval = "use Net::DNS;";

    ## no critic (Eval)
    eval($eval);
    ## use critic

    #
    #  If we don't have Net::DNS we're out of luck.
    #
    if ($@)
    {
        print "The required Net::DNS module is missing.  Aborting.\n";
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

    #
    # Defaults
    #
    $vars{ 'loop' }  = 0;
    $vars{ 'sleep' } = 1;

    exit
      if (
           !GetOptions( "help"    => \$vars{ 'help' },
                        "verbose" => \$vars{ 'verbose' },
                        "forever" => \$vars{ 'loop' },
                        "loop"    => \$vars{ 'loop' },
                        "sleep=i" => \$vars{ 'sleep' },
                      ) );

    pod2usage(1) if ( $vars{ 'help' } );

    return (%vars);

}

