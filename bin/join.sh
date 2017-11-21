if [ ! $# -eq 4 ]; then
    echo "Usage: join.sh <col1> <col2> <fn1> <fn2>"
    exit -1
fi

col1="$1"
col2="$2"
fn1="$3"
fn2="$4"
LC_ALL=C sort -t'	' -k $col1 $fn1 | dos2unix > sort_tmp1.tsv
LC_ALL=C sort -t'	' -k $col2 $fn2 | dos2unix > sort_tmp2.tsv
LC_ALL=C join -t'	' -1 $col1 -2 $col2 sort_tmp1.tsv sort_tmp2.tsv
rm sort_tmp1.tsv sort_tmp2.tsv
