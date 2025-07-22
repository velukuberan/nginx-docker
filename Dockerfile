FROM nginx:latest

# Optional: install custom tools, configs, etc.
RUN apt-get update && apt-get install -y curl

# Copy custom config and SSL
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY certs/ /etc/nginx/ssl/

# Copy website content
COPY html/ /usr/share/nginx/html/
