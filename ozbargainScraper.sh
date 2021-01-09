#!/bin/bash

# Usage
if [ "$#" -lt 2 ]
then
    echo "Usage: $0 <email@domain.com> [searchTerms...]"
    exit 1
fi
email=$1

mkdir -p ".ozBargainLogs"

webDataFile="ozbargainData.html"    # Stores the html for the website
emailFile="emailFile.txt"           # Stores the posts to be later sent via email
userLogs=".ozBargainLogs/$email"

touch "$userLogs"

date=$(date +%d-%b-%g)
time=$(date +%R%p)

echo -e "Subject:Ozbargain digest for $date $time\n\n"> $emailFile                        

# Extract html from ozbargain websiteq
curl -s https://www.ozbargain.com.au/deals > "$webDataFile"


# Construct the search regex with matching given keywords
firstSearchTerm=$2
shift 2

regex="class=\"title\" id=.* data-title=\".*$firstSearchTerm.*\""
echo "Searching ozBargain webpage for the given input search terms:"
echo "Here are the ozBargain posts found for the following search terms:" >> $emailFile
echo "$firstSearchTerm"
echo "$firstSearchTerm" >> $emailFile
for searchTerm in "$@"
do  
    echo "$searchTerm"
    echo "$searchTerm" >> $emailFile
    regex=$regex"|class=\"title\" id=.* data-title=\".*$searchTerm.*\""
done

echo -e "\n" >> $emailFile


# Loop through ozbargain web data to find matching terms
numMatches=0
while read line 
do 
    # Stop looping when reaching the sidebar info to speed up process
    sidebar=`echo $line | egrep "<ul class=\"ozblist\">"`
    if [ "$sidebar" != "" ]
    then
        echo "Finished searching."
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
    match=$(echo "$match" | sed "s/\">.*<em class=\"dollar\">/ /")
    match=$(echo "$match" | sed "s/<\/em\>.*$//")

    # Check user logs to see if the user has already been sent the post
    # This is to prevent sending the user the same post in multiple emails 
    if grep -Fxq "$match" "$userLogs"
    then
        continue
    fi

    if [ "$match" != "" ]
    then 
        numMatches=$((numMatches+1))
        echo -e "$match\n" >> $emailFile
        echo -e "$match\n" >> $userLogs
    fi
done < "$webDataFile"

# Send an email if matches were found
if [ $numMatches -ne 0 ]
then
    echo "Sending email to $email with $numMatches matching posts found."

    echo -e "\nIf you wish to unsubscribe or find any bugs or would like to request a feature to be implemented, please contact: ozbargainScraper@gmail.com\n" >> $emailFile
    cat emailFile.txt | sendmail $email
fi
