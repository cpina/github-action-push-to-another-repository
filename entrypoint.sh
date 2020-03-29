#!/bin/sh -l

echo "Starts"
FOLDER="$1"
GITHUB_USERNAME="$2"
GITHUB_REPO="$3"
GIT_USER_EMAIL="$4"

CLONE_DIR=$(mktemp)

# Setup git
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GITHUB_USERNAME"
git clone "https://$API_TOKEN_GITHUB@github.com/$GITHUB_USERNAME/$GITHUB_REPO.git" "$CLONE_DIR"

ls -la "$CLONE_DIR"

# Copy files into the git and deletes all git
find "$CLONE_DIR" | grep -v "^$CLONE_DIR/\.git" | xargs rm -rf # delete all files (to handle deletions)

ls -la "$CLONE_DIR"

cp -r "$FOLDER"/* "$CLONE_DIR"

cd "$CLONE_DIR"

git add .
git commit --message "Update from $GITHUB_REPOSITORY"
git push origin master
