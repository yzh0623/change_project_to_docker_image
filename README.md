# ChangeProject2DockerImage
脚本使用maven打包，并将动态生成dockerfile将jar包打包成docker镜像提交到本地docker仓库中

##### 脚本信息
1. 本脚本为Vert.x项目的Docker镜像自动打包脚本，动态生成的dockerfile中将使用Vert.x集群模式指令
2. dockerfile中使用的jdk为`adoptopenjdk/openjdk8-openj9:x86_64-centos-jdk8u-nightly`


##### 配置信息
不同项目在使用的时候一般只需要修改project_path和jar_name就可以，而registry_url和dockerfile_volume只需要修改一次就可以了（毕竟这些内容不会经常变动）

```
##
##
## 本配置文件为自动创建docker镜像配置（自建自用）
## 
## 作者：yuanzhenhui
## 时间：2020-12-4
##

# 项目路径
project_path=/Users/yuanzhenhui/Documents/code_space/vertx/phw2-hb-vtx

# jar包的存放路径
jar_name=phw2-hb-vtx-prod-2.0.1.jar

# 仓库url（不需要改除非ip地址经过修改）
registry_url=192.168.100.167:5000/yzh/

# volume路径（不需要改）
dockerfile_volume=/Users/yuanzhenhui/Documents/document_file/tmp/other
```
