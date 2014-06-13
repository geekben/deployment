mongodb
=====

##issue: 
ConnectionFailure: could not connect to localhost:27017: [Errno 111] Connection refused

##fix:
http://bbs.csdn.net/topics/390438041?page=1
Ubuntu:
rm /var/lib/mongodb/mongod.lock
mongod --repair
reboot
