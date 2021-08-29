yum install nginx -y
#sed -i 's/worker_connections 1024;/worker_connections 10000;/g' /etc/nginx/nginx.conf
echo "hello world" > /usr/share/nginx/html/index.html
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/nginx-selfsigned.key -out /etc/nginx/nginx-selfsigned.crt -subj '/ CN = www.mydom.com/O=My Company Name LTD./C=US'
cat <<EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 10000;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        return 301 https://\$host\$request_uri;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
server {
    listen 443 ssl http2;
    server_name _;
    ssl_certificate /etc/nginx/nginx-selfsigned.crt;
ssl_certificate_key /etc/nginx/nginx-selfsigned.key;
}
}
EOF
systemctl start nginx
systemctl enable nginx
useradd admin
mkdir -p /home/admin/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPdUg14GBioAl6Gq+mEqat6UFRAuiOBdpNtQ3LYZI64qZdak5n5bGLXDwg4jcct5uRTTDyvffYmPD2sllxPT3D/V8ujC9TmhU9CWpjuj8Kg3H5+b5sGeuB96/zCc5RLMB5utUP7p5FqOtGPUWIU89VXAwwn0VmL2gp0ezBXH5JUMYsUXYv4gUhRPtsgZ5MSVUJ1NDFqHOytZ8C2rN/TLopp3RliT1/UncAS7KA4qnKYfuceoL3eK/4BMYZJrXVPcTpt5SL9IE09ChHfehURGP8FNq697J96CkihjqycWojFk+x4mxOgTDA97Bcy51+qG07Hh6N6nQ0N/1ooIoQ7qL3 imported-openssh-key">/home/admin/.ssh/authorized_keys
chown 600 /home/admin/.ssh/authorized_keys
echo 'admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers