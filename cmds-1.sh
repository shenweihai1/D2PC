echo "start kill..."
cmd="cd D2PC;bash kill.sh"
echo "ssh 172.16.0.4"
ssh 172.16.0.4 "$cmd"
echo "ssh 172.16.0.6"
ssh 172.16.0.6 "$cmd"
echo "ssh 172.16.0.9"
ssh 172.16.0.9 "$cmd"


rm ~/D2PC/logs/*.log

keys=1000000


sleep 5
echo "start server..."
nServers=1
nShardsPerShards=24
ssh 172.16.0.4 "ulimit -n 20000;cd D2PC;bash r0.sh $nServers 0 $nShardsPerShards $keys"
ssh 172.16.0.6 "ulimit -n 20000;cd D2PC;bash r1.sh $nServers 0 $nShardsPerShards $keys"
ssh 172.16.0.9 "ulimit -n 20000;cd D2PC;bash r2.sh $nServers 0 $nShardsPerShards $keys"


sleep 5
echo "start clients..."
ssh 172.16.0.4     "ulimit -n 20000;cd D2PC;bash clients.sh 0 $nServers 0 $nShardsPerShards $keys" &
ssh 172.16.0.6     "ulimit -n 20000;cd D2PC;bash clients.sh 1 $nServers 0 $nShardsPerShards $keys" &
ssh 172.16.0.9     "ulimit -n 20000;cd D2PC;bash clients.sh 2 $nServers 0 $nShardsPerShards $keys" &


sleep 40

echo "Processing logs"
cat ~/D2PC/logs/client-*.log | sort -g -k 3 > ~/D2PC/logs/client.log 
python ~/D2PC/store/tools/process_logs.py ~/D2PC/logs/client.log 30 


echo 'DONE'
