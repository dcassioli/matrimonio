#!/bin/sh
set -e

if [ -n "$TRAVIS_BUILD_ID" ]; then
  if [ "$TRAVIS_BRANCH" != "$DEPLOY_BRANCH" ]; then
    echo "Travis should only deploy from the DEPLOY_BRANCH ($DEPLOY_BRANCH) branch"
    exit 0
  else
    if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
      echo "Travis should not deploy from pull requests"
      exit 0
    else
      docker-compose -f docker-compose-deploy.yaml up --build --exit-code-from matrimonio
    fi
  fi
fi
