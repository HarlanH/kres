#!/usr/bin/perl -ws

# hhm08_train_summary.pl -- generate a report of training curves
# USAGE: hhm08_train_summary.pl <directory>

#  foreach replication
#   get the per-block accuracies
# output a per-block summary 

use Statistics::Descriptive;

# ARGV[0] is a directory name. Glob the file names for the two conditions.
$filespec = "$ARGV[0]/log-train-trial-*.dat";
@filenames = glob $filespec;

#print join("\n", @{$filenames[1]}), "\n";
#print join("\n", @{$filenames[2]}), "\n";

for $runfilename (@filenames)
{
	# run this file through hhm08_train_block_acc.pl, and snag the result
	@result = `./hhm08_train_block_acc.pl $runfilename`;

	#print "$runfilename:", scalar @result, " #\n";

	for ($line = 1; $line <= 4; $line++)
	{
		$_ = $result[$line-1];
		chomp;
		@_ = split;
		$acc = $_[1];

		# store for later stats
		push @{$res[$line]}, $acc;
	}
}

for $b (1..4)	# block
{
	$stats = Statistics::Descriptive::Full->new();
	$stats->add_data(@{$res[$b]});
	
	print "$b ", $stats->mean(), " ", $stats->standard_deviation(), "\n";
}
