#
# Samples: .csv
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
#	indir: t/example/data/raw/test004
#	outdir: t/example/data/processed/test004
#	min: 0
#	override_process: 0
#	rule_based: 1
#	verbose: 1
#	file_rule: (.csv)$
#

#
#

# Starting backup
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test004
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/backup
#

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test004/.csv.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/backup/.csv.csv


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
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/backup
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/grep_VARA
#

echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/backup/.csv.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/backup/.csv.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/grep_VARA/.csv.grep_VARA.csv



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
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/grep_VARA
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/grep_VARB
#

grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/grep_VARA/.csv.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test004/grep_VARB/.csv.grep_VARA.grep_VARB.csv



wait

#
# Ending grep_VARB
#

#
# Ending Workflow
#
