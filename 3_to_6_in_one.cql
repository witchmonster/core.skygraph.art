:param filamentGamma => 1;
:param gigaclusterGamma => 1;
:param superclusterGamma => 5;
:param clusterGamma => 10;
:param galaxyGamma => 24;
:param nebulaGamma => 100;
:param constellationGamma => 200;

CALL gds.graph.project(
  'undirected_filament',
  'Account',
{
  FOLLOWS: {
    orientation: 'UNDIRECTED' },
  REPLIED: {
    orientation: 'UNDIRECTED',
    properties: {count: {aggregation:'SUM'}}},
  LIKED: {
    orientation: 'UNDIRECTED',
    properties: {count: {aggregation:'SUM'}}}
}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// call gds.graph.nodeProperties.drop('undirected_filament', 'community_filament');
CALL gds.leiden.mutate('undirected_filament', { mutateProperty: 'community_filament', gamma: $filamentGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_filament', 'community_filament');

match (n:Filament)-[r]-() delete r;
match (n:Filament) delete n;

//conductance is only available while you have GDS live in memory
match (n) where n.community_filament is not null
// and n.interaction>=100
with n.community_filament as c,
    count(n) as size
where size >= 10
with collect(c) as communities
call {
  with communities
  call gds.conductance.stream('undirected_filament', {communityProperty: 'community_filament'})
    yield community, conductance
    where community in communities
    return apoc.map.fromPairs(collect([community, conductance])) as conductance
}
unwind communities as community
with
  conductance,
  community,
  count { (n:Account {community_filament: community})} as totalCount

with *
call { with community match (n:Account)
where n.community_filament=community
and n.optOut is null
return n.handle as leader
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_filament=community
and n.optOut is null
with n
order by n.weight desc
limit 50
with n
return collect(n.handle) as leaders
}
with *, round(apoc.map.get(conductance, toString(community), null, false), 6) as conductance
where totalCount >= 10

// return community, conductance, leader, totalCount, leaders
// order by totalCount desc;

// with community, conductance, leader, totalCount, leaders
// return sum(totalCount);

merge (n:Filament {community:community})
on create
set n.community = community,
n.conductance = conductance,
n.leader = leader,
n.leaders = leaders,
n.size = totalCount
on match
set
n.leader = leader,
n.leaders = leaders;

call gds.graph.drop('undirected_filament', false);

CALL gds.graph.project(
  'undirected_gigacluster',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// Run Leiden
// call gds.graph.nodeProperties.drop('undirected_gigacluster', 'community_gigacluster');
CALL gds.leiden.mutate('undirected_gigacluster', { mutateProperty: 'community_gigacluster', relationshipWeightProperty: 'harmonicWeight', gamma: $gigaclusterGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_gigacluster', 'community_gigacluster');

match (n:Gigacluster)-[r]-() delete r;
match (n:Gigacluster) delete n;

//conductance is only available while you have GDS live in memory
match (n) where n.community_gigacluster is not null
// and n.interaction>=100
with n.community_gigacluster as c,
    count(n) as size
where size >= 10
with collect(c) as communities
call {
  with communities
  call gds.conductance.stream('undirected_gigacluster', {communityProperty: 'community_gigacluster'})
    yield community, conductance
    where community in communities
    return apoc.map.fromPairs(collect([community, conductance])) as conductance
}
unwind communities as community
with
  conductance,
  community,
  count { (n:Account {community_gigacluster: community})} as totalCount

with *
call { with community match (n:Account)
where n.community_gigacluster=community
and n.optOut is null
return n.handle as leader
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_gigacluster=community
and n.optOut is null
with n
order by n.weight desc
limit 50
with n
return collect(n.handle) as leaders
}
with *, round(apoc.map.get(conductance, toString(community), null, false), 6) as conductance
where totalCount >= 10

// return community, conductance, leader, totalCount, leaders
// order by totalCount desc;

// with community, conductance, leader, totalCount, leaders
// return sum(totalCount);

merge (n:Gigacluster {community:community})
on create
set n.community = community,
n.conductance = conductance,
n.leader = leader,
n.leaders = leaders,
n.size = totalCount
on match
set
n.leader = leader,
n.leaders = leaders;

call gds.graph.drop('undirected_gigacluster', false);

CALL gds.graph.project(
  'undirected_supercluster',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

CALL gds.leiden.mutate('undirected_supercluster', { mutateProperty: 'community_supercluster', relationshipWeightProperty: 'harmonicWeight', gamma: $superclusterGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_supercluster', 'community_supercluster');

match (n:Supercluster)-[r]-() delete r;
match (n:Supercluster) delete n;

//conductance is only available while you have GDS live in memory
match (n) where n.community_supercluster is not null
// and n.interactions>=100
with n.community_supercluster as c,
    count(n) as size
where size > 10
with collect(c) as communities
call {
  with communities
  call gds.conductance.stream('undirected_supercluster', {communityProperty: 'community_supercluster'})
    yield community, conductance
    where community in communities
    return apoc.map.fromPairs(collect([community, conductance])) as conductance
}
unwind communities as community
with
  conductance,
  community,
  count { (n:Account {community_supercluster: community})} as totalCount

with *
call { with community match (n:Account)
where n.community_supercluster=community
and n.optOut is null
return n.handle as leader, n.community_filament as leaderParent
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_supercluster=community
and n.optOut is null
with n
order by n.weight desc
limit 50
with n
return collect(n.handle) as leaders
}
with *, round(apoc.map.get(conductance, toString(community), null, false), 6) as conductance
where totalCount >= 10

// return community, conductance, leader, totalCount, leaderParent, leaders
// order by totalCount desc;

// with community, conductance, leader, totalCount, leaderParent, leaders
// return sum(totalCount);

with community, conductance, leader, totalCount, leaderParent, leaders
merge (n:Supercluster {community:community})
on create
set n.community = community,
n.conductance = conductance,
n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders,
n.size = totalCount
on match
set n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders;

call gds.graph.drop('undirected_supercluster', false);



CALL gds.graph.project(
  'undirected_cluster',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// Run Leiden
// call gds.graph.nodeProperties.drop('undirected_cluster', 'community_cluster');
CALL gds.leiden.mutate('undirected_cluster', { mutateProperty: 'community_cluster', relationshipWeightProperty: 'harmonicWeight', gamma: $clusterGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_cluster', 'community_cluster');

match (n:Cluster)-[r]-() delete r;
match (n:Cluster) delete n;

//conductance is only available while you have GDS live in memory
match (n) where n.community_cluster is not null
// and n.interactions>=100
with n.community_cluster as c,
    count(n) as size
where size >= 10
with collect(c) as communities
call {
  with communities
  call gds.conductance.stream('undirected_cluster', {communityProperty: 'community_cluster'})
    yield community, conductance
    where community in communities
    return apoc.map.fromPairs(collect([community, conductance])) as conductance
}
unwind communities as community
with
  conductance,
  community,
  count { (n:Account {community_cluster: community})} as totalCount

with *
call { with community match (n:Account)
where n.community_cluster=community
and n.optOut is null
return n.handle as leader, n.community_supercluster as leaderParent
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_cluster=community
and n.optOut is null
with n
order by n.weight desc
limit 50
with n
return collect(n.handle) as leaders
}
with *, round(apoc.map.get(conductance, toString(community), null, false), 6) as conductance
where totalCount >= 10

// return community, conductance, leader, totalCount, leaderParent, leaders
// order by totalCount desc;

// with community, conductance, leader, totalCount, leaderParent, leaders
// return sum(totalCount);

with community, conductance, leader, totalCount, leaderParent, leaders
merge (n:Cluster {community:community})
on create
set n.community = community,
n.conductance = conductance,
n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders,
n.size = totalCount
on match
set n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders;

call gds.graph.drop('undirected_cluster', false);


CALL gds.graph.project(
  'undirected_galaxy',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// Run Leiden
// call gds.graph.nodeProperties.drop('undirected_galaxy', 'community_galaxy');
CALL gds.leiden.mutate('undirected_galaxy', { mutateProperty: 'community_galaxy', relationshipWeightProperty: 'harmonicWeight', gamma: $galaxyGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_galaxy', 'community_galaxy');

match (n:Galaxy)-[r]-() delete r;
match (n:Galaxy) delete n;

match (n) where n.community_galaxy is not null
// and n.interactions>=500
with n.community_galaxy as c,
    count(n) as size
where size >= 10
with collect(c) as communities
call {
    with communities
    call gds.conductance.stream('undirected_galaxy', {communityProperty: 'community_galaxy', relationshipWeightProperty: 'harmonicWeight'})
    yield community, conductance
    where community in communities
    return apoc.map.fromPairs(collect([community, conductance])) as conductance
}
unwind communities as community
with
  conductance,
  community,
  count { (n:Account {community_galaxy: community})} as totalCount

where totalCount >= 0

with *
call { with community match (n:Account)
where n.community_galaxy=community
and n.optOut is null
return n.community_cluster as leaderParent, n.handle as leader
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_galaxy=community
and n.optOut is null
with n
order by n.weight desc
limit 50
with n
return collect(n.handle) as leaders
}
with *, round(apoc.map.get(conductance, toString(community), null, false), 6) as conductance
where totalCount >= 10

// return community, conductance, leader, totalCount, leaderParent, leaders
// order by totalCount desc;

// with community, conductance, leader, totalCount, leaderParent, leaders
// return sum(totalCount);

with community, conductance, leader, totalCount, leaderParent, leaders
merge (n:Galaxy {community:community})
on create
set n.community = community,
n.conductance = conductance,
n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders,
n.size = totalCount
on match
set n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders;

call gds.graph.drop('undirected_galaxy', false);


CALL gds.graph.project(
  'undirected_nebula',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)

YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// call gds.graph.nodeProperties.drop('undirected_nebula', 'community_nebula');
CALL gds.leiden.mutate('undirected_nebula', { mutateProperty: 'community_nebula', relationshipWeightProperty: 'harmonicWeight', gamma: $nebulaGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_nebula', 'community_nebula');

match (n:Nebula)-[r]-() delete r;
match (n:Nebula) delete n;

match (n) where n.community_nebula is not null
// and n.interactions>=500
with n.community_nebula as c,
    count(n) as size
where size >= 10
with collect(c) as communities
call {
    with communities
    call gds.conductance.stream('undirected_nebula', {communityProperty: 'community_nebula', relationshipWeightProperty: 'harmonicWeight'})
    yield community, conductance
    where community in communities
    return apoc.map.fromPairs(collect([community, conductance])) as conductance
}
unwind communities as community
with
  conductance,
  community,
  count { (n:Account {community_nebula: community})} as totalCount

with *
call { with community match (n:Account)
where n.community_nebula=community
and n.optOut is null
return n.community_galaxy as leaderParent, n.handle as leader
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_nebula=community
and n.optOut is null
with n
order by n.weight desc
limit 50
with n
return collect(n.handle) as leaders
}
with *, round(apoc.map.get(conductance, toString(community), null, false), 6) as conductance
where totalCount >= 10

// return community, conductance, leader, totalCount, leaderParent, leaders
// order by totalCount desc;

// with community, conductance, leader, totalCount, leaderParent, leaders
// return sum(totalCount);

with community, conductance, leader, totalCount, leaderParent, leaders
merge (n:Nebula {community:community})
on create
set n.community = community,
n.conductance = conductance,
n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders,
n.size = totalCount
on match
set n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders;

call gds.graph.drop('undirected_nebula', false);


CALL gds.graph.project(
  'undirected_constellation',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)

YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// call gds.graph.nodeProperties.drop('undirected_constellation', 'community_constellation');
CALL gds.leiden.mutate('undirected_constellation', { mutateProperty: 'community_constellation', relationshipWeightProperty: 'harmonicWeight', gamma: $constellationGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_constellation', 'community_constellation');

match (n:Constellation)-[r]-() delete r;
match (n:Constellation) delete n;

match (n) where n.community_constellation is not null
// and n.interactions>=500
with n.community_constellation as c,
    count(n) as size
where size >= 10
with collect(c) as communities
call {
    with communities
    call gds.conductance.stream('undirected_constellation', {communityProperty: 'community_constellation', relationshipWeightProperty: 'harmonicWeight'})
    yield community, conductance
    where community in communities
    return apoc.map.fromPairs(collect([community, conductance])) as conductance
}
unwind communities as community
with
  conductance,
  community,
  count { (n:Account {community_constellation: community})} as totalCount

with *
call { with community match (n:Account)
where n.community_constellation=community
and n.optOut is null
return n.community_nebula as leaderParent, n.handle as leader
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_constellation=community
and n.optOut is null
with n
order by n.weight desc
limit 50
with n
return collect(n.handle) as leaders
}
with *, round(apoc.map.get(conductance, toString(community), null, false), 6) as conductance
where totalCount >= 10

// return community, conductance, leader, totalCount, leaderParent, leaders
// order by totalCount desc;

// with community, conductance, leader, totalCount, leaderParent, leaders
// return sum(totalCount);

with community, conductance, leader, totalCount, leaderParent, leaders
merge (n:Constellation {community:community})
on create
set n.community = community,
n.conductance = conductance,
n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders,
n.size = totalCount
on match
set n.leaderParent = leaderParent,
n.leader = leader,
n.leaders = leaders;

call gds.graph.drop('undirected_constellation', false);

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
