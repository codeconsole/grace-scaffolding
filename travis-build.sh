#!/bin/bash
set -e

EXIT_STATUS=0

echo "Test for branch $TRAVIS_BRANCH JDK: $TRAVIS_JDK_VERSION"

./gradlew test --no-daemon || EXIT_STATUS=$?

if [ $EXIT_STATUS -ne 0 ]; then
  echo "test failed => exit $EXIT_STATUS"
  exit $EXIT_STATUS
fi

echo "Assemble for branch $TRAVIS_BRANCH JDK: $TRAVIS_JDK_VERSION"

./gradlew assemble --no-daemon || EXIT_STATUS=$?

if [ $EXIT_STATUS -ne 0 ]; then
  echo "assemble failed => exit $EXIT_STATUS"
  exit $EXIT_STATUS
fi

if [ "${TRAVIS_JDK_VERSION}" == "openjdk11" ] ; then
  echo "JDK 11 => exit $EXIT_STATUS"
  exit $EXIT_STATUS
fi

filename=$(find build/libs -name "*.jar" | head -1)
filename=$(basename "$filename")

echo "Publishing archives for branch $TRAVIS_BRANCH JDK: $TRAVIS_JDK_VERSION"
if [[ -n $TRAVIS_TAG ]] || [[ $TRAVIS_BRANCH =~ ^master|[3]\..\.x$ && $TRAVIS_PULL_REQUEST == 'false' ]]; then


  if [[ -n $TRAVIS_TAG ]]; then
      echo "Publishing archives"
      ./gradlew bintrayUpload --no-daemon || EXIT_STATUS=$?
  else
      ./gradlew publish --no-daemon || EXIT_STATUS=$?
  fi
fi

exit $EXIT_STATUS