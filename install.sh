#!/bin/bash
# Debian XFCE desktop custom by Golgo v1.4

# network interfaces
rm -v /etc/network/interfaces
cat <<EOF >> /etc/network/interfaces
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp
EOF

# sources.list
rm -v /etc/apt/sources.list
cat <<EOF > /etc/apt/sources.list
#deb http://192.168.7.48/debian/ jessie main contrib non-free
#deb http://192.168.7.48/debian-security/ jessie/updates main contrib non-free
#deb http://192.168.7.48/debian/ jessie-updates main contrib non-free
#deb http://192.168.7.48/debian/ jessie-backports main contrib non-free

deb http://mirror.yandex.ru/debian/ jessie main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
deb http://mirror.yandex.ru/debian/ jessie-updates main contrib non-free
deb http://mirror.yandex.ru/debian/ jessie-backports main contrib non-free
EOF

# улучшаем history
cat <<EOF >> /etc/bash.bashrc
HISTTIMEFORMAT="%Y-%m-%d - %H:%M:%S "
HISTSIZE=100000
HISTFILESIZE=2000000
shopt -s histappend
PROMPT_COMMAND='history -a'
#PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
EOF
history -a

# использовать swap только при 100% заполнения памяти
cat <<EOF >> /etc/sysctl.conf
vm.swappiness = 1
EOF

# 
aptitude update
aptitude -y safe-upgrade
### ядро backports
aptitude install -y -t jessie-backports intel-microcode firmware-linux firmware-realtek linux-image-4.6.0-0.bpo.1-amd64 linux-headers-4.6.0-0.bpo.1-amd64
aptitude install -y ssh mc htop vim iftop iperf hdparm jnettop rsync ncdu pydf nmap ntp etckeeper smbclient mtr-tiny lshw hwinfo screen tcpdump ntpdate wget pwgen beep curl

# EXPERIMENTAL Skylake Intel 5XX HD support
# apt-get install -t jessie-backports xserver-xorg-video-intel intel-gpu-tools libllvm3.5 libdrm-intel1 libdrm-nouveau2 libdrm2 libva-drm1 libegl1-mesa libegl1-mesa-drivers libgl1-mesa-dri libgl1-mesa-glx libgles1-mesa libgles2-mesa libglu1 libopenvg1-mesa libtxc-dxtn-s2tc0 libwayland-egl1-mesa 


# vim syntax on
cat <<EOF >> /etc/vim/vimrc
syntax on
EOF

# будет не плохо попытаться выставить правильное время
ntpdate 2.pool.ntp.org

### xfce десктоп
aptitude install -y xorg xfce4 task-xfce-desktop xfce4-goodies xfce4-whiskermenu-plugin
aptitude purge -y network-manager-gnome network-manager evince-gtk xarchiver
aptitude install -y -t jessie-backports xserver-xorg-video-intel
aptitude install -y -t jessie-backports libreoffice python3-uno ure libreoffice-math libreoffice-calc libreoffice-writer libreoffice-impress libreoffice-draw libreoffice-help-ru libreoffice-l10n-ru libreoffice-style-tango libreoffice-pdfimport libreoffice-style-galaxy libreoffice-gtk
aptitude install -y cups hplip printer-driver-all simple-scan transmission
aptitude install -y numlockx galternatives gksu gparted gsmartcontrol galculator freerdp-x11 mesa-utils ttf-mscorefonts-installer tumbler-plugins-extra
aptitude install -y firefox-esr-l10n-ru chromium chromium-l10n flashplugin-nonfree pepperflashplugin-nonfree browser-plugin-vlc
aptitude install -y p7zip-rar unrar unzip pavucontrol zenity geany geany-plugins gthumb
aptitude install -y cifs-utils samba exfat-fuse libimobiledevice-utils gvfs-bin gvfs-fuse gvfs-backends mtp-tools

# архиватор-разархиватор
aptitude install -y engrampa 
aptitude install -y --without-recommends thunar-archive-plugin
sed -e 's/file-roller/engrampa/g' /usr/lib/x86_64-linux-gnu/thunar-archive-plugin/file-roller.tap > /usr/lib/x86_64-linux-gnu/thunar-archive-plugin/engrampa.tap
chmod +x /usr/lib/x86_64-linux-gnu/thunar-archive-plugin/engrampa.tap


aptitude install -y eom atril pidgin mate-terminal mate-utils mate-system-monitor xinput
aptitude install -y clearlooks-phenix-theme gnome-themes mate-themes gtk3-engines-xfce gtk3-engines-oxygen remmina

# удалим лишнее
aptitude purge -y modemmanager ntp

# user_allow_other 
sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf

# Отключает xsession-errors в дамшнем каталоге
echo 'ln -fs /dev/null "$HOME"/.xsession-errors' > /etc/X11/Xsession.d/00disable-xsession-errors

# X2GO. А это что за пакет - x2goserver-fmbindings ?
apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E
cat <<EOF > /etc/apt/sources.list.d/x2go.list
deb http://packages.x2go.org/debian jessie main
EOF
aptitude update
aptitude install -y x2go-keyring && aptitude update
aptitude install -y x2goserver x2goserver-xsession 

# приложения по умолчанию - браузер Chromium
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/chromium 100
update-alternatives --set x-www-browser /usr/bin/chromium
update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/chromium 100
update-alternatives --set gnome-www-browser /usr/bin/chromium

# курсор MATE
rm -v /usr/share/icons/default/index.theme
cat <<EOF > /usr/share/icons/default/index.theme
[Icon Theme]
Inherits=mate
EOF


### Секция с програмным обеспечением ###
# Mozilla Firefox & Thunderbird
cd /opt/
rm -v thunderbird-*.tar.bz2
wget http://download.cdn.mozilla.net/pub/thunderbird/releases/45.2.0/linux-x86_64/ru/thunderbird-45.2.0.tar.bz2
tar xjf thunderbird*.tar.bz2

# Microsoft Skype i386
cd /home/user/
wget -O skype-debian_4.3.0.37-1_i386.deb http://www.skype.com/go/getskype-linux-deb
dpkg --add-architecture i386
aptitude update
dpkg -i skype-debian_4.3.0.37-1_i386.deb
apt-get -f -y install

# Wine
aptitude install -y wine msttcorefonts winetricks
mkdir -p /home/user/.wine/drive_c/windows/Fonts/
cp /usr/share/fonts/truetype/msttcorefonts/* /home/user/.wine/drive_c/windows/Fonts/
chown -R user:user /home/user/

# 2gis Иваново, там ключ по gpg приезжает, обращаю внимание
cat <<EOF > /etc/apt/sources.list.d/2gis.list
deb http://deb.2gis.ru/ trusty non-free
EOF
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 69ECCC891636CC92
gpg --armor --export 69ECCC891636CC92 | apt-key add -
aptitude update
aptitude install 2gis

# Dropbox
cat <<EOF > /etc/apt/sources.list.d/dropbox.list
deb http://linux.dropbox.com/debian jessie main
EOF
aptitude update
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
aptitude update
aptitude install dropbox

# Telegram x86_64
# wget https://tdesktop.com/linux 
# tar xvf linux*
# ln -sf /opt/Telegram/Telegram /usr/bin/telegram

### Спецсофт
# XMind - скачать руками пакет через бразуер 'http://www.xmind.net/xmind/downloads/xmind-7.5-update1-linux_amd64.deb'
#aptitude install -y meld keepassx console-setup x2goclient systemsettings arandr yakuake kde-style-oxygen kde-l10n-ru inkscape torbrowser-launcher screenruler ssh-askpass virt-manager virt-viewer spice-client-gtk pidgin-plugin-pack pidgin-otr
#aptitude install nvidia-kernel-dkms nvidia-settings nvidia-xconfig nvidia-glx
# redshift redshift-gtk и файл нужен - /home/user/.config/redshift.conf


# DUDE! wine типо есть уже
cd /opt/ && wget http://golgo.ru/assets/debian-desktop/wine/dude-install-3.5.exe
cat <<EOF > /home/user/dude_install.sh
#!/bin/bash
wine /opt/dude-install-3.5.exe &
EOF
chmod +x /home/user/dude_install.sh
### Конец секции с програмным обеспечением ###


### волшебный архив домашнего каталога
cd /home/user/
wget http://golgo.ru/assets/debian-desktop/home-user.tar
tar xf home-user.tar
rm -v home-user.tar

# Элементы брендинга
mkdir /opt/branding
cd /opt/branding
wget http://192.168.7.48/debian-desktop/branding/background.png
wget http://192.168.7.48/debian-desktop/branding/face.png
ln -s /opt/branding/face.png /home/user/.face
#update-alternatives --install /usr/share/images/desktop-base/desktop-background desktop-background /opt/branding/wallpaper-desktop.jpg 100
#xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set /opt/branding/background.jpg 


# замена файлов lightdm
cd /etc/lightdm/
mv -v lightdm.conf lightdm.conf-distro
wget http://golgo.ru/assets/debian-desktop/lightdm/lightdm.conf
mv -v users.conf users.conf-distro
wget http://golgo.ru/assets/debian-desktop/lightdm/users.conf
mv -v lightdm-gtk-greeter.conf lightdm-gtk-greeter.conf-distro
wget http://golgo.ru/assets/debian-desktop/lightdm/lightdm-gtk-greeter.conf

# Букмарки разных инженерий объеденим в одну
#mkdir -p /home/user/.config/gtk-3.0/
#chown -R user:user /home/user/.config/gtk-3.0/
#cat <<EOF > /home/user/.gtk-bookmarks
#file:///home/user/%D0%A1%D0%B5%D1%82%D0%B5%D0%B2%D1%8B%D0%B5%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D1%8B/%D0%9E%D0%B1%D1%89%D0%B0%D1%8F
#file:///home/user/%D0%A1%D0%B5%D1%82%D0%B5%D0%B2%D1%8B%D0%B5%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D1%8B/%D0%A2%D0%B5%D1%85%D0%BF%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%BA%D0%B0
#file:///home/user/%D0%A1%D0%B5%D1%82%D0%B5%D0%B2%D1%8B%D0%B5%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D1%8B/01%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D1%8B
#EOF
#ln -s /home/user/.gtk-bookmarks /home/user/.config/gtk-3.0/bookmarks

# права на каталоги
chown -R user:user /home/user
chown -R user:user /opt/

#libglapi-mesa




