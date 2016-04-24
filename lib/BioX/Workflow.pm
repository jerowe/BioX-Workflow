package BioX::Workflow;

use 5.008_005;
our $VERSION = '0.25';

use Moose;
use File::Find::Rule;
use File::Basename;
use File::Path qw(make_path remove_tree);
use Cwd qw(abs_path getcwd);
use Data::Dumper;
use List::Compare;
use YAML::XS 'LoadFile';
use Config::Any;

#use String::CamelCase qw(camelize decamelize wordsplit);
use Data::Dumper;
use Class::Load ':all';
use IO::File;
use Interpolation E => 'eval';
use Text::Template qw(fill_in_file fill_in_string);
use Data::Pairs;
use Storable qw(dclone);
use MooseX::Types::Path::Tiny qw/Path Paths AbsPath/;
use List::Uniq ':all';

use Carp::Always;

extends 'BioX::Wrapper';
with 'MooseX::Getopt::Usage';
with 'MooseX::Getopt::Usage::Role::Man';
with 'MooseX::SimpleConfig';

with 'MooseX::Object::Pluggable';

# For pretty man pages!
$ENV{TERM} = 'xterm-256color';

=encoding utf-7

=head1 NAME

BioX::Workflow - A very opinionated template based workflow writer.

=head1 SYNOPSIS

Most of the functionality can be accessed through the biox-workflow.pl script.

    biox-workflow.pl --workflow /path/to/workflow.yml

This module was written with Bioinformatics workflows in mind, but should be extensible to any sort of workflow or pipeline.

=head1 Usage

Please check out the full Usage Docs at L<BioX::Workflow::Usage>

=head1 In Code Documenation

You shouldn't really need to look here unless you have some reason to do some serious hacking.

=head2 Attributes

Moose attributes. Technically any of these can be changed, but may break everything.

=head2 comment_char

=cut

has '+comment_char' => (
    predicate => 'has_comment_char',
    clearer   => 'clear_comment_char',
);

=head2 coerce_paths

=cut

has 'coerce_paths' => (
    is        => 'rw',
    isa       => 'Bool',
    default   => 1,
    predicate => 'has_coerce_paths',
);

=head2 select_rules

Select a subsection of rules

=cut

has 'select_rules' => (
    traits   => ['Array'],
    is       => 'rw',
    isa      => 'ArrayRef[Str]',
    default  => sub { [] },
    required => 0,
    handles  => {
        all_select_rules    => 'elements',
        add_select_rule     => 'push',
        map_select_rules    => 'map',
        filter_select_rules => 'grep',
        find_select_rule    => 'first',
        get_select_rule     => 'get',
        join_select_rules   => 'join',
        count_select_rules  => 'count',
        has_select_rules    => 'count',
        has_no_select_rules => 'is_empty',
        sorted_select_rules => 'sort',
    },
    documentation => q{Select a subselection of rules to choose from},
);

=head3 resample

Boolean value get new samples based on indir/file_rule or no

Samples are found at the beginning of the workflow, based on the global indir variable and the file_find.

Chances are you don't want to set resample to try, because these files probably won't exist outside of the indirectory until the pipeline is run.

One example of doing so, shown in the gemini.yml in the examples directory, is looking for uncompressed files, .vcf extension, compressing them, and
then resampling based on the .vcf.gz extension.

=cut

has 'resample' => (
    traits    => ['NoGetopt'],
    is        => 'rw',
    isa       => 'Bool',
    default   => 0,
    predicate => 'has_resample',
    clearer   => 'clear_resample',
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
    is            => 'rw',
    isa           => 'Bool',
    default       => 0,
    documentation => q{Use this option when you sample names are directories},
    predicate     => 'has_find_by_dir',
    clearer       => 'clear_find_by_dir',
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
    is            => 'rw',
    isa           => 'Bool',
    default       => 0,
    documentation => q{When you want your output by sample},
    clearer       => 'clear_by_sample_outdir',
    predicate     => 'has_by_sample_outdir',
);

=head3 min

Print the workflow as 2 files.

    #run-workflow.sh
    export SAMPLE=sampleN && ./run_things

=cut

has 'min' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

=head3 number_rules

    Instead of
    outdir/
        rule1
        rule2

    outdir/
        001-rule1
        002-rule2

=cut

has 'number_rules' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'counter_rules' => (
    traits  => ['Counter'],
    is => 'rw',
    isa => 'Num',
    default => 1,
    handles => {
        inc_counter_rules   => 'inc',
        dec_counter_rules   => 'dec',
        reset_counter_rules => 'reset',
    },
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
    traits  => ['Bool'],
    is      => 'rw',
    isa     => 'Bool',
    default => 1,

    #clearer => 'clear_auto_name',
    predicate => 'has_auto_name',
    handles   => {
        enforce_struct       => 'set',
        clear_enforce_struct => 'unset',
        clear_auto_name      => 'unset',
    },
);

=head3 auto_input

This is similar to the auto_name function in the BioX::Workflow.
Instead this says each input should be the previous output.

=cut

has 'auto_input' => (
    is        => 'rw',
    isa       => 'Bool',
    default   => 1,
    clearer   => 'clear_auto_input',
    predicate => 'has_auto_input',
);

# Getting rid of this - its the same as auto_name
# Put it in auto_name for compatibility

#has 'enforce_struct' => (
#is => 'rw',
#isa => 'Bool',
#default => 1,
#clearer => 'clear_enforce_struct',
#predicate => 'has_enforce_struct',
#);

=head3 verbose

Output some more things

=cut

has 'verbose' => (
    is        => 'rw',
    isa       => 'Bool',
    default   => 1,
    clearer   => 'clear_verbose',
    predicate => 'has_verbose',
);

=head3 wait

Print "wait" at the end of each rule

=cut

has 'wait' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
    documentation =>
        q(Print 'wait' at the end of each rule. If you are running as a plain bash script you probably don't need this.),
    clearer   => 'clear_wait',
    predicate => 'has_wait',
);

=head3 override_process

local:
    - override_process: 1

=cut

has 'override_process' => (
    traits    => ['Bool'],
    is        => 'rw',
    isa       => 'Bool',
    default   => 0,
    predicate => 'has_override_process',
    documentation =>
        q(Instead of for my $sample (@sample){ DO STUFF } just DOSTUFF),
    handles => {
        set_override_process   => 'set',
        clear_override_process => 'unset',
    },
);

=head3 indir outdir

=cut

has 'indir' => (
    is            => 'rw',
    isa           => AbsPath,
    coerce        => 1,
    default       => sub { getcwd(); },
    predicate     => 'has_indir',
    clearer       => 'clear_indir',
    documentation => q(Directory to look for samples),
);

has 'outdir' => (
    is            => 'rw',
    isa           => AbsPath,
    coerce        => 1,
    default       => sub { getcwd(); },
    predicate     => 'has_outdir',
    clearer       => 'clear_outdir',
    documentation => q(Output directories for rules and processes),
);

=head3 create_outdir

=cut

has 'create_outdir' => (
    is        => 'rw',
    isa       => 'Bool',
    predicate => 'has_create_outdir',
    clearer   => 'clear_create_outdir',
    documentation =>
        q(Create the outdir. You may want to turn this off if doing a rule that doesn't write anything, such as checking if files exist),
    default => 1,
);

=head3 INPUT OUTPUT

Special variables that can have input/output

These variables are also used in L<BioX::Workflow::Plugin::Drake>

=cut

has 'OUTPUT' => (
    is        => 'rw',
    isa       => 'Str|Undef',
    predicate => 'has_OUTPUT',
    clearer   => 'clear_OUTPUT',
    documentation =>
        q(Maybe clean up your code some. At the end of each process the OUTPUT becomes
    the INPUT. Best when putting a single file through a stream of processes.)
);

has 'INPUT' => (
    is            => 'rw',
    isa           => 'Str|Undef',
    predicate     => 'has_INPUT',
    clearer       => 'clear_INPUT',
    documentation => q(See $OUTPUT)
);

=head3 file_rule

Rule to find files

=cut

has 'file_rule' => (
    is        => 'rw',
    isa       => 'Str',
    default   => sub { return "(.*)"; },
    clearer   => 'clear_file_rule',
    predicate => 'has_file_rule',
);

=head3 No GetOpt Here

=cut

has 'yaml' => (
    traits => ['NoGetopt'],
    is     => 'rw',
);

=head3 attr

attributes read in from runtime

=cut

has 'attr' => (
    traits => ['NoGetopt'],
    is     => 'rw',
    isa    => 'Data::Pairs',
);

=head3 global_attr

Attributes defined in the global section of the yaml file

=cut

has 'global_attr' => (
    traits  => ['NoGetopt'],
    is      => 'rw',
    isa     => 'Data::Pairs',
    lazy    => 1,
    default => sub {
        my $self = shift;

        my $n = Data::Pairs->new(
            [   { resample   => $self->resample },
                { wait       => $self->wait },
                { auto_input => $self->auto_input },
                { coerce_paths => $self->coerce_paths },
                { auto_name => $self->auto_name },
                { indir => $self->indir },
                { outdir => $self->outdir },
                { min => $self->min },
                { override_process => $self->override_process },
                { rule_based => $self->rule_based },
                { verbose => $self->verbose },
                { create_outdir => $self->create_outdir },
            ]
        );
        return $n;
    }
);

=head3 local_attr

Attributes defined in the rules->rulename->local section of the yaml file

=cut

has 'local_attr' => (
    traits => ['NoGetopt'],
    is     => 'rw',
    isa    => 'Data::Pairs',
);

=head3 local_rule

=cut

has 'local_rule' => (
    traits => ['NoGetopt'],
    is     => 'rw',
    isa    => 'HashRef'
);

=head3 infiles

Infiles to be processed

=cut

has 'infiles' => (
    traits => ['NoGetopt'],
    is     => 'rw',
    isa    => 'ArrayRef',
);

=head3 samples

=cut

has 'samples' => (
    traits   => ['Array'],
    is       => 'rw',
    isa      => 'ArrayRef',
    default  => sub { [] },
    required => 0,
    handles  => {
        all_samples    => 'elements',
        add_sample     => 'push',
        map_samples    => 'map',
        filter_samples => 'grep',
        find_sample    => 'first',
        get_sample     => 'get',
        join_samples   => 'join',
        count_samples  => 'count',
        has_samples    => 'count',
        has_no_samples => 'is_empty',
        sorted_samples => 'sort',
    },
    documentation =>
        q{Supply samples on the command line as --samples sample1 --samples sample2, or find through file_rule.}
);

=head3 process

Do stuff

=cut

has 'process' => (
    traits => ['NoGetopt'],
    is     => 'rw',
    isa    => 'Str',
);

=head3 key

Do stuff

=cut

has 'key' => (
    traits => ['NoGetopt'],
    is     => 'rw',
    isa    => 'Str',
);

=head3 workflow

Path to workflow workflow. This must be a YAML file.

=cut

has 'workflow' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

=head3 rule_based

This is the default. The outer loop are the rules, not the samples

=cut

has 'rule_based' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

=head3 sample_based

Default Value. The outer loop is samples, not rules. Must be set in your global values or on the command line --sample_based 1

If you ever have resample: 1 in your config you should NOT set this value to true!

=cut

has 'sample_based' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

=head2 stash

This isn't ever used in the code. Its just there incase you want to do some things with override_process

It uses Moose::Meta::Attribute::Native::Trait::Hash and supports all the methods.

        set_stash     => 'set',
        get_stash     => 'get',
        has_no_stash => 'is_empty',
        num_stashs    => 'count',
        delete_stash  => 'delete',
        stash_pairs   => 'kv',

=cut

has 'stash' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => ['Hash'],
    default => sub { {} },
    handles => {
        set_stash    => 'set',
        get_stash    => 'get',
        has_no_stash => 'is_empty',
        num_stashs   => 'count',
        delete_stash => 'delete',
        stash_pairs  => 'kv',
    },
);

=head2 _classes

Saves a snapshot of the entire namespace for the initial environment, and each rule.

=cut

has '_classes' => (
    traits    => ['NoGetopt'],
    is        => 'rw',
    isa       => 'HashRef',
    default   => sub { return {} },
    required  => 0,
    predicate => 'has_classes',
    clearer   => 'clear_classes',
);

=head2 Subroutines

Subroutines can also be overriden and/or extended in the usual Moose fashion.

=head3 run

Starting point.

=cut

sub run {
    my ($self) = shift;

    print "#!/bin/bash\n\n";

    $self->print_opts;

    $self->init_things;

    $self->write_workflow_meta('start');

    $self->write_pipeline;

    $self->write_workflow_meta('end');
}

sub write_workflow_meta {
    my $self = shift;
    my $type = shift;

    return unless $self->verbose;

    if ( $type eq "start" ) {
        print "$self->{comment_char}\n";
        print "$self->{comment_char} Starting Workflow\n";
        print "$self->{comment_char}\n";
        print "$self->{comment_char}\n";
        print "$self->{comment_char} Global Variables:\n";

        my @keys = $self->global_attr->get_keys();

        foreach my $k (@keys) {
            next unless $k;
            my ($v) = $self->global_attr->get_values($k);
            print "$self->{comment_char}\t$k: " . $v . "\n";
        }
        print "$self->{comment_char}\n";
    }
    elsif ( $type eq "end" ) {
        print "$self->{comment_char}\n";
        print "$self->{comment_char} Ending Workflow\n";
        print "$self->{comment_char}\n";
    }
}

sub init_things {
    my $self = shift;

    $self->key('global');
    $self->workflow_load;

    $self->class_load;
    $self->plugin_load;

    #Darn you data pairs and your shallow copies!
    $self->set_global_yaml;
    $self->attr( dclone( $self->global_attr ) );

    $self->create_attr;
    $self->eval_attr;

    $self->make_outdir;
    $self->get_samples;

    #Save our initial environment
    $self->save_env;
}

sub set_global_yaml {
    my $self = shift;

    return unless exists $self->yaml->{global};

    my $aref = $self->yaml->{global};
    for my $a (@$aref){
        while (my ($key, $value) = each(%{$a})) {
            $self->global_attr->set($key => $value);
        }
    }
}

=head2 save_env

At each rule save the env for debugging purposes.

=cut

sub save_env {
    my $self = shift;

    $DB::single = 2;
    $self->_classes->{ $self->key } = dclone($self);
    return;
    $DB::single = 2;
}

sub workflow_load {
    my $self = shift;

    my $cfg = Config::Any->load_files(
        { files => [ $self->workflow ], use_ext => 1 } );

    for (@$cfg) {
        my ( $filename, $config ) = %$_;
        $self->yaml($config);
    }
}

=head3 make_outdir

Set initial indir and outdir

=cut

sub make_outdir {
    my ($self) = @_;

    return unless $self->create_outdir;

    if ( $self->{outdir} =~ m/\{\$/ ) {
        return;
    }
    make_path( $self->outdir ) if !-d $self->outdir;
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

sub get_samples {
    my ($self) = shift;
    my ( @whole, @basename, $text );

    if ( $self->has_samples && !$self->resample ) {
        my (@samples) = $self->sorted_samples;
        $self->samples( \@samples );
        return;
    }

    $text = $self->file_rule;

    if ( $self->find_by_dir ) {
        @whole = find(
            directory => name => qr/$text/,
            maxdepth  => 1,
            in        => $self->indir
        );

        #File find puts directory we are looking in, not just subdirs
        @basename = grep { $_ != basename( $self->{indir} ) } @basename;
        @basename = map  { basename($_) } @whole;
        @basename = sort(@basename);
    }
    else {
        @whole = find(
            file     => name => qr/$text/,
            maxdepth => 1,
            in       => $self->indir
        );

#AAAH DOESN"T WORK
#@basename = map {  my @tmp = fileparse($_); my($m) = $tmp[0] =~ qr/$text/; $m }  @whole ;
        @basename = map { $self->match_samples( $_, $text ) } @whole;
        @basename = uniq(@basename);
        @basename = sort(@basename);
    }

    $self->samples( \@basename );
    $self->infiles( \@whole );

    if ( $self->verbose ) {
        print "$self->{comment_char}\n";
        print "$self->{comment_char} Samples: ",
            join( ", ", @{ $self->samples } ) . "\n";
        print "$self->{comment_char}\n";
    }
}

=head2 match_samples

Match samples based on regex written in file_rule

=cut

sub match_samples {
    my $self = shift;
    my $file = shift;
    my $text = shift;

    my @tmp = fileparse($_);
    my ($m) = $tmp[0] =~ qr/$text/;

    return $m;
}

=head3 plugin_load

Load plugins defined in yaml with MooseX::Object::Pluggable

=cut

sub plugin_load {
    my ($self) = shift;

    return unless $self->yaml->{plugins};

    my $modules = $self->yaml->{plugins};

    foreach my $m (@$modules) {
        $self->load_plugin($m);
    }
}

=head3 class_load

Load classes defined in yaml with Class::Load

=cut

sub class_load {
    my ($self) = shift;

    return unless $self->yaml->{use};

    my $modules = $self->yaml->{use};

    foreach my $m (@$modules) {
        load_class($m);
    }
}

=head3 make_template

Make the template for interpolating strings

=cut

sub make_template {
    my ( $self, $input ) = @_;

    my $template = Text::Template->new(
        TYPE   => 'STRING',
        SOURCE => "$E{$input}",
    );

    return $template;
}

=head3 create_attr

make attributes

=cut

sub create_attr {
    my ($self) = shift;

    my $meta = __PACKAGE__->meta;

    $meta->make_mutable;

    my %seen = ();

    for my $attr ( $meta->get_all_attributes ) {
        $seen{ $attr->name } = 1;
    }

    # Data Pairs is so much prettier
    my @keys = $self->attr->get_keys();

    foreach my $k (@keys) {
        my ($v) = $self->attr->get_values($k);

        if ( !exists $seen{$k} ) {
            if ( $k =~ m/_dir$/ ) {
                if ( $self->coerce_paths ) {
                    $meta->add_attribute(
                        $k => (
                            is        => 'rw',
                            isa       => AbsPath,
                            coerce    => 1,
                            predicate => "has_$k",
                            clearer   => "clear_$k"
                        )
                    );
                }
                else {
                    $meta->add_attribute(
                        $k => (
                            is        => 'rw',
                            isa       => AbsPath,
                            coerce    => 0,
                            predicate => "has_$k",
                            clearer   => "clear_$k"
                        )
                    );
                }
            }
            else {
                $meta->add_attribute(
                    $k => (
                        is        => 'rw',
                        predicate => "has_$k",
                        clearer   => "clear_$k"
                    )
                );
            }
        }
        $self->$k($v) if defined $v;
    }

    $meta->make_immutable;
}

sub eval_attr {
    my $self   = shift;
    my $sample = shift;

    my @keys = $self->attr->get_keys();

    foreach my $k (@keys) {
        next unless $k;
        my ($v) = $self->attr->get_values($k);
        next unless $v;

        my $template = $self->make_template($v);
        my $text;
        if ($sample) {
            $text = $template->fill_in(
                HASH => { self => \$self, sample => $sample } );
        }
        else {
            $text = $template->fill_in( HASH => { self => \$self } );
        }

        $self->$k($text);
    }

    #$self->make_outdir if $self->attr->exists('OUTPUT');
    $self->make_outdir if $self->create_outdir;
}

sub clear_attr {
    my $self = shift;

    my @keys = $self->attr->get_keys();

    foreach my $k (@keys) {
        my ($v) = $self->attr->get_values($k);
        next unless $v;

        my $clear = "clear_$k";
        $self->$clear;
    }
}

sub write_pipeline {
    my ($self) = shift;

    #Min and Sample_Based Mode will break with --resample
    if ( $self->min ) {
        $self->write_min_files;
        $self->process_rules;
    }
    elsif ( $self->sample_based ) {

        #Store the samples
        my $sample_store = $self->samples;
        foreach my $sample (@$sample_store) {
            $self->samples( [$sample] );
            $self->process_rules;
        }
    }
    elsif ( $self->rule_based ) {
        $self->process_rules;
    }
    else {
        die print "Workflow must be rule based or sample based!\n";
    }
}

sub write_min_files {
    my ($self) = shift;

    open( my $fh, '>', 'run-workflow.sh' )
        or die print "Could not open file $!\n";

    print $fh "#!/bin/bash\n\n";

    my $cwd = getcwd();
    foreach my $sample ( @{ $self->samples } ) {
        print $fh <<EOF;
export SAMPLE=$sample && ./workflow.sh
EOF
    }

    close $fh;

    chmod 0777, 'run-workflow.sh';

    $self->samples( ["\${SAMPLE}"] );
}

sub process_rules {
    my $self = shift;

    my $process;
    $process = $self->yaml->{rules};

    die print "Where are the rules?\n" unless $process;

    foreach my $p ( @{$process} ) {
        next unless $p;
        if($self->number_rules){
            my @keys = keys %{$p};
            my $result = sprintf("%04d", $self->counter_rules);
            my $newkey = $keys[0];
            $newkey = $result.'-'.$newkey;
            $p->{$newkey} = dclone($p->{$keys[0]});
            delete $p->{$keys[0]};
            $self->inc_counter_rules;
        }
        $self->local_rule($p);
        $self->dothings;
    }
}

sub dothings {
    my ($self) = shift;

    $self->check_keys;

    $self->init_process_vars;

    if ( $self->has_select_rules ) {
        my $p = $self->key;
        if ( !$self->filter_select_rules( sub {/^$p$/} ) ) {
            $self->clear_process_vars;

            $self->pkey( $self->key );
            $self->indir( $self->outdir . "/" . $self->pkey )
                if $self->auto_name;
            return;
        }
    }

    $self->process( $self->local_rule->{ $self->key }->{process} );

    $self->write_rule_meta('before_meta');

    $self->write_process();

    $self->write_rule_meta('after_meta');

    $self->clear_process_vars;

    $self->indir( $self->outdir . "/" . $self->pkey ) if $self->auto_name;
}

=head2 check_keys

There should be one key and one key only!

=cut

sub check_keys {
    my $self = shift;
    my @keys = keys %{ $self->local_rule };

    if ( $#keys > 0 ) {
        die print
            "We have a problem! There should only be one key. Please see the documentation!\n";
    }
    elsif ( !@keys ) {
        die print "There are no rules. Please see the documenation.\n";
    }
    else {
        $self->key( $keys[0] );
    }

    if ( !exists $self->local_rule->{ $self->key }->{process} ) {
        die print "There is no process key! Dying...\n";
    }
}

=head2 clear_process_vars

Clear the process vars

=cut

sub clear_process_vars {
    my $self = shift;

    #Set bools back to false and reinitialize global vars
    #$self->resample(0);
    #$self->override_process(0);

    $self->attr->clear;
    $self->local_attr->clear;

    $self->add_attr('global_attr');
    $self->eval_attr;
}

=head2 init_process_vars

Initialize the process vars

=cut

sub init_process_vars {
    my $self = shift;

    if ( $self->auto_name ) {
        $self->outdir( $self->outdir . "/" . $self->key );
        $self->make_outdir() unless $self->by_sample_outdir;
    }

    #TODO move this over to local
    if ( exists $self->local_rule->{ $self->key }->{override_process}
        && $self->local_rule->{ $self->key }->{override_process} == 1 )
    {
        $self->override_process(1);
    }
    else {
        $self->override_process(0);
    }

    $self->local_attr( Data::Pairs->new( [] ) );
    if ( exists $self->local_rule->{ $self->key }->{local} ) {
        $self->local_attr(
            Data::Pairs->new(
                dclone( $self->local_rule->{ $self->key }->{local} )
            )
        );
    }

    #Make sure these aren't reset to global
    ##YAY FOR TESTS
    $self->local_attr->set( 'outdir' => $self->outdir )
        unless $self->local_attr->exists('outdir');
    $self->local_attr->set( 'indir' => $self->indir )
        unless $self->local_attr->exists('indir');

    $self->add_attr('local_attr');
    $self->create_attr;
    $self->get_samples if $self->resample;
}

=head2 add_attr

Add the local attr onto the global attr

=cut

sub add_attr {
    my $self = shift;
    my $type = shift;

    my @keys = $self->$type->get_keys();

    foreach my $key (@keys) {
        next unless $key;

        my ($v) = $self->$type->get_values($key);
        $self->attr->set( $key => $v );
    }

}

=head2 write_rule_meta

=cut

sub write_rule_meta {
    my ( $self, $meta ) = @_;

    print "\n$self->{comment_char}\n";
    if ( $meta eq "after_meta" ) {
        print "$self->{comment_char} Ending $self->{key}\n";
    }
    print "$self->{comment_char}\n\n";

    return unless $meta eq "before_meta";
    print "$self->{comment_char} Starting $self->{key}\n";
    print "$self->{comment_char}\n\n";
    if ( $self->verbose ) {
        print "\n\n$self->{comment_char}\n";
        print "$self->{comment_char} Variables \n";
        print "$self->{comment_char} Indir: " . $self->indir . "\n";
        print "$self->{comment_char} Outdir: " . $self->outdir . "\n";

        if ( exists $self->local_rule->{ $self->key }->{local} ) {

            print "$self->{comment_char} Local Variables:\n";

            if ( $self->auto_input ) {
                $self->local_attr->set( 'OUTPUT' => $self->OUTPUT )
                    if $self->has_OUTPUT;
                $self->local_attr->set(
                    'INPUT' => $self->global_attr->get_values('INPUT') )
                    if $self->global_attr->exists('INPUT');
            }

            my @keys = $self->local_attr->get_keys();

            foreach my $k (@keys) {
                my ($v) = $self->local_attr->get_values($k);
                print "$self->{comment_char}\t$k: " . $v . "\n";
            }
        }

        if ( $self->resample ) {
            print "$self->{comment_char} Resampling Samples: ",
                join( ", ", @{ $self->samples } ) . "\n";
        }
        print "$self->{comment_char}\n\n";
    }

}

=head3 write_process

Fill in the template with the process

=cut

has 'pkey' => (
    is        => 'rw',
    isa       => 'Str|Undef',
    predicate => 'has_pkey'
);

sub write_process {
    my ($self) = @_;

    my ( $template, $tmp, $newprocess, $sample, $origout, $origin );

    $origout = $self->outdir;
    $origin  = $self->indir;

    $self->save_env;

    if ( !$self->override_process ) {
        foreach my $sample ( @{ $self->samples } ) {
            $self->process_by_sample_outdir($sample)
                if $self->by_sample_outdir;
            $self->eval_attr($sample);
            my $data = { self => \$self, sample => $sample };
            $self->process_template($data);
            $self->outdir($origout);
            $self->indir($origin);
        }
    }
    else {
        $self->eval_attr;
        my $data = { self => \$self };
        $self->process_template($data);
    }

    if ( $self->wait ) {
        print "\nwait\n";
    }

    $self->OUTPUT_to_INPUT;

    $self->pkey( $self->key );

    #$self->outdir($origout);
    #$self->indir($origin);
}

=head3 process_by_sample_outdir

Make sure indir/outdirs are named appropriated for samples when using by

=cut

sub process_by_sample_outdir {
    my $self   = shift;
    my $sample = shift;

    my ( $tt, $key );
    $tt  = $self->outdir;
    $key = $self->key;
    $tt =~ s/$key/$sample\/$key/;
    $self->outdir($tt);
    $self->make_outdir;
    $self->attr->set( 'outdir' => $self->outdir );

    $tt = $self->indir;
    if ( $tt =~ m/\{\$self/ ) {
        $tt = "$tt/{\$sample}";
        $self->indir($tt);
    }
    elsif ( $self->has_pkey ) {
        $key = $self->pkey;
        $tt =~ s/$key/$sample\/$key/;
        $self->indir($tt);
    }
    else {
        $tt = "$tt/$sample";
        $self->indir($tt);
    }
    $self->attr->set( 'indir' => $self->indir );
}

=head3 OUTPUT_to_INPUT

If we are using auto_input chain INPUT/OUTPUT

=cut

sub OUTPUT_to_INPUT {
    my $self = shift;

    #Change the output to input
    if ( $self->auto_input && $self->local_attr->exists('OUTPUT') ) {
        my ( $tmp, $indir, $outdir ) = (
            $self->local_attr->get_values('OUTPUT'),
            $self->indir, $self->outdir
        );
        $tmp =~ s/{\$self->outdir}/{\$self->indir}/g;
        $self->INPUT($tmp);

        #This is not the best way of doing this....
        $self->global_attr->set( INPUT => $self->INPUT );
    }
    else {
        $self->clear_OUTPUT();
    }
}

sub process_template {
    my ( $self, $data ) = @_;

    my ( $tmp, $template );

    $template = $self->make_template( $self->process );
    $template->fill_in( HASH => $data, OUTPUT => \*STDOUT );

    $self->INPUT( $self->local_attr->get_values('INPUT') )
        if $self->local_attr->exists('INPUT');
    $self->OUTPUT( $self->local_attr->get_values('OUTPUT') )
        if $self->local_attr->exists('OUTPUT');

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
