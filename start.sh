#!/bin/sh
set -e

echo "Starting WordPress setup..."

Install WP-CLI
if [ ! -f /usr/local/bin/wp ]; then
  echo "Installing WP-CLI..."
  curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
  chmod +x /usr/local/bin/wp
  echo "Installed WP-CLI version: $(/usr/local/bin/wp --version --allow-root)"
fi

Clone WordPress
cd /var/www/html
if [ ! -f wp-load.php ]; then
  echo "Pulling WordPress from GitHub..."
  TMP_DIR=$(mktemp -d)
  git clone --depth=1 --branch 6.8 https://github.com/WordPress/WordPress.git "$TMP_DIR"
  cp -rT "$TMP_DIR" .
  rm -rf "$TMP_DIR"
fi

# Wait for MySQL
echo "Waiting for MySQL on host '$WORDPRESS_DB_HOST'..."
ATTEMPTS_LEFT=10
until nc -z "$WORDPRESS_DB_HOST" 3306; do
  if [ $ATTEMPTS_LEFT -eq 0 ]; then
    echo "MySQL did not become available in time."
    exit 1
  fi
  echo "Still waiting for MySQL... attempts left: $ATTEMPTS_LEFT"
  ATTEMPTS_LEFT=$((ATTEMPTS_LEFT - 1))
  sleep 3
done

# Check DB and Install WordPress
if ! wp db check --allow-root; then
  echo "WP-CLI cannot connect to database. Check credentials."
  exit 1
fi

if ! wp core is-installed --allow-root; then
  echo "Installing WordPress..."
  wp core install \
    --url="http://localhost:8080" \
    --title="Dev Site" \
    --admin_user="admin" \
    --admin_password="password" \
    --admin_email="dev@example.com" \
    --skip-email \
    --allow-root
fi

echo "Setting permissions..."
chown -R www-data:www-data /var/www/html/wp-content
chmod -R 755 /var/www/html/wp-content

echo "WordPress is ready."
exec php-fpm

