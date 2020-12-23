#!/bin/bash
##
## 此脚本用于自动化docker打包脚本（自建自用）
##
## 作者：袁振辉
## 时间：2020-12-4
##

# 获取当前目录地址
source_path=$(pwd)

# 获取项目地址
project_path=$(sed '/^project_path=/!d;s/.*=//' $source_path/dockerbuild_config.cnf)

# 获取jar包名称
jar_name=$(sed '/^jar_name=/!d;s/.*=//' $source_path/dockerbuild_config.cnf)

# 仓库url地址
registry_url=$(sed '/^registry_url=/!d;s/.*=//' $source_path/dockerbuild_config.cnf)

# dockerfile挂载输出
dockerfile_volume=$(sed '/^dockerfile_volume=/!d;s/.*=//' $source_path/dockerbuild_config.cnf)

# 切换到项目目录并进行maven编译
cd $project_path
mvn clean package -Dmaven.test.skip=true -e -U

# dockerfile地址
currect_path=$source_path/build_folder

if [ ! -d $currect_path ]; then
	mkdir -p $currect_path
fi

# 分解jar包名称获取到项目名称和版本信息
file_name=${jar_name%-*}
head_name=${jar_name#$file_name-}
version=${head_name%.jar*}

# 先删除所有文件再将jar包拷贝到目标目录
rm -rf $currect_path/* && cp -rf $project_path/target/$jar_name $currect_path && chmod 777 -R $currect_path

# 自动生成dockerfile这里使用的是adoptopenjdk
cat >$currect_path/Dockerfile <<END_TEXT
FROM adoptopenjdk/openjdk8-openj9:x86_64-centos-jdk8u-nightly
MAINTAINER yzh0623@gmail.com
VOLUME $dockerfile_volume
ADD $jar_name /usr/local/share
WORKDIR /usr/local/share/
ENTRYPOINT ["java","-jar","$jar_name","-XX:+UnlockExperimentalVMOptions","-XX:+UseCGroupMemoryLimitForHeap","-XX:MaxRAMFraction=1","-XX:+HeapDumpOnOutOfMemoryError","-cluster"]
END_TEXT

# 编写dockerignore避免上传多余的内容
cat >$currect_path/.dockerignore <<END_TEXT
# Ignore everything
**
# Allow $jar_name
!$jar_name
END_TEXT

# 先根据容器id删除容器
docker ps -aqf "name=$file_name" | while read containerid; do
	docker kill $containerid
	docker rm -f $containerid
done

# 切换到执行docker build目录并执行docker build创建镜像
cd $currect_path
docker build -f Dockerfile -t $file_name:$version .

# 镜像创建完成后上传到私有仓库
docker rmi -f $registry_url$file_name:$version
docker tag $file_name:$version $registry_url$file_name:$version
docker push $registry_url$file_name:$version

# 删除本地镜像
docker rmi -f $file_name:$version
