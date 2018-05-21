| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## 部署主机角色说明

| 主机角色 | IP地址 |   系统版本 |  软件 |
| ------    | ------  |   ------  | ------ |
| 管理节点(Master)  | marathon-master01(172.22.1.50) | CentOS Linux release 7.3.1611 (Core) x86_64  | master + zk | 
| 管理节点(Master)  | marathon-master02(172.22.1.51) | CentOS Linux release 7.3.1611 (Core) x86_64  | master + zk | 
| 管理节点(Master)  | marathon-master03(172.22.1.52) | CentOS Linux release 7.3.1611 (Core) x86_64  | master + zk | 

# 软件环境及版本

```
jdk1.8
mesosphere-zookeeper-3.4.6-0.1.20141204175332.centos7.x86_64
mesos-1.3.0-2.0.3.x86_64
marathon-1.4.5-1.0.654.el7.x86_64
```

## 安装前基础环境检查
### 配置仓库源(如果自己建立本地源 直接跳过本步骤)

- 安装rpm仓库

```
[root@marathon-master01 ~]# yum install  http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm -y
[root@marathon-master01 ~]# yum install mesos-1.3.0-2.0.3.x86_64 marathon-1.4.5-1.0.654.el7.x86_64 chronos mesosphere-zookeeper-3.4.6-0.1.20141204175332.centos7.x86_64 -y
```

- zookeeper配置

每个master节点设置不同的myid值 /var/lib/zookeeper/myid ,假设第一个节点 

```
[root@marathon-master01 zookeeper]# echo "1" > /var/lib/zookeeper/myid
```

注意: myid中值范围是 1到255,需要注意的是，每个节点的myid不要重复,这里将3个master节点的myid分别设置为：1,2,3


- 每个master节点设置zoo.cfg

在配置文件/etc/zookeeper/conf/zoo.cfg中最后加入下面内容： 
```
server.1=marathon-master01:2888:3888
server.2=marathon-master02:2888:3888
server.3=marathon-master03:2888:3888
```

- 启动zookeeper服务 

```
[root@marathon-master01 ~]#systemctl enable zookeeper
[root@marathon-master01 ~]#systemctl start zookeeper
```

# Mesos Master 配置

- 每个master节点的/etc/mesos/zk配置文件中设置zk的地址

```
[root@marathon-master01 ~]#echo "zk://marathon-master01:2181,marathon-master02:2181,marathon-master03:2181/mesos" > /etc/mesos/zk
```

- 配置quorum
/etc/mesos-master/quorum中设置quorum值,这个值要大于master数/2，这里master数为3，则要设为2 
```
[root@marathon-master01 ~]#echo "2" > /etc/mesos-master/quorum
```


- 停掉mesos-slave

```
[root@marathon-master01 ~]#systemctl stop mesos-slave.service
[root@marathon-master01 ~]#systemctl disable mesos-slave.service
```

- 设置hostname

设置mesos master 主机名(如果dns能够解析，而且主机名必须是fqdn,就不用了),每台master 设置自己的主机名
目前我们的主机名不是FQDN,hostname 输出是短名(ops-cd-mesos01),浏览器无法解析,所以必须设置主机名 
```
[root@marathon-master01 ~]#echo "marathon-master01.ops.com" > /etc/mesos-master/hostname
```

- 启动mesos-master 

```
[root@marathon-master01 ~]#systemctl enable mesos-master
[root@marathon-master01 ~]#systemctl restart mesos-master
```

- marathon配置

- 首先，创建下他的配置文件的路径(yum装的没给我们创建) 

```
[root@marathon-master01 ~]#mkdir -p /etc/marathon/conf
```

- 主机名, 把mesos的直接拷过来 

```
[root@marathon-master01 ~]#cp /etc/mesos-master/hostname /etc/marathon/conf
```  

- 配置marathon自己的zk，另外还需要连接mesos自己的，因为需要过去调度任务呀

```
[root@marathon-master01 ~]#echo "zk://marathon-master01:2181,marathon-master02:2181,marathon-master03:2181/mesos" > /etc/marathon/conf/master
[root@marathon-master01 ~]#echo "zk://marathon-master01:2181,marathon-master02:2181,marathon-master03:2181/marathon" > /etc/marathon/conf/zk
```  

- 事件订阅模式开启(为了marathonlb获取回调信息)

```
[root@marathon-master01 ~]#echo "http_callback" > /etc/marathon/conf/event_subscriber
```   

- 启动mesos-master marathon   

```
[root@marathon-master01 ~]#systemctl enable marathon
[root@marathon-master01 ~]#systemctl restart marathon
``` 

- chronos配置

- 端口配置

```
[root@marathon-master01 ~]#cat /etc/chronos/conf/http_port
4400
```

- 主机名, 把mesos的直接拷过来

```
[root@marathon-master01 ~]#cp /etc/mesos-master/hostname /etc/chronos/conf
```

- 配置mesos的zk地址，需要过去调度任务

```
[root@marathon-master01 ~]#echo "zk://ops-cd-mesos01:2181,ops-cd-mesos02:2181,ops-cd-mesos03:2181/mesos" > /etc/chronos/conf/master
```

- 启动chronos

```
[root@marathon-master01 ~]#systemctl enable chronos
[root@marathon-master01 ~]#systemctl start chronos
```

- 添加一个定时任务 

- "schedule": "R/2014-03-08T20:00:00.000Z/PT3H", PT3H每3小时运行一次crontab 

- "epsilon":"PT1H" 如果任务失败 1小时候重试运行 任务 

具体请参考 https://mesos.github.io/chronos/docs/api.html#adding-a-scheduled-job

```
[root@marathon-master01 ~]#curl -H 'Content-Type: application/json' -X POST  http://ops-cd-mesos02.sysadmin.xinguangnet.com:4400/scheduler/iso8601 -d '{
    "name": "cmdb_sync",
    "owner": "chenjy@xinguangnet.com",
    "ownerName": "陈金宇",
    "description": "cmdb从saltstack api同步数据定时任务",
    "command": "python /opt/cmdb_sync/salt-api.py >> /tmp/cmdb_sync.log 2>&1",
    "schedule": "R/2014-03-08T20:00:00.000Z/PT3H",
    "epsilon":"PT1H",
    "constraints": ["hostname",.ops.com"]]
  }'
```

注意: 任务提交成功后,如果通过界面修改任务信息，会造成 constraints 信息丢失,所以最好通过API 方式进行任务信息更新
