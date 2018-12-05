
printf  "This Script will check the hitcounts for each rule and output into CSV\nPress Anykey to continue\n"
read ANYKEY

printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

printf "\nListing Access Policy Package Names\n"
mgmt_cli -r true -d $DOMAIN show access-layers limit 500 --format json | jq --raw-output '."access-layers"[] | (.name)'

printf "\nWhat is the Policy Package Name?\n"
read POL_NAME
POL2=$(echo $POL_NAME | tr -d ' ')

printf "\nDetermining Rulesbase Size\n"
total=$(mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" --format json |jq '.total')
printf "There are $total rules in $POL_NAME\n"

for I in $(seq 0 500 $total)
  do
    mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true --format json | jq --raw-output '.rulebase[] | ((."rule-number"|tostring) + "," + (.hits.value|tostring))' >> $POL2-hitcount.csv
  done

sed -i '1s/^/RULE_NUMBER,HITCOUNT\n/' $POL2-hitcount.csv
printf "\nYour Hitcount List is located in $POL2-hitcount.csv\n"
