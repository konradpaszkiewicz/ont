ONT
=======

Oxford Nanopore Scripts

Scripts are not robust and rely on correct input - be warned.
Never meant for public consumption!
Contact : https://github.com/PaulAONeill

1) from the LAST output, use maf-sort and maf-cull to remove redundant matches.

2) flatten the file and calculate some metrics

`perl prepare_aln_for_upload.pl < culled_minion_reads.maf > minion_reads.for_upload`

3) do the kmer calculations - takes some time and creates large intermediate file

`perl kmer.pl < minion_reads.for_upload > minion_reads.kmer`

4) load the database - expects the file to be called minion_reads.kmer - create a link if necessary
```
sqlite3 kmer.db
sqlite3 kmer.db < kmer.sql
```

5) run queries e.g.
```
sqlite3 kmer.db
select realref, num, avg_edist from kmer_summary order by avg_edist desc limit 10;
select realref, num, avg_edist from kmer_summary order by avg_edist limit 10;
```
6) graph in R
```
library(RSQLite)
db <- dbConnect(SQLite(), dbname = "kmer.db")
plot(dbGetQuery(db,"select num,perfect from kmer_summary;"),pch=18,xlab="kmer occurrence",ylab="perfect kmers", main="Perfect Kmers K=5")
```
