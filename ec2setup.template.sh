#!/bin/sh

# Env
readonly APPPATH={%ROOT_DIR%}
readonly ZONEID="{%ZONEID%}"
readonly HOSTS="/etc/hosts"

export AWS_SHARED_CREDENTIALS_FILE=$APPPATH/settings.ini
readonly TEMPLATE_FILE=$APPPATH/ChangeResourceRecordSet.template.json

readonly INSTANCE_ID=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id)
readonly IP=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
readonly HOSTNAME=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --output json | jq -r '.Reservations[].Instances[].Tags[] | select(.Key == "{%TAG_KEY%}").Value')
readonly TEMP_FILE=$APPPATH/$HOSTNAME.json

hostname $HOSTNAME
sed -i """/127.0.0.1/c\127.0.0.1 localhost ${HOSTNAME}" ${HOSTS}

sed -e "s/{%IP%}/${IP}/g;s/{%HOST%}/${HOSTNAME}/g" $TEMPLATE_FILE > $TEMP_FILE
aws route53 change-resource-record-sets --hosted-zone-id ${ZONEID} --change-batch file://$TEMP_FILE

exit
