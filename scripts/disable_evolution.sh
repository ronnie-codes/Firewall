systemctl --user stop evolution-addressbook-factory.service
systemctl --user stop evolution-calendar-factory.service
systemctl --user stop evolution-source-registry.service
systemctl --user stop evolution-data-server.service

systemctl --user disable evolution-addressbook-factory.service
systemctl --user disable evolution-calendar-factory.service
systemctl --user disable evolution-source-registry.service
systemctl --user disable evolution-data-server.service

systemctl --user mask evolution-addressbook-factory.service
systemctl --user mask evolution-calendar-factory.service
systemctl --user mask evolution-source-registry.service
systemctl --user mask evolution-data-server.service
