#!/bin/bash
if [ ! -d plantuml-cmd ]; then
	git clone --depth 1 https://github.com/missdeer/plantuml-cmd.git
	cd plantuml-cmd
	go build
	cd ..
fi
sed -i '/baseurl/d' _config.yml
sed -i 's|site.config\[\x27baseurl\x27\] +||g' _plugins/ditaa.rb
bundle exec jekyll build --trace
