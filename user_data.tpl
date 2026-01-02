#!/bin/bash
set -eux

apt update -y
apt install -y nginx

cat <<EOF > /var/www/html/index.nginx-debian.html
<!DOCTYPE html>
<html>
<body>
<h1>Hello from Instance ${instance_name}</h1>
</body>
</html>
EOF

systemctl restart nginx