
# For timezone

# interactive select timezone
cd /usr/share/zoneinfo
sudo tzselect

sudo cp /usr/share/zoneinfo/Asia/ShangHai /etc/localtime
sudo ntpdate cn.pool.ntp.org

echo "Update timezone success, you should run this now: sudo date -s <the right time>"

