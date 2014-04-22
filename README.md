s-Pindel-ITD-Detector
==================

s-Pindel-ITD-Detector is a framework for the detection of somatic ITDs using Pindel

Dependecy
----------

* [bedtools](https://code.google.com/p/bedtools/)
* [fasta36](http://faculty.virginia.edu/wrpearson/fasta/fasta36/)
* [refGene.txt, knownGene.txt, ensGene.txt and simpleRepeat.txt from the UCSC site](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/)

SetUp
----------

1. Download the s-Pindel-ITD-Detector package to any directory.

2. Download and extract and install following external tools to any directory.  
  **bedtools** (Ver. 2.14.3).  
  **fasta36** (Ver. 3.5c).  

3. Download the refGene.txt, knownGene.txt, ensGene.txt and simpleRepeat.txt files from **the UCSC site** and place them under the s-Pindel-ITD-Detector/db directory, and then unpack them.  

4. Open sPindel.env and set each entry.  
**PATH_TO_BED_TOOLS**: the path to the BEDtools executable  
**PATH_TO_FASTA**: the path to the fasta36 executable  

How to run
---

Create the annotation database

    $ bash createAnnoDB.sh

Detect ITDs in normal samples

    $ bash sPindel_ITD_inhouse.sh <input short insertions file in Pindel> <input tandem duplications file in Pindel> <output directory> <sample>
    input short insertions file in Pindel: 
    input tandem duplications file in Pindel: 
    output directory: 
    sample: 

Detect somatic ITDs in tumor samples

    $ bash sPindel_ITD_detector.sh <input short insertions file in Pindel> <input tandem duplications file in Pindel> <output directory> <sample> <target inhouse data list> 
    input short insertions file in Pindel: 
    input tandem duplications file in Pindel: 
    output directory: 
    sample: 
    target inhouse data list: 
    
