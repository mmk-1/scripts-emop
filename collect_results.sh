#!/bin/bash

ROOT_DIR=$(pwd)
# for commit in $commit1 $commit2 $commit3 $commit4 $commit5
# Read the CSV file line by line
# while IFS=',' read -r repo commit1 commit2 commit3 commit4 commit5
while IFS=',' read -r repo commit1 commit2 commit3
do
    author=$(echo $repo | cut -d '/' -f 1)
    project=$(echo $repo | cut -d '/' -f 2)
    
    for granularity in "hrps" "mrps" "rps"
    do
        # Checkout and run for each commit
        # for commit in $commit1 $commit2 $commit3
        for commit in $commit1 $commit2 $commit3
        do
            python3 $ROOT_DIR/extract_data.py $project $commit $granularity $ROOT_DIR
        done
    done
done < $1
