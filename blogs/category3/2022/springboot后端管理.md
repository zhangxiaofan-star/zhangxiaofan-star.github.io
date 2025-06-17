---
title: springboot后端管理
date: 2022-06-16
tags:
 - Web
categories:
 -  Web
---

# springboot后端管理
## 配置maven
链接: [https://maven.apache.org/download.cgi](https://maven.apache.org/download.cgi)
1、在maven官网上下载maven就可以了，无脑安装
![请添加图片描述](/1-springboot/1.png)

2、创建一个空的repository文件夹，后续需要用到
![请添加图片描述](/1-springboot/2.jpeg)



3、配置setting.xml文件（阿里源镜像）
找到mirrors，然后将下面的代码替换原有的mirrors
```
<mirrors>
    <!-- mirror
     | Specifies a repository mirror site to use instead of a given repository. The repository that
     | this mirror serves has an ID that matches the mirrorOf element of this mirror. IDs are used
     | for inheritance and direct lookup purposes, and must be unique across the set of mirrors.
     |
    <mirror>
      <id>mirrorId</id>
      <mirrorOf>repositoryId</mirrorOf>
      <name>Human Readable Name for this Mirror.</name>
      <url>http://my.repository.com/repo/path</url>
    </mirror>
     -->
     <mirror>
         <id>nexus-aliyun</id>
        <mirrorOf>*</mirrorOf>
        <name>Nexus aliyun</name>
         <url>http://maven.aliyun.com/nexus/content/groups/public</url>
      </mirror> 
 
  </mirrors>
```
## 创建springboot项目

1、先创建springboot项目
![请添加图片描述](/1-springboot/3.png)

2、添加插件和依赖
![请添加图片描述](/1-springboot/4.png)

3、配置maven
点击file->settings-> Build, Execution, Deployment->Build Tools->Maven
![请添加图片描述](/1-springboot/5.png)

4、maven配置好之后，由于我的是已经下载好的资源，所以就会自动加载出来的，如果是第一次就需要点击test（项目名）reload project一下慢慢等待就可以了
![请添加图片描述](/1-springboot/6.png)

## mvc框架
   MVC思想，MVC思想将一个应用分成三个基本部分：Model（模型）、View（视图）和Controller（控制器），这三个部分以最少的耦合协同工作，从而提高应用的可扩展性及可维护性。
  而此设计拓展了此思想且分为控制层（controller）、服务层（service）、视图层（vo，==由于方便初学者学习，此项目不使用VO层==）、实体层（entity)、数据持久层（mapper）。前端需要请求服务的时候，便请求控制器的API，控制器会把这个请求转交给对应的服务层进行服务，服务层对所请求的需求进行处理，通过利用数据持久层所生成的SQL语句从数据库增删改查数据，并返回给前端。
![请添加图片描述](/1-springboot/7.png)


1、首先创建下面四个包![请添加图片描述](/1-springboot/8.png)

后续等更新啦
