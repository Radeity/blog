---
title: Hadoop伪分布式环境搭建（MacOS）
date: 2021-08-01
tags:
 - Hadoop
sidebar: auto
categories:
 -  大数据
---
**搭建环境前需要先了解一下Hadoop的分布式系统基础架构**
## Hadoop —— 分布式系统基础架构

主要解决：海量数据存储及分析计算问题

**Hadoop四优势：**

- 高可靠性：集群维护多个数据副本

- 高扩展性：可以动态扩展（增加服务器数量）
- 高效性：并性工作
- 高容错性：能够自动将失败的任务重新分配

********

### HDFS （Hadoop分布式文件系统）

- NameNode(nn): 存储文件的**元数据**，如**文件名，文件目录结构，文件属性**(生成时间、副本数、文件权限)，以及每个文件的**块列表**和**块**所在的**DataNode**等。

- DataNode(dn): 在本地文件系统**存储文件块数据**，以及**块数据的校验和**。

- Secondary NameNode(2nn): **每隔一段时间对NameNode元数据备份**。



### Yarn（资源协调者）

- ResourceManager(RM): 整个集群资源(内存、CPU等)的老大

- NodeManager(NM): 单个节点服务器资源老大

- ApplicationMaster(AM): 单个任务运行的老大

- Container: 容器，相当一台独立的服务器，里面封装了任务运行所需要的资源，如内存、CPU、磁盘、网络等。

  **将一个任务放在一个容器中，任务执行完毕后可以直接释放容器中的资源。**

#### 一个任务的资源调度流程：

1. 客户端向RM提交一个任务

2. RM在集群调度某个NM开启一个容器运行AM

3. AM向RM申请该任务执行所需要的资源

4. RM从集群中给AM分配资源，资源不一定在AM所在节点

5. AM利用资源执行任务，若更改DataNode需要NameNode进行记录

6. 任务执行完毕后释放任务相关资源

*******

##  Hadoop伪分布式环境搭建--MacOS（从零开始的记录）

> 操作系统：MacOS Catalina 10.15.7
>
> 内存：16GB

Hadoop 支持的运行模式包括:本地模式、伪分布式模式以及完全分布式模式。

#### 首先从阅读[官方文档][https://hadoop.apache.org/docs/r3.3.1/hadoop-project-dist/hadoop-common/SingleCluster.html]开始！

官方文档中写到Hadoop支持的平台有Linux和Windows，虽然没写MacOS，但MacOS是类Linux系统，我们在此尝试一下，（可能会出错）。

Hadoop3.3向上兼容JAVA8和JAVA11，之前安装过JAVA8，这里可以直接使用。另外一个需要安装的是ssh，用于远程会话，MacOS自带，跳过。也可以再检查一下自己的系统中是否有ssh和sshd，终端执行：

```bash
$ which ssh
$ which sshd
```

接下来需要下载一个Hadoop的发行版本，我选择了最新的**Hadoop-3.3.1**，下载 对应版本tar.gz文件，解压到新建的～/hadoop目录下，MacOS解压tar.gz命令：

```bash
$ tar -zxvf hadoop-3.3.1.tar.gz
```



#### 接下来根据官方文档修改一些配置文件。

修改etc/hadoop/hadoop-env.sh（查询添加JAVA的环境变量）

```bash
$ echo ${JAVA_HOME}
$ vim etc/hadoop/hadoop-env.sh

修改：
export JAVA_HOME = 你的JAVA环境变量
```

配置Hadoop单机节点运行的伪分布式模式，进入我们的Hadoop目录，以下所有操作的根目录都是如下的Hadoop目录。

```bash
$ cd ～/hadoop/hadoop-3.3.1
```

修改核心配置文件 etc/hadoop/core-site.xml：

```xml
<configuration>
  	<!-- 指定 Hadoop 数据的存储目录 -->
		<property>
				<name>hadoop.tmp.dir</name>
				<value>/User/XXX/hadoop/hadoop-3.3.1/data</value>
		</property>

		<!-- 指定 NameNode 的地址 -->
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
```

修改HDFS 配置文件 etc/hadoop/hdfs-site.xml：

```xml
<configuration>
    <!-- 缺省的块复制数量 -->
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
  	<!-- nn web端访问地址--> 
  	<property>
				<name>dfs.namenode.http-address</name>
				<value>localhost:50070</value> 
  	</property>
		<!-- 2nn web 端访问地址--> 
  	<property>
				<name>dfs.namenode.secondary.http-address</name>
				<value>localhost:50090</value> 
  	</property>
    <!-- 数据存储位置，多个目录用英文逗号隔开 -->
  	<property>
        <name>dfs.namenode.name.dir</name>
      <value>file:/Users/XXX/hadoop/hadoop-3.3.1/data/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:/Users/XXX/hadoop/hadoop-3.3.1/data/datanode</value>
    </property>    
</configuration>
```

修改YARN 配置文件 etc/hadoop/yarn-site.xml：

```bash
$ hadoop classpath
```

```xml
<configuration>
		<!-- 指定 MR 走 shuffle --> 
  	<property>
				<name>yarn.nodemanager.aux-services</name>
				<value>mapreduce_shuffle</value> 
  	</property>
		<!-- 指定 ResourceManager 访问地址--> 
  	<property>
				<name>yarn.resourcemanager.hostname</name>
				<value>master</value> 
  	</property>
    <property>
        <name>yarn.application.classpath</name>
        <value>输入刚才返回的Hadoop classpath路径</value>
    </property>
</configuration>
```

修改MapReduce 配置文件 etc/hadoop/mapred-site.xml：

```xml
<configuration>
  <!-- 指定 MapReduce 程序运行在 Yarn 上 --> 
	<property>
			<name>mapreduce.framework.name</name>
 			<value>yarn</value>
   </property>
   <!-- 设置历史任务的主机和端口 -->
   <property>
     	<name>mapreduce.jobhistory.address</name>
      <value>localhost:10020</value>
   </property>
   <!-- 设置网页端的历史任务的主机和端口 -->
   <property>
      <name>mapreduce.jobhistory.webapp.address</name>
      <value>localhost:19080</value>
   </property>
</configuration>
```



#### 配置Hadoop环境变量

```bash
$ vim ~/.bash_profile

# 添加环境变量
export HADOOP_HOME=~/hadoop/hadoop-3.3.1
export PATH=$PATH:HADOOP_HOME/sbin:$HADOOP_HOME/bin

export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native:$HADOOP_COMMON_LIB_NATIVE_DIR"
```

修改完环境变量不要忘记source一下

测试Hadoop环境是否配置成功

```bash
$ hadoop version
```

另外，ssh每次试图连接localhost都会对身份进行验证检查，因此需要确认能否无密码ssh连接localhost，尝试：

```bash
$ ssh localhost
```

若不能，则需配置无密码连接

```bash
$ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```



#### 启动Hadoop集群

1. 首次启动HDFS需要格式化NameNode

```bash
 $ bin/hdfs namenode -format
```

2. 启动HDFS

```bash
$ sbin/start-dfs.sh
```

3. 启动Yarn

```bash
$ sbin/start-yarn.sh
```

也可以一次性开启全部Hadoop的守护进程

```bash
$ sbin/start-all.sh 
```

同理关闭全部守护进程

```bash
 $ sbin/stop-dfs.sh
```

4. 启动查看程序历史运行情况的历史服务器

```bash
$ sbin/mr-jobhistory-daemon.sh start historyserver # 启动历史服务器
$ sbin/mr-jobhistory-daemon.sh stop historyserver  # 关闭历史服务器
```

5. jps查看当前运行的守护进程

```bash
$ jps

85393 Jps
85376 JobHistoryServer
84866 NodeManager
84436 DataNode
84332 NameNode
84767 ResourceManager
84575 SecondaryNameNode
```

6. 查看集群的web页面

   - NameNode: http://localhost:50070

   - Secondary NameNode: http://localhost:50090

   - DataNode: 在NameNode中查看到当前有一个默认的DataNode节点在

     http://localhost:9864/datanode.html

   - Yarn: http://localhost:8088

   - HistoryServer: http://localhost:19080



#### 检查本地库

通过查看本地库来检查当前Hadoop环境支持的压缩方式

```bash
$ hadoop checknative -a

2021-08-05 11:09:11,047 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable

Native library checking:
hadoop:  false
zlib:    false
zstd  :  false
bzip2:   false
openssl: false
ISA-L:   false
PMDK:    false
```

官网的压缩包中不包含这些本地库，如果有需要可以自己去编译生成本地库放到lib/native目录下。
编译本地库参考链接：https://zhuanlan.zhihu.com/p/112307334；https://www.cnblogs.com/shoufeng/p/14942271.html



## 爬坑记录

1. 首次格式化NameNode时格式化出错，下面为日志中的报错信息：

```bash
2021-08-04 22:06:50,934 ERROR namenode.NameNode: Failed to start namenode.
java.lang.IllegalArgumentException: URI has an authority component
	at java.io.File.<init>(File.java:423)
	at org.apache.hadoop.hdfs.server.namenode.NNStorage.getStorageDirectory(NNStorage.java:353)
	at org.apache.hadoop.hdfs.server.namenode.FSEditLog.initJournals(FSEditLog.java:290)
	at org.apache.hadoop.hdfs.server.namenode.FSEditLog.initJournalsForWrite(FSEditLog.java:261)
	at org.apache.hadoop.hdfs.server.namenode.NameNode.format(NameNode.java:1255)
	at org.apache.hadoop.hdfs.server.namenode.NameNode.createNameNode(NameNode.java:1724)
	at org.apache.hadoop.hdfs.server.namenode.NameNode.main(NameNode.java:1832)
```

看到报错信息察觉到之前犯了一个很愚蠢的错误，配置文件中很多配置的目录都用了～，HOME目录对应的应该是/User/XXX，终端中显示为～，因此要把所有配置文件中的～替换成/User/XXX。

修改后重新进行格式化，日志中出现如下日志信息则格式化成功：

```bash
2021-08-04 22:35:35,622 INFO common.Storage: Storage directory /Users/wangweirao/hadoop/hadoop-3.3.1/data/namenode has been successfully formatted.
```

2. 之前没配置免密登陆启动时报错：

```bash
Permission denied (publickey,password,keyboard-interactive).
```

3. 运行示例wordcount程序报错

```bash 
错误: 找不到或无法加载主类org.apache.hadoop.mapreduce.v2.app.MRAppMaster
```

在yarn配置文件中添加yarn.application.classpath属性



**至此，Hadoop伪分布式的基本环境就配置完成了，如果需要配置真实的分布式环境，可以开三台虚拟机进行实验，之后还会进行进一步的Hadoop学习分享！**