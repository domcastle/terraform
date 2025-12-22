cat <<EOF >> ~/.ssh/config

Host $(hostname)
  HostName $(hostname)
  IdentityFile $(identifyfile)
  User $(user)
  ForwardAgent yes

EOF

chmod 600 ~/.ssh/config