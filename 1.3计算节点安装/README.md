| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


## 部署主机角色说明

| 主机角色 | IP地址 | 
| ---      | -----| 
| marathon-lb01(slave) | marathon-lb01（172.22.1.54） |
| marathon-lb02(slave) | marathon-lb02（172.22.1.55） |
| marathon-slave（slave) | marathon-slave（172.22.1.53） |

## 安装node节点(计算节点)

# Mesos Slave节点安装和配置

- 安装rpm仓库

```
[root@marathon-slave01 ~]#yum install  http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm -y
[root@marathon-slave01 ~]#yum install mesos-1.3.0-2.0.3.x86_64 -y
```

- mesos-slave配置

在/etc/mesos/zk中设置zk的地址,这里的zk地址就是master节点所使用的同一套zookeeper服务的地址。

```
[root@marathon-slave01 ~]#echo "zk://marathon-master01:2181,marathon-master02:2181,marathon-master03:2181/mesos" > /etc/mesos/zk
```

- 关闭mesos-master服务

```
[root@marathon-slave01 ~]#systemctl stop mesos-master.service
[root@marathon-slave01 ~]#systemctl disable mesos-master.service
```

- 配置主机名,每个slave节点配置自己的主机名,原理同mesos master一样
```
[root@marathon-slave01 ~]#echo "marathon-slave01.ops.com" >/etc/mesos-slave/hostname
```

注意：其他Mesos slave 节点参考设置成自己的主机名 

配置slave 使用docker (使用docker,需要在salve机器上安装并启动docker服务)

```
[root@marathon-slave01 ~]#echo "docker,mesos" > /etc/mesos-slave/containerizers
```

考虑到拉取容器镜像等的操作，适当增加timeout的时间(可选配置)
```
[root@marathon-slave01 ~]#echo '5mins' > /etc/mesos-slave/executor_registration_timeout
```

- 安装docker软件包

```
[root@marathon-slave01 ~]#yum install docker -y
[root@marathon-slave01 ~]#systemctl enable docker
[root@marathon-slave01 ~]#systemctl start docker
```
    
- 启动mesos-slave服务

```
[root@marathon-slave01 ~]#systemctl enable mesos-slave
[root@marathon-slave01 ~]#systemctl start mesos-slave
```
