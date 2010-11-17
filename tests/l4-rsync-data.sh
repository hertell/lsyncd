#!/bin/bash

RANGE=1
LOG="-log all"

set -e
C1="\E[47;34m"
C0="\033[0m"

echo -e "$C1****************************************************************$C0"
echo -e "$C1 Testing layer 4 default rsync with simulated data activity     $C0"
echo -e "$C1****************************************************************$C0"
echo

# root tmp dir
R=$(mktemp -d)
# source dir
S=$R/source
# target dir
T=$R/target
# logfile
L=$R/log
# pidfile
P=$R/pid

echo -e "$C1* using root dir for test $R$C0"
echo -e "$C1* populating the source$C0"
echo -e "$C1* ceating d[x]/e/f1 $C0"
mkdir -p "$S"/d/e
echo 'test' > "$S"/d/e/f1
echo -e "$C1* starting lsyncd$C0"
# lets bash detatch Lsyncd instead of itself; lets it log stdout as well.
echo ./lsyncd $LOG -logfile "$L" -pidfile "$P" -nodaemon -rsync "$S" "$T"
./lsyncd $LOG -logfile "$L" -pidfile "$P" -nodaemon -rsync "$S" "$T" &
echo -e "$C1* waiting for lsyncd to start$C0"
sleep 4s

# cp -r the directory
echo -e "$C1* making some data$C0"
echo -e "$C1* ceating d[x]/e/f2 $C0"
for i in $RANGE; do
    cp -r "$S"/d "$S"/d${i}
#    echo 'test2' > "$S"/d${i}/e/f2
done

#mkdir -p "$S"/m/n
#echo 'test3' > "$S"/m/n/file
#for i in $RANGE; do
#    cp -r "$S"/m "$S"/m$i
#    echo 'test4' > "$S"/m${i}/n/another
#done

echo -e "$C1* waiting for Lsyncd to do its job.$C0"
sleep 20s

echo -e "$C1* killing Lsyncd$C0"
PID=$(cat "$P")
if ! kill "$PID"; then
    cat "$L"
    diff -urN "$S" "$T" || true
    echo "kill failed"
    exit 1
fi
sleep 1s

echo -e "$C1* differences$C0"
diff -urN "$S" "$T"

#rm -rf "$R"

