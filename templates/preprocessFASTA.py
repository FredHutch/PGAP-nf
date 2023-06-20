#!/usr/bin/env python3

# Following criteria from https://github.com/ncbi/pgap/wiki/Input-Files

from Bio.SeqIO.FastaIO import SimpleFastaParser
import re

# Read in all of the genome
genome = dict([
    (header, seq)
    for header, seq in SimpleFastaParser(open("${fasta}"))
])

# Sanitize and write out
seen_headers = set([])
with open("${fasta}", "w") as handle:
    for header, seq in genome.items():

        # Make sure the sequence is >= 199 nucleotides
        if len(seq) < 199:
            continue

        # Trim the header to 50 characters
        if len(header) > 50:
            header = header[:50]

        # Only include letters, digits, hyphens (-), underscores (_), periods (.), colons (:), asterisks (*), and number signs (#)
        header = re.sub('[^0-9a-zA-Z-.*#\$_:]', '_', header)

        # All headers are unique
        assert header not in seen_headers
        seen_headers.add(header)

        # Make sure there are no N's at the beginning or end
        assert seq[0] != "#"
        assert seq[-1] != "#"

        handle.write(">%s\\n%s\\n" % (header, seq))
