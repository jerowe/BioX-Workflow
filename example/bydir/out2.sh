#!/bin/bash

#
# Generated at: 2015-11-10T10:18:02
# This file was generated with the following options
#	--workflow	config2.yml
#

#
# Samples: SAMPLE1, SAMPLE2
#
#
# Starting Workflow
#

#
# 
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA
# Outdir: /home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/copy1
# Local Variables:
#	INPUT: {$self->indir}/{$sample}.csv
#

echo "Working on /home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA/SAMPLE1/SAMPLE1/SAMPLE1.csv"
cp "/home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA/SAMPLE1/SAMPLE1.csv" "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE1/copy1/SAMPLE1.csv"


echo "Working on /home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA/SAMPLE2/SAMPLE2/SAMPLE2.csv"
cp "/home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA/SAMPLE2/SAMPLE2.csv" "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE2/copy1/SAMPLE2.csv"



wait

#
# Ending copy1
#


#
# Starting copy2
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/copy1
# Outdir: /home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/copy2
#

echo "Working on /home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/copy1/SAMPLE1.csv"
cp "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/copy1/SAMPLE1.csv" "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE1/copy2/SAMPLE1.csv"


echo "Working on /home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/copy1/SAMPLE2.csv"
cp "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/copy1/SAMPLE2.csv" "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE2/copy2/SAMPLE2.csv"



wait

#
# Ending copy2
#

#
# Ending Workflow
#
