#!/bin/sh
NEW_REPO_NAME=$1
REPO_DESCRIPTION=$2
TEMPLATE_REPO_NAME=$3


#This is for terraform resources
TEMPLATE_REPO_NAME_UNDERSCORE=$(echo $TEMPLATE_REPO_NAME | tr '-' '_')
NEW_REPO_NAME_UNDERSCORE=$(echo $NEW_REPO_NAME | tr '-' '_')

git config --global user.name "${GIT_USERNAME}"
git config --global user.email "${GIT_EMAIL}"

set -x
git clone https://github.com/dwp/$NEW_REPO_NAME
cd $NEW_REPO_NAME

git submodule add https://github.com/dwp/dataworks-githooks .githooks

find README.md -type f -exec sed -i "s/#\ $TEMPLATE_REPO_NAME/#\ $NEW_REPO_NAME/" {} +
find README.md -type f -exec sed -i "s/##\ Description/##\ ${REPO_DESCRIPTION}/g" {} +

case "$TEMPLATE_REPO_NAME" in
    *-terraform)
        find ci -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
        find ci -type f -exec sed -i s/"#ENABLE_BY_INITIAL_COMMIT "/""/g {} +
        find ci -type f -exec sed -i /"^.*#REMOVE_BY_INITIAL_COMMIT.*"/d {} +
        find *.tf -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
        find *.tf.j2 -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
        find aviator.yml -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
    ;;
esac

case "$TEMPLATE_REPO_NAME" in
    *-docker)
        find .github/workflows -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
        find ci -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
        find ci -type f -exec sed -i s/"#ENABLE_BY_INITIAL_COMMIT "/""/g {} +
        find ci -type f -exec sed -i /"^.*#REMOVE_BY_INITIAL_COMMIT.*"/d {} +
        find *.tf -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
        find *.tf.j2 -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
        find aviator.yml -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/g" {} +
    ;;
esac

case "$TEMPLATE_REPO_NAME" in
    *-emr-*)
        find ci -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/gI" {} +
        find ci -type f -exec sed -i "s/$TEMPLATE_REPO_NAME_UNDERSCORE/$NEW_REPO_NAME_UNDERSCORE/gI" {} +
        find ci -type f -exec sed -i s/"#ENABLE_BY_INITIAL_COMMIT "/""/g {} +
        find ci -type f -exec sed -i /"^.*#REMOVE_BY_INITIAL_COMMIT.*"/d {} +
        find *.tf -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/gI" {} +
        find *.tf -type f -exec sed -i "s/$TEMPLATE_REPO_NAME_UNDERSCORE/$NEW_REPO_NAME_UNDERSCORE/gI" {} +
        find . *.sh -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/gI" {} +
        find . *.sh -type f -exec sed -i "s/$TEMPLATE_REPO_NAME_UNDERSCORE/$NEW_REPO_NAME_UNDERSCORE/gI" {} +
        find . -name *.tpl -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/gI" {} +
        find . -name *.tpl -type f -exec sed -i "s/$TEMPLATE_REPO_NAME_UNDERSCORE/$NEW_REPO_NAME_UNDERSCORE/gI" {} +
        find . -name *.tf.j2 -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/gI" {} +
        find . -name *.tf.j2 -type f -exec sed -i "s/$TEMPLATE_REPO_NAME_UNDERSCORE/$NEW_REPO_NAME_UNDERSCORE/gI" {} +
        find aviator.yml -type f -exec sed -i "s/$TEMPLATE_REPO_NAME/$NEW_REPO_NAME/gI" {} +
    ;;
esac

git add --all
rm -f .git/index
git reset
git add --all

git commit -m "Initial commit, adding githooks submodule"
git push https://${TF_VAR_github_token}:x-oauth-basic@github.com/dwp/$NEW_REPO_NAME
