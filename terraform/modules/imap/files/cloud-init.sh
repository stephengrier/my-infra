#!/usr/bin/env bash
set -ueo pipefail

apt-get update

export DEBIAN_FRONTEND=noninteractive

# Install a few prerequisites.
apt-get install -y \
    jq \
    unzip

# Install the awscli. Install from the zip file because the
# packaged version in xenial is too old.
curl -o awscliv2.zip https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip
curl -o awscliv2.sig https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip.sig
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
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4WIQT7
Xbd/1cEYuAURraimMQrMRnJHXAUCXYKvtQIbAwUJB4TOAAULCQgHAgYVCgkICwIE
FgIDAQIeAQIXgAAKCRCmMQrMRnJHXJIXEAChLUIkg80uPUkGjE3jejvQSA1aWuAM
yzy6fdpdlRUz6M6nmsUhOExjVIvibEJpzK5mhuSZ4lb0vJ2ZUPgCv4zs2nBd7BGJ
MxKiWgBReGvTdqZ0SzyYH4PYCJSE732x/Fw9hfnh1dMTXNcrQXzwOmmFNNegG0Ox
au+VnpcR5Kz3smiTrIwZbRudo1ijhCYPQ7t5CMp9kjC6bObvy1hSIg2xNbMAN/Do
ikebAl36uA6Y/Uczjj3GxZW4ZWeFirMidKbtqvUz2y0UFszobjiBSqZZHCreC34B
hw9bFNpuWC/0SrXgohdsc6vK50pDGdV5kM2qo9tMQ/izsAwTh/d/GzZv8H4lV9eO
tEis+EpR497PaxKKh9tJf0N6Q1YLRHof5xePZtOIlS3gfvsH5hXA3HJ9yIxb8T0H
QYmVr3aIUes20i6meI3fuV36VFupwfrTKaL7VXnsrK2fq5cRvyJLNzXucg0WAjPF
RrAGLzY7nP1xeg1a0aeP+pdsqjqlPJom8OCWc1+6DWbg0jsC74WoesAqgBItODMB
rsal1y/q+bPzpsnWjzHV8+1/EtZmSc8ZUGSJOPkfC7hObnfkl18h+1QtKTjZme4d
H17gsBJr+opwJw/Zio2LMjQBOqlm3K1A4zFTh7wBC7He6KPQea1p2XAMgtvATtNe
YLZATHZKTJyiqA==
=vYOk
-----END PGP PUBLIC KEY BLOCK-----
EOF
gpg --verify awscliv2.sig awscliv2.zip
unzip awscliv2.zip && ./aws/install

# Associate Elastic IP.
aws --region ${region} ec2 associate-address \
     --allocation-id ${eip_id} \
     --instance-id $(ec2metadata --instance-id)

# Attach EBS data volumes. We have to do this here because we're using
# an ASG and launch templates don't allow attaching specific volumes.
aws --region ${region} ec2 attach-volume \
     --device /dev/sdf \
     --instance-id $(ec2metadata --instance-id) \
     --volume-id ${ldap_volume_id}

aws --region ${region} ec2 attach-volume \
     --device /dev/sdg \
     --instance-id $(ec2metadata --instance-id) \
     --volume-id ${imap_volume_id}

# Give the OS a few seconds to create devices for the above volumes.
sleep 5

echo '/dev/nvme1n1p1	/var/lib/ldap	ext4	defaults	0	0' >> /etc/fstab
echo '/dev/mapper/cloud1-varimap	/var/imap	ext3	defaults	0	0' >> /etc/fstab
echo '/dev/mapper/cloud1-varspoolimap	/var/spool/imap	ext3	noatime	0	0' >> /etc/fstab

# Create mount points.
mkdir -p /var/imap /var/spool/imap /var/lib/ldap

# Some debconf hints to install slapd non-interactively.
debconf-set-selections <<< "slapd slapd/password1 password admin"
debconf-set-selections <<< "slapd slapd/internal/adminpw password admin"
debconf-set-selections <<< "slapd slapd/internal/generated_adminpw password admin"
debconf-set-selections <<< "slapd slapd/password2 password admin"
debconf-set-selections <<< "slapd slapd/purge_database boolean false"
debconf-set-selections <<< "slapd slapd/move_old_database boolean false"

apt-get install -y slapd ldap-utils

# Mount slapd database and config. Do this after installing slapd because
# the post-install script messes with existing data and config.
service slapd stop
mount /var/lib/ldap
rm -rf /etc/ldap/slapd.d && \
  ln -s /var/lib/ldap/slapd.d /etc/ldap/slapd.d

# Fix up file ownership on the data file as the openldap UID/GID might be different.
chown -R openldap:openldap /var/lib/ldap

service slapd start

# Mount cyrus-imap partitions.
mount -a

# Pull Cyrus' config files from parameter store.
aws ssm get-parameter \
  --name "/imap/config/${environment}/imapd_conf" \
  --with-decryption \
  | jq -j .Parameter.Value > /etc/imapd.conf

aws ssm get-parameter \
  --name "/imap/config/${environment}/cyrus_conf" \
  --with-decryption \
  | jq -j .Parameter.Value > /etc/cyrus.conf

# Some more debconf hints to install postfix and cyrus-common non-interactively.
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
debconf-set-selections <<< "postfix postfix/mailname string $(hostname -f)"
debconf-set-selections <<< "cyrus-common cyrus-common/removespools boolean false"

apt-get install --yes \
                -o Dpkg::Options::="--force-confold" \
                   cyrus-admin \
                   cyrus-clients \
                   cyrus-common \
                   cyrus-imapd \
                   libpam-ldap \
                   sasl2-bin

# Allow saslauthd to actually start.
sed -i 's/START=no/START=yes/' /etc/default/saslauthd
service saslauthd restart

# Configure the PAM imap service to use pam_ldap.
cat > /etc/pam.d/imap <<EOF
auth    sufficient      pam_ldap.so
account required        pam_ldap.so
EOF

# Configure pam_ldap.
cat > /etc/ldap.conf <<EOF
uri ldapi:///
base dc=blueparity,dc=net
EOF

# Create a basic openssl.cnf for a new self-signed cert.
cat > /tmp/openssl.cnf <<EOF
[req]
default_bits       = 2048
default_md         = sha256
distinguished_name = dn
prompt             = no
x509_extensions    = v3_ca

[dn]
countryName         = GB
stateOrProvinceName = England
localityName        = London
organizationName    = blueparity.net
CN                  = imap.blueparity.net

[v3_ca]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alternate_names

[alternate_names]
DNS.1 = imap.blueparity.net
EOF

openssl req \
        -x509 \
        -sha256 \
        -nodes \
        -newkey rsa:2048 \
        -keyout /etc/ssl/certs/imap.key \
        -out /etc/ssl/certs/imap.crt \
        -config /tmp/openssl.cnf \
        -days 1095

chown cyrus /etc/ssl/certs/imap.key

# Finally, start the service.
service cyrus-imapd start

