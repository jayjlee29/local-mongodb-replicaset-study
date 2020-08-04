# Docker를 이용하여 Local테스트용 MongoDB replicaset 구성하기

해당 구성은 AWS에서 개발을 위한 단일 인스턴스에 도커를 이용한 replica-set 구성 예제입니다.
> https://codefarm.me/2017/09/08/deploy-mongodb-with-docker/

## EC2생성
AWS콘솔에서 mongodb인스턴스로 사용할 EC2를 생성
replica set 구성을 위하여 security group에서 27017, 27021, 27022포트를 접속 가능한 상태로 설정 필요

## replica set의 acl을 위한 key file 생성

```
openssl rand -base64 756 > keyfile
cat keyfile
```
> 내용
```
AFO3EYmmmQQLF68tUd3aQsFI/C53XtOpUGt8R5ecS1F9uWRFg4dN6jlCjiBbYqHC
w3lqUhlRBe00YhDM97z31oYkQBSyID20pIMeQ3e40FY6zBE1w+4lWYekuPJAUtzS
ZspGfFExltwL0700Dwu7b1mnMbqfmfrpSVxTKHaY7Hcw60mvbBPPCp6IWkDVZ9NX
NKveHX3Wuq28/PSMw8sVPUbP5eqPux05PCyp5VBp6/fhg8Np8vIlWAy9fMsAgkmE
kBeGcRNst6t0iXbqNi9VrW6szJN5yyq0x1+0XB1QJZCjnLczoXMTPQeDCTrijbpI
N4zr7L2EV6n8FsgSJ7vwzRMj0ZRFjuK/wwBblPCuisv5JlcClZ6I0WEtV1yg5HQu
AFv3v7FPmfodQ6Sz81c6sNEKuwg3kzCY7wkeA163RZrujHViYFka6zOcv/kDdQ5h
rL6EBXE3v6bnd24/nzys9Zx6CrqPPUqSVfugmIW78r9imXswUqdr/VZVbhGsKcjH
Uza306prvuWmh0o1hpFGReGbHIdWhEtP/ldXKBbPy+27tgNeSiSP1GjVG2rkaIlb
bsnahiNj2EaAa1ov9pYiyO51m+ouEg+H9LPBcLhLXipI3wbST8BqMZweLSNfeLFi
Kpel5Q3rNtmRrjCbVIiiAXmxECU+PcwL+a4XhISnktdq6Du43d4INSJ/cn8JVLFS
VbR5nTnc4cMmEE3n/0BrScZinGZT1gbtwbE5izA5E17/7n/HLGUXhfhMGWrwdL9f
CsDt8ZEg7AUCPhFhsbcwfHkROXmYYubcd41NqLEYyktDzqsu3CaXFvH3QyD5AqmN
ylh6UGgjqgWIC7y553qNE9v7Go/9zKTUj8Df/wcQVl6ALOdZgPmchNTX8PtENdKT
aPUu/dcctYZUxz1DKwkaH3aUblSBGtSHa94knUA+R3DWPTcGNt3n46AL45Ty5amX
c5yYTpaKB6jgXwIMjO96OA9XlZKxOVgqdASsN6O0wCzfAg55
```

## key file의 docker container안에서의 권한 설정
```
chmod 400 keyfile
sudo chown 999 keyfile
```
> 위 키 파일이 docker-compose.yml의 command부분에 적용되어야한다.
> docker-compose.yml mongo1 예시
```
version: '3'
services:
  mongo1:
    image: mongo:4.2.6
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: admin
    volumes:
      - $PWD/storage/db/mongo1:/data/db
      - $PWD/storage/log/mongo1:/var/log/mongodb
      - $PWD/opts/membership.key:/opts/membership.key:ro
    network_mode: host
    command: mongod --auth --keyFile {{keyfile}} --bind_ip 0.0.0.0 --port 27021 --replSet replication
```

## start/up
아래 명령을 통하여 mongodb 27021, 27022, 27023 3개의 인스턴스를 차례로 구동한다.
한번에 구동시키면 admin 유저 생성때문에 27017 포트를 중복 접근하여 오류가 발생함(host mode)

```
docker-compose up -d mongo1
docker-compose up -d mongo2
docker-compose up -d mongo3
```

## Mongdb replica set 구성하기

> 몽고 디비에 접속
```
mongo mongodb://localhost:27021 -u admin
```

> Replica set 구성
```
config = {
  _id : "replication",
  members: [
    {_id:0,host : "ec2-3-101-47-97.us-west-1.compute.amazonaws.com:27021"},
    {_id:1,host : "ec2-3-101-47-97.us-west-1.compute.amazonaws.com:27022"},
    {_id:2,host : "ec2-3-101-47-97.us-west-1.compute.amazonaws.com:27023"},
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
     pwd: "{{####}}",
     roles: [{role: "readWrite", db: "decompany"} ]
   }
)
db.auth("decompany", "{{#####}}")
```

## 접속 URL

```
mongodb://ec2-3-101-47-97.us-west-1.compute.amazonaws.com:27021,ec2-3-101-47-97.us-west-1.compute.amazonaws.com:27022,ec2-3-101-47-97.us-west-1.compute.amazonaws.com:27023/{databaseName}?replicaSet=replication&authSource=admin
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