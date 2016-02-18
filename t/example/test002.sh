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
#	indir: t/example/data/raw/test002
#	outdir: t/example/data/processed/test002
#	min: 0
#	override_process: 0
#	rule_based: 1
#	verbose: 1
#	file_rule: (sample.*)$
#	by_sample_outdir: 1
#	find_by_dir: 1
#

#
#

# Starting backup
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test002
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/backup
#

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test002/sample1/sample1.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample1/backup/sample1.csv

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test002/sample2/sample2.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample2/backup/sample2.csv

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test002/sample3/sample3.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample3/backup/sample3.csv

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test002/sample4/sample4.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample4/backup/sample4.csv

cp /home/jillian/projects/perl/BioX-Workflow/t/example/data/raw/test002/sample5/sample5.csv /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample5/backup/sample5.csv


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
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/backup
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/grep_VARA
#

echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample1/backup/sample1.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample1/backup/sample1.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample1/grep_VARA/sample1.grep_VARA.csv


echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample2/backup/sample2.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample2/backup/sample2.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample2/grep_VARA/sample2.grep_VARA.csv


echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample3/backup/sample3.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample3/backup/sample3.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample3/grep_VARA/sample3.grep_VARA.csv


echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample4/backup/sample4.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample4/backup/sample4.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample4/grep_VARA/sample4.grep_VARA.csv


echo "Working on /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample5/backup/sample5.csv"
grep -i "VARA" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample5/backup/sample5.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample5/grep_VARA/sample5.grep_VARA.csv



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
# Indir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/grep_VARA
# Outdir: /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/grep_VARB
#

grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample1/grep_VARA/sample1.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample1/grep_VARB/sample1.grep_VARA.grep_VARB.csv


grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample2/grep_VARA/sample2.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample2/grep_VARB/sample2.grep_VARA.grep_VARB.csv


grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample3/grep_VARA/sample3.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample3/grep_VARB/sample3.grep_VARA.grep_VARB.csv


grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample4/grep_VARA/sample4.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample4/grep_VARB/sample4.grep_VARA.grep_VARB.csv


grep -i "VARB" /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample5/grep_VARA/sample5.grep_VARA.csv >> /home/jillian/projects/perl/BioX-Workflow/t/example/data/processed/test002/sample5/grep_VARB/sample5.grep_VARA.grep_VARB.csv



wait

#
# Ending grep_VARB
#

#
# Ending Workflow
#
