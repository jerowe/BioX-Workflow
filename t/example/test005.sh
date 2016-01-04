#!/bin/bash

#
# Generated at: 2016-01-04T06:13:16
# This file was generated with the following options
#	--select_rules	backup
#	--select_rules	grep_VARA
#	--workflow	t/example/test004.yml
#	--samples	sample2
#	--samples	sample1
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



wait

#
# Ending grep_VARA
#

#
# Ending Workflow
#
