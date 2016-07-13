#!/bin/bash

create_superuser="
import django
django.setup()
from django.contrib.auth.models import User
try:
    User.objects.create_superuser('$DJANGO_SUPERUSER_NAME', '$DJANGO_SUPERUSER_MAIL', '$DJANGO_SUPERUSER_PASS')
except Exception:
    pass
"
create_superuser() {
    echo "Creating superuser"
    python -c "$create_superuser"
}

if [ "$1" == "runserver" ]; then
    echo "Waiting for database"
    dockerize -wait tcp://"$DJANGO_DB_HOST":"$DJANGO_DB_PORT"
    echo "Running migrations"
    # Can we always safely appy migrations?
    # Apply database migrations
    python manage.py migrate
    # Collect static files
    echo "Running collectstatic"
    python manage.py collectstatic --noinput

    create_superuser

    exec python manage.py "$@"
fi

if [ "$1" == "nomigrate" ]; then
    echo "Waiting for database"
    dockerize -wait tcp://"$DJANGO_DB_HOST":"$DJANGO_DB_PORT"
    echo "Running collectstatic"
    python manage.py collectstatic --noinput

    create_superuser

    exec python manage.py "$@"
fi

if [ "$1" == "makemigrations" ];then
    echo "Waiting for database"
    dockerize -wait tcp://"$DJANGO_DB_HOST":"$DJANGO_DB_PORT"
    exec python manage.py "$@"
fi

if [ "$1" == "loadtestdata" ];then
    echo "Waiting for database"
    dockerize -wait tcp://"$DJANGO_DB_HOST":"$DJANGO_DB_PORT"
    exec python manage.py "$@"
fi

exec "$@"
