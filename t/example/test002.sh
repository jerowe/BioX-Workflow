#
# Samples: sample5, sample1, sample3, sample, sample4, sample2
#
#
# Starting Workflow
#
#
# Global Variables:
#	indir: t/example/data/raw/test002
#	outdir: t/example/data/processed/test002
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
# Indir: t/example/data/raw/test002
# Outdir: t/example/data/processed/test002/backup
#

cp t/example/data/raw/test002/sample5/sample5.csv t/example/data/processed/test002/sample5/backup/sample5.csv

cp t/example/data/raw/test002/sample1/sample1.csv t/example/data/processed/test002/sample1/backup/sample1.csv

cp t/example/data/raw/test002/sample3/sample3.csv t/example/data/processed/test002/sample3/backup/sample3.csv

cp t/example/data/raw/test002/sample/sample.csv t/example/data/processed/test002/sample/backup/sample.csv

cp t/example/data/raw/test002/sample4/sample4.csv t/example/data/processed/test002/sample4/backup/sample4.csv

cp t/example/data/raw/test002/sample2/sample2.csv t/example/data/processed/test002/sample2/backup/sample2.csv


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
# Indir: t/example/data/processed/test002/backup
# Outdir: t/example/data/processed/test002/grep_VARA
#

echo "Working on t/example/data/processed/test002/sample5/backup/sample5.csv"
grep -i "VARA" t/example/data/processed/test002/sample5/backup/sample5.csv >> t/example/data/processed/test002/sample5/grep_VARA/sample5.grep_VARA.csv


echo "Working on t/example/data/processed/test002/sample1/backup/sample1.csv"
grep -i "VARA" t/example/data/processed/test002/sample1/backup/sample1.csv >> t/example/data/processed/test002/sample1/grep_VARA/sample1.grep_VARA.csv


echo "Working on t/example/data/processed/test002/sample3/backup/sample3.csv"
grep -i "VARA" t/example/data/processed/test002/sample3/backup/sample3.csv >> t/example/data/processed/test002/sample3/grep_VARA/sample3.grep_VARA.csv


echo "Working on t/example/data/processed/test002/sample/backup/sample.csv"
grep -i "VARA" t/example/data/processed/test002/sample/backup/sample.csv >> t/example/data/processed/test002/sample/grep_VARA/sample.grep_VARA.csv


echo "Working on t/example/data/processed/test002/sample4/backup/sample4.csv"
grep -i "VARA" t/example/data/processed/test002/sample4/backup/sample4.csv >> t/example/data/processed/test002/sample4/grep_VARA/sample4.grep_VARA.csv


echo "Working on t/example/data/processed/test002/sample2/backup/sample2.csv"
grep -i "VARA" t/example/data/processed/test002/sample2/backup/sample2.csv >> t/example/data/processed/test002/sample2/grep_VARA/sample2.grep_VARA.csv



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
# Indir: t/example/data/processed/test002/grep_VARA
# Outdir: t/example/data/processed/test002/grep_VARB
#

grep -i "VARB" t/example/data/processed/test002/sample5/grep_VARA/sample5.grep_VARA.csv >> t/example/data/processed/test002/sample5/grep_VARB/sample5.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test002/sample1/grep_VARA/sample1.grep_VARA.csv >> t/example/data/processed/test002/sample1/grep_VARB/sample1.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test002/sample3/grep_VARA/sample3.grep_VARA.csv >> t/example/data/processed/test002/sample3/grep_VARB/sample3.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test002/sample/grep_VARA/sample.grep_VARA.csv >> t/example/data/processed/test002/sample/grep_VARB/sample.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test002/sample4/grep_VARA/sample4.grep_VARA.csv >> t/example/data/processed/test002/sample4/grep_VARB/sample4.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test002/sample2/grep_VARA/sample2.grep_VARA.csv >> t/example/data/processed/test002/sample2/grep_VARB/sample2.grep_VARA.grep_VARB.csv



wait

#
# Ending grep_VARB
#

#
# Ending Workflow
#
