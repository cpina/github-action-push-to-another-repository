#!/bin/sh -l

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

echo "Started"

SOURCE_REPOSITORY_USERNAME="$1"
SOURCE_REPOSITORY_NAME="$2"
SOURCE_BRANCH="$3"

DESTINATION_REPOSITORY_USERNAME="$4"
DESTINATION_REPOSITORY_NAME="$5"
DESTINATION_BRANCH="$6"

COMMIT_USER_EMAIL="$7"
COMMIT_USERNAME="$8"
COMMIT_MESSAGE="$9"

SOURCE_DIR=$(mktemp -d)
DESTINATION_DIR=$(mktemp -d)

# Setup git
git config --global user.email "$COMMIT_USER_EMAIL"
git config --global user.name "$COMMIT_USERNAME"

echo "Cloning source git repository"
git clone --single-branch --branch "$SOURCE_BRANCH" "https://$API_TOKEN_GITHUB@github.com/$SOURCE_REPOSITORY_USERNAME/$SOURCE_REPOSITORY_NAME.git" "$SOURCE_DIR"
ls -la "$SOURCE_DIR"

echo "Cloning destination git repository"
git clone --single-branch --branch "$DESTINATION_BRANCH" "https://$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" "$DESTINATION_DIR"
ls -la "$DESTINATION_DIR"

echo "Copying from source branch to destination branch"
TARGET_DIR=$(mktemp -d)
cp -ra "$SOURCE_DIR"/. "$TARGET_DIR"

rm -rf "$TARGET_DIR"/.git
mv "$DESTINATION_DIR/.git" "$TARGET_DIR"

echo "Files that will be pushed"
cd "$TARGET_DIR"
ls -la

echo "Adding git commit"

ORIGIN_COMMIT="https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"

git add .
git status

# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push origin --set-upstream "$DESTINATION_BRANCH"
