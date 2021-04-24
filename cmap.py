import requests
import json
import csv
import argparse
import pandas as pd
url = 'https://maayanlab.cloud/L1000CDS2/query'

def upperGenes(genes):
    return [gene.upper() for gene in genes]

parser = argparse.ArgumentParser()
parser.add_argument('--TF_path')
args = parser.parse_args()

g = pd.read_csv(args.TF_path, sep='\t')
tf = g.TF1.to_list()
val = g.tfs_score.to_list()

data = {"genes":tf,"vals":val}
data['genes'] = upperGenes(data['genes'])
config = {"aggravate":True,"searchMethod":"CD","share":True,"combination":True,"db-version":"latest"}
#metadata = [{"key":"Cell","value":"VCAP"}]
metadata = []
payload = {"data":data,"config":config,"meta":metadata}
headers = {'content-type':'application/json'}
r = requests.post(url,data=json.dumps(payload),headers=headers)
resCD= r.json()

print('Drug_name , Perturbation_id , Score, Cell_line')
for Meta in resCD['topMeta']:
    print(Meta['pert_desc'], ',', Meta['pert_id'], ',', Meta['score'], ',', Meta['cell_id'])
