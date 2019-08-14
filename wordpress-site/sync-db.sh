# Pull in variables from .env
source .env

# prompt for which container to sync db to
echo "enter in the domain of the container you want to sync the db to."
echo "ex: $local_docker_domain"

read container_domain

echo "enter in the STAGING WPENGINE site name"
echo "ex: fdjstaging"

read wpengine_sitename

# copy exported sql file to local machine
scp ${wpengine_sitename}@${wpengine_sitename}.ssh.wpengine.net:/sites/${wpengine_sitename}/db-backup-sync.sql db-backup-sync.sql

echo "copied sql file successfully."

# import sql file to local db
cat db-backup-sync.sql | docker exec -i local_${site_abbreviation}_db /usr/bin/mysql -u root --password=root wordpress

echo "imported sql file to database successfully."

echo "enter in the PRODUCTION WPENGINE domain for this db WITHOUT the trailing slash"
echo "this is needed to do a search and replace in the db with your local domain"
echo "ex: $production_url"

read wpengine_domain

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

echo "do you want to save this configuration?"
echo "yes/no?"

read save_configuration

# if user wants to save config, copy sample job file and replace vars
if [ $save_configuration = "yes" ]; then

    # copy file
    cp sample-sync-db-config.sh $container_domain-sync-db.sh

    # replace variables
    sudo sed -i '' 's/$container_domain/'$container_domain'/g' $container_domain-sync-db.sh
    sudo sed -i '' 's/$wpengine_sitename/'$wpengine_sitename'/g' $container_domain-sync-db.sh
    sudo sed -i '' 's,$wpengine_domain,'$wpengine_domain',g' $container_domain-sync-db.sh

    echo "you can now run this configuration from $container_domain-sync-db.sh"
    echo "ex: sh $container_domain-sync-db.sh"

fi
