

#include "store/weakstore/server.h"

namespace weakstore {

using namespace proto;

Server::Server(const transport::Configuration &configuration, int myIdx,
               Transport *transport, Store *store)
    : store(store), configuration(configuration), transport(transport)
{
    transport->Register(this, configuration, myIdx);
}

Server::~Server() { }

void
Server::ReceiveMessage(const TransportAddress &remote,
                       const string &type, const string &data)
{
    HandleMessage(remote, type, data);
}

void
Server::HandleMessage(const TransportAddress &remote,
                      const string &type, const string &data)
{
    GetMessage get;
    PutMessage put;
    
    if (type == get.GetTypeName()) {
        get.ParseFromString(data);
        HandleGet(remote, get);
    } else if (type == put.GetTypeName()) {
        put.ParseFromString(data);
        HandlePut(remote, put);
    } else {
        Panic("Received unexpected message type in OR proto: %s",
              type.c_str());
    }
}

void
Server::HandleGet(const TransportAddress &remote,
                  const GetMessage &msg)
{
    int status;
    string value;
    
    status = store->Get(msg.clientid(), msg.key(), value);

    GetReplyMessage reply;
    reply.set_status(status);
    reply.set_value(value);
    
    transport->SendMessage(this, remote, reply);
}

void
Server::HandlePut(const TransportAddress &remote,
                  const PutMessage &msg)
{
    int status = store->Put(msg.clientid(), msg.key(), msg.value());
    PutReplyMessage reply;
    reply.set_status(status);
    
    transport->SendMessage(this, remote, reply);
}

void
Server::Load(const string &key, const string &value)
{
    store->Load(key, value);
}

} // namespace weakstore

static void Usage(const char *progName)
{
    fprintf(stderr, "usage: %s -c conf-file -i replica-index\n",
            progName);
    exit(1);
}

int
main(int argc, char **argv)
{
    int index = -1;
    const char *configPath = NULL;
    const char *keyPath = NULL;

    // Parse arguments
    int opt;
    while ((opt = getopt(argc, argv, "c:i:f:")) != -1) {
        switch (opt) {
            case 'c':
                configPath = optarg;
                break;

            case 'i':
            {
                char *strtolPtr;
                index = strtoul(optarg, &strtolPtr, 10);
                if ((*optarg == '\0') || (*strtolPtr != '\0') || (index < 0))
                {
                    fprintf(stderr,
                            "option -i requires a numeric arg\n");
                    Usage(argv[0]);
                }
                break;
            }
            case 'f':   // Load keys from file
                keyPath = optarg;
                break;

            default:
                fprintf(stderr, "Unknown argument %s\n", argv[optind]);
                break;
        }
    }

    if (!configPath) {
        fprintf(stderr, "option -c is required\n");
        Usage(argv[0]);
    }

    if (index == -1) {
        fprintf(stderr, "option -i is required\n");
        Usage(argv[0]);
    }

    // Load configuration
    std::ifstream configStream(configPath);
    if (configStream.fail()) {
        fprintf(stderr, "unable to read configuration file: %s\n",
                configPath);
        Usage(argv[0]);
    }
    transport::Configuration config(configStream);

    if (index >= config.n) {
        fprintf(stderr, "replica index %d is out of bounds; "
                "only %d replicas defined\n", index, config.n);
        Usage(argv[0]);
    }

    UDPTransport transport(0.0, 0.0, 0);
    weakstore::Server *server;

    server = new weakstore::Server(config, index, &transport, new weakstore::Store());

    if (keyPath) {
        string key;
	std::ifstream in;
        in.open(keyPath);
        if (!in) {
            fprintf(stderr, "Could not read keys from: %s\n", keyPath);
            exit(0);
        }
        for (int i = 0; i < 100000; i++) {
            getline(in, key);
            server->Load(key, key);
        }
        in.close();
    }

    transport.Run();

    return 0;
}
