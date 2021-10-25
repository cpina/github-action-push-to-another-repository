#!/bin/sh -l

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

echo "[+] Action start"
SOURCE_BEFORE_DIRECTORY="$1"
SOURCE_DIRECTORY="$2"
DESTINATION_GITHUB_USERNAME="$3"
DESTINATION_REPOSITORY_NAME="$4"
GITHUB_SERVER="$5"
USER_EMAIL="$6"
USER_NAME="$7"
DESTINATION_REPOSITORY_USERNAME="$8"
TARGET_BRANCH="$9"
COMMIT_MESSAGE="${10}"
TARGET_DIRECTORY="${11}"

if [ -z "$DESTINATION_REPOSITORY_USERNAME" ]
then
	DESTINATION_REPOSITORY_USERNAME="$DESTINATION_GITHUB_USERNAME"
fi

if [ -z "$USER_NAME" ]
then
	USER_NAME="$DESTINATION_GITHUB_USERNAME"
fi

CLONE_DIR=$(mktemp -d)

echo "[+] Cloning destination git repository $DESTINATION_REPOSITORY_NAME"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"
git clone --single-branch --branch "$TARGET_BRANCH" "https://$USER_NAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

TEMP_DIR=$(mktemp -d)
# This mv has been the easier way to be able to remove files that were there
# but not anymore. Otherwise we had to remove the files from "$CLONE_DIR",
# including "." and with the exception of ".git/"
mv "$CLONE_DIR/.git" "$TEMP_DIR/.git"

if [ -n "$TARGET_DIRECTORY" ]
then
	echo "[+] Checking if $TARGET_DIRECTORY exist in git repo $DESTINATION_REPOSITORY_NAME"

	# Remove contents of target directory and create a new empty one
	if [ -d "$CLONE_DIR/$TARGET_DIRECTORY/" ]
	then
		echo "[+] Deleting files from $TARGET_DIRECTORY in git repo $DESTINATION_REPOSITORY_NAME"
		rm -R "$CLONE_DIR/$TARGET_DIRECTORY/"
	fi
	echo "[+] Creating $TARGET_DIRECTORY if doesnt already exist"
	mkdir -p "$CLONE_DIR/$TARGET_DIRECTORY"

	echo "[+] Listing Current Directory Location"
	ls -al

	echo "[+] Listing root Location"
	ls -al /
fi

mv "$TEMP_DIR/.git" "$CLONE_DIR/.git"

echo "[+] List contents of $SOURCE_DIRECTORY"
ls "$SOURCE_DIRECTORY"

echo "[+] Checking if local $SOURCE_DIRECTORY exist"
if [ ! -d "$SOURCE_DIRECTORY" ]
then
	echo "ERROR: $SOURCE_DIRECTORY does not exist"
	echo "This directory needs to exist when push-to-another-repository is executed"
	echo
	echo "In the example it is created by ./build.sh: https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L19"
	echo
	echo "If you want to copy a directory that exist in the source repository"
	echo "to the target repository: you need to clone the source repository"
	echo "in a previous step in the same build section. For example using"
	echo "actions/checkout@v2. See: https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L16"
	exit 1
fi

echo "[+] Copying contents of source repository folder $SOURCE_DIRECTORY to folder $TARGET_DIRECTORY in git repo $DESTINATION_REPOSITORY_NAME"
cp -ra "$SOURCE_DIRECTORY"/. "$CLONE_DIR/$TARGET_DIRECTORY"
cd "$CLONE_DIR"

echo "[+] Files that will be pushed"
ls -la

ORIGIN_COMMIT="https://$GITHUB_SERVER/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"

echo "[+] Adding git commit"
git add .

echo "[+] git status:"
git status

echo "[+] git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "[+] Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push "https://$USER_NAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" --set-upstream "$TARGET_BRANCH"
