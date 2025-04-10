import collections
import subprocess
import sys

# 10 --> leader
# 10 --> follower1
# 10 --> follower2
# clients--> on same 30 machines
def getNoLeaderBasedShardsInfo():
    leaders = []
    for e in open("./ips_l.pub","r").readlines():
        leaders.append(e.strip())

    f1 = []
    for e in open("./ips_f1.pub","r").readlines():
        f1.append(e.strip())

    f2 = []
    for e in open("./ips_f2.pub","r").readlines():
        f2.append(e.strip())

    n_partitions=-1
    with open('./n_partitions', 'r') as file:
        file_contents = file.read()
        n_partitions = int(file_contents)

    data = collections.defaultdict(list)
    data["n_partitions"] = n_partitions
    for i in range(n_partitions):
        data["localhost"].append(leaders[i]) # localhost
        data["p1"].append(f1[i]) # p1
        data["p2"].append(f2[i]) # p2

    return data

def convertNoLeaderBasedYamlMulti(trds, shards):
    total = trds * shards
    shardInfo = getNoLeaderBasedShardsInfo()
    
    basePort = 51000
    i = 0
    for shard in range(shards):
        host1 = shardInfo["localhost"][shard]
        host2 = shardInfo["p1"][shard]
        host3 = shardInfo["p2"][shard]
        for trd in range(1,trds+1):
            file_name = "shard{idx}.config".format(idx=i)
            content = """f 1
replica {host1}:{port0}
replica {host2}:{port1}
replica {host3}:{port2}""".format(host1=host1, host2=host2, host3=host3, port0=basePort, port1=basePort+1, port2=basePort+2)
            f = open(file_name, "w")
            f.write(content)
            f.close()
            basePort += 3
            i += 1

if __name__ == "__main__":
    result = subprocess.run("rm *.config", shell=True, check=False, text=True)
    print("rm all config:", result.stdout)

    shards = int(sys.argv[1])
    trds = int(sys.argv[2])
    print("shards:", shards, ", trds:", trds)
    convertNoLeaderBasedYamlMulti(trds=trds, shards=shards)
