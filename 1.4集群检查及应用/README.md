# 检查 Mesos 集群部署情况

按照以上的安装和配置，一个高可用的Mesos和Marathon服务就搭建完成了。

- 可以通过http://masterip:5050来访问Mesos的web界面，
- 通过http://masterip:8080来访问Marathon的web界面。 

注意：访问可以是任意一个master节点的IP,界面中会显示当前Leader节点,如下图: 

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.4集群检查及应用/mesos-leader.jpg)

然后点击framework 就可以找到 Marathon 主节点,如下图:
 
![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.4集群检查及应用/marathon-leader.jpg)

点击红色框框 就能访问到Marathon 的web界面 如下图:

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.4集群检查及应用/marathon-app.jpg)

 几个配置启动参数的目录

/etc/mesos-master/
/etc/mesos-slave/
/etc/marathon/conf/ 

在这些目录分别用来配置mesos-master，mesos-slave，marathon的启动参数。以参数名为文件名，参数值为文件内容即可。 


# 安装服务发现 marathon-lb 服务

- 确认marathon-lb01/02 节点已经成功安装 mesos slave节点，并注册到mesos集群中 

- 下载marathon-lb docker镜像(2台服务器上都需要) 

```
[root@marathon-lb01 ~]#docker pull docker.io/mesosphere/marathon-lb
```

- 通过marathon部署marathon-lb(haproxy),应用描述json结构内容如下: 

```
[root@marathon-lb01 ~]# cat marathon-lb.json
  {
    "id": "marathon-lb",
    "cmd": null,
    "cpus": 2,
    "mem": 768,
    "disk": 0,
    "instances": 2,
    "constraints": [
      [
        "hostname",
        "LIKE",
        "marathon-master0[0-9].ops.com"
      ]
    ],
    "container": {
      "type": "DOCKER",
      "docker": {
        "image": "docker.io/mesosphere/marathon-lb",
        "privileged": true,
        "network": "HOST"
      },
      "volumes": []
    },
    "args": [
      "sse",
      "--marathon",
      "http://marathon-master01:8080",
      "--marathon",
      "http://marathon-master02:8080",
      "--marathon",
      "http://marathon-master03:8080",
      "--group",
      "external"
    ],
    "labels": {},
    "healthChecks": []
  }

```

重要参数说明:

SSE模式, marathon-lb连接到marathon的事件endpoint，app状态改变时收到通知,同时修改负载均衡

--group 参数是说明这个lb负载均衡的设备名称或者表示,后面再启动应用docker的时候会指定服务注册到那个lb设备的 

可以使用命令行或者web界面进行启动部署应用 

```
curl -i -H 'Content-Type: application/json' http://http://marathon-master01.ops.com:8080/v2/apps -d@marathon-lb.json
```

- marathon lb监控

查看9090端口，HAProxy统计

http://marathon-lb01.ops.com:9090/haproxy?stats

http://marathon-lb01.ops.com:9090/_haproxy_getconfig

内网环境将域名解析到lb上即可
lb              IN A 172.16.2.104
*.dev           IN CNAME lb
*.qaif          IN CNAME lb
*.qafc          IN CNAME lb
*.qaxn          IN CNAME lb
*.prod          IN CNAME lb

阿里云环境可以将marathonlb的节点接入到slb，然后将域名解析到slb上即可。

- 首先在后端服务器添加部署lb节点的服务器

- 添加监听端口，然后将域名解析到slb上即可，对应的marathon上HAPROXY_0_VHOST填入对应的域名即可

```
{
  "id": "/logio-server",
  "cmd": "/home/logio/run.sh",
  "cpus": 0.5,
  "mem": 1024,
  "disk": 0,
  "instances": 1,
  "constraints": [
    [
      "hostname",
      "CLUSTER",
      "marathon-slave01.ops.com"
    ]
  ],
  "container": {
    "type": "DOCKER",
    "volumes": [],
    "docker": {
      "image": "logio-server",
      "network": "HOST",
      "portMappings": [],
      "privileged": false,
      "parameters": [],
      "forcePullImage": false
    }
  },
  "labels": {
    "HAPROXY_GROUP": "external",
    "HAPROXY_0_VHOST": "logtest.yiqiguang.com"
  },
  "portDefinitions": [
    {
      "port": 10004,
      "protocol": "tcp",
      "name": "default",
      "labels": {}
    }
  ]
}
```


