import sys

nShardsPerShards=24
leaders = []
for e in open("./store/tools/ips_l.pub","r").readlines():
    leaders.append(e.strip())

p1s = []
for e in open("./store/tools/ips_f1.pub","r").readlines():
    p1s.append(e.strip())

p2s = []
for e in open("./store/tools/ips_f2.pub","r").readlines():
    p2s.append(e.strip())


def generate(shard):
    oout = open("cmds-{s}.sh".format(s=shard), "w+")
    kill='echo "start kill..."\n'
    kill+='cmd="cd D2PC;bash kill.sh"\n'
    for k in range(shard):
        kill+='echo "ssh {h}"\n'.format(h=leaders[k])
        kill+='ssh {h} "$cmd"\n'.format(h=leaders[k])
        kill+='echo "ssh {h}"\n'.format(h=p1s[k])
        kill+='ssh {h} "$cmd"\n'.format(h=p1s[k])
        kill+='echo "ssh {h}"\n'.format(h=p2s[k])
        kill+='ssh {h} "$cmd"\n'.format(h=p2s[k])

    server='keys={k}\n\n\n'.format(k=100*10000*shard)
    server+='sleep 5\n'
    server+='echo "start server..."\n'
    server+='nServers={shard}\n'.format(shard=shard)
    server+='nShardsPerShards={nShardsPerShards}\n'.format(nShardsPerShards=nShardsPerShards)

    j = 0
    for k in range(shard):
        server+='ssh {h} "ulimit -n 20000;cd D2PC;bash r0.sh $nServers {serverIdx} $nShardsPerShards $keys"\n'.format(h=leaders[k],serverIdx=k)
        j+=1
        server+='ssh {h} "ulimit -n 20000;cd D2PC;bash r1.sh $nServers {serverIdx} $nShardsPerShards $keys"\n'.format(h=p1s[k],serverIdx=k)
        j+=1
        server+='ssh {h} "ulimit -n 20000;cd D2PC;bash r2.sh $nServers {serverIdx} $nShardsPerShards $keys"\n'.format(h=p2s[k],serverIdx=k)
        j+=1

    clients='sleep 5\n'
    clients+='echo "start clients..."\n'
    j = 0
    for k in range(shard):
        clients+='ssh {h}     "ulimit -n 20000;cd D2PC;bash clients.sh {prefix} $nServers {serverIdx} $nShardsPerShards $keys" &\n'.format(h=leaders[k],prefix=j,serverIdx=k)
        j+=1
        clients+='ssh {h}     "ulimit -n 20000;cd D2PC;bash clients.sh {prefix} $nServers {serverIdx} $nShardsPerShards $keys" &\n'.format(h=p1s[k],prefix=j,serverIdx=k)
        j+=1
        clients+='ssh {h}     "ulimit -n 20000;cd D2PC;bash clients.sh {prefix} $nServers {serverIdx} $nShardsPerShards $keys" &\n'.format(h=p2s[k],prefix=j,serverIdx=k)
        j+=1
    

    get_tput=''
    get_tput+='echo "Processing logs"\n'
    get_tput+='cat ~/D2PC/logs/client-*.log | sort -g -k 3 > ~/D2PC/logs/client.log \n'
    get_tput+='python ~/D2PC/store/tools/process_logs.py ~/D2PC/logs/client.log 30 \n'


    oout.write(kill)
    oout.write("\n\n")
    oout.write("rm ~/D2PC/logs/*.log\n\n")
    oout.write(server)
    oout.write("\n\n")
    oout.write(clients)
    oout.write("\n\n")
    oout.write("sleep 40\n\n")
    oout.write(get_tput)
    oout.write("\n\n")
    oout.write("echo 'DONE'")

    oout.flush()
    

if __name__ == "__main__":
    nShardsPerShards=int(sys.argv[1])
    print("We are using nShardsPerShards:{s}".format(s=nShardsPerShards))
    n_partitions=-1
    with open('./store/tools/n_partitions', 'r') as file:
        file_contents = file.read()
        n_partitions = int(file_contents)
    for shard in range(1,n_partitions+1):
        generate(shard)
