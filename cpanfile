requires 'perl', '5.008005';
requires 'Cwd';
requires 'Data::Dumper';
requires 'DateTime';
requires 'File::Basename';
requires 'File::Find::Rule';
requires 'File::Path';
requires 'File::Basename';

requires 'Moose';
requires 'MooseX::Getopt';
requires 'MooseX::Getopt::Usage';
requires 'MooseX::SimpleConfig';
requires 'BioX::Wrapper';
requires 'MooseX::Getopt::Usage';
requires 'MooseX::Getopt::Usage::Role::Man';

requires 'YAML::XS';
requires 'String::CamelCase';
requires 'Class::Load';
requires 'IO::File';
requires 'Interpolation';
requires 'Text::Template';

# requires 'Some::Module', 'VERSION';

on test => sub {
    requires 'Test::More', '0.96';
};
