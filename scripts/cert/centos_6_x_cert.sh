cp /tmp/isubca.cer /etc/pki/ca-trust/source/anchors/
cp /tmp/irootca.cer /etc/pki/ca-trust/source/anchors/
update-ca-trust force-enable
update-ca-trust extract
