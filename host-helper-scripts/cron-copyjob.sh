#!/bin/bash
# Takes a root source path ($1) and looks for new items to copy in first level subdirectories
# These files are copied to the desination path ($2), maintaining the first level subdirectory
# $3 specifies how old items to be included are in minutes (as an integer). Match this to a cron job.

# use a negative value for `find -mmin` to find files newer then the positive value.
# add +5 for safety - missing a file will result in it never being imported, but copying twice will just waste a little time in entrypoint.sh
jobTimer=$(( ("$3" + 5) * -1 ))

# parsing `find` into `for` is bad apparently, use while read instead
while read -r subPath; do
    subFolder=$(basename "$subPath")
    if [[ ! -f "${2}/${subFolder}" ]]; then 
        mkdir -p "${2}/${subFolder}"
    fi
    find "$subPath" -type f -mmin "$jobTimer" -exec cp '{}' "${2}/${subFolder}/" \;
done < <(find "$1" -mindepth 1 -maxdepth 1 -type d)