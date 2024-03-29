# Deployment

This describes my current setup for deploying Todotxt UI, using
[Dokku](https://github.com/dokku/dokku).

## Versions

- Ubuntu 20.04 on Linode
- Dokku 0.23.2

### Updating

To update Dokku, where e.g. `version=v0.23.2`:

```bash
wget https://raw.githubusercontent.com/dokku/dokku/$version/bootstrap.sh
sudo DOKKU_TAG=$version bash bootstrap.sh
```

## To setup for deployment

Below has been gradually expanded as new steps are needed, and often required
some trial and error, so may be missing some steps or need adjustment.

```bash
# Remote
dokku plugin:install https://github.com/dokku/dokku-postgres.git
dokku plugin:install https://github.com/michaelshobbs/dokku-hostname.git dokku-hostname
dokku plugin:install https://github.com/michaelshobbs/dokku-logspout.git
dokku plugin:install letsencrypt

dokku apps:create todotxt
dokku buildpacks:add todotxt https://github.com/heroku/heroku-buildpack-ruby.git
# Using specific version of buildpack as suggested to fix issue at
# https://github.com/heroku/heroku-buildpack-nodejs/issues/856. Apparently this
# has been fixed but can't figure out how to get this to work - see
# https://github.com/heroku/heroku-buildpack-nodejs/issues/856#issuecomment-731933169
dokku buildpacks:add todotxt 'https://github.com/heroku/heroku-buildpack-nodejs.git#v174'
dokku domains:add todotxt "$public_domain"
dokku domains:remove todotxt todotxt.li1514-40.members.linode.com
dokku letsencrypt:cron-job --add

ssh-keygen -t rsa -b 4096 -C "$email_for_app" -f ~/.ssh/id_rsa -N ''
# <add this to GitHub's https://github.com/settings/keys page>

dokku storage:mount todotxt /root/.ssh/:/app/.ssh
dokku storage:mount todotxt /var/lib/dokku/data/storage/todotxt/repo:/repo
mkdir -p /var/lib/dokku/data/storage/todotxt
cd !$
git clone "$todo_repo_url" repo # Where `$todo_repo_url` is `.git` version of URL.

dokku config:set todotxt \
  AUTH_USER="$auth_user" \
  AUTH_PASSWORD="$auth_password" \
  TODO_FILE=/repo/"$path_to_todo_file" \
  # This env var is for Git itself - see
  # https://github.com/ruby-git/ruby-git/issues/386#issuecomment-416081185.
  GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i '/app/.ssh/id_rsa'" \
  GIT_EMAIL="$email_for_app" \
  DOKKU_LETSENCRYPT_EMAIL=bob.whitelock1+todotxt@gmail.com

dokku letsencrypt todotxt

# Setup database.
dokku postgres:create todotxt-database
dokku postgres:link todotxt-database todotxt
dokku run todotxt rake db:setup

# Configure logs to be sent to Papertrail - see
# http://mikebian.co/sending-dokku-container-logs-to-papertrail/.
dokku logspout:server syslog+tls://$papertrail_endpoint
dokku logspout:start
dokku ps:rebuildall
```

Also:

- Set up DNS to point to this instance at `$public_domain`

## To deploy

Deploys should happen automatically on push to `master` on GitHub, or can be
triggered manually locally like this:

```bash
git remote add prod dokku@$public_domain:todotxt
git push -f prod HEAD:master

# Any updates to `todotxt.crontab` locally will also need to be added to
# `/etc/cron.d/todotxt` remotely.
```
