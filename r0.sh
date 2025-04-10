# There are ${nServers}*${nshardsPerShards} shards in total.
nServers=$1
serverIdx=$2 # [0-9] 10 machines in total
nshardsPerShards=$3
keys=$4

# # Start all replicas and timestamp servers
# $ROOT/D2PC/timeserver/timeserver \
#     -c $ROOT/D2PC/store/tools/shard.tss.config \
#     -i 0 > $ROOT/D2PC/logs/tss.replica0.log 2>&1 &
# sleep 0.1

ROOT=$HOME
mode="occ"            # Mode for storage system.
tpcmode="parallel"  # Mode for commit algorithm (fast/slow/parellel)
total_shards=$((nServers * nshardsPerShards))

# leader:0, f1:1, f2:2
kk=0
for ((i = 0; i <= $nshardsPerShards; i++)); do

shardIdx=$((serverIdx * nshardsPerShards + i))
$ROOT/D2PC/store/strongstore/server \
    -m "$mode" -t "$tpcmode" -S $total_shards \
    -n $shardIdx -N $total_shards -f $ROOT/D2PC/store/tools/keys \
    -k $keys -e 0 -s 0 -w 0 \
    -c $ROOT/D2PC/store/tools/shard${shardIdx}.config \
    -i $kk > ./logs/server-replica$shardIdx-$i.log 2>&1 & 

done

sleep 0.1
if [ "$serverIdx" -eq 0 ]; then
$ROOT/D2PC/replication/commit/coorserver \
     -i $total_shards -N $total_shards \
     -c $ROOT/D2PC/store/tools/shard.coor.config \
     -i $kk > $ROOT/D2PC/logs/coor0.log 2>&1 &
else
    echo "skip coordinator!"
fi
