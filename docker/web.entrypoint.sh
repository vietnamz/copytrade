#!/bin/sh

echo "$DATABASE"
echo "$SQL_HOST"
echo "$SQL_PORT"
if [ "$DATABASE" = "mysql" ]
then
    echo "Waiting for mysql..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "MYSQL started"
fi
echo $@
echo $DJANGO_SETTINGS_MODULE
python manage.py flush --no-input
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic

exec "$@"

