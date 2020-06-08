#!/bin/sh
REPO_NAME=dataworks-repo-template
NEW_REPO_NAME=$1
REPO_DESCRIPTION=$2

git config --global user.name "${GIT_USERNAME}"
git config --global user.email "${GIT_EMAIL}"

git clone https://github.com/dwp/$NEW_REPO_NAME
cd $NEW_REPO_NAME

git submodule add https://github.com/dwp/dataworks-githooks .githooks

find README.md -type f -exec sed -i "s/#\ $REPO_NAME/#\ $NEW_REPO_NAME/" {} +
find README.md -type f -exec sed -i "s/##\ Description/##\ ${REPO_DESCRIPTION}/g" {} +

rm initial-commit.sh

git add --all
git commit -m "Initial commit, adding githooks submodule"
git push https://${TF_VAR_github_token}:x-oauth-basic@github.com/dwp/$NEW_REPO_NAME
