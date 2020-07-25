#!/bin/bash

#export BUILD_ID=dontKillMe这一句很重要，这样指定了，项目启动之后才不会被Jenkins杀掉。
export BUILD_ID=dontKillMe

jar_path=${1}
jar_name=${2}
spring_profile=${3}

if  [ ! -n "${jar_path}" ] ;then
    echo "参数 1. jar_path 为空"
    exit 1
fi
if  [ ! -n "${jar_name}" ] ;then
    echo "参数 2. jar_name 为空"
    exit 1
fi

if  [ ! -n "${spring_profile}" ] ;then
    echo "参数 3. spring_profile 为空"
    exit 1
fi

#Jenkins中编译好的jar位置
deploy_path=${jar_path}/

#进入工作目录，log会打在该目录下
cd ${deploy_path}

echo 'deploy_path' ${deploy_path}
#获取运行编译好的进程ID，便于我们在重新部署项目的时候先杀掉以前的进程
pid= ps -ef | grep ${jar_name} | grep -v grep | awk '{print $2}'

#杀掉以前可能启动的项目进程
kill -9 ${pid}

#启动jar，指定SpringBoot的profiles为test，后台启动
nohup java -jar -Xms256m -Xmx256m -XX:-HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./logs -Dspring.profiles.active=${spring_profile} ${deploy_path}/${jar_name} &

#将进程ID存入到pid文件中
echo $! > ${deploy_path}/pid