# NAME

BioX::Workflow - A very opinionated template based workflow writer.

# SYNOPSIS

Most of the functionality can be accessed through the biox-workflow.pl script.

    biox-workflow.pl --workflow /path/to/workflow.yml

This module was written with Bioinformatics workflows in mind, but should be extensible to any sort of workflow or pipeline.

# Usage

Please check out the full Usage Docs at [BioX::Workflow::Usage](https://metacpan.org/pod/BioX::Workflow::Usage)

# In Code Documenation

You shouldn't really need to look here unless you have some reason to do some serious hacking.

## Attributes

Moose attributes. Technically any of these can be changed, but may break everything.

### comment\_char

This should really be in BioX::Wrapper

### workflow

Path to workflow workflow. This must be a YAML file.

### rule\_based

This is the default. The outer loop are the rules, not the samples

### sample\_based

Default Value. The outer loop is samples, not rules. Must be set in your global values or on the command line --sample\_based 1

If you ever have resample: 1 in your config you should NOT set this value to true!

## stash

This isn't ever used in the code. Its just there incase you want to persist objects across rules

It uses Moose::Meta::Attribute::Native::Trait::Hash and supports all the methods.

        set_stash     => 'set',
        get_stash     => 'get',
        has_no_stash => 'is_empty',
        num_stashs    => 'count',
        delete_stash  => 'delete',
        stash_pairs   => 'kv',

## plugins

Load plugins as an opt

### No GetOpt Here

### attr

attributes read in from runtime

### global\_attr

Attributes defined in the global section of the yaml file

### local\_attr

Attributes defined in the rules->rulename->local section of the yaml file

### local\_rule

### process

Our bash string

    bowtie2 -p 12 -I {$sample}.fastq -O {$sample}.bam

### key

Name of the rule

### pkey

Name of the previous rule

## Subroutines

Subroutines can also be overriden and/or extended in the usual Moose fashion.

### run

Starting point.

### init\_things

Load the workflow, additional classes, and plugins

Initialize the global\_attr, make the global outdir, and find samples

## workflow\_load

use Config::Any to load configuration files - yaml, json, etc

### plugin\_load

Load plugins defined in yaml or on command line with --plugins with MooseX::Object::Pluggable

### class\_load

Load classes defined in yaml with Class::Load

### make\_template

Make the template for interpolating strings

## init\_global\_attr

Add our global key from config file to the global\_attr, and then to attr

Deprecated: set\_global\_yaml

### create\_attr

Add attributes to $self-> namespace

### eval\_attr

Evaluate the keys for variables using Text::Template
{$sample} -> SampleA
{$self->indir} -> data/raw (or the indir of the rule)

If variables are themselves hashes/array refs, leave them alone

## clear\_attr

After each rule is processe clear the $self->attr

## check\_keys

There should be one key and one key only!

## clear\_process\_attr

Clear the process attr

Deprecated: clear\_process\_vars

## init\_process\_vars

Initialize the process vars

## add\_attr

Add the local attr onto the global attr

# DESCRIPTION

BioX::Workflow - A very opinionated template based workflow writer.

# AUTHOR

Jillian Rowe <jillian.e.rowe@gmail.com>

# Acknowledgements

Before version 0.03

This module was originally developed at and for Weill Cornell Medical
College in Qatar within ITS Advanced Computing Team. With approval from
WCMC-Q, this information was generalized and put on github, for which
the authors would like to express their gratitude.

As of version 0.03:

This modules continuing development is supported
by NYU Abu Dhabi in the Center for Genomics and
Systems Biology. With approval from NYUAD, this
information was generalized and put on bitbucket,
for which the authors would like to express their
gratitude.

# COPYRIGHT

Copyright 2015- Weill Cornell Medical College in Qatar

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
