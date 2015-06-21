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

=head3 Run it with default setup

    biox-workflow-drake.pl --workflow workflow.yml > workflow.full.drake
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

    biox-workflow-drake.pl --workflow workflow.yml --min 1 > workflow.drake #This also creates the run-workflow.sh in the same directory
    ./run-workflow.sh

    cat drake.log #Here is the log for the first run

    2015-06-21 14:02:47,543 INFO Running 3 steps with concurrence of 1...
    2015-06-21 14:02:47,568 INFO
    2015-06-21 14:02:47,570 INFO --- 0. Running (timestamped): /home/user/workflow/output/backup/test1.csv <- /home/user/workflow/test1.csv
    2015-06-21 14:02:47,592 INFO --- 0: /home/user/workflow/output/backup/test1.csv <- /home/user/workflow/test1.csv -> done in 0.02s
    2015-06-21 14:02:47,597 INFO
    2015-06-21 14:02:47,598 INFO --- 1. Running (timestamped): /home/user/workflow/output/grep_vara/test1.grep_VARA.csv <- /home/user/workflow/output/backup/test1.csv
    2015-06-21 14:02:47,612 INFO --- 1: /home/user/workflow/output/grep_vara/test1.grep_VARA.csv <- /home/user/workflow/output/backup/test1.csv -> done in 0.01s
    2015-06-21 14:02:47,614 INFO
    2015-06-21 14:02:47,615 INFO --- 2. Running (timestamped): /home/user/workflow/output/grep_varb/test1.grep_VARA.grep_VARB.csv <- /home/user/workflow/output/grep_vara/test1.grep_VARA.csv
    2015-06-21 14:02:47,626 INFO --- 2: /home/user/workflow/output/grep_varb/test1.grep_VARA.grep_VARB.csv <- /home/user/workflow/output/grep_vara/test1.grep_VARA.csv -> done in 0.01s
    2015-06-21 14:02:47,628 INFO Done (3 steps run).




=head1 Acknowledgements

This module was originally developed at and for Weill Cornell Medical
College in Qatar within ITS Advanced Computing Team. With approval from
WCMC-Q, this information was generalized and put on github, for which
the authors would like to express their gratitude.

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
