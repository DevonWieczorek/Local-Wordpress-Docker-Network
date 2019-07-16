# do string replacement for container names and misc vars
sh set-env-vars.sh

# clone wp-content repo into directory
sh clone-repository.sh

# allow user to choose option for database
sh import-db.sh

# run docker
docker-compose up -d

#! This method has been deprecated as it clashes with nginx
# configure ssl cert
# sh configure-ssl.sh

# update localhost
sh update-localhost.sh

# Let mySQL boot up before attempting to do the db replace
echo ""
echo "Waiting 10s for mySQL to boot up..."
sleep 10

# Replace production url with local url
sh update-db-url.sh
