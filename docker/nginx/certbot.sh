#!/usr/bin/env sh

docker run -it --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/cloudflare.ini:/cloudflare.ini:ro \
  certbot-cloudflare certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /cloudflare.ini \
  --dns-cloudflare-propagation-seconds 120 \
  --non-interactive \
  --agree-tos \
  --no-eff-email \
  --email "manujkarki101@gmail.com" \
  -d "manujkarki.com.np" \
  -d "*.manujkarki.com.np"
