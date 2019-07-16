# copy exported sql file to local machine
scp $wpengine_sitename@$wpengine_sitename.ssh.wpengine.net:/sites/$wpengine_sitename/db-backup-sync.sql db-backup-sync.sql

echo "copied sql file successfully."

# import sql file to local db
cat db-backup-sync.sql | docker exec -i local_${site_abbreviation}_db /usr/bin/mysql -u root --password=root wordpress

echo "imported sql file to database successfully."

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
