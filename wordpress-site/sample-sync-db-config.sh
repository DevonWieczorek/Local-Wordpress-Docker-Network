# Copy exported sql file to local machine
scp $wpengine_sitename@$wpengine_sitename.ssh.wpengine.net:/sites/$wpengine_sitename/db-backup-sync.sql db-backup-sync.sql

echo "Copied SQL file successfully."

# Import SQL file to local db
cat db-backup-sync.sql | docker exec -i local_${site_abbreviation}_db /usr/bin/mysql -u root --password=root wordpress

echo "Imported SQL file to database successfully."

# Run the search & replace script
sh update-db-url.sh
