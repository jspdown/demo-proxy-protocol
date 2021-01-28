# Proxy protocol version

Traefik v2.4 improves the support of Proxy Protocol. Before this version, entrypoint could be configured to read the Proxy Protocol header but this information was not transfered to the backend service. Therefore, the backend couldn't see the real client IP.

In this new version we are capable of configuring Proxy Protocol also on backend services. It means we can now transparently transfer the Proxy Protocol header and carry the real client IP, end to end.

## Demo

This demo shows how the client IP can be preserved through 2 layers of proxies.

```
                                         
  Proxy 1  ->  Proxy 2 -> Backend 
|__________  |____________________|
    Host          Kubernetes

```

In this demo, both proxies are Traefik proxies but since Traefik supports Proxy Protocol v1 and v2, it could be replaced by any other proxy on the market supporting Proxy Protocol.

The client opens a TCP connection with the first proxy. The first proxy proxies the connection to the second proxy which proxies it to the backend. The backend is expected to see the real client IP.

```
# Start the first proxy
$> ./demo.sh proxy1
# Start the second proxy
$> ./demo.sh proxy2

$> nc 127.0.0.1 9000
WHO
Proxy Protocol Version: 2
Proxy Protocol Source: 90.119.200.63:40366
Proxy Protocol Destination: 192.168.1.13:9000
Hostname: backend
IP: 127.0.0.1
IP: ::1
IP: 10.42.0.4
IP: fe80::f807:8fff:fe5e:87fa
```

