#!/usr/bin/env perl
#===============================================================================
#
#         FILE: biox-workflow-drake.pl
#
#        USAGE: ./biox-workflow-drake.pl
#
#  DESCRIPTION: Command line interface to BioX::Wrapper::Workflow::Drake
#
#       AUTHOR: YOUR NAME (),
# ORGANIZATION: Weill Cornell Medical College Qatar
#      VERSION: 1.0
#      CREATED: 06/17/2015 03:45:59 PM
#     REVISION: ---
#===============================================================================


package Main;
use Moose;

extends 'BioX::Wrapper::Workflow::Drake';

Main->new_with_options->run;

1;

