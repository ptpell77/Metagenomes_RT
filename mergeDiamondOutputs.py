import pandas as pd
import numpy as np
import os
import sys

# This function will take a path to a directory containing the DIAMOND outputs to be merged, and it will generate a 
# list of all the TSV files there. It will then ineratively call getCAZySeries on individual files in order to
# build a dataframe summarizing all the data from all inputs. 
def buildCAZyDB(directory):
    pathlist = [x for x in os.listdir(directory) if '.tsv' in x]
    tempDF = pd.DataFrame() # columns = colNames)
    seriesDict = {}
    for path in pathlist:
        tempSeries = getCAZySeries(os.path.join(directory, path))
        tempSeries.name = path.split(".tsv")[0]
        seriesDict[tempSeries.name] = tempSeries
        # tempDF = pd.concat([tempDF, tempSeries], join = 'outer', axis = 1)
        # tempDF.to_csv(join(directory, "merged_CAZy_outputs.csv"))
    tempDF = pd.DataFrame(seriesDict)
    tempDF.to_csv(os.path.join(directory, "merged_CAZy_outputs.csv"))
    return tempDF
    
# This function will accept a path to a .tsv file output by DIAMOND and read it in. It will then check the 'Target accession' 
# string and split based on the pipe character ("|") to grab the CAZy name. The counts of each name will be summarized in a 
# series that is returned. 
def getCAZySeries(path):
    colNames = [
        "Query accession","Target accession","Sequence identity","Length",
        "Mismatches","Gap openings","Query start","Query end","Target start",
        "Target end","E-value","Bit Score"
    ]
    counts = {}
    chunksize = 1_000_000  # adjust based on RAM
    
    for chunk in pd.read_table(path, delimiter="\t", names=colNames, chunksize=chunksize):
        targets = chunk['Target accession'].str.split("|", expand=True)
        chunk_counts = targets[1].value_counts()
        for k, v in chunk_counts.items():
            counts[k] = counts.get(k, 0) + v
    
    return pd.Series(counts)
    
    
#     colNames = ["Query accession","Target accession","Sequence identity","Length","Mismatches","Gap openings","Query start","Query end","Target start","Target end","E-value", "Bit Score"]
#     df = pd.read_table(path, delimiter= "\t", names = colNames)
#     targets = df['Target accession'].str.split("|", expand = True)
#     CAZySeries = targets[1].value_counts()
    
    # return CAZySeries
    
buildCAZyDB(sys.argv[1])

