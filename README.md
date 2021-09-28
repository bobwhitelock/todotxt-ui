# Todotxt UI

[![CI/CD workflow badge](https://github.com/bobwhitelock/todotxt-ui/workflows/CI/CD/badge.svg?branch=master&event=push)](https://github.com/bobwhitelock/todotxt-ui/actions?query=workflow%3ACI%2FCD+branch%3Amaster+event%3Apush)

Developer-focused plain text todo list manager, using
[todo.txt](https://github.com/todotxt/todo.txt) format and Git for
storage/syncing. Currently very WIP.

## To setup for development

```bash
git clone https://github.com/bobwhitelock/todotxt-ui.git
cd todotxt-ui
bin/setup
rake db:setup
bin/rails server -b '0.0.0.0'
cd client && yarn start  # In separate shell.
```

## To deploy

See [docs/deployment.md](docs/deployment.md).
