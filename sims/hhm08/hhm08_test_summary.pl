#!/usr/bin/perl -ws

# hhm08_test_summary.pl -- generate a report of test accuracies and settle times. 
# USAGE: hhm08_test_summary.pl <trained dims> <directory>

#  foreach replication
#   get the mean response accuracy for each category of test
# output a summary for each test type

use Statistics::Descriptive;

# items: 1-20
# single-feature: 21 - (21+traineddims-1), 31 - (31+traineddims-1)

# ARGV[0] is the number of dimensions used for training
$traineddims = $ARGV[0] + 0;

# ARGV[1] is a directory name. Glob the file names for the two conditions.
$filespec = "$ARGV[1]/log-test-trial-*.dat";
@filenames = glob $filespec;

#print join("\n", @{$filenames[1]}), "\n";
#print join("\n", @{$filenames[2]}), "\n";

for $runfilename (@filenames)
{
	#print "$runfilename\n";
	open INFILE, $runfilename or die;

	# get the header, and calculate indexes
	$headerline = <INFILE>;
	chomp($headerline);
	@headers = split(/,\s*/, $headerline);

	for ($h = 0; $h < scalar @headers; $h++)
	{
		$headeridx{$headers[$h]} = $h;
	}
	$targetXidx = $headeridx{"Input(X)"};	# these are the two we most need
	$outputXidx = $headeridx{"Output(X)"};
	$settleidx = $headeridx{"SettleTime"};	# and this
	#die "$settleidx != 92" unless $settleidx == 92;

	@itemAcc = ();
	@SFAcc = ();
	@itemST = ();
	@SFST = ();
	@SFAcc4 = ();
	#@HF = (); @LF = (); @proto = (); @exception = (); @normal = ();

	# great, now loop over the rest of the lines and do what needs to be done
	for ($item = 1; $item <= 40; $item++)
	{
		# get fields for each line
		$_ = <INFILE>;
		chomp($_);
		@_ = split /,\s*/;

		# get accuracy and append to a list
		$targetX = ($_[$targetXidx] + 1) / 2;
		$outputX = ($_[$outputXidx] + 0);
		$accuracy = 1 - abs($targetX - $outputX);

		push @itemAcc, $accuracy if $item <= 20;
		push @SFAcc, $accuracy if ($item >= 21 and $item < 21 + $traineddims);
		push @SFAcc, $accuracy if ($item >= 31 and $item < 31 + $traineddims);

		# weird stuff to calculate real SF items learned
		$sfidx = -1;
		$sfidx = $item - 21 if ($item >= 21 and $item < 21 + $traineddims);
		$sfidx = $item - 31 if ($item >= 31 and $item < 31 + $traineddims);
		$SFAcc4[$sfidx] += $accuracy if $sfidx != -1;

		# and do the same for settle time
		$settleTime = ($_[$settleidx] + 0);

		push @itemST, $settleTime if $item <= 20;
		push @SFST, $settleTime if ($item >= 21 and $item < 21 + $traineddims);
		push @SFST, $settleTime if ($item >= 31 and $item < 31 + $traineddims);
	}

	die "itemAcc=@itemAcc" if scalar @itemAcc != 20;
	die "SFAcc=@SFAcc" if scalar @SFAcc != $traineddims*2;

	# now we've got arrays for this file, but we need the mean for the file

	# compute and report file-level stats
	$itemAccStats = Statistics::Descriptive::Full->new();
	$SFAccStats = Statistics::Descriptive::Full->new();
	$itemSTStats = Statistics::Descriptive::Full->new();
	$SFSTStats = Statistics::Descriptive::Full->new();
	$itemAccStats->add_data(@itemAcc);
	$SFAccStats->add_data(@SFAcc);
	$itemSTStats->add_data(@itemST);
	$SFSTStats->add_data(@SFST);
	
	# delete this later
	#print "$runfilename:\n";
	#printf("HF   : %0.2f  (%d-%d)\n", $HFstats->mean(), $HFstats->min(), $HFstats->max());
	#printf("LF   : %0.2f  (%d-%d)\n", $LFstats->mean(), $LFstats->min(), $LFstats->max());
	#printf("proto: %0.2f  (%d-%d)\n", $protostats->mean(), $protostats->min(), $protostats->max());
	#printf("excep: %0.2f  (%d-%d)\n", $exceptionstats->mean(), $exceptionstats->min(), $exceptionstats->max());
	#printf("norml: %0.2f  (%d-%d)\n", $normalstats->mean(), $normalstats->min(), $normalstats->max());
	#print "\n";

	# now, grab the mean and store it for summary stats
	push @itemAccSum, $itemAccStats->mean();
	push @SFAccSum, $SFAccStats->mean();
	push @itemSTSum, $itemSTStats->mean();
	push @SFSTSum, $SFSTStats->mean();

	# now calculate the sum-of-fourths of the average SF accs
	$SFAcc4Sum = 0;
	for $i (1..$traineddims)
	{
		$SFAcc4Sum += ($SFAcc4[$i-1]/2)**4;
	}
	push @SFAcc4Sum, $SFAcc4Sum;

	close INFILE;
}

$itemAcc = Statistics::Descriptive::Full->new();
$SFAcc = Statistics::Descriptive::Full->new();
$itemST = Statistics::Descriptive::Full->new();
$SFST = Statistics::Descriptive::Full->new();
$itemAcc->add_data(@itemAccSum);
$SFAcc->add_data(@SFAccSum);
$itemST->add_data(@itemSTSum);
$SFST->add_data(@SFSTSum);
$SFAcc4 = Statistics::Descriptive::Full->new();
$SFAcc4->add_data(@SFAcc4Sum);

push @stats, $itemAcc->mean(), $SFAcc->mean(), $itemST->mean(), 
	$SFST->mean(), $SFAcc4->mean();

print join("\t", @stats), "\n";

