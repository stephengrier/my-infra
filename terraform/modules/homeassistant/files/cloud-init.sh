#!/usr/bin/env bash
set -ueo pipefail

DOCKER_COMPOSE_FILE='/root/docker-compose.yaml'

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# Install a few prerequisites.
apt-get install -y \
    jq \
    unzip

# Install the awscli. Install from the zip file because the
# packaged version in Jammy is too old.
curl -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip
curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip.sig
gpg --import <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4CGwMF
CwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQT7Xbd/1cEYuAURraimMQrMRnJHXAUC
ZMKcEgUJCSEf3QAKCRCmMQrMRnJHXCilD/4vior9J5tB+icri5WbDudS3ak/ve4q
XS6ZLm5S8l+CBxy5aLQUlyFhuaaEHDC11fG78OduxatzeHENASYVo3mmKNwrCBza
NJaeaWKLGQT0MKwBSP5aa3dva8P/4oUP9GsQn0uWoXwNDWfrMbNI8gn+jC/3MigW
vD3fu6zCOWWLITNv2SJoQlwILmb/uGfha68o4iTBOvcftVRuao6DyqF+CrHX/0j0
klEDQFMY9M4tsYT7X8NWfI8Vmc89nzpvL9fwda44WwpKIw1FBZP8S0sgDx2xDsxv
L8kM2GtOiH0cHqFO+V7xtTKZyloliDbJKhu80Kc+YC/TmozD8oeGU2rEFXfLegwS
zT9N+jB38+dqaP9pRDsi45iGqyA8yavVBabpL0IQ9jU6eIV+kmcjIjcun/Uo8SjJ
0xQAsm41rxPaKV6vJUn10wVNuhSkKk8mzNOlSZwu7Hua6rdcCaGeB8uJ44AP3QzW
BNnrjtoN6AlN0D2wFmfE/YL/rHPxU1XwPntubYB/t3rXFL7ENQOOQH0KVXgRCley
sHMglg46c+nQLRzVTshjDjmtzvh9rcV9RKRoPetEggzCoD89veDA9jPR2Kw6RYkS
XzYm2fEv16/HRNYt7hJzneFqRIjHW5qAgSs/bcaRWpAU/QQzzJPVKCQNr4y0weyg
B8HCtGjfod0p1A==
=gdMc
-----END PGP PUBLIC KEY BLOCK-----
EOF
gpg --verify awscliv2.sig awscliv2.zip
unzip awscliv2.zip && ./aws/install

# Associate Elastic IP.
aws --region ${region} ec2 associate-address \
     --allocation-id ${eip_id} \
     --instance-id $(ec2metadata --instance-id)

# Wait a few seconds for the EIP to come up.
sleep 5

# Attach EBS data volumes. We have to do this here because we're using
# an ASG and launch templates don't allow attaching specific volumes.
aws --region ${region} ec2 attach-volume \
     --device /dev/sdf \
     --instance-id $(ec2metadata --instance-id) \
     --volume-id ${ha_volume_id}

aws --region ${region} ec2 attach-volume \
     --device /dev/sdh \
     --instance-id $(ec2metadata --instance-id) \
     --volume-id ${srv_volume_id}

# Wait for the OS to create block devices for the above volumes.
for _ in $(seq 30); do
  [ -b '/dev/nvme1n1' ] && [ -b '/dev/nvme2n1' ] && break
  echo 'Waiting for block devices to be created...'
  sleep 1;
done

# Create partitions and filesystems if volumes are new.
for vol in /dev/nvme1n1 /dev/nvme2n1; do
  blkid $${vol} > /dev/null && true
  if [ "$?" != "0" ]; then
    /sbin/parted $${vol} mklabel gpt --script
    /sbin/parted $${vol} mkpart primary 0% 100% --script
    # Wait a second for the block device to appear.
    sleep 1
    mkfs.ext4 $${vol}p1
  fi
done

echo '/dev/nvme1n1p1	/etc/homeassistant	ext4	defaults	0	0' >> /etc/fstab
echo '/dev/nvme2n1p1	/srv	ext4	defaults	0	0' >> /etc/fstab

# Create mount points.
mkdir -p /etc/homeassistant /srv

# Mount partitions.
mount -a

apt-get install --yes docker-compose

# Add the ubuntu user to the docker group.
usermod -a -G docker ubuntu

# Create docker-compose file.
cat > $DOCKER_COMPOSE_FILE <<EOF
version: "3.1"
services:
  mosquitto:
    image: eclipse-mosquitto
    container_name: mosquitto
    restart: unless-stopped
    volumes:
      - /srv/mosquitto:/mosquitto
      - /srv/mosquitto/data:/mosquitto/data
      - /srv/mosquitto/log:/mosquitto/log
    ports:
      - 1883:1883
      - 8883:8883
      - 9001:9001
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - /etc/homeassistant:/config
    environment:
      - TZ="Europe/London"
    restart: unless-stopped
    privileged: true
    ports:
      - 8123:8123
  nginx:
    container_name: nginx
    image: nginx:latest
    user: root
    ports:
      - 80:80
      - 443:443
    restart: unless-stopped
    volumes:
      - /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/nginx/conf.d:/etc/nginx/conf.d:ro
      - /srv/certbot/www:/var/www/certbot:ro
      - /srv/certbot/conf:/etc/nginx/ssl:ro
  certbot:
    image: certbot/certbot:latest
    volumes:
      - /srv/certbot/www/:/var/www/certbot/:rw
      - /srv/certbot/conf/:/etc/letsencrypt/:rw
EOF

# Create mosquitto directory structure
mkdir -p /srv/mosquitto/{config,data,log,tls}

# Create directories for nginx and certbot config
mkdir -p /etc/nginx/conf.d /srv/certbot/{conf,www}

# Create an initial port 80 nginx config so that certbot can complete the
# validation step for a new certificate from LetsEncrypt
cat > /etc/nginx/nginx.conf <<EOF
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    keepalive_timeout  65;
    map \$http_upgrade \$connection_upgrade {
        default upgrade;
        ''      close;
    }
    include /etc/nginx/conf.d/*.conf;
}
EOF

cat > /etc/nginx/conf.d/homeassistant_80.conf <<EOF
server {
    listen 80;
    listen [::]:80;

    server_name ${server_name};
    server_tokens off;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}
EOF

# Start the services
docker-compose -f $DOCKER_COMPOSE_FILE up -d

# Request a new TLS certificate from LetsEncrypt if we don't have one already
# Specify a key type of 'rsa' as tasmota doesn't work with ECDSA
if [ ! -d /srv/certbot/conf/live/${server_name} ]; then
  docker-compose -f $DOCKER_COMPOSE_FILE run \
                 --rm certbot certonly \
                 --webroot \
                 --webroot-path /var/www/certbot/ \
                 -d ${server_name} \
                 -d ${mqtt_server_name} \
                 -m ${letsencrypt_email} \
                 --no-eff-email \
                 --agree-tos \
                 --key-type rsa \
                 ${certbot_extra_args}
fi

# Now that we have a TLS cert, create an HTTPS server in nginx
cat > /etc/nginx/conf.d/homeassistant_443.conf <<EOF
server {
    listen 443 default_server ssl http2;
    listen [::]:443 ssl http2;

    server_name ${server_name};

    ssl_certificate /etc/nginx/ssl/live/${server_name}/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/live/${server_name}/privkey.pem;

    location / {
        proxy_pass http://homeassistant:8123;
        proxy_set_header Host \$host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
    }
}
EOF

# Copy the certs to a location mosquitto can use them.
# Change ownership to the mosquito UID/GID so mosquitto can read them.
cp -p /srv/certbot/conf/live/${server_name}/{cert.pem,privkey.pem,chain.pem} /srv/mosquitto/tls/
chown 1883:1883 /srv/mosquitto/tls/*.pem

# Create a mosquitto config
cat > /srv/mosquitto/config/mosquitto.conf <<EOF
persistence true
persistence_location /mosquitto/data/
persistent_client_expiration 14d
log_dest file /mosquitto/log/mosquitto.log
per_listener_settings true

# A non-TLS listener for local clients
listener 1883
allow_anonymous true

listener 8883
cafile /mosquitto/tls/chain.pem
certfile /mosquitto/tls/cert.pem
keyfile /mosquitto/tls/privkey.pem
allow_anonymous false
password_file /mosquitto/config/passwd
EOF

# Make sure mosquitto's passwd file exists
[ -f /srv/mosquitto/config/passwd ] || touch /srv/mosquitto/config/passwd

# Restart the nginx and mosquitto containers
docker-compose -f $DOCKER_COMPOSE_FILE restart nginx mosquitto

# Lastly, create a cron job to renew the LetsEncrypt certificate
cat > /etc/cron.daily/certbot-renew <<EOF
#!/usr/bin/env bash
set -ueo pipefail

CERTBOT_CONF_DIR=/srv/certbot/conf
MOSQUITTO_TLS_DIR=/srv/mosquitto/tls

docker-compose \\
    -f $DOCKER_COMPOSE_FILE run \\
    --rm \\
    certbot renew --deploy-hook 'touch /etc/letsencrypt/renewed'

if [ -f "\$CERTBOT_CONF_DIR/renewed" ]; then
    cp -p "\$CERTBOT_CONF_DIR"/live/${server_name}/{cert.pem,privkey.pem,chain.pem} "\$MOSQUITTO_TLS_DIR"/
    chown 1883:1883 "\$MOSQUITTO_TLS_DIR"/*.pem
    docker-compose -f $DOCKER_COMPOSE_FILE restart nginx mosquitto
    rm "\$CERTBOT_CONF_DIR/renewed"
fi
EOF
chmod 0755 /etc/cron.daily/certbot-renew
