VERSION ?= latest
TARBALL_URL := $(shell \
	if [ "$(VERSION)" = "latest" ]; then \
		echo https://github.com/fontra/fontra-pak/releases/latest/download/FontraPak-Ubuntu.tgz; \
	else \
		echo https://github.com/fontra/fontra-pak/releases/download/$(VERSION)/FontraPak-Ubuntu.tgz; \
	fi)

.PHONY: fetch stage clean

fetch:
	curl -L -o FontraPak-Ubuntu.tgz "$(TARBALL_URL)"

stage: fetch
	rm -rf stage
	mkdir -p stage/usr/lib/fontrapak stage/usr/bin
	tar -xzf FontraPak-Ubuntu.tgz -C stage/usr/lib/fontrapak
	ln -sf ../lib/fontrapak/fontrapak stage/usr/bin/fontrapak

clean:
	rm -rf stage FontraPak-Ubuntu.tgz *.deb
