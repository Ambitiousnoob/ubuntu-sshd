#!/bin/bash

# Set default values for SSH_USERNAME and SSH_PASSWORD if not provided
: ${SSH_USERNAME:=ubuntu}
: ${SSH_PASSWORD:?"Error: SSH_PASSWORD environment variable is not set."}
: ${SSHD_CONFIG_ADDITIONAL:=""}
: ${ENABLE_SYSTEMD:=}

# Create the user with the provided username and set the password
if id "$SSH_USERNAME" &>/dev/null; then
    echo "User $SSH_USERNAME already exists"
else
    useradd -ms /bin/bash "$SSH_USERNAME"
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    echo "User $SSH_USERNAME created with the provided password"
fi

# Set the authorized keys from the AUTHORIZED_KEYS environment variable (if provided)
if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p /home/$SSH_USERNAME/.ssh
    echo "$AUTHORIZED_KEYS" > /home/$SSH_USERNAME/.ssh/authorized_keys
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh
    chmod 700 /home/$SSH_USERNAME/.ssh
    chmod 600 /home/$SSH_USERNAME/.ssh/authorized_keys
    echo "Authorized keys set for user $SSH_USERNAME"
    # Disable password authentication if authorized keys are provided
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
fi

# Apply additional SSHD configuration if provided
if [ -n "$SSHD_CONFIG_ADDITIONAL" ]; then
    echo "$SSHD_CONFIG_ADDITIONAL" >> /etc/ssh/sshd_config
    echo "Additional SSHD configuration applied"
fi

# Apply additional SSHD configuration from a file if provided
if [ -n "$SSHD_CONFIG_FILE" ] && [ -f "$SSHD_CONFIG_FILE" ]; then
    cat "$SSHD_CONFIG_FILE" >> /etc/ssh/sshd_config
    echo "Additional SSHD configuration from file applied"
fi



# If a PORT environment variable is provided (e.g. on Railway),
# configure sshd to listen on that port instead of the default 22.
if [ -n "$PORT" ] && [ "$PORT" != "22" ]; then
    echo "Configuring SSHD to listen on port $PORT..."
    # If a Port line exists, replace it; otherwise, append a new one.
    if grep -qE '^[# ]*Port ' /etc/ssh/sshd_config; then
        sed -i "s/^[# ]*Port .*/Port $PORT/" /etc/ssh/sshd_config
    else
        echo "Port $PORT" >> /etc/ssh/sshd_config
    fi
fi

# Start either systemd (for full systemctl support) or a standalone sshd
if [ "$ENABLE_SYSTEMD" = "1" ] || [ "$ENABLE_SYSTEMD" = "true" ]; then
    echo "Starting systemd as PID 1..."
    exec /sbin/init
else
    echo "Starting SSH server..."
    exec /usr/sbin/sshd -D
fi
