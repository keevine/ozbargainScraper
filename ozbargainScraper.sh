#!/bin/sh

# Usage
if [ "$#" -eq 0 ]
then
    echo "Usage: $0 [searchTerms...]"
    exit 1
fi

webDataFile="ozbargainData.html"

> temp.html

# Extract html from ozbargain websiteq
curl -s https://www.ozbargain.com.au/deals > "$webDataFile"

# Construct the search term with matching given keywords
firstSearchTerm=$1
shift

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

    # Search for matches 
    match=`echo "$line" | egrep -i "$regex"`
    if [ "$match" != "" ]
    then 
        numMatches=$((numMatches+1))
        echo "$match" >> temp.html
        node=`echo "$match" | grep -P "href=\"\/node\/([0-9]+)\"" -o | sed -E "s/href=\"\/node\/|\"$//g"`
    fi
done < "$webDataFile"

echo "Exiting program with $numMatches matching posts found."

#echo $node
#echo $data > temp.html