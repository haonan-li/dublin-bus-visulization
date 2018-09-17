for entry in `ls *.gz`
do
    gunzip $entry
done
