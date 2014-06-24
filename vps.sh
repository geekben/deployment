
# For timezone

# interactive select timezone
cd /usr/share/zoneinfo
sudo tzselect

sudo cp /usr/share/zoneinfo/Asia/ShangHai /etc/localtime
sudo ntpdate cn.pool.ntp.org

echo "Update timezone success, you should run this now: sudo date -s <the right time>"

grep zh_CN /var/lib/locales/supported.d/local || echo "zh_CN.UTF-8 UTF-8" >> /var/lib/locales/supported.d/local
locale-gen
