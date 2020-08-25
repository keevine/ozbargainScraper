#!/bin/sh

webDataFile="ozbargainData.html"

searchTerm="amazon"


curl https://www.ozbargain.com.au/deals > "$webDataFile"

while read line 
do 
    sidebar=`echo $line | egrep "<ul class=\"ozblist\">"`
    if [ "$sidebar" != "" ]
    then
        echo "stopping..."
        break
    fi
    match=`echo "$line" | egrep -i "class=\"title\" id=.* data-title=\".*$searchTerm.*\""`
    if [ "$match" != "" ]
    then 
        echo "$match" >> temp.html
    fi
done < "$webDataFile"


#echo $node
#echo $data > temp.html