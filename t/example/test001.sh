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
#	indir: t/example/data/raw/test001
#	outdir: t/example/data/processed/test001
#	min: 0
#	override_process: 0
#	rule_based: 1
#	verbose: 1
#	file_rule: (.*).csv$
#

#
#

# Starting backup
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test001
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup
#

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test001/sample1.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample1.csv

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test001/sample2.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample2.csv

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test001/sample3.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample3.csv

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test001/sample4.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample4.csv

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test001/sample5.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample5.csv


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
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA
#

echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample1.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample1.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample1.grep_VARA.csv


echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample2.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample2.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample2.grep_VARA.csv


echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample3.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample3.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample3.grep_VARA.csv


echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample4.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample4.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample4.grep_VARA.csv


echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample5.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/backup/sample5.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample5.grep_VARA.csv



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
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARB
#

grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample1.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARB/sample1.grep_VARA.grep_VARB.csv


grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample2.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARB/sample2.grep_VARA.grep_VARB.csv


grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample3.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARB/sample3.grep_VARA.grep_VARB.csv


grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample4.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARB/sample4.grep_VARA.grep_VARB.csv


grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARA/sample5.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test001/grep_VARB/sample5.grep_VARA.grep_VARB.csv



wait

#
# Ending grep_VARB
#

#
# Ending Workflow
#
