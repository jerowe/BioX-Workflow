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

## comment\_char

## coerce\_paths

## select\_rules

Select a subsection of rules

### resample

Boolean value get new samples based on indir/file\_rule or no

Samples are found at the beginning of the workflow, based on the global indir variable and the file\_find.

Chances are you don't want to set resample to try, because these files probably won't exist outside of the indirectory until the pipeline is run.

One example of doing so, shown in the gemini.yml in the examples directory, is looking for uncompressed files, .vcf extension, compressing them, and
then resampling based on the .vcf.gz extension.

## find\_by\_dir

Use this option when you sample names are by directory
The default is to find samples by filename

    /SAMPLE1
        SAMPLE1_r1.fastq.gz
        SAMPLE1_r2.fastq.gz
    /SAMPLE2
        SAMPLE2_r1.fastq.gz
        SAMPLE2_r2.fastq.gz

## by\_sample\_outdir

    outdir/
    /outdir/SAMPLE1
        /rule1
        /rule2
        /rule3
    /outdir/SAMPLE2
        /rule1
        /rule2
        /rule3

Instead of

    /outdir
        /rule1
        /rule2

This feature is not particularly well supported, and may break when mixed with other methods, particularly --resample

### min

Print the workflow as 2 files.

    #run-workflow.sh
    export SAMPLE=sampleN && ./run_things

### number\_rules

    Instead of
    outdir/
        rule1
        rule2

    outdir/
        001-rule1
        002-rule2

### auto\_name

Auto\_name - Create outdirectory based on rulename

global:
    - outdir: /home/user/workflow/processed
rule:
    normalize:
        process:
            dostuff {$self->indir}/{$sample}.in >> {$self->outdir}/$sample.out

Would create your directory structure /home/user/workflow/processed/normalize (if it doesn't exist)

### auto\_input

This is similar to the auto\_name function in the BioX::Workflow.
Instead this says each input should be the previous output.

### verbose

Output some more things

### wait

Print "wait" at the end of each rule

### override\_process

local:
    - override\_process: 1

### indir outdir

### create\_outdir

### INPUT OUTPUT

Special variables that can have input/output

These variables are also used in [BioX::Workflow::Plugin::Drake](https://metacpan.org/pod/BioX::Workflow::Plugin::Drake)

### file\_rule

Rule to find files

### No GetOpt Here

### attr

attributes read in from runtime

### global\_attr

Attributes defined in the global section of the yaml file

### local\_attr

Attributes defined in the rules->rulename->local section of the yaml file

### local\_rule

### infiles

Infiles to be processed

### samples

### process

Do stuff

### key

Do stuff

### workflow

Path to workflow workflow. This must be a YAML file.

### rule\_based

This is the default. The outer loop are the rules, not the samples

### sample\_based

Default Value. The outer loop is samples, not rules. Must be set in your global values or on the command line --sample\_based 1

If you ever have resample: 1 in your config you should NOT set this value to true!

### save\_object\_env

Save object env. This will save all the variables. Useful for debugging, but gets unweildly for larger workflows.

## stash

This isn't ever used in the code. Its just there incase you want to do some things with override\_process

It uses Moose::Meta::Attribute::Native::Trait::Hash and supports all the methods.

        set_stash     => 'set',
        get_stash     => 'get',
        has_no_stash => 'is_empty',
        num_stashs    => 'count',
        delete_stash  => 'delete',
        stash_pairs   => 'kv',

## \_classes

Saves a snapshot of the entire namespace for the initial environment, and each rule.

## Subroutines

Subroutines can also be overriden and/or extended in the usual Moose fashion.

### run

Starting point.

## save\_env

At each rule save the env for debugging purposes.

### make\_outdir

Set initial indir and outdir

### get\_samples

Get basename of the files. Can add optional rules.

sample.vcf.gz and sample.vcf would be sample if the file\_rule is (.vcf)$|(.vcf.gz)$

Also gets the full path to infiles

Instead of doing

    foreach my $sample (@$self->samples){
        dostuff
    }

Could have

    foreach my $infile (@$self->infiles){
        dostuff
    }

## match\_samples

Match samples based on regex written in file\_rule

### plugin\_load

Load plugins defined in yaml with MooseX::Object::Pluggable

### class\_load

Load classes defined in yaml with Class::Load

### make\_template

Make the template for interpolating strings

### create\_attr

make attributes

## check\_keys

There should be one key and one key only!

## clear\_process\_vars

Clear the process vars

## init\_process\_vars

Initialize the process vars

## add\_attr

Add the local attr onto the global attr

## write\_rule\_meta

### write\_process

Fill in the template with the process

### process\_by\_sample\_outdir

Make sure indir/outdirs are named appropriated for samples when using by

### OUTPUT\_to\_INPUT

If we are using auto\_input chain INPUT/OUTPUT

# DESCRIPTION

BioX::Workflow - A very opinionated template based workflow writer.

# AUTHOR

Jillian Rowe &lt;jillian.e.rowe@gmail.com>

# Acknowledgements

Before version 0.03

This module was originally developed at and for Weill Cornell Medical
College in Qatar within ITS Advanced Computing Team. With approval from
WCMC-Q, this information was generalized and put on github, for which
the authors would like to express their gratitude.

As of version 0.03:

This modules continuing development is supported by NYU Abu Dhabi in the Center for Genomics and Systems Biology.
With approval from NYUAD, this information was generalized and put on bitbucket, for which
the authors would like to express their gratitude.

# COPYRIGHT

Copyright 2015- Weill Cornell Medical College in Qatar

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
