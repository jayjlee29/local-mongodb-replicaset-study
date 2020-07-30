# Docker를 이용하여 Local테스트용 MongoDB replicaset 구성하기

해당 구성은 AWS에서 개발을 위한 단일 인스턴스에 도커를 이용한 replica-set 구성 예제입니다.

## EC2생성
AWS콘솔에서 mongodb인스턴스로 사용할 EC2를 생성
replica set 구성을 위하여 security group에서 27017, 27021, 27022포트를 접속 가능한 상태로 설정 필요

## start/up
아래 명령을 통하여 mongodb 27017, 27021, 27022 3개의 인스턴스를 구동한다.

```
docker-compose up -d
```

## Mongdb replica set 구성하기

> 몽고 디비에 접속
```
mongo mongodb://localhost:27017
```

> Replica set 구성
```
config = {
  _id : "replication",
  members: [
    {_id:0,host : "{{EC2 Public DNS}}:27017"},
    {_id:1,host : "{{EC2 Public DNS}}:27021"},
    {_id:2,host : "{{EC2 Public DNS}}:27022"},
  ]
}
rs.initiate(config);
rs.conf();
```

위 단계를 각 인스턴스마다 실행

## decompany db 생성및 decompany사용자 생성
```
use decompany
db.createUser(
   {
     user: "decompany",
     pwd: "decompany1234",
     roles: [{role: "readWrite", db: "decompany"} ]
   }
)
db.auth("decompany", "decompany1234")
```
***

# 기타 
## Slave에서 쿼리 실행하기

```
rs.slaveOk()
```

## Clear

```
docker-compose down
rm -rf ./storage/db
```

## replica set member추가/삭제
```
rs.set(host)
rs.remove(host)
```

## 강제로 Master node 변경하기

> 마스터 노드 확인
```
rs.status().members
```

>해당 인덱스로 설정 변경
```
const cfg = rs.conf()
cfg.members[0].priority = 0.5
cfg.members[1].priority = 0.5
cfg.members[2].priority = 1
rs.reconfig(cfg)

```