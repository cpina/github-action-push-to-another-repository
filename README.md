# GitHub Action: Push to Another Repository (Fixed Fork)

## Why This Fork Exists

This is a fork of [cpina/github-action-push-to-another-repository](https://github.com/cpina/github-action-push-to-another-repository) created to fix a critical OpenSSL version mismatch issue that was causing deployment failures.

## What Was Changed

### OpenSSL Version Mismatch Fix

**Problem**: The original action was failing with the error:
```
OpenSSL version mismatch. Built against 3050003f, you have 30500010
```

**Root Cause**: The Alpine Linux base image was using inconsistent OpenSSL versions between the container's SSH client and the system's OpenSSL library.

**Solution**: Updated the Dockerfile to:
1. Pin Alpine to version 3.20 for consistency
2. Explicitly install the `openssl` package alongside other dependencies
3. Update package index before installation

### Changes Made

**Before**:
```dockerfile
FROM alpine:latest
RUN apk add --no-cache git git-lfs openssh-client
```

**After**:
```dockerfile
FROM alpine:3.20
RUN apk update && apk add --no-cache git git-lfs openssh-client openssl
```

## Usage

Use this fork in your GitHub Actions workflows:

```yaml
- name: Push to another repository
  uses: Play-Perfect/github-action-push-to-another-repository@main
  with:
    source-directory: 'output'
    destination-github-username: 'your-username'
    destination-repository-name: 'your-repo'
    user-email: your-email@example.com
    target-branch: main
  env:
    SSH_DEPLOY_KEY: ${{ secrets.SSH_DEPLOY_KEY }}
```

## Documentation

For complete usage documentation, examples, and troubleshooting, refer to the original documentation:
https://cpina.github.io/push-to-another-repository-docs/

## Compatibility

This fork maintains full compatibility with the original action's API and parameters. It's a drop-in replacement that simply fixes the OpenSSL version mismatch issue.
