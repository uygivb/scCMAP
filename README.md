# scCMAP
Computational search for target genes for chemical reprograming of the cells using gene regulatory networks

scINTREGNET can be used to improve results of the [Connectivity Mapping (CMAP)](https://www.broadinstitute.org/connectivity-map-cmap) pipeline for drug repurposing by accounting of Transription-Regulation-Network for target cell population and providing core transcription factors as drug targets.

export TF_path="${TFS_PRED_DIR}/${initial_celltype}_to_${SAMPLE_NAME}_FinalVals.tsv"
python3 $WORKDIR/scripts/main/cmap.py --TF_path "$TF_path" > $TFS_PRED_DIR/cmap.csv
