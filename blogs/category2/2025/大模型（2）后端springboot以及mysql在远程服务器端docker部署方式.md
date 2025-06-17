---
title: 大模型（2）后端springboot以及mysql在远程服务器端docker部署方式
date: 2025-05-17
tags:
 - 大模型
categories:
 -  大模型
---
# 1、springboot配置
## （1）配置application.yml文件
```properties
server:
  port: 8787
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://mysql:3306/mywx?useUnicode=true&characterEncoding=utf-8
    username: root
    password: 123456
  jackson:
    date-format: yyyy-MM-ss HH:mm:ss
    time-zone: GMT+8
accessFile:
  resourceHandler: /show/** #匹配需要拦截的URL
  location: /root/assest/vr1/  #本地文件夹
```
### application.yml解释
- **Server 端口号**: `8787`
- **MySQL 连接 URL**: `jdbc:mysql://mysql:3306/mywx?useUnicode=true&characterEncoding=utf-8` ，是因为我需要部署一个mysql:8.3.0的docker容器（后续可以看到），mysql:3306是我的容器name以及容器内部的端口号（不是宿主机的）
- **静态文件映射**: 通过 `WebMvcConfigurer` 配置 `/static/**` 映射到宿主机的 `/path/to/your/static/files/`### 配置 Server 端口号
将服务器的端口号设置为 `8787`。可以在应用程序的配置文件中进行设置，例如 `application.properties` 或 `application.yml`。

## （2）maven打包
在IDEA中打开右侧的maven，先双击clean清除原有target，再双击package打包springboot为jar包。如下图所示。
![请添加图片描述](/2025-deep2/1.png)
打包好的jar包如下图所示，把这个上传到服务器中
![请添加图片描述](/2025-deep2/2.png)

# 2、linux服务器部署mysql
***自定义 Docker 网络 + 容器名访问*** ：这种方式最优雅稳定，且适合多容器部署
## （1）创建一个 Docker 网络

创建一个名称为mywx_net的docker网络
```python
docker network create mywx_net
```
## （2）拉取mysql镜像
使用下面命令拉取mysql:8.3.0的镜像
```python
docker pull mysql:8.3.0
```
如果因为网络问题拉取不到，可以使用一个能拉取的电脑先把拉取到的mysql镜像打包为tar包

```bash
docker save -o mysql_8.3.0.tar  mysql:8.3.0
```

之后再放到服务器上并加载
```powershell
docker load < mysql_8.3.0.tar 
```

## （3）创建mysql容器

需要创建一个mysql的文件映射到mysql容器内部
```python
mkdir -p  /root/mysql/{conf,data,log}
```

编辑`/root/mysql/conf/my.cnf`，如下直接复制进去

```python
[client]
default-character-set=utf8mb4
[mysql]
default-character-set=utf8mb4
[mysqld]
server-id = 1
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
max_connections=1000
symbolic-links=0
default-time_zone = '+8:00'
```

创建 MySQL 容器，加入网络`mywx_net`  ，并挂载创建的`/root/mysql/{conf,data,log}`
```powershell
docker run -p 3307:3306 --restart=always \
  --network mywx_net  --name mysql \
  --privileged=true -v /root/mysql/log:/var/log/mysql \
  -v /root/mysql/data:/var/lib/mysql \
  -v /root/mysql/conf/my.cnf:/etc/mysql/my.cnf \
  -e MYSQL_ROOT_PASSWORD=123456 -d mysql:8.3.0  
```
注意！！！我的宿主机端口号设置为3307，application.yml中MySQL 连接 URL使用的3306，即docker内部的端口，==因此这个网络内部的端口号应该是不可以重复分配的（如果有误，请大佬指出）。==
## （4）mysql数据导入
我有一个mywx.sql文件，放到容器里面：

```python
docker cp mywx.sql 1e49b5459127:/home     # 1e49b5459127是要改成你自己mysql容器的id号码，不知道的可以使用docker ps自己看
docker  exec -it 1e49b5459127 /bin/bash   # 进入mysql容器内部
mysql -uroot -p123456  # 进入容器内部的mysql
Create database mywx;  # 创建一个mywx数据库
use mywx;              # 使用mywx数据库
source /home/mywx.sql  # 导入mywx.sql数据库文件
exit                   # 退出mysql
```


# 3、linux服务器部署springboot
## （1）Dockerfile编写
```javascript
# 使用官方Java镜像作为基础镜像
FROM openjdk:8-jre

# 设置工作目录为容器内部的 /root/emsys
WORKDIR /root/mywx

# 将当前目录下的jar文件复制到容器内部的 /root/emsys 目录
COPY mywx-0.0.1-SNAPSHOT.jar .

# 暴露容器运行时需要用到的端口，这里假设您的应用程序使用8083端口
EXPOSE 8787


# 运行jar文件，这里使用了 exec 形式的 CMD，以便可以对运行的容器发送停止信号
CMD ["sh", "-c", "java $JAVA_OPTS -jar mywx-0.0.1-SNAPSHOT.jar"]
```
### Dockerfile解释
- **jdk1.8版本的docker镜像**: `openjdk:8-jre` 
- **EXPOSE**: 容器端口号设置为`8787` ，请注意，此处的端口号与server的端口号都是*8787*

## （2）镜像和容器创建
请把jar包和Dockerfile放在同一目录，如下所示
![请添加图片描述](/2025-deep2/3.png)
1、创建镜像

```python
docker build -f ./Dockerfile -t mywx .
```
2、创建容器并加入`mywx_net` 网络
```python
docker run -id -p 8787:8787 --name mywx  -v /root/assest/vr1:/root/assest/vr1 --network mywx_net mywx
```
`-v /root/assest/vr1:/root/assest/vr1`：把宿主机的/root/assest/vr1映射到/root/assest/vr1，宿主机的路径可以在这里自适应，但是容器内的需要在application.yml中修改并重新打包和创建容器，如果你的宿主机文件目录是 `/xxx/assest/vr1`，只需要改成`-v /xxx/assest/vr1:/root/assest/vr1`即可。

# 4、结果验证
## （1）访问数据库
http://xxxxxxx:18418/users/list    xxxxxxx替换成自己的服务器ip,便可以看到服务得到的结果了。

![请添加图片描述](/2025-deep2/4.png)

由于我的服务器将*8787*端口映射到了*18418*，因此我在浏览器使用的*18418*端口号。

## （2）访问静态资源文件 
http://xxxxxxx:18418/show/glb/diban.glb    xxxxxxx替换成自己的服务器ip,便可以下载了。
![请添加图片描述](/2025-deep2/5.png)

