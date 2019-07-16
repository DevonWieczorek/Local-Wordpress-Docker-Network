# destroy existing docker containers/images, and data
docker-compose down --volumes


# replace local db path variable to default empty one
sed -i '' 's+local_database_path=.*+local_database_path=./docker/data/wordpress.sql+g' .env


# clear existing local.thesmartwallet.com entries from /etc/hosts
source .env
echo "removing $local_docker_domain from hosts file"
sudo sed -i '' '/'$local_docker_domain'/d' /etc/hosts
sudo sed -i '' '/local_docker_domain/d' .env


# if production_url is set as an env var, remove it in .htaccess
if [[ ! -z $production_url ]]
then
    sed -i '' 's+'$production_url'+ PRODUCTION_URL_HERE+g' docker_ssl_proxy/.htaccess
fi
# remove production_url from env config
sed -i '' 's+production_url=.*++g' .env


# if site_abbreviation is set as an env var, remove it in docker-compose.yml
if [[ ! -z $site_abbreviation ]]
then
    sed -i '' "s/$site_abbreviation/SITE_ABBV/g" docker-compose.yml
fi
# remove production_url from env config
sed -i '' 's+site_abbreviation=.*++g' .env
