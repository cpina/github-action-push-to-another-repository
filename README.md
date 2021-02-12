# github-action-push-branch-to-another-repository-branch

Used to push generated files from a branch from Git Action step into a branch in another repository on Github. By design it deletes the files from the destination branch as it is meant to "publish" a set generated files.

Basically, after running this action, the contents of the destination branch will be the same as the contents of the source branch.

**Note:** Both source and destination branch must exists. This action does not create the destination branch if it doesn't exists.

**Note:** The new commit will override the entire content of the destination branch with the source branch in a new commit. It does not override the history in destination branch.

## Inputs

```yaml
  source-repository-username:
    description: 'Username/organization of the source repository'
    required: true
  source-repository-name:
    description: 'Name of the source repository'
    required: true
  source-branch:
    description: 'Name of the source branch'
    required: true
  destination-repository-username:
    description: 'Username/organization of the destination repository'
    required: true
  destination-repository-name:
    description: 'Name of the destination repository'
    required: true
  destination-branch:
    description: 'Name of the destination branch'
    required: true
  commit-user-email:
    description: 'Email for the git commit'
    required: true
  commit-username:
    description: 'User name for the git commit'
    required: true
  commit-message:
    description: '[Optional] commit message for the output repository. ORIGIN_COMMIT is replaced by the URL@commit in the origin repo'
    default: 'Update from ORIGIN_COMMIT'
    required: false
```

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
      - name: Pushes to branch in another repository
        uses: emre-e/github-action-push-branch-to-another-repository-branch@master
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
        with:
          source-repository-username: 'example-username'
          source-repository-name: 'source-repo'
          source-branch: 'source-branch'
          destination-repository-username: 'emre-e'
          destination-repository-name: 'dest-blog'
          destination-branch: 'dest-branch'
          commit-user-email: 'example.email@for.the.commit.com'
          commit-username: 'example-username'
```

### Push directory into another repository instead
https://github.com/cpina/github-action-push-to-another-repository
