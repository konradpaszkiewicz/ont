.separator \t
CREATE TABLE kmer (
        realref string,
        refkmer string,
        minkmer string,
        matches integer,
        edist integer,
		ins integer,
		del integer,
		bcomplex integer,
		ppcomplex integer
);

.import 5-mer.txt kmer  --for example

CREATE table kmer_summary as
select realref, bcomplex, ppcomplex,
  count(*) as num,
  avg(matches) as avg_match,
  avg(edist) as avg_edist,
  (refkmer=minkmer) as perfect,
  avg(ins) as avg_ins,
  avg(del) as avg_del
from kmer
group by realref, bcomplex, ppcomplex
;

