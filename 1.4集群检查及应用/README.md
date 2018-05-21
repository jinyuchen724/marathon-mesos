# 检查 Mesos 集群部署情况

按照以上的安装和配置，一个高可用的Mesos和Marathon服务就搭建完成了。

- 可以通过http://masterip:5050来访问Mesos的web界面，
- 通过http://masterip:8080来访问Marathon的web界面。 

注意：访问可以是任意一个master节点的IP,界面中会显示当前Leader节点,如下图所示: 

![image](https://github.com/jinyuchen724/marathon-mesos/raw/master/1.4集群检查及应用/mesos-leader.jpg)
