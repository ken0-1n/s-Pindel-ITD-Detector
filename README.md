s-Pindel-ITD-Detector
==================

s-Pindel-ITD-Detector is a framework for the detection of somatic ITDs using the Pindel output files, "Short Insertions file(_SI)" and "Tandem duplications file(_TD)".

**Restrictions on performing Pindel**   
When you run Pindel, please use the BAM config file that lists only one BAM file. For example,   

    # bam config file (only one line)
    $ /home/user_name/input/tumor/tumor.bam 300 output/sample001
        
    # run the pindel
    $ ./pindel -f ./hg19.fasta -i ${bam config file} -c ALL -o $prefix

For additional information about Pindel, please visit their website at [http://gmt.genome.wustl.edu/pindel/0.2.4/index.html](http://gmt.genome.wustl.edu/pindel/0.2.4/index.html)


Dependecy
----------

* [bedtools](https://code.google.com/p/bedtools/)
* [fasta36](http://faculty.virginia.edu/wrpearson/fasta/fasta36/)
* [refGene.txt, knownGene.txt, ensGene.txt and simpleRepeat.txt from the UCSC site](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/)

SetUp
----------

1. Download the s-Pindel-ITD-Detector package to any directory.

2. Download, extract and install the following two external tools to any directory.  
  **bedtools** (Ver. 2.14.3).  
  **fasta36** (Ver. 3.5c).  

3. Download the refGene.txt, knownGene.txt, ensGene.txt and simpleRepeat.txt files from **the UCSC site** and place them under the s-Pindel-ITD-Detector/db directory, and then unpack them.  

4. Open sPindel.env and set each entry.  
<table>
<tr>
<th>PATH_TO_FASTA</th>
<td>the path to the fasta36 executable</td>  
</tr>
<tr>
<th>PATH_TO_BED_TOOLS</th>
<td>the path to the BEDtools executable</td>  
</tr>
</table>


How to run
---

1) Create the annotation database

    $ bash createAnnoDB.sh

2) Detect ITDs in control samples

    $ bash sPindel_ITD_inhouse.sh <_SI file> <_TD file> <output directory> <sample> [sPindel.env]
    # _SI file: it is the output obtained from Pindel
    # _TD file: it is the output obtained from Pindel
    # output directory: output dir name
    # sample: it is used to set the output file prefix and store in inhouse database
    # sPindel.env: optional you can change the config file
    
3) Create inhouse database  
Please open the new file and add the paths of "${sample}.inhouse.bed" files† for each of control samples. For example,   

    $ /home/your_username/s-Pindel-ITD-Detector-master/inhouse/sample001.inhouse.bed
    $ /home/your_username/s-Pindel-ITD-Detector-master/inhouse/sample002.inhouse.bed
    $ /home/your_username/s-Pindel-ITD-Detector-master/inhouse/sample003.inhouse.bed
    …
    $ /home/your_username/s-Pindel-ITD-Detector-master/inhouse/sample099.inhouse.bed
    
† The file "${sample}.inhouse.bed" is included in the outputs obtained from sPindel_ITD_inhouse.sh   

4) Detect somatic ITDs in tumor samples

    $ bash sPindel_ITD_detector.sh <_SI file> <_TD file> <output directory> <sample> <inhouse data list> [sPindel.env]
    # _SI file: it is the output obtained from Pindel
    # _TD file: it is the output obtained from Pindel
    # output directory: output dir name
    # sample: it is used to set the output file prefix and deselect the same sample from inhouse database
    # inhouse data list: list of inhouse bed created on "3) Create inhouse database"    
    # sPindel.env: optional you can change the config file
Output
---

The results are formatted as TSV format.

The followings are the information of the columns of the output file:   
The definitions from "chr" to "contig" are same as those in Pindel
<table>
<tr>
<th>chr</th>
<td>The identifier of the chromosome the read was found on.</td>  
</tr>
<tr>
<th>start<br>end</th>
<td>The start and end positions of the SV.</td>
</tr>
<th>itd_length</th>
<td>The length of the SV.</td>    
</tr>
<tr>
<th>support</th>
<td>The number of reads supporting the SV.</td>   
</tr>
<tr>
<th>support_uniq</th>
<td>The number of unique reads supporting the SV (so not counting duplicate reads).</td>   
</tr>
<tr>
<th>support_+<br>support_uniq_+</th>
<td>Total number of supporting reads and unique number of supporting reads whose anchors are upstream of the SV.</td>
</tr>
<tr>
<th>support_-<br>support_uniq_-</th>
<td>Total number of supporting reads and unique number of supporting reads whose anchors are downstream of the SV.</td>   
</tr>
<tr>
<th>itd_contig</th>
<td>The sequence(s) of the NT fragment(s)</td>
</tr>
<tr>
<th>contig</th>
<td>The contig sequences by supported reads.</td>
</tr>
<tr>
<th>exon<br>intron<br>5putr<br>3putr<br>noncoding_exon<br>noncoding_intron</th>
<td>RefSeq Gene Name and Gene ID annotation.</td>   
</tr>
<tr>
<th>ens_gene</th>
<td>Ensamble Gene ID annotation.</td>  
</tr>
<tr>
<th>known_gene</th>
<td>Known Gene ID annotation.</td>  
</tr>
<tr>
<th>tandem_repeat</th>
<td>Simple Repeat annotation.</td>  
</tr>
<tr>
<th>inhouse</th>
<td>The results of matching ITD to inhouse database.</td>       
</tr>
</table>

Copyright
----------
Copyright (c) 2013, Kenichi Chiba, Yuichi Shiraishi

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

