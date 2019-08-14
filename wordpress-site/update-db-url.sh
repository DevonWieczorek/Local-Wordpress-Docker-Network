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

# Use wp-cli to do the search/replace
docker exec local_${site_abbreviation}_wpcli wp search-replace "$wpengine_domain" "https://$container_domain" --all-tables --precise
docker exec local_${site_abbreviation}_wpcli wp cache flush

echo "Replaced all old url references successfully."
