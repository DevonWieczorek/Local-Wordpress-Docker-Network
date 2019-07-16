# Will need to install mkcert manually before running this script
# https://github.com/FiloSottile/mkcert

# Once certificate is make you will have to place it in the certs folder
# Then restart the network container: docker restart global-network_nginx-proxy_1

echo ""
echo "Please enter the local domain you wish to create a certificate for"
echo "ex. local.my-wordpress-instance.com"
read ssl_domain

# Create the certificate
mkcert $ssl_domain

# Copy to the certs directory under the correct name
cp ./$ssl_domain.pem ./certs/$ssl_domain.crt
cp ./$ssl_domain-key.pem ./certs/$ssl_domain.key

# Cleanup
rm ./$ssl_domain.pem
rm ./$ssl_domain-key.pem

echo "Would you like to generate another certificate? [y/n]"
read rerun

if [ $rerun = "y" ] || [ $rerun = "Y" ] || [ $rerun = "yes" ]; then
    # Run the program again
    sh mkcert.sh
else
    echo ""
    echo "Restarting network container..."
    # Restart the container to recognize the certificate
    docker restart global-network_nginx-proxy_1
fi
