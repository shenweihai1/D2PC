prefix=$1
nServers=$2
serverIdx=$3 # [0-9] 10 machines in total, close replicaId
nshardsPerShards=$4
keys=$5
let clients=$nshardsPerShards*5
echo "using keys: $keys, clients: $clients"

ROOT=$HOME
srcdir="$HOME/D2PC"
mode="occ"            # Mode for storage system.
tpcmode="parallel"  # Mode for commit algorithm (fast/slow/parellel)
total_shards=$((nServers * nshardsPerShards))

for ((i = 1; i <= $clients; i++)); do
  $ROOT/D2PC/store/benchmark/benchClient \
    -c $srcdir/store/tools/shard \
    -N $total_shards \
    -f $ROOT/D2PC/store/tools/keys \
    -d 30 \
    -r $serverIdx \
    -t "$tpcmode" \
    -n 3 \
    -l $total_shards \
    -w 50 -k $keys -m "$mode" -e 0 -s 0 \
    -z -1 > ./logs/client-$prefix-$i.log 2>&1 &

done
