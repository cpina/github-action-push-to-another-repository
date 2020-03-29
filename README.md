# github-action-push-to-another-repository

Used to push generated files from a directory from Git Action step into another repository on Github.

E.g.
Repository pandoc-test contains Markdown and a Git Action to generate, using Pandoc, an output: HTML, PDF, odt, epub, etc.

Repository pandoc-test-output: contains only the generated files from the first Git Action. Pushed here with github-action-push-to-another-repository

And pandoc-test-output can have Git Pages to give access to the files (or just links to the raw version of the files)

## Inputs
### `source-directory` (argument)
From the repository that this Git Action is executed the directory that contains the files to be pushed into the repository.

### `destination-github-username` (argument)
For the repository `https://github.com/cpina/pandoc-test-output` is `cpina`. It's also used for the `Author:` in the generated git messages.

### `destination-repository-name` (argument)
For the repository `https://github.com/cpina/pandoc-test-output` is `pandoc-test-output`

### `user-email` (argument)
The email that will be used for the commit in the destination-repository-name.

### `API_TOKEN_GITHUB` (environment)
E.g.:
  `API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}`

Generate it from the Settings of the account that needs access to push.

## Example usage
`
      - name: Pushes to another repository
        uses: cpina/github-action-push-to-another-repository@master
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
        with:
          source-directory: 'output'
          destination-github-username: 'cpina'
          destination-repository-name: 'pandoc-test-output'
          git-user-email: carles@pina.cat
`
