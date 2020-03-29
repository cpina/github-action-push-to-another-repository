#!/bin/sh -l

echo "Starts"
FOLDER="$1"
GITHUB_USERNAME="$2"
GITHUB_REPO="$3"
GIT_USER_EMAIL="$4"

CLONE_DIR="clone_repo"

# Setup git
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GITHUB_USERNAME"
git clone "https://$API_TOKEN_GITHUB@github.com/$GITHUB_USERNAME/$GITHUB_REPO.git" "$CLONE_DIR"

# Copy files into the git and deletes all git
cd "$CLONE_DIR"
# find needs to be in the git repository directory
find . | grep -v ".git" | grep -v "^\.*$" | xargs rm -rf # delete all files (to handle deletions)
cp -r "../$FOLDER"/* .

git add .
git commit --message "Update from $GITHUB_REPOSITORY"
git push origin master
