#!/bin/sh

webDataFile="ozbargainData.html"

searchTerm="amazon"
> temp.html

# Extract html from ozbargain website
curl https://www.ozbargain.com.au/deals > "$webDataFile"


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
    match=`echo "$line" | egrep -i "class=\"title\" id=.* data-title=\".*$searchTerm.*\""`
    if [ "$match" != "" ]
    then 
        echo "$match" >> temp.html
        node=`echo "$match" | grep -P "href=\"\/node\/([0-9]+)\"" -o | sed -E "s/href=\"\/node\/|\"$//g"`
    fi
done < "$webDataFile"


#echo $node
#echo $data > temp.html