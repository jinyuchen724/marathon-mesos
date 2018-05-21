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

```
/etc/mesos-master/
/etc/mesos-slave/
/etc/marathon/conf/ 
```
在这些目录分别用来配置mesos-master，mesos-slave，marathon的启动参数。以参数名为文件名，参数值为文件内容即可。 


# 安装服务发现 marathon-lb 服务

- 确认marathon-lb01/02 节点已经成功安装 mesos slave节点，并注册到mesos集群中 

- 下载marathon-lb docker镜像(2台服务器上都需要) 

```
[root@marathon-lb01 ~]#docker pull docker.io/mesosphere/marathon-lb
```

- 通过marathon部署marathon-lb(haproxy),应用描述 json结构内容如下: 

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
        "ops-cd-lb0[1-2].sysadmin.xinguangnet.com"
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
      "http://ops-cd-mesos01:8080",
      "--marathon",
      "http://ops-cd-mesos02:8080",
      "--marathon",
      "http://ops-cd-mesos03:8080",
      "--group",
      "external"
    ],
    "labels": {},
    "healthChecks": []
  }

```









