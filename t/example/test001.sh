#
# Samples: sample2, sample1, sample5, sample3, sample4
#
#
# Starting Workflow
#

#
#

# Starting backup
#



#
# Variables 
# Indir: t/example/data/raw/test001
# Outdir: t/example/data/processed/test001/backup
#

cp t/example/data/raw/test001/sample2.csv t/example/data/processed/test001/backup/sample2.csv

cp t/example/data/raw/test001/sample1.csv t/example/data/processed/test001/backup/sample1.csv

cp t/example/data/raw/test001/sample5.csv t/example/data/processed/test001/backup/sample5.csv

cp t/example/data/raw/test001/sample3.csv t/example/data/processed/test001/backup/sample3.csv

cp t/example/data/raw/test001/sample4.csv t/example/data/processed/test001/backup/sample4.csv


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
# Indir: t/example/data/processed/test001/backup
# Outdir: t/example/data/processed/test001/grep_VARA
#

echo "Working on t/example/data/processed/test001/backup/sample2.csv"
grep -i "VARA" t/example/data/processed/test001/backup/sample2.csv >> t/example/data/processed/test001/grep_VARA/sample2.grep_VARA.csv


echo "Working on t/example/data/processed/test001/backup/sample1.csv"
grep -i "VARA" t/example/data/processed/test001/backup/sample1.csv >> t/example/data/processed/test001/grep_VARA/sample1.grep_VARA.csv


echo "Working on t/example/data/processed/test001/backup/sample5.csv"
grep -i "VARA" t/example/data/processed/test001/backup/sample5.csv >> t/example/data/processed/test001/grep_VARA/sample5.grep_VARA.csv


echo "Working on t/example/data/processed/test001/backup/sample3.csv"
grep -i "VARA" t/example/data/processed/test001/backup/sample3.csv >> t/example/data/processed/test001/grep_VARA/sample3.grep_VARA.csv


echo "Working on t/example/data/processed/test001/backup/sample4.csv"
grep -i "VARA" t/example/data/processed/test001/backup/sample4.csv >> t/example/data/processed/test001/grep_VARA/sample4.grep_VARA.csv



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
# Indir: t/example/data/processed/test001/grep_VARA
# Outdir: t/example/data/processed/test001/grep_VARB
#

grep -i "VARB" t/example/data/processed/test001/grep_VARA/sample2.grep_VARA.csv >> t/example/data/processed/test001/grep_VARB/sample2.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test001/grep_VARA/sample1.grep_VARA.csv >> t/example/data/processed/test001/grep_VARB/sample1.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test001/grep_VARA/sample5.grep_VARA.csv >> t/example/data/processed/test001/grep_VARB/sample5.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test001/grep_VARA/sample3.grep_VARA.csv >> t/example/data/processed/test001/grep_VARB/sample3.grep_VARA.grep_VARB.csv


grep -i "VARB" t/example/data/processed/test001/grep_VARA/sample4.grep_VARA.csv >> t/example/data/processed/test001/grep_VARB/sample4.grep_VARA.grep_VARB.csv



wait

#
# Ending grep_VARB
#

#
# Ending Workflow
#
