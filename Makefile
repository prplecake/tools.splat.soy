SITE_URL := tools.splat.soy
DATE := $(shell date "+%Y-%m-%d %H:%M:%S")

.PHONY: all clean install update

all: serve

build:
	echo "### Building site ###"
	mkdir _site
	pandoc -s --template templates/tools.splat.soy.html \
		--metadata title="tools.splat.soy" \
		--include-in-header=scripts/analytics.js \
		-o _site/index.html README.md
	cp CNAME _site
	cp submodules/robots.txt/robots.txt _site
	cp -r submodules/pleroma-access-token _site

sshopts := -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa

deploy: build
	echo "### Post-build commit ###"
	git add _site/* && git commit -m "$(DATE) build" && git push
	rsync --rsh="ssh $(sshopts)" -rP _site/ deploy@$(SITE_URL):/var/www/$(SITE_URL) --delete

clean:
	rm -r _site