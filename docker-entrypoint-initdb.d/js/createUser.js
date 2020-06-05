if(db.isMaster().ismaster){
  print('this node is master, creating user~')
  db.getSiblingDB("decompany").createUser(
    {
      user: "decompany",
      pwd: "decompany1234",
      roles: [{role: "readWrite", db: "decompany"}]
    }
  )
  db.getSiblingDB("decompanyauth").createUser(
    {
      user: "decompany",
      pwd: "decompany1234",
      roles: [{role: "readWrite", db: "decompanyauth"}]
    }
  )
} else {
  print('this node is slave')
}
