#!/bin/bash
if [ ! -d plantuml-cmd ]; then
	git clone --depth 1 https://github.com/missdeer/plantuml-cmd.git
	cd plantuml-cmd
	go build
	cd ..
fi
sed -i 's/\/usr\/local\/bin\/plantuml-cmd/\/opt\/build\/repo\/plantuml-cmd\/plantuml-cmd/g' _config.yml
sed -i '/baseurl/d' _config.yml
sed -i 's|site.config\[\x27baseurl\x27\] +||g' _plugins/ditaa.rb
bundle exec jekyll build --trace
