#!/bin/bash

# Usage
if [ "$#" -lt 2 ]
then
    echo "Usage: $0 <email@domain.com> [searchTerms...]"
    exit 1
fi

webDataFile="ozbargainData.html"    # Stores the html for the website
nodesFile="nodesFile.html"          # Stores the data for each individual post 

> $nodesFile                        

# Extract html from ozbargain websiteq
curl -s https://www.ozbargain.com.au/deals > "$webDataFile"

email=$1

# Construct the search regex with matching given keywords
firstSearchTerm=$2
shift 2

regex="class=\"title\" id=.* data-title=\".*$firstSearchTerm.*\""
echo "Searching ozBargain webpage for the given input search terms:"
echo "$firstSearchTerm"
for searchTerm in "$@"
do  
    echo "$searchTerm"
    regex=$regex"|class=\"title\" id=.* data-title=\".*$searchTerm.*\""
    # echo $regex
done


# Loop through ozbargain web data to find matching terms
numMatches=0
while read line 
do 
    # Ignore the sidebar info to speed up process
    sidebar=`echo $line | egrep "<ul class=\"ozblist\">"`
    if [ "$sidebar" != "" ]
    then
        echo "stopping..."
        break
    fi

    # Search for matches and format output 
    match=`echo "$line" | egrep -i "$regex"`

    # Ignore posts which have already expired
    if [[ "$match" == *"class=\"tagger expired\""* ]]
    then
        continue
    fi

    # Extract the relevant data: Title, link, price
    match=`echo "$match" | sed s/^.*data-title=\"//`
    match=`echo "$match" | sed s/"\"><a href=\""/" https\:\/\/www\.ozbargain\.com\.au"/`
    #match=$(echo "$match" | sed "s/\">[-a-zA-Z0-9 \'\"!@#$%^&*()\[\=\+\`\~,\.\?\/]*<em class=\"dollar\">/ /")
    match=$(echo "$match" | sed "s/\">.*<em class=\"dollar\">/ /")
    match=$(echo "$match" | sed "s/<\/em\>.*$//")
    if [ "$match" != "" ]
    then 
        numMatches=$((numMatches+1))
        echo "$match" >> $nodesFile
    fi
done < "$webDataFile"

echo "Exiting program with $numMatches matching posts found."
