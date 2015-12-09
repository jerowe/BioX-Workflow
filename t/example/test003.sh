#
# Samples: sample1, sample2, sample3, sample4, sample5
#
#
# Starting Workflow
#
#
# Global Variables:
#	indir: t/example/data/raw/test003
#	outdir: t/example/data/processed/test003
#	ROOT: t/example/data/processed/test003
#	file_rule: (sample.*)$
#	by_sample_outdir: 1
#	find_by_dir: 1
#	LOCAL_VAR: This should be overwritten
#

#
#

# Starting backup
#



#
# Variables 
# Indir: t/example/data/raw/test003
# Outdir: t/example/data/processed/test003/backup
# Local Variables:
#	LOCAL_VAR: my_local_var
#	analysis_dir: {$self->ROOT}/analysis
#	outdir: t/example/data/processed/test003/backup
#	indir: t/example/data/raw/test003
#

echo "my_local_var" && \
echo t/example/data/processed/test003/analysis && \
cp t/example/data/raw/test003/sample1/sample1.csv t/example/data/processed/test003/sample1/backup/sample1.csv


echo "my_local_var" && \
echo t/example/data/processed/test003/analysis && \
cp t/example/data/raw/test003/sample2/sample2.csv t/example/data/processed/test003/sample2/backup/sample2.csv


echo "my_local_var" && \
echo t/example/data/processed/test003/analysis && \
cp t/example/data/raw/test003/sample3/sample3.csv t/example/data/processed/test003/sample3/backup/sample3.csv


echo "my_local_var" && \
echo t/example/data/processed/test003/analysis && \
cp t/example/data/raw/test003/sample4/sample4.csv t/example/data/processed/test003/sample4/backup/sample4.csv


echo "my_local_var" && \
echo t/example/data/processed/test003/analysis && \
cp t/example/data/raw/test003/sample5/sample5.csv t/example/data/processed/test003/sample5/backup/sample5.csv



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
# Indir: t/example/data/processed/test003/backup
# Outdir: t/example/data/processed/test003/grep_VARA
# Local Variables:
#	LOCAL_VAR: my_local_new_var
#	outdir: t/example/data/processed/test003/grep_VARA
#	indir: t/example/data/processed/test003/backup
#

echo "my_local_new_var" && \
echo "Working on t/example/data/processed/test003/sample1/backup/sample1.csv"
grep -i "VARA" t/example/data/processed/test003/sample1/backup/sample1.csv >> t/example/data/processed/test003/sample1/grep_VARA/sample1.grep_VARA.csv


echo "my_local_new_var" && \
echo "Working on t/example/data/processed/test003/sample2/backup/sample2.csv"
grep -i "VARA" t/example/data/processed/test003/sample2/backup/sample2.csv >> t/example/data/processed/test003/sample2/grep_VARA/sample2.grep_VARA.csv


echo "my_local_new_var" && \
echo "Working on t/example/data/processed/test003/sample3/backup/sample3.csv"
grep -i "VARA" t/example/data/processed/test003/sample3/backup/sample3.csv >> t/example/data/processed/test003/sample3/grep_VARA/sample3.grep_VARA.csv


echo "my_local_new_var" && \
echo "Working on t/example/data/processed/test003/sample4/backup/sample4.csv"
grep -i "VARA" t/example/data/processed/test003/sample4/backup/sample4.csv >> t/example/data/processed/test003/sample4/grep_VARA/sample4.grep_VARA.csv


echo "my_local_new_var" && \
echo "Working on t/example/data/processed/test003/sample5/backup/sample5.csv"
grep -i "VARA" t/example/data/processed/test003/sample5/backup/sample5.csv >> t/example/data/processed/test003/sample5/grep_VARA/sample5.grep_VARA.csv



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
# Indir: t/example/data/processed/test003/grep_VARA
# Outdir: t/example/data/processed/test003/grep_VARB
#

echo "This should be overwritten" && \
grep -i "VARB" t/example/data/processed/test003/sample1/grep_VARA/sample1.grep_VARA.csv >> t/example/data/processed/test003/sample1/grep_VARB/sample1.grep_VARA.grep_VARB.csv


echo "This should be overwritten" && \
grep -i "VARB" t/example/data/processed/test003/sample2/grep_VARA/sample2.grep_VARA.csv >> t/example/data/processed/test003/sample2/grep_VARB/sample2.grep_VARA.grep_VARB.csv


echo "This should be overwritten" && \
grep -i "VARB" t/example/data/processed/test003/sample3/grep_VARA/sample3.grep_VARA.csv >> t/example/data/processed/test003/sample3/grep_VARB/sample3.grep_VARA.grep_VARB.csv


echo "This should be overwritten" && \
grep -i "VARB" t/example/data/processed/test003/sample4/grep_VARA/sample4.grep_VARA.csv >> t/example/data/processed/test003/sample4/grep_VARB/sample4.grep_VARA.grep_VARB.csv


echo "This should be overwritten" && \
grep -i "VARB" t/example/data/processed/test003/sample5/grep_VARA/sample5.grep_VARA.csv >> t/example/data/processed/test003/sample5/grep_VARB/sample5.grep_VARA.grep_VARB.csv



wait

#
# Ending grep_VARB
#

#
# Ending Workflow
#
