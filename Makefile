SITE_URL := tools.splat.soy
DATE := $(shell date "+%Y-%m-%d %H:%M:%S")

.PHONY: all clean install update

all: serve

submodule-update:
	echo "### Updating submodules ###"
	git submodule update --init --remote --merge

build: submodule-update
	echo "### Building site ###"
	pandoc -s --template templates/tools.splat.soy.html \
		--metadata title="tools.splat.soy" \
		--include-in-header=scripts/analytics.js \
		-o _site/index.html README.md

sshopts := -o StrictHostKeyChecking=no -i ~/.ssh/deploy_rsa

deploy: build
	echo "### Post-build commit ###"
	git add _site/* && git commit -m "$(DATE) build" && git push
	rsync --rsh="ssh $(sshopts)" -rP _site/ deploy@$(SITE_URL):/var/www/$(SITE_URL) --delete

clean:
	rm -r _site