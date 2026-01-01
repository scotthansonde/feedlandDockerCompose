# FeedLand Docker Compose 
## A Docker Compose file to quickly start an instance of [FeedLand](https://docs.feedland.com/)

### Installation and start-up
0. Prerequisites
    - A DNS entry pointing to your server
    - Docker installed on your server (Steps 1 and 2 of this tutorial )
1. Download this repo into a folder on your server
2. Copy .env.example to .env and set the values
    - Set FEEDLAND_DOMAIN to your DNS entry
    - Create passwords for MYSQL_ROOT_PASSWORD and MYSQL_USER_PASSWORD
    - If you want caddy to handle HTTPS set COMPOSE_PROFILES=caddy
3. Run `docker compose up` from the folder containing docker-compose.yml

### What this does 
- A config.json file will be generated using the values from .env
- A mysql server will be started and a feedland database will be initialized
- A FeedLand server will be started using the generated config.json
- If activated, a caddy server is started forwarding https to the FeedLand instance

Restart the servers with `docker compose restart`. Stop the servers with `docker compose down`. 

Once started, additional values can be added to config.json. An existing config.json will not be overwritten when starting or restarting the server.

### FeedLand E-Mail Validation
Some users running a local Feedland instance may not have the ability or desire to connect Feedland with an email service. As a shortcut to getting a new user added to the system, you can
do the following:

  * Sign up for a new user, and enter a username and email address
  * FeedLand will report an error sending email, but still create a new record in its `pendingConfirmations` table
  * From the folder containing docker-compose.yml run 
    ```
    docker exec -it mysql_db \. 
    mysql -u feedland -p"$MYSQL_USER_PASSWORD" feedland \. 
    -e "SELECT * FROM pendingConfirmations\G"
    ``` 
    to show the contents of the `pendingConfirmations` table.
  * Copy the `magicString` value for the new, pending user, and insert it into a URL that looks like: `http://"$FEEDLAND_DOMAIN"/userconfirms?emailConfirmCode=MAGIC_STRING_HERE`
  * Submit that URL in your browser and enjoy!

(adapted from [DOCKER.md](https://github.com/cshotton/feedlandInstall/blob/main/DOCKER.md) by Chuck Schotton)
