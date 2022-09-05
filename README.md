# github-action-push-to-another-repository

This GitHub Action will help to push files from one GitHub repository to another. For example, on a git push in a `source` repository, files can be pushed into a `destination` repository. 

A couple of examples of this could be:
 * Specifying a directory in a `source` repository to be pushed to a `destination` repository
 * Generating some files using another GitHub Action and pushing them into another `destination` repository (e.g. generate PDFs from MarkDown and push the PDFs across to the `destination` repository)

Please read the documentation to understand which files and commits are kept in the destination repository and `target-directory`.

`source` or `destination` can be private.

## Table of contents

* [Overview](#overview)
* [Usage](#usage)
* [Setup](#setup)
* [Troubleshooting](#troubleshooting)
* [FAQ](#faq)

## Overview

There are two ways to set up this GitHub action:
 * Using SSH deploy keys (recommended, a bit harder to set up): [push-to-another-repository-deploy-keys-example](https://github.com/cpina/push-to-another-repository-deploy-keys-example). The configuration is in the file [.github/workflows/ci.yml](https://github.com/cpina/push-to-another-repository-deploy-keys-example/blob/main/.github/workflows/ci.yml#L21)
 * Using a Personal Access Token (first iteration, not recommended but easier to set up: [push-to-another-repository-example](https://github.com/cpina/push-to-another-repository-example). The configuration is in the file [.github/workflows/ci.yml](https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L21)

Once the setup using one of the methods above has been done, the file [build.sh](https://github.com/cpina/push-to-another-repository-deploy-keys-example/blob/main/build.sh) is executed, creating a new directory `output/`, and this directory is copied across to the [destination repository](https://github.com/cpina/push-to-another-repository-output).

:warning: Please bear in mind that the files in the specified directory of the target repository are deleted unless the option `target-directory` is used (in this case, only the files for this directory are deleted).

## Usage

The variables below set up the behaviour of the GitHub Action:

### `source-directory` (argument)
Directory that the GitHub Action will push files from. Note: it can be `.` to push all the repository, but read the FAQ!

### `destination-github-username` (argument)
Username/Organization of the GitHub repository that will be used for the `destination` repository. To output to a repository such as `https://github.com/cpina/push-to-another-repository-output` this variable would be `cpina`.

### `destination-repository-name` (argument)
Name of the `destination` repository. To output to a repository such as `https://github.com/cpina/push-to-another-repository-output` this variable would be `push-to-another-repository-output`

:warning:: the GitHub Action currently deletes all the files and directories in the destination repository. The idea is to copy from an `output` directory into the `destination-repository-name`, removing all pre-existing files.

### `user-email` (argument)
The email that will be used for the commit to the destination-repository-name. Used for the "Author" of the generated commit.

### `user-name` (argument) [optional]
The name that will be used for the commit to the destination-repository-name. If not specified, the `destination-github-username` will be used instead.

### `destination-repository-username` (argument) [optional]
The Username/Organization for the destination repository, if different from `destination-github-username`. For the repository `https://github.com/cpina/push-to-another-repository-output` this variable would be `cpina`.

### `target-branch` (argument) [optional]
The branch name for the destination repository. It defaults to `main`.

### `commit-message` (argument) [optional]
The commit message to be used in the output repository. Optional and defaults to "Update from ORIGIN_COMMIT".

The string `ORIGIN_COMMIT` is replaced by `$ORIGIN_REPOSITORY_URL@commit`.

### `target-directory` (argument) [optional]
The directory to wipe and replace in the target repository. Defaults to wiping the entire repository.

## Setup

Before using the GitHub Action, **either the SSH Keys (recommended) or the Personal Access Token need to be set up as described below.**

### `SSH_DEPLOY_KEY` Vs. `API_TOKEN_GITHUB`

The Action, entirely executed in your GitHub continuous integration environment, needs to be able to push to the destination repository.

There are two options to do this:
 * Create an SSH deploy key. This key is restricted to the destination repository only (recommended)
 * Create a GitHub Personal Access Token. The Token has access to all your repositories

Someone with write access to your repository or this Action, could technically add code to leak the Token. Thus, *it is recommended to use the SSH deploy key method to minimise the impact* if this were to happen.

Initially, this Action only used the Personal Access Token method and it still supports both methods to keep backwards compatibility.

### Setup using SSH deploy key

Recommended, but the setup has a few more steps compared with the Personal Access Token option.

#### Generate the key files

 * In your computer terminal, generate an SSH key using: `ssh-keygen -t ed25519 -C "your_email@example.com"` (the type ed25519 is recommended by [GitHub documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)).
 * `ssh-keygen` will ask for a file path: `Enter file in which to save the key`: write a new file name. I suggest the default directory and as a filename: `id_github_{name_of_your_destination_repository}` to avoid overwriting a previous file. If you will be using this Action for multiple repositories, you might want to generate different keys for each one. For the repository `https://github.com/cpina/push-to-another-repository-example/`, `id_github_push-to-another-repository-example` could be used.
 * Leave the passphrase empty (otherwise the GitHub Action cannot use it)

Example:
```
carles@pinux:~$ ssh-keygen -t ed25519 -C carles@pina.cat
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/carles/.ssh/id_ed25519): /home/carles/.ssh/id_ed255^C
carles@pinux:~$ ssh-keygen -t ed25519 -C carles@pina.cat
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/carles/.ssh/id_ed25519): /home/carles/.ssh/id_github_push-to-another-repository
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/carles/.ssh/id_github_push-to-another-repository
Your public key has been saved in /home/carles/.ssh/id_github_push-to-another-repository.pub
The key fingerprint is:
SHA256:qkWM49d0ecTh+d9/CoRIv/N05oYGYvu+wOreQH9PoQ4 carles@pina.cat
The key's randomart image is:
+--[ED25519 256]--+
|            .    |
|           o o   |
|        .   =    |
|     o . o + .   |
|    o + S = + .  |
|   . + *o..= . ..|
|    . =.Eo=.+.o o|
|     + +.= *o=. o|
|    .o+ .o=oo.o.o|
+----[SHA256]-----+
carles@pinux:~$ 
```

This generates two files, the public and private ssh keys:
```
carles@pinux:~$ ls -l /home/carles/.ssh/id_github_push-to-another-repository*
-rw------- 1 carles carles 411 Jul 28 09:40 /home/carles/.ssh/id_github_push-to-another-repository
-rw-r--r-- 1 carles carles  97 Jul 28 09:40 /home/carles/.ssh/id_github_push-to-another-repository.pub
carles@pinux:~$ 
```

#### Destination repository

In this section, we will add the generated public key to the destination repository. This allows the Action to push there.

 * Go to the GitHub page of the **destination** repository (e.g. https://github.com/cpina/push-to-another-repository-output)
 * Click on "Settings" (settings for the repository, not the account settings)
  
    ![Screenshot-settings](docs/screenshots/ssh-key-10.png)

 * On the left-hand side pane click on "Deploy keys"
 
    ![Screenshot-deploy-keys](docs/screenshots/ssh-key-20.png)

 * Click on "Add deploy key"
 
    ![Screenshot-add-deploy-key](docs/screenshots/ssh-key-30.png)

 * Title: "GitHub Action push to another repository"
 * Key: paste the contents of the file with the public key. This was generated in the "Generate the key files" step and the name is "id_github_name_of_your_repository.pub"
 * **Enable** "Allow write access"

    ![Screenshot-title-key-enable](docs/screenshots/ssh-key-40.png)

#### Source repository

In this section, we will add the generated private key to the source repository. This allows the Action to push to the destination repository.

 * Go to the GitHub page of the source repository (e.g. https://github.com/cpina/push-to-another-repository-deploy-keys-example)

 * Click on the "Settings" (settings for the repository, not the account settings)

    ![Screenshot-settings](docs/screenshots/ssh-key-10.png)

 * On the left-hand side pane click on "Secrets" and then on "Actions"

    ![Screenshot-secrets-actions](docs/screenshots/ssh-key-50.png)

 * Click on "New repository secret"

    ![Screenshot-new-repository-secret](docs/screenshots/ssh-key-60.png)

 * Name: "SSH_DEPLOY_KEY"
 * Value: paste the contents of the file with the private key. This was generated in the "Generate the key files" step and the name is "id_github_name_of_your_repository"

    ![Screenshot-ssh-deploy-key-private-key](docs/screenshots/ssh-key-70.png)

The GitHub Action will detect the SSH_DEPLOY_KEY secret and use the private key to push to the destination directory.

Please read the [Troubleshooting](#troubleshooting) section if you encounter problems.

### Setup using Personal Access Token

This does not need to be done if you chose to set up the deploy keys using the steps above. This method is here for compatibility with the initial approach of this GitHub Action. The Personal Access Token would have access to all your repositories, so if it were to be leaked, the damage would be greater: it would allow pushes to the same repositories to which the Personal Access Token owner has access, and other possible associated permissions. On the other hand, the setup is a bit easier because it does not involve creating the deploy key.

Generate your Personal Access Token using the following steps:
 * Go to the general GitHub Settings (on the right-hand side on the profile picture)

    ![Screenshot-settings](docs/screenshots/pat-10.png)

 * On the left-hand side pane, scroll to the bottom and click on "Developer Settings"

    ![Screenshot-developer-settings](docs/screenshots/pat-20.png)

 * Click on "Personal Access Tokens" (also available at https://github.com/settings/tokens)

    ![Screenshot-personal-access-token](docs/screenshots/pat-30.png)
   
 * Generate a new token entering a name and expiration date, and choose "Repo". Click the bottom button "Generate token". If you choose an expiration date you will need to create a new token after this date. In this example, I have used "No expiration"; this should be used carefully.

    ![Screenshot-personal-access-token-comment-expiration-scope](docs/screenshots/pat-40.png)

 * Copy the displayed token

    ![Screenshot-personal-access-token-comment-displayed](docs/screenshots/pat-50.png)

Then make the token available to the GitHub Action using the following steps:
 * Go to the GitHub page for the repository that you push from (**origin repository**). Click on "Settings" for the repository

    ![Screenshot-secrets-actions](docs/screenshots/ssh-key-50.png)

 * Click on "New repository secret"

    ![Screenshot-new-repository-secret](docs/screenshots/ssh-key-60.png)

 * Name: "API_TOKEN_GITHUB"
 * Value: paste the token that you copied earlier
 * Click on "Add secret"

    ![Screenshot-new-repository-secret](docs/screenshots/pat-70.png)


#### Example set up

This example shows both set up methods. Only one of the lines, `SSH_DEPLOY_KEY` or `API_TOKEN_GITHUB`, is needed according to the set up method that is being used. Do not include the other line.

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

Working example:

https://github.com/cpina/push-to-another-repository-deploy-keys-example/blob/main/.github/workflows/ci.yml

This generates files from:
https://github.com/cpina/push-to-another-repository-deploy-keys-example

and pushes them to:
https://github.com/cpina/push-to-another-repository-output

## Troubleshooting

### Cannot push to the destination repository

This is the most common problem. Carefully read the logs on the GitHub Action pages of the source repositories. The action tries to write the errors and gives possible solutions / hints. To solve this problem, the first suggestion is to follow the steps above to redo the setup following the steps above. If this still does not work, the following problems have occurred in the past, so they may be useful points to start solving the problem:

 * User was logged in to GitHub with an account that did not have permission to push into the destination repository. The action could not push (permission denied).

 * Expired Token.

 * SSH generated key pair (public/private) was set in the wrong way.

 * Wrong copy-paste including spaces or other characters that did not belong to the key / token 

### Testing the SSH keys

#### Test connection to GitHub using the key pair

The public key should have been added into the repository (as an SSH deploy key following the documentation above).

Then, do:
```
$ ssh -o IdentitiesOnly=yes -i .ssh/id_push-to-another-repository-output_ed25519 git@github.com
```

Instead of `.ssh/id_push-to-another-repository-output_ed25519`, use the file as you created it. This is the **private** key (it does not end with `.pub`). If you used the correct private key for the correctly uploaded public key, it will print something along the lines of:
```
Hi cpina! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

If you see:
```
git@github.com: Permission denied (publickey).
```

the public key for this private key is not available on GitHub.

#### Verify that the key is in the correct repository

```
$ ssh-keygen -lf .ssh/id_push-to-another-repository-output_ed25519
```
The output will be something like:
```
256 SHA256:SOME_STRING_OF_CHARACTERS carles@pina.cat (ED25519)
```

This should match what you see in the deploy key of the destination repository. If it does not match, the deploy key is not properly set (perhaps different public/private keys were used, for example).

#### Permission of the key

Visualise the key in the destination repository, and it should say:
```
Read/Write
```
### Testing the Personal Access Token

If the Personal Access Token method was used for the setup, check it has the correct permissions to push to the destination repository and has not expired.

In your terminal do:

```
$ git clone https://YOUR_USERNAME:YOUR_ACCESS_TOKEN@github.com/SOMETHING/REPO
# YOUR_ACCESS_TOKEN probably starts with ghp_
$ cd REPO
$ git checkout -b test
$ git push origin test
```

For example, if the token did not have permission to write (because `repo` was not enabled for this token), you might see the following:
```
$ git push origin test
remote: Permission to cpina/qdacco.git denied to cpina.
fatal: unable to access 'https://github.com/cpina/qdacco/': The requested URL returned error: 403
```

### Error: URL using bad/illegal format or missing URL

It seems that GitHub created a Personal Access Token with a space character. This would happen if the Personal Token had a `#` or some other characters.

Firstly, check that no space was copied by mistake to the `API_TOKEN_GITHUB`. If this was the case, do the correct the copy. 

Secondly, if GitHub created a token with `#` or a space inside, I suggest creating a new one.

The problem, for those that are curious, is that the Personal Access Token is used in the git URLs and the URLs don't support `#`. The error "URL using bad/illegal format" comes from the curl library used by git.

More information: [issue 70](https://github.com/cpina/github-action-push-to-another-repository/issues/70)

### Error: remote: Repository not found.

Bug report where the GitHub Action ended with:
```
remote: Repository not found.
fatal: repository 'https://github.com/ORGNAME/REPONAME.git/' not found
```

See the possible solution in the comments of the [issue 75](https://github.com/cpina/github-action-push-to-another-repository/issues/75)

## FAQ

### How can I copy the whole repository?

Use `source_directory: .` to copy all the source GitHub repository to the destination.

:warning: this will also copy `.github/workflows/`! The destination repository will try to execute the Action. It will probably fail because the SSH keys / Personal Acccess Token will not be available for the destination repository.

A suggestion if you are using `source_directory: .` is to disable the GitHub Actions in the destination repository. To disable Actions in the destination repository:

 * Go to the destination repository (e.g. https://github.com/cpina/push-to-another-repository-output/settings)
 * Click on "Settings"
 * On the left side bar click on "Actions" and then "General"
 * Click on "Disable actions"
 * Click on "Save"

### How can I copy only some files / only some directories / exclude some files / etc.?

If you need to filter files or directories (exclude files, include only some, etc.) use a step before the Action to filter these into a temporary directory that will be pushed. This can be done with "rsync" or any tool that you feel comfortable with (could be "rclone" or "find + exec + rm", "find + exec + mv", etc. depending on your needs).

For example, see the step: https://github.com/cpina/push-to-another-repository-deploy-keys-example/blob/main/.github/workflows/ci.yml#L21

In the step above, rsync is installed (depending on your environment it will already be installed) and everything is copied from "output_temp" to "output" excluding "main.epub". Be careful with the usage of "/" and the exclude parameter in rsync directories. Refer to the rsync documentation for other options such as filter using an extension to include only some files / directories, etc.
