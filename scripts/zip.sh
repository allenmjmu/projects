# AI Generated

#!/bin/bash

# Define the folder to be zipped
FOLDER="/path/to/folder"

# Define the output zip file name
OUTPUT_ZIP="output.zip"

# Define the files to be excluded
EXCLUDED_FILES=("file1.txt" "file2.txt" "file3.txt")

# Create the zip file exluded the specified files
zip -r "$OUTPUT_ZIP" "$FOLDER" -x "${EXCLUDED_FILES[@]}"
