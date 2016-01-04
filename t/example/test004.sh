#!/bin/bash

#
# Generated at: 2016-01-04T05:54:10
# This file was generated with the following options
#	--select_rules	backup
#	--select_rules	grep_VARA
#	--workflow	t/example/test004.yml
#

#
# Samples: sample1, sample2, sample3, sample4, sample5
#
#
# Starting Workflow
#
#
# Global Variables:
#	indir: t/example/data/raw/test004
#	outdir: t/example/data/processed/test004
#	file_rule: (.csv)$
#

#
#

# Starting backup
#



#
# Variables 
# Indir: t/example/data/raw/test004
# Outdir: t/example/data/processed/test004/backup
#

cp t/example/data/raw/test004/sample1.csv t/example/data/processed/test004/backup/sample1.csv

cp t/example/data/raw/test004/sample2.csv t/example/data/processed/test004/backup/sample2.csv

cp t/example/data/raw/test004/sample3.csv t/example/data/processed/test004/backup/sample3.csv

cp t/example/data/raw/test004/sample4.csv t/example/data/processed/test004/backup/sample4.csv

cp t/example/data/raw/test004/sample5.csv t/example/data/processed/test004/backup/sample5.csv


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
# Indir: t/example/data/processed/test004/backup
# Outdir: t/example/data/processed/test004/grep_VARA
#

echo "Working on t/example/data/processed/test004/backup/sample1.csv"
grep -i "VARA" t/example/data/processed/test004/backup/sample1.csv >> t/example/data/processed/test004/grep_VARA/sample1.grep_VARA.csv


echo "Working on t/example/data/processed/test004/backup/sample2.csv"
grep -i "VARA" t/example/data/processed/test004/backup/sample2.csv >> t/example/data/processed/test004/grep_VARA/sample2.grep_VARA.csv


echo "Working on t/example/data/processed/test004/backup/sample3.csv"
grep -i "VARA" t/example/data/processed/test004/backup/sample3.csv >> t/example/data/processed/test004/grep_VARA/sample3.grep_VARA.csv


echo "Working on t/example/data/processed/test004/backup/sample4.csv"
grep -i "VARA" t/example/data/processed/test004/backup/sample4.csv >> t/example/data/processed/test004/grep_VARA/sample4.grep_VARA.csv


echo "Working on t/example/data/processed/test004/backup/sample5.csv"
grep -i "VARA" t/example/data/processed/test004/backup/sample5.csv >> t/example/data/processed/test004/grep_VARA/sample5.grep_VARA.csv



wait

#
# Ending grep_VARA
#

#
# Ending Workflow
#