# import db script

# prompt user to see if they need to import a db
echo "do you want to import a database or create an empty one?"
echo "enter 'import' or 'create'."

read db_selection

# if user selected import a db, prompt them for db path and use it
if [ $db_selection = "import" ]; then

    echo "please enter the ABSOLUTE path to the sql file you want to import."

    read db_path

    # replace db path in docker-compose.yml with user specified path
    sed -i '' 's+./docker/data/wordpress.sql+'$db_path'+g' .env

    echo "database path has been set."

fi
