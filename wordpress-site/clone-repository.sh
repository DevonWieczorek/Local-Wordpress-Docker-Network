# script to clone wp-content repo and user it for docker container

# pull in vars from .env
source .env

# where we want to clone the repository to
DIRECTORY="wp-content"

# default repository link
repository_link="https://github.com/FluentCo/${site_abbreviation}_wp-content.git"

# if wp-content already exists, don't continue
if [ -d "$DIRECTORY" ]; then
  echo ""
  echo "wp-content directory already exists. continuing without cloning from repository."
fi

# if wp-content does not exist, let's prompt user about which repo to use
if [ ! -d "$DIRECTORY" ]; then

    # user prompt
    echo ""
    echo "wp-content directory does not exist."
    echo "would you like to use a custom repository, or the default FDJ repository?"
    echo "enter 'custom' or 'default'"

    read repository_selection

    # if user selected custom repo, prompt them for repo url and use it
    if [ $repository_selection = "custom" ]; then

        echo "please enter repository url"

        read custom_repository

        repository_link=$custom_repository

    fi

    # clone repo and let user know
    echo "cloning ${site_abbreviation}..."
    git clone $repository_link wp-content
    echo "completed cloning wp-content repository."

fi
