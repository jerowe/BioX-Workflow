package BioX::Workflow;

use 5.008_005;
our $VERSION = '0.12';

use Moose;
use File::Find::Rule;
use File::Basename;
use File::Path qw(make_path remove_tree);
use Cwd;
use Data::Dumper;
use List::Compare;
use YAML::XS 'LoadFile';
use String::CamelCase qw(camelize decamelize wordsplit);
use Data::Dumper;
use Class::Load ':all';
use IO::File;
use Interpolation E => 'eval';
use Text::Template qw(fill_in_file fill_in_string);
use Data::Pairs;

use Carp::Always;

extends 'BioX::Wrapper';
with 'MooseX::Getopt::Usage';
with 'MooseX::Getopt::Usage::Role::Man';
with 'MooseX::SimpleConfig';

with 'MooseX::Object::Pluggable';


# For pretty man pages!
$ENV{TERM}='xterm-256color';

=encoding utf-7

=head1 NAME

BioX::Workflow - A very opinionated template based workflow writer.

=head1 SYNOPSIS

Most of the functionality can be accessed through the biox-workflow.pl script.

    biox-workflow.pl --workflow /path/to/workflow.yml

This module was written with Bioinformatics workflows in mind, but should be extensible to any sort of workflow or pipeline.

=head1 Philosophy

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

It also makes several assumptions about your output structure. It assumes you
have each of your processes/rules outputting to a distinct directory.

These directories will be created and automatically named based on your process
name. You can disable this and make your own out directories by either
specifiying auto_name: 0 in your global, in any of the local rules to disable
it for that rule, or by specifying an outdirectory.

=head1 A Simple Example

Here is a very simple example that searches a directory for *.csv files and creates an outdir /home/user/workflow/output if one doesn't exist.

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

=head2 Look at the directory structure

    /home/user/workflow/
        test1.csv
        test2.csv
        /output
            /backup
            /grep_vara
            /grep_varb

=head2 Run the workflow

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


=head2 A closer look at workflow.sh

This top part here is the metadata. It tells you the options used to run the script.

    #
    # This file was generated with the following options
    #	--workflow	config.yml
    #

If --verbose is enabled, and it is by default, you'll see some variables printed out for your benefit

    #
    # Variables
    # Indir: /home/user/workflow
    # Outdir: /home/user/workflow/output/backup
    # Samples: test1	test2
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
    # Samples: test1	test2
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
    # Samples: test1	test2
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

=head2 Finding your Samples

Finding samples is the most crucial step of the workflow. If no samples are found, nothing is done.

Normally, samples are files.

    /path/to/indir
        sample1.vcf
        sample2.vcf
        sample3.vcf

But sometimes samples are directories.

    /path/to/indir
        /sample1
            billions_of_small_files
            from_the_Sequencer
        /sample2
            billions_of_small_files
            from_the_Sequencer

If this is the case with your workflow, please specify find_by_dir=>1.

=head1 Customizing your output and special variables

BioX::Workflow uses a few conventions and special variables. As you
probably noticed these are indir, outdir, infiles, and file_rule. In addition
sample is the currently scoped sample. Infiles is not used by default, but is
simply a store of all the original samples found when the script is first run,
before any processes. In the above example the $self->infiles would evaluate as
['test1.csv', 'test2.csv'].

Variables are interpolated using L<Interpolation> and L<Text::Template>. All
variables, unless explictly defined with "$my variable = "stuff"" in your
process key, must be referenced with $self, and surrounded with brackets {}.
Instead of $self->outdir, it should be {$self->outdir}. It is also possible to
define variables with other variables in this way. Everything is referenced
with $self in order to dynamically pass variables to Text::Template. The sample
variable, $sample, is the exception because it is defined in the loop. In
addition you can create an OUTPUT/OUTPUT variables to clean up your process
code. These are special variables that are also used in Drake. Please see L<BioX::Workflow::Plugin::Drake>
for more details.

    ---
    global:
        - ROOT: /home/user/workflow
        - indir: {$self->ROOT}
        - outdir: {$self->indir}/output
    rules:
        - backup:
            local:
                - INPUT: {$self->indir}/{$sample}.in
                - OUTPUT: {$self->outdir}/{$sample}.out

Your variables must be defined in an appropriate order.

=head2 Local and Global Variables

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

=head2 Rules

Rules are processed in the order they appear.

Before any rules are processed, first the samples are found. These are grepped using File::Basename, the indir, and the file_rule variable. The
default is to get rid of the everything after the final '.' .

=head2 Overriding Processes

By default your process is evaluated as

    foreach my $sample (@{$self->samples}){
        #Get the value from the process key.
    }

If instead you would like to use the infiles, or some other random process that has nothing to do with your samples, you can override the process
template. Make sure to use the previously defined $OUT. For more information see the L<Text::Template> man page.

    rules:
        - backup:
            outdir: {$self->ROOT}/datafiles
            override_process: 1
            process: |
                $OUT .= wget {$self->some_globally_defined_parameter}
                {
                foreach my $infile (@{$self->infiles}){
                    $OUT .= "dostuff $infile";
                }
                }



=head2 Directory Structure

BioX::Workflow will create a directory structure based on your rule name, and your globally defined outdir.

=head3 Default Structure

/path/to/outdir
    /rule1
    /rule2
    /rule3

If you don't like this you can globally disable auto_name (auto_name: 0), or simply defined indir or outdir within your global variables. If using the
second method it is probably a good idea to also defined a ROOT_DIR in your global variables.

=head3 By Sample Directory Structure

Alternately you can create a directory structure that separates your rules into sample directories with by_sample_outdir=1

/path/to/outdir
    SAMPLE1/
        /rule1
        /rule2
        /rule3
    SAMPLE2/
        /rule1
        /rule2
        /rule3

=head2 Other variables

A quick overview of other samples

=head3 Resampling

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

The bgzip rule would first run a resample looking for only files ending in .vcf, and compress them. The following rule, normalize_snpeff, looks again
in the indir (which we set here otherwise it would have been the previous rules outdir), and resamples based on the .vcf.gz extension.

=head2 Plugins

As of 0.10 there is a plugin system using L<MooseX::Object::Pluggable>

    ---
    plugins:
        - FileDetails
    global:
        - indir: /home/user/gemini
        - outdir: /home/user/gemini/gemini-wrapper
        - file_rule: (.vcf)$|(.vcf.gz)$
        - infile:
    #So On and So Forth

BioX::Workflow::Drake has been moved to BioX::Workflow::Plugin Drake. Instead of using

biox-workflow-drake.pl --THINGS

Instead add 'Drake' to your plugins list in your workflow file.

=head3 Drake Plugin

Drake is a 'make for data.' More information about it can be found here:
L<https://github.com/Factual/drake> and the module can be found at L<BioX::Workflow::Plugin::Drake>.

=head3 FileDetails Plugin

BioX::Workflow will optionally put some commands at the end of your workflow to check files for
metadata: MD5, DateTime created, last accessed, last modified, size, and human readable size.

It creates a structure {$self->outdir}/meta/file.meta. The output structure will probably be changed in the future.

For more information please see L<BioX::Workflow::Plugin::FileDetails>

=head1 In Code Documenation

You shouldn't really need to look here unless you have some reason to do some serious hacking.

=head2 Attributes

Moose attributes. Technically any of these can be changed, but may break everything.

=head3 resample

Boolean value get new samples based on indir/file_rule or no

Samples are found at the beginning of the workflow, based on the global indir variable and the file_find.

Chances are you don't want to set resample to try, because these files probably won't exist outside of the indirectory until the pipeline is run.

One example of doing so, shown in the gemini.yml in the examples directory, is looking for uncompressed files, .vcf extension, compressing them, and
then resampling based on the .vcf.gz extension.

=cut

has 'resample' => (
    traits  => [ 'NoGetopt'  ],
    is => 'rw',
    isa => 'Bool',
    default => 0,
    predicate => 'has_resample',
    clearer => 'clear_resample',
);

=head2 find_by_dir

Use this option when you sample names are by directory
The default is to find samples by filename

    /SAMPLE1
        SAMPLE1_r1.fastq.gz
        SAMPLE1_r2.fastq.gz
    /SAMPLE2
        SAMPLE2_r1.fastq.gz
        SAMPLE2_r2.fastq.gz

=cut

has 'find_by_dir' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
    documentation => q{Use this option when you sample names are directories},
);

=head2 by_sample_outdir

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

=cut

has 'by_sample_outdir' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
    documentation => q{When you want your output by sample},
);

=head3 auto_name

Auto_name - Create outdirectory based on rulename

global:
    - outdir: /home/user/workflow/processed
rule:
    normalize:
        process:
            dostuff {$self->indir}/{$sample}.in >> {$self->outdir}/$sample.out

Would create your directory structure /home/user/workflow/processed/normalize (if it doesn't exist)

=cut

has 'auto_name' => (
     is => 'rw',
     isa => 'Bool',
     default => 1,
);

=head3 auto_input

This is similar to the auto_name function in the BioX::Workflow.
Instead this says each input should be the previous output.

=cut

has 'auto_input' => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);

=head3 enforce_struct

Enforce a particular workflow where the outdirectory (outdir) from the previous rule is the indirectory for the current

=cut

has 'enforce_struct' => (
     is => 'rw',
     isa => 'Bool',
     default => 1,
);

=head3 verbose

Output some more things

=cut

has 'verbose' => (
     is => 'rw',
     isa => 'Bool',
     default => 1,
);

=head3 wait

Print "wait" at the end of each rule

=cut

has 'wait' => (
     is => 'rw',
     isa => 'Bool',
     default => 1,
     documentation => q(Print 'wait' at the end of each rule. If you are running as a plain bash script you probably don't need this.)
);


=head3 override_process

local:
    - override_process: 1

=cut

has 'override_process' => (
    traits  => ['Bool'],
    is => 'rw',
    isa => 'Bool',
    default => 0,
    predicate => 'has_override_process',
    documentation => q(Instead of for my $sample (@sample){ DO STUFF } just DOSTUFF),
    handles => {
        set_override_process => 'set',
        clear_override_process => 'unset',
    },
);

=head3 indir outdir

=cut

has 'indir'  => (
    is => 'rw',
    isa => 'Str',
    default => sub {getcwd();},
    predicate => 'has_indir',
    clearer => 'clear_indir',
    documentation => q(Directory to look for samples),
);

has 'outdir'  => (
    is => 'rw',
    isa => 'Str',
    default => sub {getcwd();},
    predicate => 'has_outdir',
    clearer => 'clear_outdir',
    documentation => q(Output directories for rules and processes),
);

=head3 create_outdir

=cut

has 'create_outdir' => (
    is => 'rw',
    isa => 'Bool',
    predicate => 'has_create_outdir',
    clearer => 'clear_create_outdir',
    documentation => q(Create the outdir. You may want to turn this off if doing a rule that doesn't write anything, such as checking if files exist),
    default => 1,
);

=head3 INPUT OUTPUT

Special variables that can have input/output

These variables are also used in L<BioX::Workflow::Plugin::Drake>

=cut

has 'OUTPUT' =>(
    is => 'rw',
    isa => 'Str|Undef',
    predicate => 'has_OUTPUT',
    clearer => 'clear_OUTPUT',
    documentation => q(Maybe clean up your code some. At the end of each process the OUTPUT becomes
    the INPUT. Best when putting a single file through a stream of processes.)
);

has 'INPUT' =>(
    is => 'rw',
    isa => 'Str|Undef',
    predicate => 'has_INPUT',
    clearer => 'clear_INPUT',
    documentation => q(See $OUTPUT)
);

=head3 file_rule

Rule to find files

=cut

has 'file_rule' =>(
     is => 'rw',
     isa => 'Str',
     default => sub { return "\\.[^.]*"; }
);

=head3 No GetOpt Here

=cut

has 'yaml' => (
    traits  => [ 'NoGetopt'  ],
    is => 'rw',
);

=head3 attr

attributes read in from runtime

=cut

has 'attr' => (
    traits  => [ 'NoGetopt'  ],
    is => 'rw',
    isa => 'Data::Pairs',
);

=head3 global_attr

Attributes defined in the global section of the yaml file

=cut

has 'global_attr' => (
    traits  => [ 'NoGetopt'  ],
    is => 'rw',
    isa => 'Data::Pairs',
);

=head3 local_attr

Attributes defined in the rules->rulename->local section of the yaml file

=cut

has 'local_attr' => (
    traits  => [ 'NoGetopt'  ],
    is => 'rw',
    isa => 'Data::Pairs',
);

=head3 local_rule

=cut

has 'local_rule' => (
    traits  => [ 'NoGetopt'  ],
    is => 'rw',
    isa => 'HashRef'
);

=head3 infiles

Infiles to be processed

=cut

has 'infiles' => (
    traits  => [ 'NoGetopt'  ],
     is => 'rw',
     isa => 'ArrayRef',
);

=head3 samples

=cut

has 'samples' => (
     is => 'rw',
     isa => 'ArrayRef',
);

=head3 process

Do stuff

=cut

has 'process' => (
    traits  => [ 'NoGetopt'  ],
    is => 'rw',
    isa => 'Str',
);

=head3 key

Do stuff

=cut

has 'key' => (
    traits  => [ 'NoGetopt'  ],
    is => 'rw',
    isa => 'Str',
);

=head3 workflow

Path to workflow workflow. This must be a YAML file.

=cut

has 'workflow' => (
     is => 'rw',
     isa => 'Str',
     required => 1,
);

=head3 rule_based

This is the default. The outer loop are the rules, not the samples

=cut

has 'rule_based' => (
     is => 'rw',
     isa => 'Bool',
     default => 1,
);

=head3 sample_based

Default Value. The outer loop is samples, not rules. Must be set in your global values or on the command line --sample_based 1

If you ever have resample: 1 in your config you should NOT set this value to true!

=cut

has 'sample_based' => (
     is => 'rw',
     isa => 'Bool',
     default => 0,
);


=head2 Subroutines

Subroutines can also be overriden and/or extended in the usual Moose fashion.

=head3 run

Starting point.

=cut

sub run {
    my($self) = shift;

    print "#!/bin/bash\n\n";

    $self->print_opts;

    my $array =  LoadFile($self->workflow);

    $self->yaml($array);

    $self->class_load;
    $self->plugin_load;

    $self->global_attr(Data::Pairs->new($array->{global}));

    $self->attr($self->global_attr);

    $self->create_attr;
    $self->eval_attr;

    $self->make_outdir;

    $self->get_samples;

    if($self->verbose){
        print "$self->{comment_char}\n";
        print "$self->{comment_char} Starting Workflow\n";
        print "$self->{comment_char}\n";
    }

    $self->write_pipeline;

    if($self->verbose){
        print "$self->{comment_char}\n";
        print "$self->{comment_char} Ending Workflow\n";
        print "$self->{comment_char}\n";
    }
}

=head3 make_outdir

Set initial indir and outdir

=cut

sub make_outdir {
    my($self) = @_;

    return unless $self->create_outdir;

    make_path($self->outdir) if ! -d $self->outdir;
}

=head3 get_samples

Get basename of the files. Can add optional rules.

sample.vcf.gz and sample.vcf would be sample if the file_rule is (.vcf)$|(.vcf.gz)$

Also gets the full path to infiles

Instead of doing

    foreach my $sample (@$self->samples){
        dostuff
    }

Could have

    foreach my $infile (@$self->infiles){
        dostuff
    }

=cut

sub get_samples{
    my($self) = shift;
    my(@whole, @basename, $text);

    return if $self->attr->exists('samples');

    $text = $self->file_rule;

    if($self->find_by_dir){
        @whole = find(directory => name => qr/$text/, maxdepth => 1, in => $self->indir);
        @basename = map {  basename($_) }  @whole ;
    }
    else{
                $DB::single=2;
        @whole = find(file => name => qr/$text/, maxdepth => 1, in => $self->indir);
        @basename = map {  my @tmp = fileparse($_,  qr/$text/); $tmp[0] }  @whole ;
    }

    $self->samples(\@basename);
    $self->infiles(\@whole);

    if($self->verbose){
        print "$self->{comment_char}\n";
        print "$self->{comment_char} Samples: ",join(", ", @{$self->samples})."\n";
        print "$self->{comment_char}\n";
    }
}


=head3 plugin_load

Load plugins defined in yaml with MooseX::Object::Pluggable

=cut

sub plugin_load {
    my($self) = shift;

    return unless $self->yaml->{plugins};

    my $modules = $self->yaml->{plugins};

    foreach my $m (@$modules){
       $self->load_plugin($m);
    }
}

=head3 class_load

Load classes defined in yaml with Class::Load

=cut

sub class_load {
    my($self) = shift;

    return unless $self->yaml->{use};

    my $modules = $self->yaml->{use};

    foreach my $m (@$modules){
        load_class($m);
    }
}

=head3 make_template

Make the template for interpolating strings

=cut

sub make_template{
    my($self, $input) = @_;

    my  $template = Text::Template->new( TYPE => 'STRING',
        SOURCE => "$E{$input}",
    );

    return $template;
}

=head3 create_attr

make attributes

=cut

sub create_attr{
    my($self) = shift;

    my $meta = __PACKAGE__->meta;

    $meta->make_mutable;

    my %seen = ();

    for my $attr ( $meta->get_all_attributes  ) {
        $seen{$attr->name} = 1;
    }

    # Data Pairs is so much prettier
    my @keys = $self->attr->get_keys();

    foreach my $k (@keys){
        my($v) = $self->attr->get_values($k);

        if(! exists $seen{$k}){
            $meta->add_attribute($k => (is => 'rw', predicate => "has_$k", clearer => "clear_$k"));
        }
        $self->$k($v) if $v;
    }

    $meta->make_immutable;
}

sub eval_attr {
    my $self = shift;
    my $sample = shift;

    #$DB::single=2;
    my @keys = $self->attr->get_keys();

    foreach my $k (@keys){
        my($v) = $self->attr->get_values($k);

        next unless $v;

        my $template = $self->make_template($v);
        my $text;
        if($sample){
            $text = $template->fill_in(HASH => {self => \$self, sample => $sample});
        }
        else{
            $text = $template->fill_in(HASH => {self => \$self});
        }

        #$DB::single=2;
        $self->$k($text);
    }

    #$self->make_outdir if $self->attr->exists('OUTPUT');
    $self->make_outdir if $self->create_outdir;
}

sub clear_attr {
    my $self = shift;

    my @keys = $self->attr->get_keys();

    foreach my $k (@keys){
        my($v) = $self->attr->get_values($k);
        next unless $v;

        my $clear = "clear_$k";
        $self->$clear;
    }
}

sub write_pipeline{
    my($self) = shift;

    my $process = $self->yaml->{rules};

    die print "Where are the rules?\n" unless $process;

    # This is untested with resampling!
    if($self->sample_based){
        #Store the samples
        my $sample_store = $self->samples;

        foreach my $sample (@$sample_store){
            $self->samples([$sample]);
            foreach my $p (@{$process}){
                next unless $p;
                $self->local_rule($p);
                $self->dothings;
            }
        }
    }
    elsif($self->rule_based){
        foreach my $p (@{$process}){
            next unless $p;
            $self->local_rule($p);
            $self->dothings;
        }
    }
    else{
        die print "Workflow must be rule based or sample based!\n";
    }
}

sub dothings {
    my($self) = shift;


    #$DB::single=2;
    my(@keys, $pairs,$camel_key, $key, $process_outdir);

    $self->local_attr(Data::Pairs->new([]));

    @keys = keys %{$self->local_rule};

    #TODO make these more informative messages
    return unless @keys;

    if($#keys > 0){
        die print "We have a problem! There should only be one key. Please see the documentation!\n";
    }

    $key = $keys[0];
    $self->key($key);
    $camel_key= $key;

    if($self->auto_name){
        $self->outdir($self->outdir."/$camel_key");
        $process_outdir = $self->outdir;
        $self->make_outdir() unless $self->by_sample_outdir;
    }

    if (exists $self->local_rule->{$key}->{override_process} && $self->local_rule->{$key}->{override_process} == 1){
        $self->override_process(1);
    }

    if(exists $self->local_rule->{$key}->{local}){
        $self->local_attr(Data::Pairs->new($self->local_rule->{$key}->{local}));
        $self->add_attr;
        #$self->attr($self->local_attr);
        $self->create_attr;
    }

    if(! exists $self->local_rule->{$key}->{process}){
        die print "There is no process key! Dying...\n";
    }

    $self->process($self->local_rule->{$key}->{process});

    $self->write_rule_meta('before_meta');

    if($self->resample){
        $self->get_samples;
    }

    if($self->verbose){
        print "\n\n$self->{comment_char}\n";
        print "$self->{comment_char} Variables \n";
        print "$self->{comment_char} Indir: ".$self->indir."\n";
        print "$self->{comment_char} Outdir: ".$self->outdir."\n";

        if(exists $self->local_rule->{$key}->{local}){

            print "$self->{comment_char} Local Variables:\n";

            if($self->auto_input ){
                $self->local_attr->set('OUTPUT' => $self->OUTPUT) if $self->has_OUTPUT;
                $self->local_attr->set('INPUT' => $self->global_attr->get_values('INPUT')) if $self->global_attr->exists('INPUT');
            }

            my @keys = $self->local_attr->get_keys();

            foreach my $k (@keys){
                my($v) = $self->local_attr->get_values($k);
                print "$self->{comment_char}\t$k: ".$v."\n";
            }
        }

        if($self->resample){
            print "$self->{comment_char} Resampling Samples: ",join(", ", @{$self->samples})."\n";
        }
        print "$self->{comment_char}\n\n";
    }

    $self->write_process();

    #Write after meta
    $self->write_rule_meta('after_meta');

    #Set bools back to false and reinitialize global vars
    $self->resample(0);
    $self->clear_attr;
    $self->attr($self->global_attr);
    $self->eval_attr;
    $self->local_attr(Data::Pairs->new([]));

    if($self->enforce_struct){
        $self->indir($process_outdir);
    }
}

=head2 add_attr

Add the local attr onto the global attr

=cut

sub add_attr{
    my $self = shift;
    my @keys = $self->local_attr->get_keys();

    foreach my $key (@keys){
        $self->attr->add($key => $self->local_attr->get_values($key));
    }
}

=head2 write_rule_meta

=cut

sub write_rule_meta{
    my($self, $meta) = @_;

    if(exists $self->local_rule->{$self->{key}}->{$meta}){
        $DB::single=2;
        print "\n$self->{comment_char}\n";
        print "$self->{comment_char} ".$self->local_rule->{$self->key}->{after_meta}."\n";
        print "$self->{comment_char}\n\n";
    }
    else{
        print "\n$self->{comment_char}\n";
        if($meta eq "before_meta"){
            print "$self->{comment_char} Starting $self->{key}\n";
        }
        elsif($meta eq "after_meta"){
            print "$self->{comment_char} Ending $self->{key}\n";
        }
        print "$self->{comment_char}\n\n";
    }


}

=head3 write_process

Fill in the template with the process

=cut

has 'pkey' => (
    is => 'rw',
    isa => 'Str|Undef',
    predicate => 'has_pkey'
);

sub write_process{
    my($self) = @_;

    my($template, $tmp, $newprocess, $sample, $origout, $origin);

    $origout = $self->outdir;
    $origin = $self->indir;

    $DB::single = 2;

    if(!$self->override_process){
        foreach my $sample (@{$self->samples}){
            $self->process_by_sample_outdir($sample) if $self->by_sample_outdir;
            $DB::single=2;
            $self->eval_attr($sample);
            my $data = {self => \$self, sample => $sample};
            #$DB::single=2;
            $self->process_template($data);
            $self->outdir($origout);
            $self->indir($origin);
        }
    }
    else{
        $self->eval_attr;
        my $data = {self => \$self};
        $self->process_template($data);
    }

    if($self->wait){
        print "\nwait\n";
    }

    $self->OUTPUT_to_INPUT;

    $self->pkey($self->key);
}

=head3 process_by_sample_outdir

Make sure indir/outdirs are named appropriated for samples when using by

=cut

sub process_by_sample_outdir {
    my $self = shift;
    my $sample = shift;

    my($tt, $key);
    $tt = $self->outdir;
    $key = $self->key;
    $tt =~ s/$key/$sample\/$key/;
    $self->outdir($tt);
    $self->make_outdir;
    $DB::single=2;

    $tt = $self->indir;
    if($tt =~ m/\{\$self/){
        $DB::single=2;
        $tt = "$tt/{\$sample}";
        $self->indir($tt);
        $self->attr->set('indir' => $self->indir) if $self->attr->exists('indir');
    }
    elsif($self->has_pkey){
        $DB::single=2;
        $key = $self->pkey;
        $tt =~ s/$key/$sample\/$key/;
        $self->indir($tt);
        $self->attr->set('indir' => $self->indir) if $self->attr->exists('indir');
    }
    else{
        $DB::single=2;
        $tt = "$tt/$sample";
        $self->indir($tt);
        $self->attr->set('indir' => $self->indir) if $self->attr->exists('indir');
    }
}


=head3 OUTPUT_to_INPUT

If we are using auto_input chain INPUT/OUTPUT

=cut

sub OUTPUT_to_INPUT {
    my $self = shift;
    $DB::single=2;
    #Change the output to input
    if($self->auto_input && $self->local_attr->exists('OUTPUT')){
        $DB::single=2;
        my($tmp, $indir, $outdir) = ($self->local_attr->get_values('OUTPUT'), $self->indir, $self->outdir);
        $tmp =~ s/{\$self->outdir}/{\$self->indir}/g;
        $self->INPUT($tmp);
        #This is not the best way of doing this....
        $self->global_attr->set(INPUT => $self->INPUT);
        $DB::single=2;
    }
    else{
        $self->clear_OUTPUT();
    }
}

sub process_template{
    my($self, $data) = @_;

    my($tmp, $template);

    $template = $self->make_template($self->process);
    $DB::single=2;
    $template->fill_in(HASH => $data, OUTPUT => \*STDOUT);

    $self->INPUT($self->local_attr->get_values('INPUT')) if $self->local_attr->exists('INPUT');
    $self->OUTPUT($self->local_attr->get_values('OUTPUT')) if $self->local_attr->exists('OUTPUT');

    print "\n\n";
}


__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 DESCRIPTION

BioX::Workflow - A very opinionated template based workflow writer.

=head1 AUTHOR

Jillian Rowe E<lt>jillian.e.rowe@gmail.comE<gt>

=head1 Acknowledgements

Before version 0.03

This module was originally developed at and for Weill Cornell Medical
College in Qatar within ITS Advanced Computing Team. With approval from
WCMC-Q, this information was generalized and put on github, for which
the authors would like to express their gratitude.

As of version 0.03:

This modules continuing development is supported by NYU Abu Dhabi in the Center for Genomics and Systems Biology.
With approval from NYUAD, this information was generalized and put on bitbucket, for which
the authors would like to express their gratitude.

=head1 COPYRIGHT

Copyright 2015- Weill Cornell Medical College in Qatar

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
