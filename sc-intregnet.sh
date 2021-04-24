#!/bin/bash

set -e

check_dependecies() {
    command -v python3 >/dev/null 2>&1 || {
        echo >&2 "scINTREGNET requires python3 but it's not installed.  Aborting."
        exit 1
    }
    command -v Rscript >/dev/null 2>&1 || {
        echo >&2 "scINTREGNET requires Rscript but it's not installed.  Aborting."
        exit 1
    }
    command -v matlab >/dev/null 2>&1 || {
        echo >&2 "scINTREGNET requires MATLAB R2019a or higher but it's not installed.  Aborting."
        exit 1
    }
}

check_required_arg() {
    local NAMED_ARG=$1
    local VALUE_SET=$2

    if [[ -z $VALUE_SET ]]; then
        echo "[ERROR] - required argument ($NAMED_ARG) not set"
        exit 1
    fi
}

check_mutually_exclusive_args() {
    local NAMED_ARG_1=$1
    local VALUE_SET_1=$2
    local NAMED_ARG_2=$3
    local VALUE_SET_2=$4
    if [[ -z $VALUE_SET_1 ]] && [[ -z $VALUE_SET_2 ]]; then
        echo "[ERROR] - please, specify one of the required arguments: ($NAMED_ARG_1) or ($NAMED_ARG_2)"
        exit 1
    fi

    if [[ -n $VALUE_SET_1 ]] && [[ -n $VALUE_SET_2 ]]; then
        echo "[ERROR] - please, specify only one of the required arguments: ($NAMED_ARG_1) or ($NAMED_ARG_2)"
        exit 1
    fi
}

usage() {
    python3 /usr/bin/sc-intregnet-help.py -h
    exit 1
}

create_simlink_in_dir() {
    local DESTINATION_DIR_PATH=$1
    local FILE_PATH=$2

    if [[ -n $FILE_PATH ]] && [[ ! -f $DESTINATION_DIR_PATH/$(basename -- "$FILE_PATH") ]]; then
        mkdir -p "$DESTINATION_DIR_PATH"
        ln -s "$FILE_PATH" "${DESTINATION_DIR_PATH}"/"$(basename -- "$FILE_PATH")"
    fi
}

check_dependecies

if [[ $# -eq 0 ]]; then
    usage
fi

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    --sc-intregnet-path)
        WORKDIR="$2"
        shift # past argument
        shift # past value
        ;;
    --tfs-in-combo)
        number_tfs_in_combo="$2"
        shift
        shift
        ;;
    --start-sample-name)
        initial_celltype="$2"
        shift
        shift
        ;;
    --start-exp)
        initial_celltype_expression="$2"
        shift
        shift
        ;;
    --start-h3k27ac)
        initial_celltype_H3K27ac="$2"
        shift
        shift
        ;;
    --start-h3k4me3)
        initial_celltype_H3K4me3="$2"
        shift
        shift
        ;;
    --target-sample-name)
        SAMPLE_NAME="$2"
        shift
        shift
        ;;
    --target-exp)
        target_exp_path="$2"
        shift
        shift
        ;;
    --target-exp-ranking)
        target_exp_ranking_path="$2"
        shift
        shift
        ;;
    --target-access-regs)
        target_access_regions="$2"
        shift
        shift
        ;;
    --target-h3k27ac)
        target_H3K27ac="$2"
        shift
        shift
        ;;
    --target-h3k4me3)
        target_H3K4me3="$2"
        shift
        shift
        ;;
    --target-specific-chip-seq)
        target_specific_chip_seq="$2"
        shift
        shift
        ;;
    --custom-output-dir)
        custom_output_dir="$2"
        shift
        shift
        ;;
    -h | --help)
        usage
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -n $1 ]]; then
    echo "Unknown or unspecified argument: $1"
    exit 1
fi

## CHECK AND ASSIGN ARGUMENTS

if [[ -z $WORKDIR ]]; then
    export WORKDIR=$INTREGNET_DIR
fi

check_mutually_exclusive_args "--target-exp" "$target_exp_path" "--target-exp-ranking" "$target_exp_ranking_path"

check_required_arg "--tfs-in-combo" "$number_tfs_in_combo"
check_required_arg "--start-sample-name" "$initial_celltype"
check_required_arg "--target-sample-name" "$SAMPLE_NAME"
check_required_arg "--start-exp" "$initial_celltype_expression"
# check_required_arg "--target-access-regs" "$target_access_regions"

export WORKDIR
export number_tfs_in_combo
export initial_celltype
export initial_celltype_expression
export initial_celltype_H3K27ac
export initial_celltype_H3K4me3
export SAMPLE_NAME
export target_exp_path
export target_access_regions
export target_H3K27ac
export target_H3K4me3

echo "WORKDIR                       =   ${WORKDIR}"
echo "number_tfs_in_combo           =   ${number_tfs_in_combo}"
echo "initial_celltype              =   ${initial_celltype}"
echo "initial_celltype_expression   =   ${initial_celltype_expression}"
echo "initial_celltype_H3K27ac      =   ${initial_celltype_H3K27ac}"
echo "initial_celltype_H3K4me3      =   ${initial_celltype_H3K4me3}"
echo "SAMPLE_NAME                   =   ${SAMPLE_NAME}"
echo "target_exp_path               =   ${target_exp_path}"
echo "target_access_regions         =   ${target_access_regions}"
echo "target_H3K27ac                =   ${target_H3K27ac}"
echo "target_H3K4me3                =   ${target_H3K4me3}"

cd "$WORKDIR"

## LOAD DEFAULT FILES

export EnsemblToTF_path="$WORKDIR/default_files/EnsemblToTF.txt"
export Ens_TF_path="$WORKDIR/default_files/TF_list_hs_AnimalTFDB3_Nov18.txt"
export description_file_TPM_clust_path="$WORKDIR/default_files/description_file_TPM_clust_v2.RData"
export Recount_TPM_GSM_Bg_path="$WORKDIR/default_files/Recount_TPM_GSM_Bg.RData"
export dataset_raw_TPM_TFs_path="$WORKDIR/default_files/dataset_raw_TPM_TFs.RData"
export cor_TPM_path="$WORKDIR/default_files/cor_TPM.RData"
export JSD_ranked_TFs_Cor_path="$WORKDIR/default_files/JSD_ranked_TFs_Cor_Processed_0.75_v2.txt"

export AnimalTFDB_TF="$WORKDIR/default_files/AnimalTFDB_TF.bed"
export Processed_GeneHancer_GRCh38="$WORKDIR/default_files/Processed_GeneHancer_GRCh38.bed"
export GRCh38_promoter="$WORKDIR/default_files/GRCh38_promoter.bed"

if [[ -n $target_specific_chip_seq ]]; then
    export ChIPseq_for_networks="$target_specific_chip_seq"
else
    export ChIPseq_for_networks="$WORKDIR/default_files/Cistrome_ChIPseq_sorted.bed"
fi

## Initialize directories for start and target data if needed

export START_INPUT_DIR="$WORKDIR/data/$initial_celltype/input_files"
mkdir -p "$START_INPUT_DIR"

create_simlink_in_dir "$START_INPUT_DIR" "$initial_celltype_expression"
create_simlink_in_dir "$START_INPUT_DIR" "$initial_celltype_H3K27ac"
create_simlink_in_dir "$START_INPUT_DIR" "$initial_celltype_H3K4me3"

export TARGET_INPUT_DIR="$WORKDIR/data/$SAMPLE_NAME/input_files"
mkdir -p "$TARGET_INPUT_DIR"

create_simlink_in_dir "$TARGET_INPUT_DIR" "$target_exp_path"
create_simlink_in_dir "$TARGET_INPUT_DIR" "$target_access_regions"
create_simlink_in_dir "$TARGET_INPUT_DIR" "$target_H3K27ac"
create_simlink_in_dir "$TARGET_INPUT_DIR" "$target_H3K4me3"

if [[ -n $custom_output_dir ]]; then
    export OUTPUT_DIR="$custom_output_dir/output_files"
    export TFS_PRED_DIR="$custom_output_dir/tfs_predictions"
else
    export OUTPUT_DIR="$WORKDIR/data/$SAMPLE_NAME/output_files"
    export TFS_PRED_DIR="$WORKDIR/data/$SAMPLE_NAME/tfs_predictions"
fi

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TFS_PRED_DIR"

## RUN

############################################################
## Booleanize the query sample and compute the JSD for it ##
############################################################

if [[ -n $target_exp_ranking_path ]]; then
    export gene_ranking_file="$target_exp_ranking_path"
    top_10_gene_ranking_file="$OUTPUT_DIR/$(basename -- ${gene_ranking_file%.txt})_top_10_genes.txt"
    head -10 "$target_exp_ranking_path" > "$top_10_gene_ranking_file"
    export coreTFs_file="$top_10_gene_ranking_file"
else
    echo "Start pipeline_cluster.R ...    ($(date))"
    Rscript $WORKDIR/scripts/main/pipeline_cluster.R
    echo "Successfully executed pipeline_cluster.R    ($(date))"
    export gene_ranking_file="${OUTPUT_DIR}/${SAMPLE_NAME}_mRNA_TFs.txt"
    export coreTFs_file="${OUTPUT_DIR}/${SAMPLE_NAME}_TF.tsv"
fi

#########################################
## Get raw network among expressed TFs ##
#########################################

echo "Start code_v2_clus.sh    ($(date))"

bash $WORKDIR/scripts/main/code_v2_clus.sh

echo "Successfully executed code_v2_clus.sh    ($(date))"

#########################################################################
## Create final network for query sample with logic rules for core TFs ##
#########################################################################

echo "Start GenerateNetworks_Cluster.R ...    ($(date))"

Rscript $WORKDIR/scripts/main/GenerateNetworks_Cluster.R

echo "Successfully executed GenerateNetworks_Cluster.R    ($(date))"

############################################
## Create network file suitable for PRISM ##
############################################

echo "Start ConvertNetworkToModelChecking.R ...    ($(date))"

Rscript $WORKDIR/scripts/main/ConvertNetworkToModelChecking.R

echo "Successfully executed ConvertNetworkToModelChecking.R    ($(date))"

##############################################################################
## Create reward and reachability files for TFs in the query sample network ##
##############################################################################

echo "Start WriteProperties.R ...    ($(date))"

Rscript $WORKDIR/scripts/main/WriteProperties.R

echo "Successfully executed WriteProperties.R    ($(date))"

######################################################################
## Get scores for different TF perturbation candidates combinations ##
######################################################################

export prism_network_path="${OUTPUT_DIR}/${SAMPLE_NAME}_Network_Prism_v1.txt"
export reward_file_path="${OUTPUT_DIR}/${SAMPLE_NAME}_Reward.txt"
export prism_output="${OUTPUT_DIR}/${SAMPLE_NAME}_Prism_Output"

PRISM="${WORKDIR}/scripts/main/prism-4.5-linux64/bin/prism"

echo "Start PRISM ...    ($(date))"

$PRISM -v $prism_network_path $reward_file_path >$prism_output

# Process the PRISM output file to have it in a proper format
sh $WORKDIR/scripts/main/TransformModelCheckingOutput.sh $prism_output

echo "Successfully executed PRISM    ($(date))"

####################################################
## Plot Gene Regulatory Network for target sample ##
####################################################

echo "Start plot_GRN.py ...    ($(date))"

export EnhRegulators_path="${OUTPUT_DIR}/${SAMPLE_NAME}_EnhRegulators.txt"
export PromRegulators_path="${OUTPUT_DIR}/${SAMPLE_NAME}_PromRegulators.txt"

export VIS_DIR="${OUTPUT_DIR}/visualization"
mkdir -p $VIS_DIR

python3 $WORKDIR/scripts/visualization/plot_GRN.py --EnhRegulators_path "$EnhRegulators_path" \
    --PromRegulators_path "$PromRegulators_path" \
    --output_dir "$VIS_DIR" \
    --sample_prefix "$SAMPLE_NAME"

echo "Successfully executed plot_GRN.py ...    ($(date))"

##############################################################
# Network perturbation analysis to find instructive factors ##
##############################################################

echo "Start PerturbCluster_Rowwise.R ...    ($(date))"

Rscript $WORKDIR/scripts/main/PerturbCluster_Rowwise.R

echo "Successfully executed PerturbCluster_Rowwise.R    ($(date))"

echo "[SUCCESS]: scINTREGNET completed successfully!"
echo "See the TFs combo ranking at: $TFS_PRED_DIR"
