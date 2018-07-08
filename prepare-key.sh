#!/bin/bash
echo "$SSH_PRIVATE_KEY_0" > "$SSH_KEY_FILENAME"
for PRIVATE_KEY_VAR in SSH_PRIVATE_KEY_{1..26}
do
    echo "${!PRIVATE_KEY_VAR}" >> "$SSH_KEY_FILENAME"
done
