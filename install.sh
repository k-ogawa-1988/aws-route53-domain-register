#!/bin/sh

# ENV
readonly ROOT_DIR=$(pwd)
readonly SERVICE_NAME=update-route53
readonly TEMP_INIT_SHELL_NAME=init-shell.template.sh
readonly TEMP_EXEC_SHELL_NAME=ec2setup.template.sh
readonly TEMP_SETTING_NAME=settings.template.ini
readonly INIT_SHELL_NAME=init-shell.sh
readonly EXEC_SHELL_NAME=ec2setup.sh
readonly SETTING_NAME=settings.ini

# question
echo "--- AWS User ---"
echo -n "Enter your region: "
read REGION
echo -n "Enter your Access Key: "
read ACCESS_KEY
echo -n "Enter your Secret Access Key: "
read SECRET_KEY
echo "--- Route53 ---"
echo -n "Enter your Hosted Zone ID: "
read ZONEID
echo "--- EC2 ---"
echo -n "Enter your Hostname's tag key: "
read TAG_KEY

while :
do
    echo "--- Confirm ---"
    echo "region = "$REGION
    echo "aws_access_key_id = "$ACCESS_KEY
    echo "aws_secret_access_key = "$SECRET_KEY
    echo ""
    echo "Zone ID = "$ZONEID
    echo ""
    echo -n "Are you ok? (y/n)"
    read -n 1 ans
    case $ans in
        [yY])
            break
            ;;
        [nN])
            exit 0
            ;;
    esac
done

# rewrite init-shell.sh
sed -e "s:{%ROOT_DIR%}:${ROOT_DIR}:g" $TEMP_INIT_SHELL_NAME > $INIT_SHELL_NAME
#rm -f $TEMP_INIT_SHELL_NAME
# rewrite ec2setup.sh
sed -e "s:{%ROOT_DIR%}:${ROOT_DIR}:g;s/{%ZONEID%}/${ZONEID}/g;s/{%TAG_KEY%}/${TAG_KEY}/g" $TEMP_EXEC_SHELL_NAME > $EXEC_SHELL_NAME
#rm -f $TEMP_EXEC_SHELL_NAME
# rewrite settings.ini
sed -e "s/{%REGION%}/${REGION}/g;s/{%ACCESS_KEY%}/${ACCESS_KEY}/g;s,{%SECRET_KEY%},${SECRET_KEY},g" $TEMP_SETTING_NAME > $SETTING_NAME
#rm -f $TEMP_SETTING_NAME

# change file mode
chmod +x $ROOT_DIR/$INIT_SHELL_NAME
chmod +x $ROOT_DIR/$EXEC_SHELL_NAME

# make symbolic link
ln -sf $ROOT_DIR/$INIT_SHELL_NAME /etc/init.d/$SERVICE_NAME

# register service
chkconfig --add $SERVICE_NAME
chkconfig $SERVICE_NAME on
