package BioX::Wrapper::Workflow::Drake;

use Data::Dumper;
use Moose;
extends 'BioX::Wrapper::Workflow';

=head1 NAME

BioX::Wrapper::Workflow::Writer::Drake - A very opinionated template based workflow writer for Drake.

=head1 SYNOPSIS

=head2 Things

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

    my $aref = $self->local_rule->{$self->key}->{local};
    my(%seen, @keys);

    foreach my $a (@$aref){
       push @keys, keys %{ $aref->[$a] };
    }
    %seen = map{ $_ => 1 } @keys;

    print Dumper(\%seen);

    if(! exists $seen{'INPUT'} || ! exists $seen{'OUTPUT'} ){
        die print "You must specify an INPUT or an OUTPUT!\n";
    }

};

sub write_process{
    my($self, $override, $process) = @_;

    my $template = $self->make_template($process);

    $process .= "{$self->OUTPUT} <- {$self->INPUT}\n";

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

after 'write_process' => sub{
    my($self) = shift;

    $self->INPUT('');
    $self->OUTPUT('');
};


=head1 Acknowledgements

This module was originally developed at and for Weill Cornell Medical
College in Qatar within ITS Advanced Computing Team. With approval from
WCMC-Q, this information was generalized and put on github, for which
the authors would like to express their gratitude.

=cut

1;
