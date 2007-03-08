#! /bin/sh

echo "Asking all remaining processes to terminate ..."
killall5 -15
for seq in 1 2 3 4 5; do
	killall5 -18 || break
	sleep 1
done
echo "Killing all remaining processes"
killall5 -9
