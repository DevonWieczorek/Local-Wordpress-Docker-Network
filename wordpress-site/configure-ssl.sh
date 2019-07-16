# create new bash session on wordpress container and install + configure ssl cert
# DEPRECATED: Do not use if you're using an nginx proxy!
docker exec -ti local_fdj_wordpress sh -c "apt-get update && apt-get install -y  --no-install-recommends ssl-cert && rm -r /var/lib/apt/lists/* && a2enmod ssl && a2ensite default-ssl && service apache2 reload"
