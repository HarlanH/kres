#!/usr/bin/perl -ws

# script to calculate the number of errors made on each exemplar of wdmm86
#
# usage: wdmm86_item_errors.pl <list of filenames> 

# foreach file
#  foreach line
#   construct exemplar as Input(A0)+Input(A1)... 
#   figure out P(error), and sum
# report overall results

%errs = ();

$numfiles = 0;

foreach $filename (@ARGV)
{
	open INFILE, $filename or die;

	$numfiles++;

	# get the header, and calculate indexes
	$headerline = <INFILE>;
	chomp($headerline);
	@headers = split(/,\s*/, $headerline);

	for ($h = 0; $h < scalar @headers; $h++)
	{
		$headeridx{$headers[$h]} = $h;
	}

	# great, now loop over the rest of the lines and do what needs to be done
	

	while (<INFILE>)
	{
		chomp;
		@_ = split /,\s*/;

		# construct item key
		$A0 = (int($_[$headeridx{"Input(A0)"}]) + 1) / 2;
		$B0 = (int($_[$headeridx{"Input(B0)"}]) + 1) / 2;
		$C0 = (int($_[$headeridx{"Input(C0)"}]) + 1) / 2;
		$D0 = (int($_[$headeridx{"Input(D0)"}]) + 1) / 2;
		$key = $A0 . $B0 . $C0 . $D0;

		# given Output(X), decide on output, and see if it matches Input(X)
		$OIdx = $headeridx{"Output(X)"};
		$IIdx = $headeridx{"Input(X)"};
		$PofX = $_[$OIdx] + 0;
		$TargetIsX = ($_[$IIdx] + 1) / 2;

		$errs{$key} += abs($PofX - $TargetIsX);

	}

}

foreach $k (sort keys %errs)
{
	if ($terse)
	{
		print $errs{$k} / $numfiles . " ";
	}
	else
	{
		print "$k " . $errs{$k} / $numfiles . "\n";
	}
}
print "\n" if $terse;
