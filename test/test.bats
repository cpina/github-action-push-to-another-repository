#!/bin/sh

set -e
setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'
	load '../functions.sh'
}

_var_setup() {
	SSH_DEPLOY_KEY="SSH TEST"
	DESTINATION_REPOSITORY_USERNAME="UserTest"
	DESTINATION_REPOSITORY_NAME="RepoTest"
	GITHUB_SERVER="github.com"
}

_mockup_repo() {
	cd "$1"
	git init
	git checkout -b main
	touch "TEST"
	git add ./TEST
	git config user.name "Test"
	git config user.email "test@example.com"
	git commit -m "TEST_COMMIT"
}

@test "Script arguments" {
	getArgs 1 2 3 4 5 6 7 8 9 10 11 12
	assert [ $SOURCE_BEFORE_DIRECTORY = "1" ]
	assert [ $SOURCE_DIRECTORY = "2" ]
	assert [ $DESTINATION_GITHUB_USERNAME = "3" ]
	assert [ $DESTINATION_REPOSITORY_NAME = "4" ]
	assert [ $GITHUB_SERVER = "5" ]
	assert [ $USER_EMAIL = "6" ]
	assert [ $USER_NAME = "7" ]
	assert [ $DESTINATION_REPOSITORY_USERNAME = "8" ]
	assert [ $TARGET_BRANCH = "9" ]
	assert [ $COMMIT_MESSAGE = "10" ]
	assert [ $TARGET_DIRECTORY = "11" ]
	assert [ $CREATE_TARGET_BRANCH_IF_NEEDED = "12" ]
}

@test "Create SSH keys" {
	_var_setup
	HOME="$BATS_TEST_TMPDIR"
	GITHUB_KEYS="KNOWN TEST"
	ssh-keyscan() {
		echo "KNOWN TEST"
	}
	
	sshDeployKey
	
	assert [ -d "$BATS_TEST_TMPDIR/.ssh" ]
	assert [ -f "$BATS_TEST_TMPDIR/.ssh/deploy_key" ]
	assert [ "$(cat $BATS_TEST_TMPDIR/.ssh/deploy_key)" = "$SSH_DEPLOY_KEY" ]
	assert [ -f "$BATS_TEST_TMPDIR/.ssh/known_hosts" ]
	assert [ "$(cat $BATS_TEST_TMPDIR/.ssh/known_hosts)" = "$GITHUB_KEYS" ]
	assert [ "$GIT_CMD_REPOSITORY" = "git@$GITHUB_SERVER:$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" ]
	assert [ "$GIT_SSH_COMMAND" = "ssh -i $BATS_TEST_TMPDIR/.ssh/deploy_key -o UserKnownHostsFile=$BATS_TEST_TMPDIR/.ssh/known_hosts" ]
}

@test "Put github host in kwown_hosts" {
	skip "Network test"
	_var_setup
	HOME="$BATS_TEST_TMPDIR"
	# Get only the ssh keys (not hostnames)
	GITHUB_KEYS=$(ssh-keyscan "github.com" | cut -d " " -f 3)

	sshDeployKey
	for KEY in $GITHUB_KEYS; do
		# Check if the ssh keys are in known hosts
		assert grep -q "$KEY" "$BATS_TEST_TMPDIR/.ssh/known_hosts"
	done
}

@test "Set Github token in GIT_CMD_REPOSITORY" {
	_var_setup
	API_TOKEN_GITHUB="TokenTest"
	githubToken
	assert [ "$GIT_CMD_REPOSITORY" = "https://$DESTINATION_REPOSITORY_USERNAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" ]
}

@test "Setup git" {
	export HOME="$BATS_TEST_TMPDIR"
	USER_NAME="TestUser"
	USER_EMAIL="TestEmail@example.com"
	setupGit
	assert [ -f "$BATS_TEST_TMPDIR/.gitconfig" ]
	assert grep -q "$USER_NAME" "$BATS_TEST_TMPDIR/.gitconfig"
	assert grep -q "$USER_EMAIL" "$BATS_TEST_TMPDIR/.gitconfig"
}

@test "When source directory exist do nothing" {
	SOURCE_DIRECTORY="$BATS_TEST_TMPDIR/SourceTest"
	mkdir --parents $SOURCE_DIRECTORY
	run checkSource
	assert_output ""
}

@test "When source directory is missing exit" {
	SOURCE_DIRECTORY="$BATS_TEST_TMPDIR/SourceTest"
	run checkSource
	assert_failure
}

@test "Switch branch when \$CREATE_TARGET is true" {
	mkdir "$BATS_TEST_TMPDIR/Repo"
	_mockup_repo "$BATS_TEST_TMPDIR/Repo"
	CREATE_TARGET_BRANCH_IF_NEEDED="true"
	TARGET_BRANCH="TestBranch"
	switchBranch
	assert [ "$(git branch --show-current --format="%(refname:short)")" = "$TARGET_BRANCH" ]
}

@test "Only switch branch when \$CREATE_TARGET is true" {
	mkdir "$BATS_TEST_TMPDIR/Repo"
	_mockup_repo "$BATS_TEST_TMPDIR/Repo"
	CREATE_TARGET_BRANCH_IF_NEEDED="false"
	TARGET_BRANCH="TestBranch"
	switchBranch
	assert [ "$(git branch --show-current --format="%(refname:short)")" = "main" ]
}

@test "Clone repo (network)" {
	skip "Network test"
	TARGET_BRANCH="main"
	GIT_CMD_REPOSITORY="https://github.com/cpina/github-action-push-to-another-repository.git"
	CLONE_DIR="$BATS_TEST_TMPDIR"
	run cloneRepo
	assert_success
}

@test "Clone repo (local)" {
	TARGET_BRANCH="main"
	GIT_CMD_REPOSITORY="$BATS_TEST_TMPDIR/Repo"
	CLONE_DIR="$BATS_TEST_TMPDIR/RepoCloned"
	mkdir --parent "$CLONE_DIR"
	mkdir --parent "$GIT_CMD_REPOSITORY"
	_mockup_repo "$GIT_CMD_REPOSITORY"
	run cloneRepo
	assert_success
}

@test "When cloning repo and \$CREATE_TARGET is true create missing branch" {
	TARGET_BRANCH="TestBranch"
	GIT_CMD_REPOSITORY="$BATS_TEST_TMPDIR/Repo"
	CLONE_DIR="$BATS_TEST_TMPDIR/RepoCloned"
	CREATE_TARGET_BRANCH_IF_NEEDED="true"
	mkdir --parent "$GIT_CMD_REPOSITORY"
	_mockup_repo "$GIT_CMD_REPOSITORY"
	run cloneRepo
	assert_success
}

@test "When cloning with missing branch and \$CREATE_TARGET is false exit" {
	TARGET_BRANCH="TestBranch"
	GIT_CMD_REPOSITORY="$BATS_TEST_TMPDIR/Repo"
	CLONE_DIR="$BATS_TEST_TMPDIR/RepoCloned"
	CREATE_TARGET_BRANCH_IF_NEEDED="false"
	mkdir --parent "$CLONE_DIR"
	mkdir --parent "$GIT_CMD_REPOSITORY"
	_mockup_repo "$GIT_CMD_REPOSITORY"
	run cloneRepo
	assert_failure
}

@test "When cloning non existing repo exit" {
	TARGET_BRANCH="TestBranch"
	GIT_CMD_REPOSITORY="$BATS_TEST_TMPDIR/Repo"
	CLONE_DIR="$BATS_TEST_TMPDIR/RepoCloned"
	CREATE_TARGET_BRANCH_IF_NEEDED="false"
	run cloneRepo
	assert_failure
}

@test "When cloning non existing repo exit (network)" {
	TARGET_BRANCH="TestBranch"
	GIT_CMD_REPOSITORY="http://example.example/"
	CLONE_DIR="$BATS_TEST_TMPDIR/RepoCloned"
	CREATE_TARGET_BRANCH_IF_NEEDED="false"
	run cloneRepo
	assert_failure
}
