# Задание 4. Кеширование

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
### 2. Инициализация набора реплик первого шарда (`shard1`)
```shell
docker exec -i shard1-0 mongosh --port 27018 <<EOF
rs.initiate(
  {
    _id : "shard1",
    members: [
      { _id : 1, host : "shard1-0:27018" },
      { _id : 2, host : "shard1-1:27019" },
      { _id : 3, host : "shard1-2:27020" }
    ]
  }
);
EOF
```
### 3. Инициализация набора реплик второго шарда (`shard2`)
```shell
docker exec -i shard2-0 mongosh --port 27021 <<EOF
rs.initiate(
  {
    _id : "shard2",
    members: [
      { _id : 4, host : "shard2-0:27021" },
      { _id : 5, host : "shard2-1:27022" },
      { _id : 6, host : "shard2-2:27023" }
    ]
  }
);
EOF
```
### 4. Добавление шардов в маршрутизатор (`mongos_router`)
```shell
docker exec -i mongos_router mongosh --port 27025 <<EOF
sh.addShard( "shard1/shard1-0:27018");
sh.addShard( "shard2/shard2-0:27021");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF
```
