# Git Privacy Setup

If you want to use Git under a secret identity, you will find this tool useful.

## What it does?

* Setup author name and email for commits.
* Setup GPG signing key for signing your commits.
* Setup SSH private key to be used for Git over SSH authentication.
* Setup SOCKS5 proxy for all standard Git protocols: HTTP, HTTPS, and SSH.
* Convert timezone to UTC for your commits, and remove hours, minutes, and seconds details.

## Installation

You have to install this tool under a path with no spaces. Suppose you want to
install it under `/var/git-privacy-setup` (Unix) or `C:\git-privacy-setup`
(Windows), then do the following:

Please change the SOCKS5 proxy setting in the following command:

```
# For Unix
cd /var/git-privacy-setup

# For Windows
cd C:\git-privacy-setup

# Clone the project through a SOCKS5 proxy
git init
git config http.proxy "socks5h://user:pass@127.0.0.1:1080"
git remote add origin "https://github.com/cramershoup/git-privacy-setup.git"
git pull origin master
```

Add `/var/git-privacy-setup/bin` (Unix) or `C:\git-privacy-setup\bin` (Windows)
to your `PATH` environment variable. Please don't use symbolic link to install.

## Usage

Inside any Git repository root directory, run:

```bash
git privacy-setup [profile]
```

Follow the instructions to setup your Git repository. These settings are only
valid for the current repository, you need to setup each individual repository.

You can use or edit a common profile by specifying the `profile` parameter.

## Contributing

Please feel free to contribute to this project. But before you do so, just make
sure you understand the following:

1\. Make sure you have access to the official repository of this project where
the maintainer is actively pushing changes. So that all effective changes can go
into the official release pipeline.

2\. **IMPORTANT!** Use THIS tool to properly configure your local git repository
to protect your privacy.

3\. Make sure your editor has [EditorConfig](https://editorconfig.org/) plugin
installed and enabled. It's used to unify code formatting style.

4\. Use [Conventional Commits 1.0.0-beta.2](https://conventionalcommits.org/) to
format Git commit messages.

5\. Use [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
as Git workflow guideline.

6\. Use [Semantic Versioning 2.0.0](https://semver.org/) to tag release
versions.

## Contact

This project is currently maintained by
Cramer Shoup &lt;<cramershoup@gmail.com>&gt;. You can
also contact on
Discord &lt;cramershoup#7188&gt;, 
Reddit &lt;[cramershoup](https://www.reddit.com/user/cramershoup)&gt;, 
Keybase &lt;[shoup](https://keybase.io/shoup)&gt;, 
and P2P-Network &lt;cramer&gt;.

## License

Copyright © 2018 Cramer Shoup &lt;<cramershoup@gmail.com>&gt;

This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.
