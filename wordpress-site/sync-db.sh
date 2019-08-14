# Pull in variables from .env
source .env

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

# Get the staging environment to copy the SQL file from
echo "Enter in the STAGING WPEngine site name"
echo "ex: fdjstaging"
read wpengine_sitename

# Copy exported sql file to local machine
scp $wpengine_sitename@$wpengine_sitename.ssh.wpengine.net:/sites/$wpengine_sitename/db-backup-sync.sql db-backup-sync.sql
echo "Copied SQL file successfully."

# Import sql file to local db
cat db-backup-sync.sql | docker exec -i local_${site_abbreviation}_db /usr/bin/mysql -u root --password=root wordpress
echo "Imported SQL file to database successfully."

# Run the search & replace script
sh update-db-url.sh

# Prompt user to save configuration
echo "Do you want to save this configuration?"
echo "yes/no?"
read save_configuration

# If user wants to save config, copy sample job file and replace vars
if [ $save_configuration = "yes" ]; then

    # Copy file
    cp sample-sync-db-config.sh $container_domain-sync-db.sh

    # Replace variables
    sudo sed -i '' 's/$container_domain/'$container_domain'/g' $container_domain-sync-db.sh
    sudo sed -i '' 's/$wpengine_sitename/'$wpengine_sitename'/g' $container_domain-sync-db.sh
    sudo sed -i '' 's/${site_abbreviation}/'$site_abbreviation'/g' $container_domain-sync-db.sh
    sudo sed -i '' 's,$wpengine_domain,'$wpengine_domain',g' $container_domain-sync-db.sh

    echo "you can now run this configuration from $container_domain-sync-db.sh"
    echo "ex: sh $container_domain-sync-db.sh"

fi
