# Convert http(s)://www.sitename.com to local.sitename.com
localize () {
  reProtocol=$(sed 's~http[s]*://~~g' <<< "$1")
  reWWW=$(sed 's~www.~~g' <<< $reProtocol)
  echo "local.$reWWW"
}

# we want the production url so we can proxy images and do a db replace
echo ""
echo "please enter the production url for this site"
echo "ex: https://www.finddreamjobs.com"

read production_url

# add production url to htaccess config and env
sed -i '' 's+PRODUCTION_URL_HERE+'$production_url'+g' docker_ssl_proxy/.htaccess
echo 'production_url='$production_url >> .env

# create string for local domain prompt
local_name=$(localize $production_url)

# prompt user for domain they'd like to use
echo ""
echo "enter the domain you'd like to use for your local environment"
echo "ex: $local_name"

read local_domain

sudo sed -i '' '/local_docker_domain/d' .env
echo "local_docker_domain=$local_domain" >> .env


# Get a site abbreviation to use in container names
echo ""
echo "Please enter a short UNIQUE abbreviation for this site (for use in container names)"
echo "ex. fdj"

read abbreviation

# Replace our placeholder with the site abbreviation
sed -i '' "s/SITE_ABBV/$abbreviation/g" docker-compose.yml

# Save as an environment variable
echo 'site_abbreviation='$abbreviation >> .env
