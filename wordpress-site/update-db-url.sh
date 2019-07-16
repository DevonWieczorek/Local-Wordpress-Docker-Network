# Pull in variables from .env
source .env

# Check if production url is set as an env var
if [[ ! -z $production_url ]]
    then
    wpengine_domain=$production_url
else
    echo ""
    echo "Enter in the PRODUCTION WPENGINE domain for this db WITHOUT the trailing slash"
    echo "This is needed to do a search and replace in the db with your local domain"
    echo "ex: https://www.finddreamjobs.com"
    read wpengine_domain
fi

# Check if local url is set as an env var
if [[ ! -z $local_docker_domain ]]
then
    container_domain=$local_docker_domain
else
    echo ""
    echo "Enter in the domain of the LOCAL url you want to use in the database"
    echo "ex: local.finddreamjobs.com"
    read container_domain
fi

echo ""
echo "Replacing instances of ${wpengine_domain} with ${container_domain} in the database..."

# start bash session on local db container so we can search and replace inside new sql file
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_options SET option_value = replace(option_value, \"$wpengine_domain\", \"https://$container_domain\") WHERE option_name = \"home\" OR option_name = \"siteurl\"';"
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_posts SET post_content = replace(post_content, \"$wpengine_domain\", \"https://$container_domain\")';"
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_postmeta SET meta_value = replace(meta_value,\"$wpengine_domain\",\"https://$container_domain\")';"
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_usermeta SET meta_value = replace(meta_value, \"$wpengine_domain\",\"https://$container_domain\")';"
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_links SET link_url = replace(link_url, \"$wpengine_domain\",\"https://$container_domain\")';"
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_comments SET comment_content = replace(comment_content , \"$wpengine_domain\",\"https://$container_domain\")';"
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_posts SET post_content = replace(post_content, \"$wpengine_domain\", \"https://$container_domain\")';"
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_links SET link_image = replace(link_image, \"$wpengine_domain\",\"https://$container_domain\")';"
docker exec -it local_${site_abbreviation}_db sh -c "mysql -u root -proot wordpress -e 'UPDATE wp_posts SET guid = replace(guid, \"$wpengine_domain\",\"https://$container_domain\")';"

echo "replaced all old url references successfully."
