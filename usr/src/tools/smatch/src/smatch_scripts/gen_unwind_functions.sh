#!/bin/bash

file=$1
project=$(echo "$2" | cut -d = -f 2)

if [[ "$file" = "" ]] ; then
    echo "Usage:  $0 <file with smatch messages> -p=<project>"
    exit 1
fi

if [[ "$project" != "kernel" ]] ; then
    exit 0
fi

outfile="kernel.unwind_functions"
bin_dir=$(dirname $0)
remove=$(echo ${bin_dir}/../smatch_data/${outfile}.remove)
tmp=$(mktemp /tmp/smatch.XXXX)
tmp2=$(mktemp /tmp/smatch.XXXX)

echo "// list of unwind functions." > $outfile
echo '// generated by `gen_unwind_functions.sh`' >> $outfile
grep "is unwind function" $file | cut -d ' ' -f 2 | cut -d '(' -f 1 >> $tmp
cat $tmp | sort -u > $tmp2
mv $tmp2 $tmp
cat $tmp $remove $remove 2> /dev/null | sort | uniq -u >> $outfile
rm $tmp
echo "Done.  List saved as '$outfile'"
