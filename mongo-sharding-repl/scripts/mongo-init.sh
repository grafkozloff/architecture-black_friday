#!/bin/bash

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

docker exec -i mongos_router mongosh --port 27025 <<EOF
sh.addShard( "shard1/shard1-0:27018");
sh.addShard( "shard2/shard2-0:27021");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF
