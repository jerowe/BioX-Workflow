#
# Generated at: 2015-11-09T10:17:17
# This file was generated with the following options
#	--workflow	config.yml
#	--verbose	
#

#
# Samples: SAMPLE1, SAMPLE2
#
#
# Starting Workflow
#

#
# Starting copy1
#



#
# Variables 
# Indir: /home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA
# Outdir: /home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/copy1
#

echo "Working on /home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA/SAMPLE1/SAMPLE1.csv"
cp "/home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA/SAMPLE1.csv" "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE1/copy1/SAMPLE1.csv"


echo "Working on /home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA/SAMPLE2/SAMPLE2.csv"
cp "/home/jillian/projects/perl/BioX-Workflow/example/bydir/DATA/SAMPLE2.csv" "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE2/copy1/SAMPLE2.csv"



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

echo "Working on /home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE1/copy1/SAMPLE1.csv"
cp "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE1/copy1/SAMPLE1.csv" "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE1/copy2/SAMPLE1.csv"


echo "Working on /home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE2/copy1/SAMPLE2.csv"
cp "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE2/copy1/SAMPLE2.csv" "/home/jillian/projects/perl/BioX-Workflow/example/bydir/OUT/SAMPLE2/copy2/SAMPLE2.csv"



wait

#
# Ending copy2
#

#
# Ending Workflow
#
