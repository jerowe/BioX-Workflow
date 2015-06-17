#!/usr/bin/env perl

package Main;

use Moose;
#use Carp::Always;

extends 'BioX::Wrapper::Writer';

Main->new_with_options->run;

1;
