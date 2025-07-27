# Задание 2. Шардирование

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Инициализируем шардирование и заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

## Шаги для инициализации шардирования, выполняемые в mongo-init.sh

### 1. Инициализация конфигурационного сервера (`configSrv`)
```shell
docker exec -i configSrv mongosh --port 27017 <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF
```
### 2. Инициализация первого шарда (`shard1`)
```shell
docker exec -i shard1 mongosh --port 27018 <<EOF
rs.initiate(
  {
    _id : "shard1",
    members: [
      { _id : 1, host : "shard1:27018" }
    ]
  }
);
EOF
```
### 3. Инициализация второго шарда (`shard2`)
```shell
docker exec -i shard2 mongosh --port 27019 <<EOF
rs.initiate(
  {
    _id : "shard2",
    members: [
      { _id : 2, host : "shard2:27019" }
    ]
  }
);
EOF
```
### 4. Добавление шардов в маршрутизатор (`mongos_router`)
```shell
docker exec -i mongos_router mongosh --port 27020 <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF
```
