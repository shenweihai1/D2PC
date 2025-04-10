echo "start kill..."
cmd="cd D2PC;bash kill.sh"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"
echo "ssh 127.0.0.1"
ssh 127.0.0.1 "$cmd"


rm ~/D2PC/logs/*.log

keys=4000000


sleep 5
echo "start server..."
nServers=4
nShardsPerShards=24
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r0.sh $nServers 0 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r1.sh $nServers 0 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r2.sh $nServers 0 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r0.sh $nServers 1 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r1.sh $nServers 1 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r2.sh $nServers 1 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r0.sh $nServers 2 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r1.sh $nServers 2 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r2.sh $nServers 2 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r0.sh $nServers 3 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r1.sh $nServers 3 $nShardsPerShards $keys"
ssh 127.0.0.1 "ulimit -n 20000;cd D2PC;bash r2.sh $nServers 3 $nShardsPerShards $keys"


sleep 5
echo "start clients..."
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 0 $nServers 0 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 1 $nServers 0 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 2 $nServers 0 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 3 $nServers 1 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 4 $nServers 1 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 5 $nServers 1 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 6 $nServers 2 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 7 $nServers 2 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 8 $nServers 2 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 9 $nServers 3 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 10 $nServers 3 $nShardsPerShards $keys" &
ssh 127.0.0.1     "ulimit -n 20000;cd D2PC;bash clients.sh 11 $nServers 3 $nShardsPerShards $keys" &


sleep 40

echo "Processing logs"
cat ~/D2PC/logs/client-*.log | sort -g -k 3 > ~/D2PC/logs/client.log 
python ~/D2PC/store/tools/process_logs.py ~/D2PC/logs/client.log 30 


echo 'DONE'