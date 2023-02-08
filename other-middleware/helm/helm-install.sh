helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

# MySQL production env使用阿里云RDS更可靠
helm install mysql bitnami/mysql --set architecture=standalone  --namespace prod \
--set auth.rootPassword='fuyao@123' \
--set auth.username='fyzs' \
--set auth.password='fuyao@123' \
--set primary.persistence.storageClass='alicloud-disk-available' \
--set primary.persistence.size='20Gi'


# RocketMQ 参考README.md安装
https://github.com/apache/rocketmq-operator
使用这个版本，修改了RocketMQ镜像、参数配置、储存卷等 example/rocketmq_v1alpha1_rocketmq_cluster_fyzs.yaml
https://github.com/CodingAdai/rocketmq-operator

# ZooKeeper
helm install zookeeper bitnami/zookeeper --namespace prod --version 11.1.2 \
--set persistence.storageClass="alibabacloud-cnfs-nas" \
--set persistence.size="5Gi" \
--set dataLogDir="/zookeeper/log/" \
--set persistence.dataLogDir.size="5Gi" \
--set replicaCount=3 \
--set metrics.enabled=true \
--set-json 'metrics.service.annotations={"prometheus.io/scrape":"true","prometheus.io/port":"9141"}' \
--set-json 'resources.limits={"cpu":"500m","memory":"2000Mi"}'


# Redis
helm install redis bitnami/redis --namespace prod  --version 17.7.2 \
--set architecture=replication \
--set auth.password='123qwe@!~' \
--set master.count=1 \
--set-json 'master.disableCommands=[]' \
--set master.startupProbe.enabled=true \
--set master.persistence.storageClass="alibabacloud-cnfs-nas" \
--set master.persistence.size="2Gi" \
--set-json 'master.resources.requests={"cpu":"50m","memory":"100Mi"}' \
--set-json 'master.resources.limits={"cpu":"500m","memory":"200Mi"}' \
--set replica.replicaCount=1 \
--set-json 'replica.disableCommands=[]' \
--set-json 'replica.resources.requests={"cpu":"50m","memory":"100Mi"}' \
--set-json 'replica.resources.limits={"cpu":"500m","memory":"200Mi"}' \
--set replica.persistence.storageClass="alibabacloud-cnfs-nas" \
--set replica.persistence.size="2Gi" \
--set metrics.enabled=true \
--set-json 'metrics.resources.requests={"cpu":"10m","memory":"100Mi"}' \
--set-json 'metrics.resources.limits={"cpu":"100m","memory":"200Mi"}' \
--set-json 'metrics.service.annotations={"prometheus.io/scrape":"true","prometheus.io/port":"9121"}'




# ElasticSearch   有官方helm仓库和 ，需要使用自己定制的 ElasticSearch 容器镜像，安装分词插件
helm repo add elastic https://helm.elastic.co
helm repo update elastic

# 7.17.3
helm install elasticsearch --version 7.17.3 elastic/elasticsearch --set replicas=2 --namespace prod \
--set antiAffinity=soft \
--set image=registry-vpc.cn-shanghai.aliyuncs.com/fyzs-base/elasticsearch \
--set imageTag=7.17.3 \
--set imagePullSecrets[0].name=acr \
--set-json 'resources.requests={"cpu":"500m","memory":"2Gi"}' \
--set-json 'resources.limits={"cpu":"2000m","memory":"4Gi"}' \
--set volumeClaimTemplate.resources.requests.storage='30Gi' \
--set volumeClaimTemplate.storageClassName='alibabacloud-cnfs-nas'

# 8.5.1
helm install elasticsearch --version 8.5.1 elastic/elasticsearch --set replicas=3 --namespace prod \
--set image=registry-vpc.cn-shanghai.aliyuncs.com/fyzs-base/elasticsearch \
--set imageTag=8.5.1 \
--set imagePullSecrets[0].name=acr \
--set antiAffinity=soft \
--set minimumMasterNodes=2 \
--set-json 'resources.requests={"cpu":"500m","memory":"2Gi"}' \
--set-json 'resources.limits={"cpu":"2000m","memory":"4Gi"}' \
--set volumeClaimTemplate.resources.requests.storage='30Gi' \
--set volumeClaimTemplate.storageClassName='alibabacloud-cnfs-nas' \
--set secret.password='lk36j7XSL030dhl629dHS'

# 测试插件
curl -k --user elastic:lk36j7XSL030dhl629dHS -X GET https://elasticsearch-master.prod:9200/_cat/plugins

# bitnami仓库版本，功能更丰富，TODO 待完善
#helm install elasticsearch  bitnami/elasticsearch --namespace=prod  --version 19.5.10 \
#--set image.registry="" \
#--set image.repository="" \
#--set image.tag="" \
#--set-json 'image.pullSecrets=[{"name":"acr"}]' \



# Kibana
helm install kibana --version 8.5.1 elastic/kibana --namespace prod \
--set elasticsearchHosts=https://elasticsearch-master.prod:9200 \
--set-json 'resources.requests={"cpu":"100m","memory":"1Gi"}' \
--set-json 'resources.limits={"cpu":"500m","memory":"2Gi"}' \
--set service.type=NodePort


./helm install kibana --version 8.5.1 elastic/kibana --namespace prod \
--set elasticsearchHosts=https://elasticsearch-master.prod:9200 \
--set-json 'resources.requests={"cpu":"100m","memory":"1Gi"}' \
--set-json 'resources.limits={"cpu":"500m","memory":"2Gi"}' \
--set service.type=NodePort -f values.yaml
# 这个不知道怎么传文件参数，暂时本地修改values.yaml文件实现


# Dubbo Admin
https://github.com/CodingAdai/dubbo-admin

# RocketMQ dashboard
开启登录和用户配置
https://github.com/apache/rocketmq-dashboard/blob/master/docs/1_0_0/UserGuide_CN.md

# 删除
helm uninstall zookeeper
helm uninstall mysql
helm uninstall redis
helm uninstall elasticsearch
helm uninstall kibana



