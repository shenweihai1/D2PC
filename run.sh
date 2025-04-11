for ((i=1; i<=24; i++))
do
    echo "start shards: $i....."
    folder="$HOME/D2PC/logs/run-$i"
    mkdir -p $folder 
    echo "created a folder: $folder" 
    python3 generater.py $i 
    bash cmds-1.sh
    mv ~/D2PC/logs/*.log $folder/
    echo ""
    echo ""
done