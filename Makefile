BREW := /opt/homebrew/bin/brew

.PHONY: install create-symlinks osx homebrew node

install: create-symlinks osx homebrew node

create-symlinks:
	ln -fs $(CURDIR)/.config            $(HOME)/
	ln -fs $(CURDIR)/.gitignore         $(HOME)/
	ln -fs $(CURDIR)/.gitconfig         $(HOME)/
	ln -fs $(CURDIR)/.zshrc             $(HOME)/

osx:
	defaults write -g InitialKeyRepeat -int 14
	defaults write -g KeyRepeat -int 1

homebrew:
	test -x $(BREW) || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	$(BREW) bundle --file=$(CURDIR)/Brewfile
	$(BREW) cleanup

node:
	$(BREW) install volta
	volta install node@lts yarn
