---
title: 大模型（2）后端springboot以及mysql在远程服务器端docker部署方式
date: 2025-05-17
tags:
  - 大模型
  - docker
  - springboot
  - mysql
categories:
  - 大模型
---

本文介绍如何将 SpringBoot 后端项目与 MySQL 数据库，通过 Docker 部署到远程 Linux 服务器上，采用「自定义 Docker 网络 + 容器名访问」的方式实现容器间通信，是大模型系列项目的后端部署篇。

## 一、SpringBoot 配置

### 1、配置 application.yml 文件

```yaml
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
  resourceHandler: /show/**   # 匹配需要拦截的URL
  location: /root/assest/vr1/ # 本地文件夹
```

::: tip 关键配置说明
- `server.port`：服务端口设置为 `8787`
- `spring.datasource.url`：连接地址中 `mysql` 是 Docker 容器名，`3306` 是容器内部端口（非宿主机端口）
- `accessFile.resourceHandler`：静态文件 URL 拦截规则 `/show/**`
- `accessFile.location`：宿主机静态文件目录 `/root/assest/vr1/`
:::

::: warning 注意
MySQL 连接 URL 中使用的是容器名 `mysql` 而非 IP，这是自定义 Docker 网络容器间通信的关键所在。
:::

### 2、Maven 打包

在 IDEA 中操作步骤：

1. 打开右侧 **Maven** 面板
2. 双击 `clean` 清除原有 target 目录
3. 双击 `package` 将 SpringBoot 打包为 jar 包
4. 将生成的 jar 包上传到服务器

![Maven 面板操作截图](/2-springboot-docker/01-maven-package.png)

![打包好的 jar 包](/2-springboot-docker/02-jar-file.png)

## 二、Linux 服务器部署 MySQL

::: tip 部署策略
采用「自定义 Docker 网络 + 容器名访问」方式，该方式最优雅稳定，适合多容器协同部署。
:::

### 1、创建 Docker 网络

创建名为 `mywx_net` 的自定义 Docker 网络：

```bash
docker network create mywx_net
```

### 2、拉取 MySQL 镜像

```bash
docker pull mysql:8.3.0
```

若因网络问题无法直接拉取，可使用离线方式：

```bash
# 在能联网的机器上打包镜像
docker save -o mysql_8.3.0.tar mysql:8.3.0

# 上传到服务器后加载镜像
docker load < mysql_8.3.0.tar
```

### 3、创建 MySQL 容器

**第一步：创建宿主机挂载目录**

```bash
mkdir -p /root/mysql/{conf,data,log}
```

**第二步：编辑 MySQL 配置文件** `/root/mysql/conf/my.cnf`

```ini
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

**第三步：创建并启动 MySQL 容器**

```bash
docker run -p 3307:3306 --restart=always \
  --network mywx_net --name mysql \
  --privileged=true -v /root/mysql/log:/var/log/mysql \
  -v /root/mysql/data:/var/lib/mysql \
  -v /root/mysql/conf/my.cnf:/etc/mysql/my.cnf \
  -e MYSQL_ROOT_PASSWORD=123456 -d mysql:8.3.0
```

| 参数 | 说明 |
|------|------|
| `-p 3307:3306` | 宿主机端口 `3307` 映射容器内部端口 `3306` |
| `--network mywx_net` | 加入自定义网络 |
| `--name mysql` | 容器名称为 `mysql`（与 application.yml 中 URL 对应） |
| `--restart=always` | 容器自动重启 |
| `--privileged=true` | 赋予容器特权 |
| `-v` 挂载 | 分别挂载 log、data、conf 目录 |
| `-e MYSQL_ROOT_PASSWORD` | 设置 root 密码为 `123456` |

::: warning 注意
宿主机端口为 `3307`，application.yml 中使用的 `3306` 是容器内部端口，两者不冲突。
:::

### 4、MySQL 数据导入

```bash
# 将 sql 文件复制到容器内部（容器ID可通过 docker ps 查看）
docker cp mywx.sql 1e49b5459127:/home

# 进入 mysql 容器内部
docker exec -it 1e49b5459127 /bin/bash

# 进入 MySQL 命令行
mysql -uroot -p123456

# 创建数据库
CREATE DATABASE mywx;

# 切换到目标数据库
USE mywx;

# 导入 SQL 文件
source /home/mywx.sql

# 退出
exit
```

## 三、Linux 服务器部署 SpringBoot

### 1、编写 Dockerfile

在服务器上与 jar 包同目录下创建 `Dockerfile` 文件：

```dockerfile
# 使用官方 Java 镜像作为基础镜像
FROM openjdk:8-jre

# 设置工作目录
WORKDIR /root/mywx

# 将 jar 文件复制到容器工作目录
COPY mywx-0.0.1-SNAPSHOT.jar .

# 暴露端口
EXPOSE 8787

# 运行 jar 文件
CMD ["sh", "-c", "java $JAVA_OPTS -jar mywx-0.0.1-SNAPSHOT.jar"]
```

| 指令 | 说明 |
|------|------|
| `FROM openjdk:8-jre` | 基础镜像使用 JDK 1.8 |
| `WORKDIR /root/mywx` | 容器内工作目录 |
| `COPY mywx-0.0.1-SNAPSHOT.jar .` | 将 jar 包复制到工作目录 |
| `EXPOSE 8787` | 暴露端口，与 `server.port` 一致 |
| `CMD` | 启动命令，支持 `$JAVA_OPTS` 环境变量传参 |

### 2、构建镜像并创建容器

将 jar 包和 Dockerfile 放在服务器的同一目录下：

![服务器目录截图](/2-springboot-docker/03-server-dir.png)

**第一步：构建镜像**

```bash
docker build -f ./Dockerfile -t mywx .
```

**第二步：创建容器并加入网络**

```bash
docker run -id -p 8787:8787 --name mywx \
  -v /root/assest/vr1:/root/assest/vr1 \
  --network mywx_net mywx
```

| 参数 | 说明 |
|------|------|
| `-p 8787:8787` | 宿主机与容器端口均为 `8787` |
| `--name mywx` | 容器名称 |
| `-v /root/assest/vr1:/root/assest/vr1` | 静态资源目录挂载（宿主机路径:容器路径） |
| `--network mywx_net` | 加入与 MySQL 相同的网络，实现容器间通信 |

::: tip 灵活挂载说明
若宿主机静态文件目录不同，只需修改 `-v` 左侧路径，例如：`-v /xxx/assest/vr1:/root/assest/vr1`。容器内路径需与 application.yml 中 `accessFile.location` 保持一致。
:::

## 四、结果验证

### 1、访问数据库接口

```
http://服务器IP:18418/users/list
```

返回 JSON 数据说明后端与数据库连通正常。

![访问数据库接口返回结果](/2-springboot-docker/04-api-result.png)

::: tip 端口说明
本示例中服务器将内部 `8787` 端口映射到了对外 `18418` 端口，因此浏览器使用 `18418` 访问。
:::

### 2、访问静态资源文件

```
http://服务器IP:18418/show/glb/diban.glb
```

浏览器触发文件下载，说明静态资源挂载配置生效。

![访问静态资源文件结果](/2-springboot-docker/05-static-file.png)

## 五、整体架构总结

```
浏览器/客户端
     │
     │ HTTP 请求（18418 端口）
     ▼
宿主机（端口映射 18418 → 8787）
     │
     ▼
┌─────────────────────────────────┐
│        Docker 网络: mywx_net    │
│                                 │
│  ┌──────────────┐               │
│  │  SpringBoot  │               │
│  │  容器: mywx  │               │
│  │  端口: 8787  │               │
│  └──────┬───────┘               │
│         │ jdbc:mysql://mysql:3306│
│         ▼                       │
│  ┌──────────────┐               │
│  │  MySQL 容器  │               │
│  │  name: mysql │               │
│  │  内部: 3306  │               │
│  │  外部: 3307  │               │
│  └──────────────┘               │
└─────────────────────────────────┘
```

::: tip 核心要点
两个容器通过同一个自定义 Docker 网络 `mywx_net` 互联，SpringBoot 通过容器名 `mysql` 直接访问数据库，无需关心宿主机端口映射，部署方式优雅且稳定。
:::
