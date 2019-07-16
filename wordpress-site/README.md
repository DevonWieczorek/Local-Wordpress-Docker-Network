# Local Wordpress Docker Environment
The purpose of this is to allow developers to easily set up a local environment that mirrors our production wordpress environments on WPEngine.

# What is Docker?
Docker provides container software that is ideal for developers and teams looking to get started and experimenting with container-based applications. Containers serve as basically a pre-packaged environment with everything an application needs to run, so an application never has to reach outside that pre-built box for it. A developer can build and test a container on their own system, then push it up to a staging or prod server, without having to worry about dependencies or system variables, or about bad interactions with other applications already on the server. 

# Setup

## Things to note:
If you are planning to import a database, you will need to replace the values of `siteurl` and `home` in the sql file to `http://local.thesmartwallet.com` if you are planning on using local.thesmartwallet.com as your local environment domain.

There are a few files that are WPEngine specific that you will likely need to remove from your local wp-content folder, or else you will see errors.

These files are: 
- `wp-content/mu-plugins/mu-plugin.php`
- `wp-content/mu-plugins/wpengine-common/`

We are also running php v7.2 on this local environment. Our prod WPEngine instance is running php v7.0, but we will be forced to upgrade in a little while. You may see an error saying `Warning: Parameter 2 to wp_hide_post_Public::query_posts_join() expected to be a reference, value given in /var/www/html/wp-includes/class-wp-hook.php on line 286`. This is because in php v7.2, you cannot assign values by a reference anymore. In order to fix this, go into <a href="https://github.com/FluentCo/tsw_wp-content/blob/030ed01142bffb11484688437b4772613e106883/plugins/wp-hide-post/public/class-wp-hide-post-public.php#L318">`wp-content/plugins/wp-hide-post/public/class-wp-hide-post-public.php`</a> and do a search for `&$wp_query` (should be line 318). Remove the `&` from that line.

## 1. Install and run Docker
Download Docker for Desktop <a href="https://www.docker.com/get-started" target="_blank">here</a> and then walk through the installation steps. Once it is installed, make sure Docker is running on your machine.

## 2. Clone this repository
`git clone https://github.com/FluentCo/local_wordpress_docker.git`

## 3. Open terminal and change into the `local_wordpress_docker` directory after it is finished cloning.
`cd wherever_you_are/local_wordpress_docker`

## 4. Build the docker containers
I have setup a script that will take care of building everything for you, along with prompt you for some additional information. 

Run `sh run-docker.sh`. Here is what will happen:

### a. First, it will prompt you for the github repo that you'd like to use. You can choose to use the default TSW repo, or clone another one. If choosing to clone a different repo, please note this repo should only contain wp-content folders and assets.
### b. Second, it will prompt you and ask if you'd like to import a database or create an empty one. If you choose to import an existing database, please be sure to provide the ABSOLUTE path to the sql file on your machine.
### c. Next, it will go ahead and set up all of the docker containers and images for you.
### d. Lastly, it will prompt you to ask what domain you'd like to use to access your local environment. Once entereed, it will update your hosts file to point your localhost to your desired domain.

Once the process is complete, you will be able to access your local environment from localhost or whatever domain you entered.

# How to use
Once Docker is up and running, you will be able to use/view your local environment at the domain you entered when prompted.

In order to edit files, edit them directly in the wp-content folder that is inside of wherever you cloned this repo.

Ex: Repo location - `/Users/joshdarby/Desktop/local_wordpress_docker`

Ex: wp-content location - `/Users/joshdarby/Desktop/local_wordpress_docker/wp-content`

To manipulate data inside the Database, see the "Access PHPMyAdmin" section in "Tips & Tricks" below.

If you need to access anything at the server level, see the "SSH into a Docker container" section in "Tips & Tricks" below and
use the `local_wordpress_docker_wordpress` container. This is the one that houses wordpress, apache, php, etc.

If you'd like to destroy your docker environment and clear all local variables set, run `sh destroy-docker.sh`. It is necessary to run this command if you would like to rebuild with a different database.

# Sync Your Database from Production
If you'd like to bring your local database up to date with the production site database, you can run `sh sync-db.sh` from this directory.

First and foremost, be sure that your SSH key is added to your WPEngine account so the script is able to connect to the WPEngine environment and copy the sql file down. If you need help creating an SSH key, read <a href="https://secure.vexxhost.com/billing/knowledgebase/171/How-can-I-generate-SSH-keys-on-Mac-OS-X.html" target="_blank">this</a>.

These are the steps the script will go through to sync your database:

### 1. You will first be prompted for the domain of your local wordpress install (ex: local.thesmartwallet.com). 

### 2. Next, you will be prompted for the WPEngine install name of the staging environment for the site you want to sync the database from (ex: tswstaging). 

### 3. After that, you will be prompted for the production url of the site you are syncing from (ex: https://thesmartwallet.com). This is so that a search and replace can be performed on the local version of your database so all references pointing to the production domain will now point to your local domain. 

### 4. Once the sync has been finished, you will get a prompt asking if you'd like to save the configuration you just entered. If you choose to do so, you will be able to run the saved configuration by running `sh local.local_domain.com-sync-db.sh`

# Tips & Tricks

## View running containers
`docker ps`

## Access PHPMyAdmin
To access PHPMyAdmin, visit local.domain_you_chose.com:8181, or localhost:8181

The root username is `root` and the password is `root`

## SSH into a Docker container
This is useful if you need to check access/error logs or want to install a server-side extension.

`docker exec -it container_id (or container_name) bash`

## Shut down and destroy all containers but preserve data
This will remove all containers but not their databases

`docker-compose down`

## Shut down and destroy all containers and data
This will remove all containers and their databases

`docker-compose down --volumes`

# Tech Stack
The stack of this local environment is based off of and meant to mirror WPEngine's stack. You can read more about their stack <a href="https://wpengine.com/support/platform-settings/" target="_blank">here</a>.







