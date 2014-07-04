use strict;
use List::Util qw [max];

# refname - name of reference sequence hit
# refstart - start of alignment in reference
# refalnsize - size of alignment in reference
# refstrand - reference strand
# refseqsize - size of reference sequence
# refseq - gapped reference sequence
# realref - ungapped reference sequence
# minname - name of read
# minstart - start of aligmnent in read
# minalnsize - size of alignment in read
# minstrand - strand of read (?)
# minseqsize - size of read
# minseq - gapped read sequence
# score - alignment score
# matches - matched bases after aligment
# edit distance - mismatched bases after alignment
# number of insertions
# number of deletions
# longest prefect kmer

while (!eof()) {
	
	my $finished = 0;
	my $score = get_score();
	my ($refname, $refstart, $refalnsize, $refstrand, $refseqsize, $refseq) = get_read();
	my ($minname, $minstart, $minalnsize, $minstrand, $minseqsize, $minseq) = get_read();
	my $realref = $refseq; $realref =~ s/-//g;
	my $minqual = get_qual();
	
	if ($score) {
		printf "%s" . "\t%s"x18, 
			$refname, $refstart, $refalnsize, $refstrand, $refseqsize, $refseq, $realref,
			$minname, $minstart, $minalnsize, $minstrand, $minseqsize, $minseq, $score, 
			get_mismatch_stats($refseq,$minseq), get_longest_perfect_kmer($refseq,$minseq);
		printf "\t%s", $minqual if $minqual;
		print "\n";
	}
}

sub get_read_type {
	my $n = shift;
	return 1 if $n =~ m/template/; 
	return 2 if $n =~ m/complem/; 
	return 3 if $n =~ m/twod/; 
	return 0;
}

sub get_read {
	$_ = <>;
	chomp;
	return (split(/\s+/))[1..6];
}

sub get_score {
	$_ = <> until eof() or m/score=(\d+)/;
	return $1;
}

sub get_qual {
	$_ = <>;
	chomp;
	my ($test,$refname,$qual) = split(/\s+/);
	return $test eq 'q' ? $qual : undef; 
}

sub get_longest_perfect_kmer {
	my ($r1,$r2) = @_;
	my $maxpk=0;
	my $pk=0;
	for (my $i = 0; $i < length($r1); $i++) {
		$maxpk = max($maxpk, substr($r1,$i,1) eq substr($r2,$i,1) ? ++$pk : ($pk=0));
	}

	return $maxpk;
}

sub get_mismatch_stats {
	my ($r1,$r2) = @_;
	my $mism = 0;
	my $match = 0;
	for (my $i = 0; $i < length($r1); $i++) {
		$mism++ if substr($r1,$i,1) ne substr($r2,$i,1);
		$match++ if substr($r1,$i,1) eq substr($r2,$i,1);
	}
	my $ins = $r1 =~ tr/-/-/;
	my $del = $r2 =~ tr/-/-/;
	return($match,$mism,$ins,$del);
}

