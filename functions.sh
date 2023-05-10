#!/bin/sh

getArgs() {
	SOURCE_BEFORE_DIRECTORY="${1}"
	SOURCE_DIRECTORY="${2}"
	DESTINATION_GITHUB_USERNAME="${3}"
	DESTINATION_REPOSITORY_NAME="${4}"
	GITHUB_SERVER="${5}"
	USER_EMAIL="${6}"
	USER_NAME="${7}"
	DESTINATION_REPOSITORY_USERNAME="${8}"
	TARGET_BRANCH="${9}"
	COMMIT_MESSAGE="${10}"
	TARGET_DIRECTORY="${11}"
	CREATE_TARGET_BRANCH_IF_NEEDED="${12}"
}

sshDeployKey() {
	mkdir --parents "$HOME/.ssh"
	DEPLOY_KEY_FILE="$HOME/.ssh/deploy_key"
	echo "${SSH_DEPLOY_KEY}" > "$DEPLOY_KEY_FILE"
	chmod 600 "$DEPLOY_KEY_FILE"

	SSH_KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
	ssh-keyscan -H "$GITHUB_SERVER" > "$SSH_KNOWN_HOSTS_FILE"

	export GIT_SSH_COMMAND="ssh -i "$DEPLOY_KEY_FILE" -o UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE"

	GIT_CMD_REPOSITORY="git@$GITHUB_SERVER:$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git"
}

githubToken() {
	GIT_CMD_REPOSITORY="https://$DESTINATION_REPOSITORY_USERNAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git"
}

setupGit() {
	git config --global user.email "$USER_EMAIL"
	git config --global user.name "$USER_NAME"
}

cloneSimple() {
	git clone --single-branch --depth 1 --branch "$TARGET_BRANCH" "$GIT_CMD_REPOSITORY" "$CLONE_DIR"
}

cloneCreateBranch() {
	if [ "$CREATE_TARGET_BRANCH_IF_NEEDED" = "true" ]
	then
		# Default branch of the repository is cloned. Later on the required branch
		# will be created
		git clone --single-branch --depth 1 "$GIT_CMD_REPOSITORY" "$CLONE_DIR"
	else
		false
	fi
}

cloneError() {
	echo "::error::Could not clone the destination repository. Command:"
	echo "::error::git clone --single-branch --branch $TARGET_BRANCH $GIT_CMD_REPOSITORY $CLONE_DIR"
	echo "::error::(Note that if they exist USER_NAME and API_TOKEN is redacted by GitHub)"
	echo "::error::Please verify that the target repository exist AND that it contains the destination branch name, and is accesible by the API_TOKEN_GITHUB OR SSH_DEPLOY_KEY"
	exit 1
}

cloneRepo() {
	cloneSimple || cloneCreateBranch || cloneError
}

checkSource() {
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
}

switchBranch() {
	if [ "$CREATE_TARGET_BRANCH_IF_NEEDED" = "true" ]
	then
		git switch -c "$TARGET_BRANCH"
	fi
}
