#!/usr/bin/perl -ws

# hhm08_train_block_acc.pl -- compute block accuracies for a single run
# USAGE: hhm08_train_block_acc.pl <file>

# compute trial accuracies, storing in list of blocks
# report mean accuracies for each block

use Statistics::Descriptive;

open INFILE, $ARGV[0] or die;

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
# and we also need to know the index
#$epochIdx = $headeridx{"Epoch"};

# great, now loop over the rest of the lines and do what needs to be done
$item = 0;
#$thisepoch = 0;
while (<INFILE>)
{
	$item++;
	$block = int(($item-1) / 20) + 1;
	#print "$item $block\n";

	# get fields for each line
	chomp;
	@_ = split /,\s*/;

	# get accuracy and append to a list
	# could convert to a bivariate, but better to keep as probabilities...
	$targetX = ($_[$targetXidx] + 1) / 2;
	$outputX = ($_[$outputXidx] + 0);
	$accuracy = 1 - abs($targetX - $outputX);

	push @{$acc[$block]}, $accuracy;
}

#print scalar @acc - 1, " blocks\n";
#print "block 1: ", join(" ", @{$acc[1]}), "\n";

# foreach block, compute stats and output 

for $b (1..$block)
{
	$stats = Statistics::Descriptive::Full->new();
	$stats->add_data(@{$acc[$b]});

	print "$b ", $stats->mean(), "\n";
}


