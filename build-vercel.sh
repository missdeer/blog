#!/bin/bash
if [ ! -d plantuml-cmd ]; then
	curl -sSL -o go.tar.gz https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
	curl -sSL -o plantuml-cmd.tar.gz https://api.github.com/repos/missdeer/plantuml-cmd/tarball/master
	tar xvf go.tar.gz
	tar xvf plantuml-cmd.tar.gz
	mv missdeer-plantuml-cmd-* plantuml-cmd
	cd plantuml-cmd
	$PWD/../go/bin/go build
	cd ..
fi
sed -i 's/\/usr\/local\/bin\/plantuml-cmd/\/vercel\/path0\/plantuml-cmd\/plantuml-cmd/g' _config.yml
sed -i '/baseurl/d' _config.yml
sed -i 's|site.config\[\x27baseurl\x27\] +||g' _plugins/ditaa.rb
