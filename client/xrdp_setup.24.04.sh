#!/bin/sh

# Reference: https://github.com/microsoft/linux-vm-tools/blob/master/ubuntu/18.04/install.sh
# Add script to setup the ubuntu session properly
if [ ! -e /etc/xrdp/startubuntu.sh ]; then
cat >> /etc/xrdp/startubuntu.sh << EOF
#!/bin/sh
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
exec /etc/xrdp/startwm.sh
EOF
chmod a+x /etc/xrdp/startubuntu.sh
fi

# use the script to setup the ubuntu session
sed -i_orig -e 's/startwm/startubuntu/g' /etc/xrdp/sesman.ini

# rename the redirected drives to 'shared-drives'
sed -i -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini

# Changed the allowed_users
sed -i_orig -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config

# Configure the policy xrdp session
cat > /etc/polkit-1/rules.d/99-allow_colord.rules <<EOF
polkit.addRule(function(action, subject){
    if(action.id.match(/^org\.freedesktop\.color\-manager\.create\-*/))
        return polkit.Result.YES;
    if(action.id.match(/^org\.freedesktop\.color\-manager\.delete\-*/))
        return polkit.Result.YES;
    if(action.id.match(/^org\.freedesktop\.color\-manager\.modify\-*/))
        return polkit.Result.YES;
});
EOF