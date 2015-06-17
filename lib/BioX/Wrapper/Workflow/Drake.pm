package BioX::Wrapper::Workflow::Drake;

use Data::Dumper;
use Moose;
extends 'BioX::Wrapper::Workflow';

=head1 NAME

BioX::Wrapper::Workflow::Writer::Drake - A very opinionated template based workflow writer for Drake.

=head1 SYNOPSIS

=head2 Things

=head3 before write_pipeline

We need to initialize some values for before write pipeline

=cut

before 'write_pipeline' => sub{
    my($self) = shift;

    print "Before in write pipeline!\n";
    print Dumper($self)."\n";
};

=head3 write_process

Fill in the template with the process

=cut

sub write_process{
    my($self, $override, $process) = @_;

    my $template = $self->make_template($process);

    if(!$override){

        foreach my $sample (@{$self->samples}){
            $template->fill_in(HASH => {self => \$self, sample => $sample}, OUTPUT => \*STDOUT);
            print "\n";
        }
    }
    else{
        # Example
        #my $tt =(<<'EOF');
        #{
        #foreach my $infile (@{$self->infiles}){
           #$OUT .= $infile."\n";
        #}
        #}
        $template->fill_in(HASH => {self => \$self}, OUTPUT => \*STDOUT);
        print "\n";
    }

    if($self->wait){
        print "\nwait\n";
    }

}

1;
