#!/bin/bash
echo "Running SonarQube scan before commit..."
sonar-scanner
if [ $? -ne 0 ]; then
  echo "SonarQube scan failed. Commit aborted."
  exit 1
fi
