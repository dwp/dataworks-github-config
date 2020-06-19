#!/bin/sh
NEW_REPO_NAME=$1
REPO_DESCRIPTION=$2
REPO_NAME=$3

git config --global user.name "${GIT_USERNAME}"
git config --global user.email "${GIT_EMAIL}"

git clone https://github.com/dwp/$NEW_REPO_NAME
cd $NEW_REPO_NAME

git submodule add https://github.com/dwp/dataworks-githooks .githooks

find README.md -type f -exec sed -i "s/#\ $REPO_NAME/#\ $NEW_REPO_NAME/" {} +
find README.md -type f -exec sed -i "s/##\ Description/##\ ${REPO_DESCRIPTION}/g" {} +

case "$REPO_NAME" in
    *-terraform)
        find ci -type f -exec sed -i "s/$REPO_NAME/$NEW_REPO_NAME/g" {} +
        find ci -type f -exec sed -i s/"#ENABLE_BY_INITIAL_COMMIT "/""/g {} +
        find ci -type f -exec sed -i /"^.*#REMOVE_BY_INITIAL_COMMIT.*"/d {} +
        find *.tf -type f -exec sed -i "s/$REPO_NAME/$NEW_REPO_NAME/g" {} +
        find aviator.yml -type f -exec sed -i "s/$REPO_NAME/$NEW_REPO_NAME/g" {} +
    ;;
esac

git add --all
git commit -m "Initial commit, adding githooks submodule"
git push https://${TF_VAR_github_token}:x-oauth-basic@github.com/dwp/$NEW_REPO_NAME
