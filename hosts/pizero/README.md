# pizero

## adding ssl certs for a website

```nginx
    server {
            listen 443 ssl;
            server_name vault.example.com;

            ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
            ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

            location / {
                proxy_pass http://127.0.0.1:8080; # Vaultwarden runs on port 8080
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                # WebSocket support (if needed)
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
            }
    }
    # upgrade to https, browsers might do it automatically
    server {
        listen 80;
        server_name vault.example.com openbooks.example.com;
        return 301 https://$host$request_uri;
    }

```
