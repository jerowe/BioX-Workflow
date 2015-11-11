# NAME

BioX::Workflow - A very opinionated template based workflow writer.

# SYNOPSIS

Most of the functionality can be accessed through the biox-workflow.pl script.

    biox-workflow.pl --workflow /path/to/workflow.yml

This module was written with Bioinformatics workflows in mind, but should be extensible to any sort of workflow or pipeline.

# Philosophy

Most bioinformatics workflows involve starting with a set of samples, and
processing those samples in one or more steps. Also, most bioinformatics
workflows are bash based, and no one wants to reinvent the wheel to rewrite
their code in perl/python/whatever.

For example with our samples test1.vcf and test2.vcf, we want to bgzip and
annotate using snpeff, and then parse the output using vcf-to-table.pl
(shameless plug for BioX::Wrapper::Annovar).

BioX::Workflow assumes your have a set of inputs, known as samples,
and these inputs will carry on through your pipeline. There are some exceptions
to this, which we will explore with the resample option.

It also makes several assumtions about your output structure. It assumes you
have each of your processes/rules outputting to a distinct directory.

These directories will be created and automatically named based on your process
name. You can disable this and make your own out directories by either
specifiying auto\_name: 1 in your global, in any of the local rules to disable
it for that rule, or by specifying an outdirectory.

# A Simple Example

Here is a very simple example that searches a directory for \*.csv files and creates an outdir /home/user/workflow/output if one doesn't exist.

Create the /home/user/workflow/workflow.yml

    ---
    global:
        - indir: /home/guests/jir2004/workflow
        - outdir: /home/guests/jir2004/workflow/output
        - file_rule: (.csv)$
    rules:
        - backup:
            process: cp {$self->indir}/{$sample}.csv {$self->outdir}/{$sample}.csv
        - grep_VARA:
            process: |
                echo "Working on {$self->{indir}}/{$sample.csv}"
                grep -i "VARA" {$self->indir}/{$sample}.csv >> {$self->outdir}/{$sample}.grep_VARA.csv
        - grep_VARB:
            process: |
                grep -i "VARB" {$self->indir}/{$sample}.grep_VARA.csv >> {$self->outdir}/{$sample}.grep_VARA.grep_VARB.csv

If we step through the whole process

    cd /home/user/workflow

    #Create test1.csv with some lines
    echo "This is VARA" >> test1.csv
    echo "This is VARB" >> test1.csv
    echo "This is VARC" >> test1.csv

    #Create test2.csv with some lines
    echo "This is VARA" >> test2.csv
    echo "This is VARB" >> test2.csv
    echo "This is VARC" >> test2.csv
    echo "This is some data I don't want" >> test2.csv

Run the script to create out directory structure and workflow bash script

    biox-workflow.pl --workflow workflow.yml > workflow.sh

## Look at the directory structure

    /home/user/workflow/
        test1.csv
        test2.csv
        /output
            /backup
            /grep_vara
            /grep_varb

## Run the workflow

Assuming you saved your output to workflow.sh if you run ./workflow.sh you will get the following.

    /home/user/workflow/
        test1.csv
        test2.csv
        /output
            /backup
                test1.csv
                test2.csv
            /grep_vara
                test1.grep_VARA.csv
                test2.grep_VARA.csv
            /grep_varb
                test1.grep_VARA.grep_VARB.csv
                test2.grep_VARA.grep_VARB.csv

## A closer look at workflow.sh

This top part here is the metadata. It tells you the options used to run the script.

    #
    # This file was generated with the following options
    #   --workflow      config.yml
    #

If --verbose is enabled, and it is by default, you'll see some variables printed out for your benefit

    #
    # Variables
    # Indir: /home/user/workflow
    # Outdir: /home/user/workflow/output/backup
    # Samples: test1    test2
    #

Here is out first rule, named backup. As you can see our $self->outdir is automatically named 'backup', relative to the globally defined outdir.

    #
    # Starting backup
    #

    cp /home/user/workflow/test1.csv /home/user/workflow/output/backup/test1.csv
    cp /home/user/workflow/test2.csv /home/user/workflow/output/backup/test2.csv

    wait

    #
    # Ending backup
    #

Notice the 'wait' command. If running your outputted workflow through any of the HPC::Runner scripts, the wait signals to wait until all previous processes have ended before beginning the next one.

For instance, if running this as

    slurmrunner.pl --infile workflow.sh
    #OR
    mcerunner.pl --infile workflow.sh

The "cp blahblahblah" commands would run in parallel, and the next rule would not begin until those processes have finished.

Here is some verbose output for the next rule.

    #
    # Variables
    # Indir: /home/guests/jir2004/workflow/output
    # Outdir: /home/guests/jir2004/workflow/output/grep_vara
    # Samples: test1    test2
    #

And here is the actual work.

    #
    # Starting grep_VARA
    #

    echo "Working on $self->indir/test1csv"
    grep -i "VARA" /home/guests/jir2004/workflow/output/test1.csv >> /home/guests/jir2004/workflow/output/grep_vara/test1.grep_VARA.csv

    echo "Working on $self->indir/test2csv"
    grep -i "VARA" /home/guests/jir2004/workflow/output/test2.csv >> /home/guests/jir2004/workflow/output/grep_vara/test2.grep_VARA.csv

    wait

    #
    # Ending grep_VARA
    #

So on and so forth.

    #
    # Variables
    # Indir: /home/guests/jir2004/workflow/output
    # Outdir: /home/guests/jir2004/workflow/output/grep_varb
    # Samples: test1    test2
    #


    #
    # Starting grep_VARB
    #

    grep -i "VARB" /home/guests/jir2004/workflow/output/test1.csv >> /home/guests/jir2004/workflow/output/grep_varb/test1.grep_VARB.csv

    grep -i "VARB" /home/guests/jir2004/workflow/output/test2.csv >> /home/guests/jir2004/workflow/output/grep_varb/test2.grep_VARB.csv

    wait

    #
    # Ending grep_VARB
    #

    #
    # Workflow Finished
    #

# Customizing your output and special variables

BioX::Workflow uses a few conventions and special variables. As you
probably noticed these are indir, outdir, infiles, and file\_rule. In addition
sample is the currently scoped sample. Infiles is not used by default, but is
simply a store of all the original samples found when the script is first run,
before any processes. In the above example the $self->infiles would evaluate as
\['test1.csv', 'test2.csv'\].

Variables are interpolated using [Interpolation](https://metacpan.org/pod/Interpolation) and [Text::Template](https://metacpan.org/pod/Text::Template). All
variables, unless explictly defined with "$my variable = "stuff"" in your
process key, must be referenced with $self, and surrounded with brackets {}.
Instead of $self->outdir, it should be {$self->outdir}. It is also possible to
define variables with other variables in this way. Everything is referenced
with $self in order to dynamically pass variables to Text::Template. The sample
variable, $sample, is the exception because it is defined in the loop. In
addition you can create an OUTPUT/OUTPUT variables to clean up your process
code.

    ---
    global:
        - ROOT: /home/user/workflow
        - indir: {$self->ROOT}
        - outdir: {$self->indir}/output
    rules:
        - backup:
            local:
                - OUTPUT: {$self->indir}/{$sample}.in
                - OUTPUT: {$self->outdir}/{$sample}.out

Your variables must be defined in an appropriate order.

## Local and Global Variables

Global variables will always be available, but can be overwritten by local
variables contained in your rules.

    ---
    global:
        - indir: /home/user/example-workflow
        - outdir: /home/user/example-workflow/gemini-wrapper
        - file_rule: (.vcf)$|(.vcf.gz)$
        - some_variable: {$self->indir}/file_to_keep_handy
    rules:
        - backup:
            local:
                - ext: "backup"
            process: cp {$self->indir}/{$sample}.csv {$self->outdir}/{$sample}.{$self->ext}.csv

## Rules

Rules are processed in the order they appear.

Before any rules are processed, first the samples are found. These are grepped using File::Basename, the indir, and the file\_rule variable. The
default is to get rid of the everything after the final '.' .

## Overriding Processes

By default your process is evaluated as

    foreach my $sample (@{$self->samples}){
        #Get the value from the process key.
    }

If instead you would like to use the infiles, or some other random process that has nothing to do with your samples, you can override the process
template. Make sure to use the previously defined $OUT. For more information see the [Text::Template](https://metacpan.org/pod/Text::Template) man page.

    rules:
        - backup:
            outdir: {$self->ROOT}/datafiles
            override: 1
            process: |
                $OUT .= wget {$self->some_globally_defined_parameter}
                {
                foreach my $infile (@{$self->infiles}){
                    $OUT .= "dostuff $infile";
                }
                }

## Directory Structure

BioX::Workflow will create a directory structure based on your rule name, decamelized, and your globally defined outdir.

/path/to/outdir
    /rule1
    /rule2
    /rule3

If you don't like this you can globally disable auto\_name (auto\_name: 0), or simply defined indir or outdir within your global variables. If using the
second method it is probably a good idea to also defined a ROOT\_DIR in your global variables.

## Other variables

A quick overview of other samples

### Resampling

I can only think of a few examples where one would want to perform a resample, since the files probably won't exist, but one example is if you want to
check for uncompressed files, compress them, and then carry on with your life.

    ---
    global:
        - indir: /home/user/gemini
        - outdir: /home/user/gemini/gemini-wrapper
        - file_rule: (.vcf)$|(.vcf.gz)$
        - infile:
    rules:
        - bgzip:
            local:
                - file_rule: (.vcf)$
                - resample: 1
            before_meta: bgzip and tabix index uncompressed files
            after_meta: finished bgzip
            process: bgzip {$self->{indir}}/{$sample}.vcf && tabix {$self->{indir}}/{$sample}.vcf.gz
        - normalize_snpeff:
            local:
                - indir: /home/user
                - file_rule: (.vcf.gz)$
                - resample: 1
            process: |
                bcftools view {$self->indir}/{$sample}.vcf.gz | sed 's/ID=AD,Number=./ID=AD,Number=R/' \
                    | vt decompose -s - \
                    | vt normalize -r $REFGENOME - \
                    | java -Xmx4G -jar $SNPEFF/snpEff.jar -c \$SNPEFF/snpEff.config -formatEff -classic GRCh37.75  \
                    | bgzip -c > \
                    {$self->{outdir}}/{$sample}.norm.snpeff.gz && tabix {$self->{outdir}}/{$sample}.norm.snpeff.gz

The bgzip rule would first run a resample looking for only files ending in .vcf, and compress them. The following rule, normalize\_snpeff, looks again
in the indir (which we set here otherwise it would have been the previous rules outdir), and resamples based on the .vcf.gz extension.

# In Code Documenation

You shouldn't really need to look here unless you have some reason to do some serious hacking.

## Attributes

Moose attributes. Technically any of these can be changed, but may break everything.

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

### enforce\_struct

Enforce a particular workflow where the outdirectory (outdir) from the previous rule is the indirectory for the current

### verbose

Output some more things

### wait

Print "wait" at the end of each rule

### override\_process

local:
    - override: 1

### indir outdir

### Input Output

Special variables that can have input/output

### file\_rule

Rule to find files

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

## Subroutines

Subroutines can also be overriden and/or extended in the usual Moose fashion.

### run

Starting point.

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

### load

Load classes defined in yaml with Class::Load

### make\_template

Make the template for interpolating strings

### create\_attr

make attributes

## write\_rule\_meta

### write\_process

Fill in the template with the process

# DESCRIPTION

BioX::Workflow - A very opinionated template based workflow writer.

# AUTHOR

Jillian Rowe &lt;jillian.e.rowe@gmail.com>

# Acknowledgements

This module was originally developed at and for Weill Cornell Medical
College in Qatar within ITS Advanced Computing Team. With approval from
WCMC-Q, this information was generalized and put on github, for which
the authors would like to express their gratitude.

# COPYRIGHT

Copyright 2015- Weill Cornell Medical College in Qatar

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
