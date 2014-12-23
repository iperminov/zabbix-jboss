VERSION = 0.1

ARCHIVE = zabbix-jboss-$(VERSION).tar.gz

.PHONY: all
all: $(ARCHIVE)

$(ARCHIVE):
	tar czf $(@) --group root --owner root \
	    -C resources/usr/local/share zabbix-jboss/
