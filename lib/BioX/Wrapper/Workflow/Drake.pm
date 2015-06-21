package BioX::Wrapper::Workflow::Drake;

use Data::Dumper;
use Data::Pairs;

use Moose;
extends 'BioX::Wrapper::Workflow';

use Interpolation E => 'eval';

=head1 NAME

BioX::Wrapper::Workflow::Writer::Drake - A very opinionated template based workflow writer for Drake.

=head1 SYNOPSIS

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

    $self->wait(0);
    $self->comment_char(';');
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
    $newprocess = $tmp.$self->process;
    #

    $template = $self->make_template($newprocess);
    $template->fill_in(HASH => $data, OUTPUT => \*STDOUT);

    print "\n\n";

    $self->INPUT($self->local_attr->get_values('INPUT'));
    $self->OUTPUT($self->local_attr->get_values('OUTPUT'));

}

__PACKAGE__->meta->make_immutable;

=head1 Acknowledgements

This module was originally developed at and for Weill Cornell Medical
College in Qatar within ITS Advanced Computing Team. With approval from
WCMC-Q, this information was generalized and put on github, for which
the authors would like to express their gratitude.

=cut

1;
