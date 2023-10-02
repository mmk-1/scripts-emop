#!/bin/bash

PLUGIN='\<plugin\>\
\<groupId\>edu.illinois\<\/groupId\>\
\<artifactId\>starts-maven-plugin\<\/artifactId\>\
\<version\>1.4-SNAPSHOT\<\/version\>\
\<\/plugin\>\
\<plugin\>\
\<artifactId\>emop-maven-plugin\<\/artifactId\>\
\<groupId\>edu.cornell\<\/groupId\>\
\<version\>1.0-SNAPSHOT\<\/version\>\
\<\/plugin\> \
\<plugin\>\
\<groupId\>org.apache.maven.plugins\<\/groupId\>\
\<artifactId\>maven-surefire-plugin\<\/artifactId\>\
\<version\>2.20\<\/version\>\
\<configuration\>\
\<argLine\>\
-javaagent:${settings.localRepository}\/javamop-agent\/javamop-agent\/1.0\/javamop-agent-1.0.jar\<\/argLine\>\
\<\/configuration\>\
\<\/plugin\>'

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
    
    # The logic is to copy the .starts directory to the parent directory
    # and then copy it back to the current directory after running the plugin
    # for each commit to find changes between commits
    for granularity in "hrps" "mrps" "rps"
    do
        rm -rf $REPOS_DIR/.starts/
        mkdir $REPOS_DIR/.starts/
        # Checkout and run for each commit
        for commit in $commit1 $commit2 $commit3
        do
            mkdir -p $RESULTS_DIR/$project/$commit/
            git checkout $commit -f
            mvn clean
            rm -rf .starts/
            cp -r ../.starts/ ./.starts/
            sed -i "/<\/plugins>/i\\$PLUGIN" pom.xml
            mvn emop:$granularity -Drat.skip | tee -a $RESULTS_DIR/$project/$commit/$granularity.txt
            # echo "=====" >> $ROOT_DIR/results/$project/$commit/$granularity.txt
            
            rm -rf $REPOS_DIR/.starts/
            cp -rf ./.starts/ $REPOS_DIR/.starts/
            rm -rf ./.starts/
            # python3 $ROOT_DIR/extract_data.py $project $commit $granularity $ROOT_DIR
        done
    done
done < $1
