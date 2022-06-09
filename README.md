# github-action-push-to-another-repository

When to use this GitHub Action? It can be used if you have a GitHub repository with a directory that you want to push to another GitHub repository using GitHub Actions (automated on push, for example). It is also useful if when using GitHub Actions, you generate certain files that you want to push to another GitHub repository. For example, if you have MarkDown files and want to generate HTML files, then push them into another repository.

Flow:

There are two example repositories:
 * [Repository 1](https://github.com/cpina/push-to-another-repository-deploy-keys-example): using SSH deploy keys (recommended)
 * [Repository 2](https://github.com/cpina/push-to-another-repository-example): using a personal access token setup

On a push of the repositories (thanks to the file [.github/workflows/ci.yml](https://github.com/cpina/push-to-another-repository-deploy-keys-example/tree/main/.github/workflows) it uses Pandoc to read the MarkDown file [main.md](https://github.com/cpina/push-to-another-repository-deploy-ssh-example/blob/main/main.md) (via [this step](https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L19) and the example [build.sh](https://github.com/cpina/push-to-another-repository-deploy-keys-example/blob/main/build.sh). build.sh generates the output/ directory configurable via [source-directory](https://github.com/cpina/push-to-another-repository-deploy-keys-example/blob/main/.github/workflows/ci.yml#L27) appears in the [output repository](https://github.com/cpina/push-to-another-repository-output).

Please bear in mind: files in the target repository's specified directory are deleted. This is to make sure that it contains only the files generated on the last run.

There are different variables to set up the behaviour:

## Inputs
### `source-directory` (argument)
From the repository that this Git Action is executed the directory that contains the files to be pushed into the repository.

### `destination-github-username` (argument)
For the repository `https://github.com/cpina/push-to-another-repository-output` is `cpina`.

### `destination-repository-name` (argument)
For the repository `https://github.com/cpina/push-to-another-repository-output` is `push-to-another-repository-output`

*Warning:* this GitHub Action currently deletes all the files and directories in the destination repository. The idea is to copy from an `output` directory into the `destination-repository-name` having a copy without any previous files there.

### `user-email` (argument)
The email that will be used for the commit in the destination-repository-name.

### `user-name` (argument) [optional]
The name that will be used for the commit in the destination-repository-name. If not specified, the `destination-github-username` will be used instead.

### `destination-repository-username` (argument) [optional]
The Username/Organization for the destination repository, if different from `destination-github-username`. For the repository `https://github.com/cpina/push-to-another-repository-output` is `cpina`.

### `target-branch` (argument) [optional]
The branch name for the destination repository. It defaults to `main`.

### `commit-message` (argument) [optional]
The commit message to be used in the output repository. Optional and defaults to "Update from $REPOSITORY_URL@commit".

The string `ORIGIN_COMMIT` is replaced by `$REPOSITORY_URL@commit`.

### `target-directory` (argument) [optional]
The directory to wipe and replace in the target repository.  Defaults to wiping the entire repository

### `SSH_DEPLOY_KEY` or `API_TOKEN_GITHUB`
The action, entirely executed in your GitHub continuous integration environment, needs to be able to push to the destination repository.

There are two options to do this:
 * Create an SSH deploy key. This key is restricted to the destination repository only
 * Create a GitHub Personal Authentication Token: the token has access to all your repositories

Someone with write access to your repository or this action, could technically add code to leak the key. Thus, *it is recommended to use the SSH deploy key method to minimise repercusions* if this was the case.

This action supports both methods to keep backwards compatibility, because in the beginning it only supported the GitHub Personal Authentication token.

## Setup with SSH deploy key
### Generate the key files

* `ssh-keygen -t ed25519 -C "your_email@example.com"` (the type ed25519 is recommended by [GitHub documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key))
* ssh will ask for a file path: `Enter file in which to save the key`: write a new file name. I suggest the default directory and as a filename: `id_github_name_of_your_repository` to avoid overwriting a previous file. If you will be using this action for multiple repositories, you might want to generate different keys for each one. 
* Leave the passphrase empty (otherwise we would need to pass the passphrase to the GitHub Action)

### Set up the deployment key

#### Destination repository

* Go to the GitHub page of the destination repository
* Click on "Settings" (settings for the repository, not the account settings)
* On the left-hand side pane click on "Deploy keys"
* Click on "Add deploy key"
* Title: "GitHub Action push to another repository"
* Key: paste the contents of the file with the public key. This was generated in the "Generate the key files" step and the name is "id_github_name_of_your_repository.pub"
* Enable "Allow write access"barbar

#### Origin repository

* Go to the GitHub page of the origin repository
* On the left-hand side pane click on "Secrets" and then on "Actions"
* Click on "New repository secret"
* Name: "SSH_DEPLOY_KEY"
* Value: paste the contents of the file with the private key. This was generated in the "Generate the key files" step and the name is "id_github_name_of_your_repository"

### Set up the personal access token

You don't need to do this if you chose to set up the deploy keys using the steps above. This method is here for compatibility with the initial approach of this GitHub Action. The personal access token would have access to all your repositories, so if it were to be leaked the damage would be greater.

Generate your personal token following the steps:
* Go to the GitHub Settings (on the right-hand side on the profile picture)
* On the left-hand side pane click on "Developer Settings"
* Click on "Personal Access Tokens" (also available at https://github.com/settings/tokens)
* Generate a new token, choose "Repo". Copy the token.

Then make the token available to the Github Action following the steps:
* Go to the GitHub page for the repository that you push from. Click on "Settings"
* On the left-hand side pane click on "Secrets" then "Actions"
* Click on "New repository secret"
* Name: "API_TOKEN_GITHUB"
* Value: paste the token that you copied earlier

## Example usage
```yaml
      - name: Pushes to another repository
        uses: cpina/github-action-push-to-another-repository@main
        env:
          SSH_DEPLOY_KEY: ${{ secrets.SSH_DEPLOY_KEY }}
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
        with:
          source-directory: 'output'
          destination-github-username: 'cpina'
          destination-repository-name: 'pandoc-test-output'
          user-email: carles3@pina.cat
          target-branch: main
```
(you only need `SSH_DEPLOY_KEY` or `API_TOKEN_GITHUB` depending on the method that you used)

Working example:

https://github.com/cpina/push-to-another-repository-deploy-keys-example/blob/main/.github/workflows/ci.yml

It generates files from:
https://github.com/cpina/push-to-another-repository-deploy-keys-example

To:
https://github.com/cpina/push-to-another-repository-output
