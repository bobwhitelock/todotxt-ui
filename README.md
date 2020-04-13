
# Todotxt UI

TODO actual documentation on other stuff.

## Deployment Notes

- Ubuntu 16.04 on Linode
- Dokku 0.19.13


### To setup for deployment

Below took some bashing, so may be missing a step/need adjustment.

```bash
# Remote
dokku apps:create todotxt
dokku domains:add todotxt "$public_domain"
dokku domains:remove todotxt todotxt.li1514-40.members.linode.com
dokku plugins:install letsencrypt

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

# Local
git remote add prod dokku@li1514-40.members.linode.com:todotxt
```

Also:
- Set up DNS to point to this instance at `$public_domain`

TODO Document SSL things


### To deploy

```bash
git push prod master
```
