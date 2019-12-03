# Maven Publish GitHub Action

**GitHub Action for automatically publishing a Maven package to the Central Repository**

It's recommended to publish using the [Digipost open super pom](https://github.com/digipost/digipost-open-super-pom/tree/master), which greatly simplifies the process.

## Requirements

Add the `Digipost open super pom` to your project

```xml
<parent>
    <groupId>no.digipost</groupId>
    <artifactId>digipost-open-super-pom</artifactId>
    <version>6</version>
</parent>
```

## Usage

### Authentication

In your project's GitHub repository, go to Settings → Secrets. On this page, set the following variables:

- `release_version`: The version you want the project to be released with
- `sonatype_secrets`: a comma separated string that consists of `sonatype_username,sonatype_password,key_password,key_private`
    - `sonatype_username` is your projects username at Sonatype
    - `sonatype_password` is your projects password at Sonatype
    - `key_password` is the password of you gpg key to sign the deployed artfacts with. 
    - `key_private` is the actual private key encoded as base64 sign the deployed artfacts with.

These secrets will be passed as environment variables into the action, allowing it to do the deployment for you.

### Action

Create a GitHub workflow file (e.g. `.github/workflows/release.yml`) in your repository. Use the following configuration, which tells GitHub to use the Maven Publish Action when running your CI pipeline. The steps are self-explanatory:

```yml
name: Release

on:
  push:
    tags:
    - '*'
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Check out Git repository
        uses: actions/checkout@v1
      - name: Set release version
        run: echo ::set-env name=RELEASE_VERSION::$(echo ${GITHUB_REF:10})
      - name: Release to Central Repository
        uses: digipost/action-maven-publish@1.0.0
        with:
          sonatype_secrets: ${{ secrets.sonatype_secrets }}
          release_version: ${{ env.RELEASE_VERSION }}
```

This should be all the configuration you need. Every time you push a tag or make a release in github, the action will be run. If your `pom.xml` file contains a non-snapshot version tag and all tests pass, your package will automatically be deployed to the Central Repository.

## Development

### Implementation

The Maven Publish GitHub Action works the following way:

- When imported from a CI workflow in your project, GitHub will look for this repository's [`action.yml`](./action.yml) file. This file tells GitHub to run a new Docker container for the action and to pass in the action's input variables (GPG key and OSSRH login credentials).
- Docker will spin up a new container with Java and Maven installed (see [`Dockerfile`](./Dockerfile)).
- In the container, the [`entrypoint.sh`](./entrypoint.sh) script will be executed. It checks whether all required variables are defined, decodes the GPG private key and runs the Maven deploy command. Maven will use this repository's [`settings.xml`](./settings.xml) file, which instructs it to use the GPG passphrase and OSSRH credentials from the provided environment variables.

### Contributing

Suggestions and contributions are always welcome! Please discuss larger changes via issue before submitting a pull request.
