#!/bin/bash
#
# Samples: sample1, sample2, sample3, sample4, sample5
#
#
# Starting Workflow
#
#
# Global Variables:
#	resample: 0
#	wait: 1
#	auto_input: 1
#	coerce_paths: 1
#	auto_name: 1
#	indir: t/example/data/raw/test005
#	outdir: t/example/data/processed/test005
#	min: 1
#	override_process: 0
#	rule_based: 1
#	verbose: 1
#	file_rule: (.*).csv
#

#
#

# Starting backup
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test005
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/backup
#

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test005/${SAMPLE}.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/backup/${SAMPLE}.csv


wait

#
# Ending backup
#


#
#

# Starting grep_VARA
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/backup
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/grep_VARA
#

echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/backup/${SAMPLE}.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/backup/${SAMPLE}.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/grep_VARA/${SAMPLE}.grep_VARA.csv



wait

#
# Ending grep_VARA
#


#
#

# Starting grep_VARB
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/grep_VARA
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/grep_VARB
#

grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/grep_VARA/${SAMPLE}.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test005/grep_VARB/${SAMPLE}.grep_VARA.grep_VARB.csv



wait

#
# Ending grep_VARB
#

#
# Ending Workflow
#
