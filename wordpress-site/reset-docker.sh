# pull in vars from .env
source .env

echo ""
echo "Destroying ${site_abbreviation} Docker containers..."

sh destroy-docker.sh

echo "${site_abbreviation} Docker containers successfully destroyed!"

echo ""
echo "Rebuilding Docker containers..."

sh run-docker.sh
