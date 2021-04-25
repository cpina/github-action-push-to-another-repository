# github-action-push-to-another-repository

When to use this GitHub Action? It is useful in case that you have a GitHub repository with a a directory that you want to push to another GitHub repository using GitHub Actions (automated on push, for example). It is also useful if using GitHub Actions you generate certain files that you want to push to another GitHub repository.

Flow:

The [example repository](https://github.com/cpina/push-to-another-repository-example) has a MarkDown file [main.md](https://github.com/cpina/push-to-another-repository-example/blob/main/main.md)), during the [GitHub Actions flow](https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L19) it executes [build.sh](https://github.com/cpina/push-to-another-repository-example/blob/main/build.sh) and the output/ directory (configurable via [source-directory](https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L27) appears in the [output repository](https://github.com/cpina/push-to-another-repository-output).

Please bear in mind: files in the target repository are deleted. This is to make sure that it contains only the generated files in the last run without previously generated files.

There are different variables to setup the behaviour:

## Inputs
### `source-directory` (argument)
From the repository that this Git Action is executed the directory that contains the files to be pushed into the repository.

### `destination-github-username` (argument)
For the repository `https://github.com/cpina/push-to-another-repository-output` is `cpina`. It's also used for the `Author:` in the generated git messages.

### `destination-repository-name` (argument)
For the repository `https://github.com/cpina/push-to-another-repository-output` is `push-to-another-repository-output`

*Warning:* this Github Action currently deletes all the files and directories in the destination repository. The idea is to copy from an `output` directory into the `destination-repository-name` having a copy without any previous files there.

### `user-email` (argument)
The email that will be used for the commit in the destination-repository-name.

### `destination-repository-username` (argument) [optional]
The Username/Organization for the destination repository, if different from `destination-github-username`. For the repository `https://github.com/cpina/push-to-another-repository-output` is `cpina`.

### `target-branch` (argument) [optional]
The branch name for the destination repository. It defaults to `main` for historical reasons, feel free to change it to `main`.

### `commit-message` (argument) [optional]
The commit message to be used in the output repository. Optional and defaults to "Update from $REPOSITORY_URL@commit".

The string `ORIGIN_COMMIT` is replaced by `$REPOSITORY_URL@commit`.

### `API_TOKEN_GITHUB` (environment)
E.g.:
  `API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}`

Generate your personal token following the steps:
* Go to the Github Settings (on the right hand side on the profile picture)
* On the left hand side pane click on "Developer Settings"
* Click on "Personal Access Tokens" (also available at https://github.com/settings/tokens)
* Generate a new token, choose "Repo". Copy the token.

Then make the token available to the Github Action following the steps:
* Go to the Github page for the repository that you push from, click on "Settings"
* On the left hand side pane click on "Secrets"
* Click on "Add a new secret" and name it "API_TOKEN_GITHUB"

## Example usage
```yaml
      - name: Pushes to another repository
        uses: cpina/github-action-push-to-another-repository@main
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
        with:
          source-directory: 'output'
          destination-github-username: 'cpina'
          destination-repository-name: 'pandoc-test-output'
          user-email: carles3@pina.cat
          target-branch: main
```

Working example:

https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml

It generates files from:
https://github.com/cpina/push-to-another-repository-example

To:
https://github.com/cpina/push-to-another-repository-output
