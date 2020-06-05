# Docker를 이용하여 Local테스트용 MongoDB replicaset 구성하기

## 주의 
해당 구성은 로컬 테스트용이며, replica-set 구성 참조를 위한 예제입니다.
구성후 replica-set uri를 통하여 접속이 불가능하며 remote 확인을 위해서 각 인스턴스별로 접속이 해야만 합니다.

mongodb://decompany:decompany1234@localhost:27020/decompany

## Build

```
docker-compose build
```

## start/up

```
docker-compose up -d
```

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


## Slave에서 쿼리 실행하기

```
rs.slaveOk()
```

## Clear

```
docker-compose down
rm -rf ./storage/db
```