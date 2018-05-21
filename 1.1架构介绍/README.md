| 版本   |   日期   |   状态  | 修订人    |    摘要   |
| ------ | ----- | ----- | ------- | ------ |
| V1.0  | 2018-04-17  | 创建  |  开源方案   |    初始版本  |


# 系统功能概述

- mesos 介绍

Apache Mesos能够在同样的集群机器上运行多种分布式系统类型，更加动态有效率低共享资源。
提供失败侦测，任务发布，任务跟踪，任务监控，低层次资源管理和细粒度的资源共享，可以扩展伸缩到数千个节点。 

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.1架构介绍/mesos_arch.png)

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.1架构介绍/mesos_architecture.png)

- Marathon 介绍

它是一个mesos框架，能够支持运行长服务，比如web应用等。
是集群的分布式Init.d，能够原样运行任何Linux二进制发布版本，如Tomcat Play等等，可以集群的多进程管理。
也是一种私有的Pass，实现服务的发现，为部署提供提供REST API服务，有授权和SSL、配置约束，通过HAProxy实现服务发现和负载平衡。 

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.1架构介绍/marathon_01.png)

这样，我们可以如同一台Linux主机一样管理数千台服务器，它们的对应原理如下图，
使用Marathon类似Linux主机内的init Systemd等外壳管理，而Mesos则不只包含一个Linux核，
可以调度数千台服务器的Linux核，实际是一个数据中心的内核： 

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.1架构介绍/marathon_02.png)

- chronos 介绍

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.1架构介绍/chronos.jpg)

Chronos本质上是cron-on-mesos,这是一个用来运行基于容器定时任务的Mesos框架。 

# 应用/系统拓扑图

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.1架构介绍/mesos_cluster.png)


上图: 是mesos marathon 集群架构图

整体架构采用MESOS+MARATHON+ZK 来保持高可用
服务发现和负载均衡使用marathon-lb 来实现，可以使用docker运行,也可使用vm跑或者物理机运行,统一使用marathon来进行应用管理
集群所有服务器配置统一使用saltstack进行配置管理
发布系统(CD)和marathon api 进行交互执行容器部署和常规应用部署 








