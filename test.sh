#!/bin/bash

word_to_remove="LineToRemove"
line_to_insert="var globalEnvironment = Environment.testing; // LineToRemove"
input_file="lib/constants/global_variables.dart"
temp_file=$(mktemp)
while IFS= read -r line; do
    if [[ "$line" != *"$word_to_remove"* ]]; then
        echo "$line" >>"$temp_file"
    else
        echo "$line_to_insert" >>"$temp_file"
    fi
done <"$input_file"
mv "$temp_file" "$input_file"
rm -f "$temp_file"
