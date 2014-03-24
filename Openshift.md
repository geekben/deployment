DIY your env for web hosting, use openshift as VPS

======

1, apply an openshift account, you can add some cartridge MongoDB 2.4 database added. 

2, create a new app, with your app name and namespace, input github source code address of this app project.

3, add mongodb cartridge; add rockmongo cartridge; etc. This can be done on web page.

4, From now on, the operations are under ssh, for example, ssh 532e5a96e0b8cd1057000238@crike-geekben.rhcloud.com
  you can find the ssh address on the web page with your account login.

5, Mkdir under $OPENSHIFT_DATA_DIR, virtualenv <the dir you just created>, cd <the dir again>, source bin/activate

6, use pip install what you need, for example, django-nonrel.

7, modify settings.py as bellow, NAME must be admin, don't know why

    DATABASES = {
        'default': {
           'ENGINE': 'django_mongodb_engine', 
           #'NAME': os.environ['OPENSHIFT_APP_NAME'],
           'NAME': 'admin', #only admin works, don't know why
           'USER': os.environ['OPENSHIFT_MONGODB_DB_USERNAME'],                     
           'PASSWORD': os.environ['OPENSHIFT_MONGODB_DB_PASSWORD'],                
           'HOST': os.environ['OPENSHIFT_MONGODB_DB_HOST'],          
           'PORT': 27017,                     
        },
    }
8, gear stop --cart python, and create a script, namely "restart.sh", like bellow to start your server:

    pkill -f 'python manage.py runserver $OPENSHIFT_PYTHON_IP:$OPENSHIFT_PYTHON_PORT'
    export PYTHONIOENCODING=utf-8
    python manage.py runserver $OPENSHIFT_PYTHON_IP:$OPENSHIFT_PYTHON_PORT &

9， if mongodb connetion refused, use "gear start --cart mongodb", you can also "gear start --cart rockmongo" to start other cartridges

10， python manage.py syncdb; ./restart.sh

11， pull the code to your local machine, then you can modify and push your updated code to web host. You can find the ssh adress from the web page

