// -------------------- Gigaclusters --------------------

:auto
match (c:Gigacluster)
call {
  with c
  match (n:Account)
  where n.community_gigacluster=c.community
  with n, c
  order by n.weight desc
  with n, c
  with distinct n.community_filament as filament, c
  match (m:Account) where m.community_filament = filament
  and m.community_gigacluster = c.community
  with filament, count(m) as accountsInParent, c
  with *, round(toFloat(accountsInParent*100)/c.size,6) as portion
  match (child:Gigacluster {community:c.community}), (parent:Filament{community:filament})
  merge (child)-[g:IS_PARENT_FILAMENT {accountsIn:accountsInParent, portion:portion}]->(parent)
} in transactions
return *;

// set topParent data
match (c:Gigacluster)
call {
with c
match (c)-[r]-(p:Filament)
with p, r
order by r.portion desc
limit 1
return r.portion as portion, p.community as topParent, p.leader as parentLeader
}
with c, portion, topParent
set c.topParent=topParent, c.topParentPortion=portion

// -------------------- Gigaclusters --------------------


// -------------------- Superclusters --------------------

// set parents (1 minute)
:auto
match (c:Supercluster)
call {
  with c
  match (n:Account)
  where n.community_supercluster=c.community
  with n, c
  order by n.weight desc
  with n, c
  with distinct n.community_gigacluster as gigacluster, c
  match (m:Account) where m.community_gigacluster = gigacluster
  and m.community_supercluster = c.community
  with gigacluster, count(m) as accountsInParent, c
  with *, round(toFloat(accountsInParent*100)/c.size,6) as portion
  match (child:Supercluster {community:c.community}), (parent:Gigacluster{community:gigacluster})
  merge (child)-[g:IS_PARENT_GIGACLUSTER {accountsIn:accountsInParent, portion:portion}]->(parent)
} in transactions
return *;

// set topParent data
match (c:Supercluster)
call {
with c
match (c)-[r]-(p:Gigacluster)
with p, r
order by r.portion desc
limit 1
return r.portion as portion, p.community as topParent, p.leader as parentLeader
}
with c, portion, topParent
set c.topParent=topParent, c.topParentPortion=portion

// -------------------- Superclusters --------------------

// -------------------- Clusters --------------------

// set parents (2-5 minutes)
:auto
match (c:Cluster)
call {
  with c
  match (n:Account)
  where n.community_cluster=c.community
  with n, c
  order by n.weight desc
  with n, c
  with distinct n.community_supercluster as supercluster, c
  match (m:Account) where m.community_supercluster = supercluster
  and m.community_cluster = c.community
  with supercluster, count(m) as accountsInParent, c
  with *, round(toFloat(accountsInParent*100)/c.size,6) as portion
  match (child:Cluster {community:c.community}), (parent:Supercluster{community:supercluster})
  merge (child)-[g:IS_PARENT_SUPERCLUSTER {accountsIn:accountsInParent, portion:portion}]->(parent)
} in transactions
return *;

// set topParent data
match (c:Cluster)
call {
with c
match (c)-[r]-(p:Supercluster)
with p, r
order by r.portion desc
limit 1
return r.portion as portion, p.community as topParent, p.leader as parentLeader
}
with c, portion, topParent
set c.topParent=topParent, c.topParentPortion=portion;

// -------------------- Clusters --------------------


// -------------------- Galaxies --------------------

// set parents (12-15 min)
:auto
match (c:Galaxy)
call {
  with c
  match (n:Account)
  where n.community_galaxy=c.community
  with n, c
  order by n.weight desc
  with n, c
  with distinct n.community_cluster as cluster, c
  match (m:Account) where m.community_cluster = cluster
  and m.community_galaxy = c.community
  with cluster, count(m) as accountsInParent, c
  with *, round(toFloat(accountsInParent*100)/c.size,6) as portion
  match (child:Galaxy {community:c.community}), (parent:Cluster{community:cluster})
  merge (child)-[g:IS_PARENT_CLUSTER {accountsIn:accountsInParent, portion:portion}]->(parent)
} in transactions
return *;

// set topParent data
match (c:Galaxy)
call {
with c
match (c)-[r]-(p:Cluster)
with p, r
order by r.portion desc
limit 1
return r.portion as portion, p.community as topParent, p.leader as parentLeader
}
with c, portion, topParent
set c.topParent=topParent, c.topParentPortion=portion;

// -------------------- Galaxies --------------------



// -------------------- Nebulas --------------------

// set parents (4-5 min)
:auto
match (c:Nebula)
call {
  with c
  match (n:Account)
  where n.community_nebula=c.community
  with n, c
  order by n.weight desc
  with n, c
  with distinct n.community_galaxy as galaxy, c
  match (m:Account) where m.community_galaxy = galaxy
  and m.community_nebula = c.community
  with galaxy, count(m) as accountsInParent, c
  with *, round(toFloat(accountsInParent*100)/c.size,6) as portion
  match (child:Nebula {community:c.community}), (parent:Galaxy{community:galaxy})
  merge (child)-[g:IS_PARENT_GALAXY {accountsIn:accountsInParent, portion:portion}]->(parent)
} in transactions
return *;

// set topParent data
match (c:Nebula)
call {
with c
match (c)-[r]-(p:Galaxy)
with p, r
order by r.portion desc
limit 1
return r.portion as portion, p.community as topParent, p.leader as parentLeader
}
with c, portion, topParent
set c.topParent=topParent, c.topParentPortion=portion;

// -------------------- Nebulas --------------------



// -------------------- Constellations --------------------

// set parents (1-2 min)
:auto
match (c:Constellation)
call {
  with c
  match (n:Account)
  where n.community_constellation=c.community
  with n, c
  order by n.weight desc
  with n, c
  with distinct n.community_nebula as nebula, c
  match (m:Account) where m.community_nebula = nebula
  and m.community_constellation = c.community
  with nebula, count(m) as accountsInParent, c
  with *, round(toFloat(accountsInParent*100)/c.size,6) as portion
  match (child:Constellation {community:c.community}), (parent:Nebula{community:nebula})
  merge (child)-[g:IS_PARENT_NEBULA {accountsIn:accountsInParent, portion:portion}]->(parent)
} in transactions
return *;

// set topParent data
match (c:Constellation)
call {
with c
match (c)-[r]-(p:Nebula)
with p, r
order by r.portion desc
limit 1
return r.portion as portion, p.community as topParent, p.leader as parentLeader
}
with c, portion, topParent
set c.topParent=topParent, c.topParentPortion=portion;

// -------------------- Constellations --------------------
