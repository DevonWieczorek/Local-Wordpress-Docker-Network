# Local Wordpress Docker Network
The purpose of this is to allow developers to easily set up a multiple environments locally that mirror our production Wordpress environments on WPEngine. This set up is based off of our <a href="https://github.com/FluentCo/local_wordpress_docker" target="_blank">Single Wordpress Docker Setup.</a>

# What is Docker?
Docker provides container software that is ideal for developers and teams looking to get started and experimenting with container-based applications. Containers serve as basically a pre-packaged environment with everything an application needs to run, so an application never has to reach outside that pre-built box for it. A developer can build and test a container on their own system, then push it up to a staging or prod server, without having to worry about dependencies or system variables, or about bad interactions with other applications already on the server. 

# Nginx
This Docker network uses Nginx as a reverse-proxy, allowing for multiple custom local domains to run at the same time without having to specify ports. For example, if you want to run a local instance of Find Dream Jobs and a local instance of The Smart Wallet at the same time, Nginx will point local.finddreamjobs and local.thesmartwallet.com to their appropriate Docker containers without any additional consideration.

# SSL
We have made a push to secure all of our Wordpress sites and force the HTTPS protocol. Because of this, you'll also have to run your local Wordpress sites as secure. 

This repo already comes with the SSL certificates for the following local domains:
- 127.0.0.1
- localhost
- local.thesmartwallet.com
- local.finddreamjobs.com

If you need to generate an SSL for a new local domain, change into **global-network** and run `sh mkcert.sh`. You will be prompted for the local domain you wish to generate an SSL for, and then the script will spit it out into the **certs** directory and restart the local network.

*Note: You will need to have <a href="https://github.com/FiloSottile/mkcert" target="_blank">mkcert</a> installed on your local machine before you can generate an SSL certificate.*

# Setup

## 1. Install and run Docker
Download Docker for Desktop <a href="https://www.docker.com/get-started" target="_blank">here</a> and then walk through the installation steps. Once it is installed, make sure Docker is running on your machine.

## 2. Clone this repository
`git clone https://github.com/FluentCo/local_docker_network.git`

## 3. Open terminal and change into the `local_docker_network` directory after it is finished cloning.
`cd wherever_you_are/local_docker_network`

## 4. Set up the Docker network
Change into the **global-network** directory `cd global-network` and run `sh start-network.sh`.

## 5. Build the Docker containers
For each Wordpress environment you want to run, change into the directory and run the setup script:

 `cd local_docker_network/wordpress-instance`
 
Run `sh run-docker.sh`. 

Here is what will happen:

1. First, you will be prompted to set a few environment variables: production domain, local domain, and a site abbreviation. Local domains should be `local.<production-site-name>` (ex. `local.finddreamjobs.com` or `local.thesmartwallet.com`). Site abbreviations should be **UNIQUE** and be roughly two or three letters (ex. fdj or tsw).
2. Second, it will prompt you and ask if you'd like to import a database or create an empty one. If you choose to import an existing database, please be sure to provide the **ABSOLUTE** path to the sql file on your machine.
3. Next, it will go ahead and set up all of the docker containers and images for you (Wordpress, phpMyAdmin, mySQL).
4. Lastly, it will prompt you to ask what domain you'd like to use to access your local environment. Once entereed, it will update your hosts file to point your localhost to your desired domain. Nginx listens to localhost and directs the browser to whichever container you are trying to access, based on the local domain you specified.

Once the process is complete, you will be able to access your local environment from whatever domain you entered.

# How to use
Once Docker is up and running, you will be able to use/view your local environment at the domain you entered when prompted.

In order to edit files, edit them directly in the wp-content folder of whichever repo you cloned.

Ex: Repo location - `/Users/devonwieczorek/Desktop/local_docker_network/<wordpress-instance>`

Ex: wp-content location - `/Users/devonwieczorek/Desktop/local_docker_network/<wordpress-instance>/wp-content`

To manipulate data inside the Database, see the "Access PHPMyAdmin" section in "Tips & Tricks" below.

If you need to access anything at the server level, see the "SSH into a Docker container" section in "Tips & Tricks" below and
use the `local_<site-abbreviation>_wordpress` container. This is the one that houses wordpress, apache, php, etc.

If you'd like to destroy your docker environment and clear all local variables set, run `sh destroy-docker.sh`. It is necessary to run this command if you would like to rebuild with a different database.

# Sync Your Database from Production
If you'd like to bring your local database up to date with the production site database, you can run `sh sync-db.sh` from this directory.

First and foremost, be sure that your SSH key is added to your WPEngine account so the script is able to connect to the WPEngine environment and copy the sql file down. If you need help creating an SSH key, read <a href="https://secure.vexxhost.com/billing/knowledgebase/171/How-can-I-generate-SSH-keys-on-Mac-OS-X.html" target="_blank">this</a>.

These are the steps the script will go through to sync your database:

1. The script will attempt to retrieve your local wordpress domain from the .env file. If it cannot find that variable, you will be prompted for the domain of your local wordpress install (ex: `local.finddreamjobs.com`). 

2. Next, you will be prompted for the WPEngine install name of the staging environment for the site you want to sync the database from (ex: fdjstaging).

3. After that, the script will either grab your production url from the .env file or you will be prompted for the production url of the site you are syncing from (ex: https://www.finddreamjobs.com). This is so that a search and replace can be performed on the local version of your database so all references pointing to the production domain will now point to your local domain. 

4. Once the sync has been finished, you will get a prompt asking if you'd like to save the configuration you just entered. If you choose to do so, you will be able to run the saved configuration by running `sh local.<local_domain.com>-sync-db.sh`

# Redirect Broken Images
For images that live on your Production site but not Staging or Development, you will need to reach out to WPEngine to set up a general redirect for you. To learn how, you can follow <a href="https://github.com/FluentCo/local_docker_network/wiki/Special-Redirects">these instructions</a>.

# Set up a Cron Job to Sync the Database
In order to make sure our Development and Staging environments accurately reflect the Production environment, we have a cron job that backs up the production database daily and imports it into the other environments.

To set up this job in Gitlab, follow <a href="https://github.com/FluentCo/local_docker_network/wiki/Scheduled-Database-Sync">this tutorial</a>.

# Tips & Tricks

## View running containers
`docker ps`

## Access phpMyAdmin
Because we are running a multi-site network, there is no standardized port for phpMyAdmin. First find out what port your instance of phpMyAdmin is running on by running `docker ps`.

Then, you can access your phpMyAdmin panel by going to `<your-local-domain>:<port>` (ex. `local.finddreamjobs.com:8181`).

The root username is `root` and the password is `root`

## SSH into a Docker container
This is useful if you need to check access/error logs or want to install a server-side extension.

`docker exec -it container_id (or container_name) bash`

## Shut down and destroy all containers but preserve data
This will remove all containers for a given instance but not their databases.

`cd local-wordpress-directory`

`docker-compose down`

## Shut down and destroy all containers, data, and variables
This will remove all containers and their databases for a given instance.

`cd local-wordpress-directory`

`sh destroy-docker.sh`

**When shutting down one of the Wordpress instances it is CRUCIAL you run `sh destroy-docker.sh` to shut it down. Our docker-compose.yml and a few other bash scripts use placeholder strings that get replaced when running `sh run/destroy-docker.sh`. Things can break if you use a typical `docker-compose up/down`.**

## Restart a Docker instance
If something changes with the set up of your Docker instance you will have to restart the containers.

`cd local-wordpress-directory`

`sh reset-docker.sh`

## Restart the entire Docker network
If something changes in your network set up (such as the addition of an SSL certificate) you will need to restart the network.

First, you will have to change into each Wordpress instance and shut it down using `sh destroy-docker.sh`.

Once all of your Wordpress instances are shut down, change into the **global-network** directory and run the reset script:

`cd ../global-network`

`sh reset-network.sh`

# Tech Stack
The stack of the local Wordpress environments are based off of and meant to mirror WPEngine's stack. You can read more about their stack <a href="https://wpengine.com/support/platform-settings/" target="_blank">here</a>.

# Considerations

- First and foremost, I am by no means a Docker expert. If you find bugs or ways to improve this set up, please create a PR with a message describing the optimizations and I will happily merge. 

- This set up was created and tested on a Mac. I have been told there are a lot of issues when running the setup on Windows. Whoever can help, please update as needed for Windows and create a PR so that we can support both.

- The **wp-content** folder in this repository is simply a placeholder. If you are setting up a new Wordpress instance on your local machine, make sure to export the site's **wp-content** folder from WPEngine.

- If you plan on using our Deploybot development pipeline with your Wordpress instance, make sure to use the .gitignore file that is in the **wp-content** folder in this repo. The most important thing there is that you ignore `wp-content/mu-plugins/**` as WPEngine will reject the request because users do not have permissions to update or modify them.






