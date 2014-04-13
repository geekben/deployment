installation
=====

###u disk
*  need to use ubuntu's “startup disk creator” to make a startup disk, other tool may encounter cdrom can't mount error
*  sometimes, need to insert the u disk before reboot to turn on USB boot in BIOS

###hard drive
* use easybcd add an entry to windows grub

configuration
=====

###keep it awake
* add the kernel options "acpi=off apm=off" to the GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub, then reboot

nginx+gunicorn+supervisor
=====
http://michal.karzynski.pl/blog/2013/06/09/django-nginx-gunicorn-virtualenv-supervisor/

###gunicorn
* pip install gunicorn
* create a file in your webapp dir/bin (~/crike/bin) like this:
```bash
#!/bin/bash

NAME="crike"                                                      # Name of the application
DJANGODIR=/home/hongxian/crike/crike/src/crike_django             # Django project directory
SOCKFILE=$DJANGODIR/run/gunicorn.sock                             # we will communicte using this unix socket
USER=hongxian                                                     # the user to run as
GROUP=hongxian                                                    # the group to run as
NUM_WORKERS=3                                                     # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=crike_django.settings                      # which settings file should Django use
DJANGO_WSGI_MODULE=crike_django.wsgi                              # WSGI module name
 
echo "Starting $NAME as `whoami`"
 
# Activate the virtual environment
cd $DJANGODIR
source ../../../bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH
 
# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR
 
# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec ../../../bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --log-level=debug \
  --bind=unix:$SOCKFILE
```

###supervisor
use this to run gunicorn_start with the system booting or restart it after crash
* sudo apt-get install supervisor
* create a file under /etc/supervisor/conf.d/<crike>.conf
```
[program:crike]
command = /home/hongxian/crike/bin/gunicorn_start                     ; Command to start app
user = hongxian                                                       ; User to run as
stdout_logfile = /home/hongxian/crike/logs/gunicorn_supervisor.log    ; Where to write log messages
redirect_stderr = true 
```
* Create the file to store your application’s log messages:
```
mkdir -p /home/hongxian/crike/logs
touch /home/hongxian/crike/logs/gunicorn_supervisor.log
```
* ask supervisor to reread configuration files and update
```
$ sudo supervisorctl reread
hello: available
$ sudo supervisorctl update
hello: added process group
```
* check the status of your app or start, stop or restart it using supervisor
```
$ sudo supervisorctl status hello                       
hello                            RUNNING    pid 18020, uptime 0:00:50
$ sudo supervisorctl stop hello  
hello: stopped
$ sudo supervisorctl start hello                        
hello: started
$ sudo supervisorctl restart hello 
hello: stopped
hello: started
```
###Nginx
* sudo apt-get install nginx
* sudo service nginx start
* Create an Nginx virtual server configuration for Django under /etc/nginx/sites-available
```
upstream crike_server {
  # fail_timeout=0 means we always retry an upstream even if it failed
  # to return a good HTTP response (in case the Unicorn master nukes a
  # single worker for timing out).
 
  server unix:/home/hongxian/crike/crike/src/crike_django/run/gunicorn.sock fail_timeout=0;
}
 
server {
 
    listen   80;
    # server_name crike.com;
 
    client_max_body_size 4G;
 
    access_log /home/hongxian/crike/logs/nginx-access.log;
    error_log /home/hongxian/crike/logs/nginx-error.log;
 
    location /static/ {
        alias   /home/hongxian/crike/crike/src/crike_django/crike_django/static/;
    }
    
    location /media/ {
        alias   /home/hongxian/crike/crike/src/crike_django/crike_django/media/;
    }
 
    location / {
        # an HTTP header important enough to have its own Wikipedia entry:
        #   http://en.wikipedia.org/wiki/X-Forwarded-For
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 
        # enable this if and only if you use HTTPS, this helps Rack
        # set the proper protocol for doing redirects:
        # proxy_set_header X-Forwarded-Proto https;
 
        # pass the Host: header from the client right along so redirects
        # can be set properly within the Rack application
        proxy_set_header Host $http_host;
 
        # we don't want nginx trying to do something clever with
        # redirects, we set the Host: header above already.
        proxy_redirect off;
 
        # set "proxy_buffering off" *only* for Rainbows! when doing
        # Comet/long-poll stuff.  It's also safe to set if you're
        # using only serving fast clients with Unicorn + nginx.
        # Otherwise you _want_ nginx to buffer responses to slow
        # clients, really.
        # proxy_buffering off;
 
        # Try to serve static files from nginx, no point in making an
        # *application* server like Unicorn/Rainbows! serve static files.
        if (!-f $request_filename) {
            proxy_pass http://crike_server;
            break;
        }
    }
 
    # Error pages
    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root /home/hongxian/crike/crike/src/crike_django/crike_django/static/;
    }
}
```
* python manage.py collectstatic   *(very important)*
* create symbolic link in /etc/nginx/sites-enabled/ to the file created in available
* sudo service nginx restart

