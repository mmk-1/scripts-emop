#!/bin/bash

# Check if the directory exists
if [ ! -d "results/" ]; then
    mkdir results/
fi

if [ ! -d "repos/" ]; then
    mkdir repos/
fi

if [ ! -d "output_tables/" ]; then
    mkdir output_tables/
fi

ROOT_DIR=$(pwd)

REPOS_DIR=$ROOT_DIR/repos/
RESULTS_DIR=$ROOT_DIR/results/
# $granularity=test
# Read the CSV file line by line
# while IFS=',' read -r repo commit1
while IFS=',' read -r repo commit1 commit2 commit3
do
    # Clone the project
    # cd $REPOS_DIR
    author=$(echo $repo | cut -d '/' -f 1)
    project=$(echo $repo | cut -d '/' -f 2)
    git clone https://github.com/$repo.git $REPOS_DIR/$project
    mkdir -p results/$project/
    cd $REPOS_DIR/$project
    
    for commit in $commit1 $commit2 $commit3
    do
        mkdir -p $RESULTS_DIR/$project/$commit/
        git checkout $commit -f
        mvn clean
        LOG_PATH=$RESULTS_DIR/$project/$commit/test.txt
        mvn test -Drat.skip | tee >(grep -P "\[INFO\] Total time:\s+([\d.:]+\s\w+)" >> $LOG_PATH)
    done
done < $1
