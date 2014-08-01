use strict;
use List::Util qw [max];

# compares minion read alignment with reference
# breaks each read down into kmers of size
my $K=5;

my $FIN=-999;

# takes input from flattened aln file - format:

# outputs reference kmer, reference kmer after alignment, minion kmer, number of matches
# edit distance, number of insertions, number of deletions.

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
# kmer complexity - !!!under development - use at your own peril!!!

while (!eof()) {
	
	my ($refname, $refstart, $refalnsize, $refstrand, $refseqsize, $refseq, $realref,
			$minname, $minstart, $minalnsize, $minstrand, $minseqsize, $minseq, $score, 
			$match,$mism,$ins,$del,$bpkmer) = get_line();
	
	
	my $finished = 0;
	my $kstart = 0;
	my $refkmer = "";
	my $minkmer = "";
	my $finished = 0;

	while ( !$finished ) {
		($refkmer, $kstart) = get_ref_kmer($refseq, $kstart);
		if ($kstart == $FIN) {
			$finished = 1;
		} else {
			my $realref = $refkmer;
			$realref =~ s/-//g;
			$minkmer = substr($minseq, $kstart - 1, length($refkmer));
			printf "%s\t"x8 . "%s\n", $realref, $refkmer, $minkmer, 
				get_mismatch_stats ($refkmer, $minkmer),   #4 values $match,$mism,$ins,$del 
				get_kmer_complexity($refkmer)
			unless $refkmer =~ m/N/;
		}
	}
}
	
sub get_read_type {
	my $n = shift;
	return 1 if $n =~ m/template/; 
	return 2 if $n =~ m/complem/; 
	return 3 if $n =~ m/twod/; 
	return 0;
}

sub get_kmer_complexity {
	# returns 2 numbers base complexity and pyrimidene/purine complexity
	my $k = shift;
	my $l = scalar length($k);
	my $bx = $l / 4;
	my $ppx = $l / 2;
	my $a = $k =~ tr/Aa/Aa/;
	my $c = $k =~ tr/Cc/Cc/;
	my $g = $k =~ tr/Gg/Gg/;
	my $t = $k =~ tr/Tt/Tt/;
	my $base_cplex = (( $a - $bx )**2)/$bx + (( $c - $bx )**2)/$bx + (( $g - $bx )**2)/$bx + (( $t - $bx )**2)/$bx;
	my $pp_cplex = (( $a + $t - $ppx )**2)/$ppx + (( $c + $g - $ppx )**2)/$ppx;	
	return ($base_cplex,$pp_cplex)
}

sub get_line {
	$_ = <>;
	chomp;
	return split(/\t/);
}

sub get_ref_kmer {
	my ($seq,$ptr) = @_;
	my $kmer = "";
	my $Km1 = $K - 1; # K minus 1 for regex

	# get K characters from reference (may include inserts)

		#skip if starting with "-"
		while ( ($ptr < length($seq) - $K) and substr($seq,$ptr,1) eq "-" ) {
			$ptr += 1;
		}
		#try to get 5 bases from the reference
		$kmer = sprintf "%s", substr($seq,$ptr) =~ m/^(([ACGTN]-*){$Km1}[ACGTN])/; 
		$ptr += 1;
	
	if ($K == ($kmer=~tr/ACGTN//)) {
		return $kmer,$ptr;
	} else {
		return ($FIN,$FIN);
	}
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


