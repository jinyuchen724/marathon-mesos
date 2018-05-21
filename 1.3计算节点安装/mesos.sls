install_mesos_rpm:
  cmd.run:
    - names:
      - yum install mesos-1.3.0-2.0.3.x86_64 -y

config_mesos:
  cmd.run:
    - names:
      - echo "zk://ops-cd-mesos01:2181,ops-cd-mesos02:2181,ops-cd-mesos03:2181/mesos" > /etc/mesos/zk

colse_mesos_master:
  cmd.run:
    - names:
      - systemctl stop mesos-master.service
      - systemctl disable mesos-master.service
    - require:
      - cmd: config_mesos

set_hostname:
  cmd.run:
    - names:
      - echo "`hostname`.ops.com" > /etc/mesos-slave/hostname
      - echo "docker,mesos" > /etc/mesos-slave/containerizers
      - echo '5mins' > /etc/mesos-slave/executor_registration_timeout
    - require:
      - cmd: colse_mesos_master

start_mesos:
  cmd.run:
    - names:
      - systemctl enable mesos-slave
      - systemctl start mesos-slave
    - require:
      - cmd: set_hostname