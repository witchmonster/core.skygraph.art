#!/bin/bash
source .env

set -e

echo ${DUMP_DIR}/csv
timestamp=$(date +'%Y%m%d' --utc)

filesToBackup=(
    "handles.csv"
    "dids.csv"
    "blocks.csv"
    "follows.csv"
    "like_counts.csv"
    "post_counts.csv"
    "optout.csv"
    "timestamp.csv"
)

echo "Initializing import folder..."

mkdir -p ${NEO4J_DB_DIR}/import/export
mkdir -p ${NEO4J_DB_DIR}/import/monthly
echo "did:ID{label:Account}" > ${NEO4J_DB_DIR}/import/empty.csv

if  [[ $1 = "-o" ]]; then
    echo "Dumping old files..."

    mkdir -p ${DUMP_DIR}/csv
    mkdir -p ${DUMP_DIR}/csv/${timestamp}_dump

    rm -f ${NEO4J_DB_DIR}/import/weights.csv

    for csv in ${filesToBackup[@]}; do
        mv ${NEO4J_DB_DIR}/import/$csv ${DUMP_DIR}/csv/${timestamp}_dump/$csv
    done
else
    echo "If you want to make a NEW full import, use -o to dump old files and overwrite them with new ones."
fi

echo "Syncing csv files for full dump..."

for csv in ${filesToBackup[@]}; do
    if test -f ${NEO4J_DB_DIR}/import/$csv; then
        echo "Skipping $csv. File exists."
    elif [ ${SSH} = true ]; then
        scp ${SSH_HOST}:${CSV_SRC_DIR}/$csv ${NEO4J_DB_DIR}/import/$csv
    else
        sync ${CSV_SRC_DIR}/$csv ${NEO4J_DB_DIR}/import/$csv
    fi
done

if  [[ $1 = "-m" ]]; then
echo "Syncing csv files for monthly dump..."

for csv in ${filesToBackup[@]}; do
    if test -f ${NEO4J_DB_DIR}/import/monthly/$csv; then
        echo "Skipping $csv. File exists."
    elif [ ${SSH} = true ]; then
        scp ${SSH_HOST}:${CSV_SRC_MONTHLY_DIR}/$csv ${NEO4J_DB_DIR}/import/monthly/$csv
    else
        sync ${CSV_SRC_MONTHLY_DIR}/$csv ${NEO4J_DB_DIR}/import/monthly/$csv
    fi
done

else
    echo "If you want to make a montly import, use -m."
fi