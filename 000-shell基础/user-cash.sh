#!/bin/sh

# 使用说明
usage() {
        echo "Usage: sh use-case.sh 1 [+|-|*|/] 1"
}


case $2 in
+)
	echo $(($1 + $3))
	;;
-)
	echo $(($1 - $3))
	;;
*|x)
	echo $(($1 * $3))
	;;
/)
	echo $(($1 / $3))
	;;
*)
	usage
	;;
esac
exit 0



