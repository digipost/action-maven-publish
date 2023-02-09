#!/usr/bin/env bash
# https://github.com/keybase/keybase-issues/issues/2798
export GPG_TTY=$(tty)

# Make sure the required env variables are set
[ -z "$SONATYPE_SECRETS" ] && echo 'Missing "sonatype_secrets" input variable' && exit 1;
[ -z "$RELEASE_VERSION" ] && echo 'Missing "release_version" input variable' && exit 1;
[ -z "$PERFORM_RELEASE" ] && echo 'Missing "perform_release" input variable' && exit 1;

IFS=, read username password passphrase private_key <<< $(echo $SONATYPE_SECRETS | base64 -d)

export GPG_PASSPHRASE=$passphrase
export OSSRH_USERNAME=$username
export OSSRH_PASSWORD=$password

if [ "$PERFORM_RELEASE" = "true" ];
  then
    target="sonatype-oss-nexus-staging"
    profiles="build-sources-and-javadoc,sign-artifacts,release";
  else
    target="sonatype-oss-nexus-snapshots"
    profiles="build-sources-and-javadoc,sonatype_snapshots";
fi

# Import GPG key from env variable into keychain
# Env variable is base64 encoded -> Decode it before import
echo ${private_key} | base64 --decode | gpg --batch --import

echo ""
echo "**** maven publish ****"
echo "version : $RELEASE_VERSION"
echo "target  : $target"
echo "profiles: $profiles"
echo "***********************"
echo ""


## Deploy to OSSRH, which will automatically release to Central Repository
cd $GITHUB_WORKSPACE
mvn versions:set --no-transfer-progress -DnewVersion=$RELEASE_VERSION
mvn clean deploy \
	--batch-mode \
	--no-transfer-progress \
	--activate-profiles $profiles \
	--settings /settings.xml
