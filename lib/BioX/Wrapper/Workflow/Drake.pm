package BioX::Wrapper::Workflow::Drake;

use Data::Dumper;
use Data::Pairs;

use Moose;
extends 'BioX::Wrapper::Workflow';

use Interpolation E => 'eval';

=head1 NAME

BioX::Wrapper::Workflow::Writer::Drake - A very opinionated template based bioinformatics workflow writer for Drake.

=head1 SYNOPSIS

The main documentation for this module is at L<BioX::Wrapper::Workflow>. This module extends Workflow in order to add functionality for outputing workflows in drake format.

    biox-workflow-drake.pl --workflow workflow.yml > workflow.drake
    drake --workflow workflow.drake  #with other functionality such as --jobs for asynchronous output, etc.

More information about Drake can be found here L<https://github.com/Factual/drake>.

=head2 Default Variables

BioX::Wrapper::Workflow::Drake assumes your INPUT/OUTPUT and indir/outdirs are
linked.

This means the output from step1 is the input for step2.

You can override this behavior by either declaring any of these values, or in the global
variables set auto_input: 0, disable automatic indir/outdir naming with
auto_name: 0, and disable automatically naming outdirectories by rule names with
enforce_struct: 0.


=head2 Example

=head3 workflow.yml

    ---
    global:
        - indir: /home/user/workflow
        - outdir: /home/user/workflow/output
        - file_rule: (.csv)$
    rules:
        - backup:
            local:
                - INPUT: "{$self->indir}/{$sample}.csv"
                - OUTPUT: "{$self->outdir}/{$sample}.csv"
                - thing: "other thing"
            process: |
                cp $INPUT $OUTPUT
        - grep_VARA:
            local:
                - OUTPUT: "{$self->outdir}/{$sample}.grep_VARA.csv"
            process: |
                echo "Working on {$self->{indir}}/{$sample.csv}"
                grep -i "VARA" {$self->indir}/{$sample}.csv >> {$self->outdir}/{$sample}.grep_VARA.csv \
                || touch {$self->OUTPUT}
        - grep_VARB:
            local:
                - OUTPUT: "{$self->outdir}/{$sample}.grep_VARA.grep_VARB.csv"
            process: |
                grep -i "VARB" {$self->indir}/{$sample}.grep_VARA.csv >> {$self->outdir}/{$sample}.grep_VARA.grep_VARB.csv || touch {$self->OUTPUT}

=head3 Notes on the drake.yml

Drake will stop everything if you're job returns with an exit code of anything
besides 0. For this reason we have the last command have a command1 || command2
syntax, so that even if we don't grep any "VARB" from the file the workflow
could continue.

=head3 Run it with default setup

    biox-workflow-drake.pl --workflow workflow.yml > workflow.full.drake

=head3 Output with default setup

I don't want to inlcude the whole file, but you get the idea

    ;
    ; Generated at: 2015-06-21T11:01:24
    ; This file was generated with the following options
    ;	--workflow	drake.yml
    ;	--min	1
    ;

    ;
    ; Samples: test1, test2
    ;
    ;
    ; Starting Workflow
    ;

    ;
    ; Starting backup
    ;


    ;
    ; Variables
    ; Indir: /home/guests/jir2004/workflow
    ; Outdir: /home/guests/jir2004/workflow/output/backup
    ; Local Variables:
    ;	INPUT: {$self->indir}/{$sample}.csv
    ;	OUTPUT: {$self->outdir}/{$sample}.csv
    ;	thing: other thing
    ;

    /home/guests/jir2004/workflow/output/backup/$[SAMPLE].csv <- /home/guests/jir2004/workflow/$[SAMPLE].csv
        cp $INPUT $OUTPUT


    ;
    ; Ending backup
    ;


    ;
    ; Starting grep_VARA
    ;


Run drake

    drake --workflow workflow.full.drake

    The following steps will be run, in order:
      1: /home/user/workflow/output/backup/test1.csv <- /home/user/workflow/test1.csv [timestamped]
      2: /home/user/workflow/output/backup/test2.csv <- /home/user/workflow/test2.csv [timestamped]
      3: /home/user/workflow/output/grep_vara/test1.grep_VARA.csv <- /home/user/workflow/output/backup/test1.csv [projected timestamped]
      4: /home/user/workflow/output/grep_vara/test2.grep_VARA.csv <- /home/user/workflow/output/backup/test2.csv [projected timestamped]
      5: /home/user/workflow/output/grep_varb/test1.grep_VARA.grep_VARB.csv <- /home/user/workflow/output/grep_vara/test1.grep_VARA.csv [projected timestamped]
      6: /home/user/workflow/output/grep_varb/test2.grep_VARA.grep_VARB.csv <- /home/user/workflow/output/grep_vara/test2.grep_VARA.csv [projected timestamped]
    Confirm? [y/n] y
    Running 6 steps with concurrence of 1...

    --- 0. Running (timestamped): /home/user/workflow/output/backup/test1.csv <- /home/user/workflow/test1.csv
    --- 0: /home/user/workflow/output/backup/test1.csv <- /home/user/workflow/test1.csv -> done in 0.02s

    --- 1. Running (timestamped): /home/user/workflow/output/backup/test2.csv <- /home/user/workflow/test2.csv
    --- 1: /home/user/workflow/output/backup/test2.csv <- /home/user/workflow/test2.csv -> done in 0.01s

    --- 2. Running (timestamped): /home/user/workflow/output/grep_vara/test1.grep_VARA.csv <- /home/user/workflow/output/backup/test1.csv
    Working on /home/user/workflow/output/backup/test1csv
    --- 2: /home/user/workflow/output/grep_vara/test1.grep_VARA.csv <- /home/user/workflow/output/backup/test1.csv -> done in 0.01s

    --- 3. Running (timestamped): /home/user/workflow/output/grep_vara/test2.grep_VARA.csv <- /home/user/workflow/output/backup/test2.csv
    Working on /home/user/workflow/output/backup/test2csv
    --- 3: /home/user/workflow/output/grep_vara/test2.grep_VARA.csv <- /home/user/workflow/output/backup/test2.csv -> done in 0.01s

    --- 4. Running (timestamped): /home/user/workflow/output/grep_varb/test1.grep_VARA.grep_VARB.csv <- /home/user/workflow/output/grep_vara/test1.grep_VARA.csv
    --- 4: /home/user/workflow/output/grep_varb/test1.grep_VARA.grep_VARB.csv <- /home/user/workflow/output/grep_vara/test1.grep_VARA.csv -> done in 0.01s

    --- 5. Running (timestamped): /home/user/workflow/output/grep_varb/test2.grep_VARA.grep_VARB.csv <- /home/user/workflow/output/grep_vara/test2.grep_VARA.csv
    --- 5: /home/user/workflow/output/grep_varb/test2.grep_VARA.grep_VARB.csv <- /home/user/workflow/output/grep_vara/test2.grep_VARA.csv -> done in 0.08s
    Done (6 steps run).


=head3 Run in minified mode

As an alternative you can run this with the --min option, which instead of
printing out each workflow prints out only one, and creates a run-workflow.sh
which has all of your environmental variables.

This option is preferable if running on an HPC cluster with many nodes.

This WILL break with use of --resample, either local or global. You need to
split up your workflows as opposed to using the --resample option.

    biox-workflow-drake.pl --workflow workflow.yml --min 1 > workflow.drake #This also creates the run-workflow.sh in the same directory
    ./run-workflow.sh

    cat drake.log #Here is the log for the first run

    2015-06-21 14:02:47,543 INFO Running 3 steps with concurrence of 1...
    2015-06-21 14:02:47,568 INFO
    2015-06-21 14:02:47,570 INFO --- 0. Running (timestamped): /home/user/workflow/output/backup/test1.csv <- /home/user/workflow/test1.csv
    2015-06-21 14:02:47,592 INFO --- 0: /home/user/workflow/output/backup/test1.csv <- /home/user/workflow/test1.csv -> done in 0.02s

    #So on and so forth

If you look in the example directory you will see a few png files, these are outputs of the drake workflow.

 =cut

=head1 Acknowledgements

This module was originally developed at and for Weill Cornell Medical
College in Qatar within ITS Advanced Computing Team. With approval from
WCMC-Q, this information was generalized and put on github, for which
the authors would like to express their gratitude.

=head1 Inline Code Documentation

You shouldn't need these, but if you do here they are.

=head2 Attributes

=cut

=head3 full

Print the whole workflow hardcoded. This is the default

=cut

has 'full' => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);

=head3 min

Print the workflow as 2 files.

Run the drake things

    drake --vars "SAMPLE=$sample" --workflow/workflow.drake

workflow.drake

    Our regular file

=cut

has 'min' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

=head2 Subroutines

Subroutines

=head3 before run

Must initialize some variables

=cut

before 'run' => sub{
    my($self) = shift;

    if($self->min){
        $self->full(0);
    }
    $self->wait(0);
    $self->comment_char(';');
};

=head3 after get_samples

Things to do if we decide to do a min version

=cut

after 'get_samples' => sub{
    my($self) = shift;

    return unless $self->min;

    open(my $fh, '>', 'run-workflow.sh') or die print "Could not open file $!\n";

    print $fh "#!/bin/bash\n\n";

    foreach my $sample (@{$self->samples}){
        print $fh <<EOF;
drake --vars "SAMPLE=$sample" --workflow workflow.drake
EOF
    }

    close $fh;

    chmod 0777, 'run-workflow.sh';

    $self->samples(["\$SAMPLE"]);
};

=head3 write_process

Fill in the template with the process

=cut

before 'write_process' => sub{
    my($self) = shift;

    if($self->local_attr){
        if((! $self->local_attr->get_values('INPUT')) && ! $self->local_attr->get_values('OUTPUT') ){
            print "$self->{comment_char} There is no INPUT or OUTPUT!\n";
        }
    }

    my @tmp = split("\n", $self->process);
    $self->process(join("\n\t", @tmp));
};


sub process_template{
    my($self, $data) = @_;

    my($tmp, $template, $newprocess, $INPUT, $OUTPUT);

    $self->INPUT($self->local_attr->get_values('INPUT')) unless $self->INPUT;
    $self->OUTPUT($self->local_attr->get_values('OUTPUT'));

    #Get the INPUT template
    if($self->INPUT){
        $INPUT = $self->INPUT;
        $tmp = "$E{$self->INPUT}";
        $template = $self->make_template($tmp);
        $self->INPUT($template->fill_in(HASH => $data));
    }

    #Get the output template
    if($self->OUTPUT){
        $OUTPUT = $self->OUTPUT;
        $tmp = "$E{$self->OUTPUT}";
        $template = $self->make_template($tmp);
        $self->OUTPUT($template->fill_in(HASH => $data));
    }

    #This is exactly the same as the previous except for this one statement bah
    $tmp = "$E{$self->OUTPUT} <- $E{$self->INPUT}\n\t";
    if($self->min){
        $tmp =~ s/\$SAMPLE/\$[SAMPLE]/g;
    }
    $newprocess = $tmp.$self->process;
    #

    $template = $self->make_template($newprocess);
    $template->fill_in(HASH => $data, OUTPUT => \*STDOUT);

    print "\n\n";

    $self->INPUT($self->local_attr->get_values('INPUT'));
    $self->OUTPUT($self->local_attr->get_values('OUTPUT'));

}

__PACKAGE__->meta->make_immutable;


1;
