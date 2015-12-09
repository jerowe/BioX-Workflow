package TestsFor::BioX::Workflow::Test003;
use Test::Class::Moose;
use BioX::Workflow;
use Cwd;
use FindBin qw($Bin);
use File::Path qw(make_path remove_tree);
use IPC::Cmd qw[can_run];
use Data::Dumper;
use Capture::Tiny ':all';
use Slurp;

sub test_001 :Tags(samples) {
    my $test = shift;

    for(my $i=1; $i<=5; $i++){
        make_path("$Bin/example/data/raw/test003/sample$i");
    }

    ok(1);
}

sub test_006 :Tags(output) {
    my $test = shift;

    my $obj = BioX::Workflow->new(workflow => "$Bin/example/test003.yml");
    isa_ok($obj, 'BioX::Workflow');

    my $expected = slurp("$Bin/example/test003.sh");

    my $got = capture {
        $obj->init_things;
        $obj->write_workflow_meta('start');

        $obj->write_pipeline;

        $obj->write_workflow_meta('end');
    };
    is($got, $expected, "Got expected output!" );
    ok(-d "$Bin/example/data/processed/test003");

    #my @processes = qw(backup grep_VARA grep_VARB);

    #foreach my $sample (@{$obj->samples}){
        #foreach my $process (@processes){
            #ok(-d "$Bin/example/data/processed/test003/$sample/$process", "Sample $sample Process $process dir exists");
        #}
    #}
}

1;
