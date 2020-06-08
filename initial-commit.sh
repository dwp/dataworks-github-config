#!/bin/sh
NEW_REPO_NAME=$1

git config --global user.name "${GIT_USERNAME}"
git config --global user.email "${GIT_EMAIL}"

git clone https://github.com/dwp/$NEW_REPO_NAME
cd $NEW_REPO_NAME
git submodule add https://github.com/dwp/dataworks-githooks .githooks
make git-hooks

find README.md -type -f -exec sed -i '' "s/#\ $TF_REPO_NAME/#\ $NEW_REPO_NAME/" {} +

rm initial-commit.sh

git add --all
git commit -m "Initial commit, adding githooks submodule"
git push https://${TF_VAR_github_token}:x-oauth-basic@github.com/dwp/$NEW_REPO_NAME
