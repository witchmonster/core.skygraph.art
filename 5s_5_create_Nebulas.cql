// match (n:Nebula)-[r]-() delete r;
// match (n:Nebula) delete n;

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
and a.optOut is null
return n.community_galaxy as leaderParent, n.handle as leader
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_nebula=community
and a.optOut is null
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

// with community, conductance, leader, totalCount, leaderParent, leaders
// merge (n:Nebula {community:community})
// on create
// set n.community = community,
// n.conductance = conductance,
// n.leaderParent = leaderParent,
// n.leader = leader,
// n.leaders = leaders,
// n.size = totalCount
// on match
// n.leaderParent = leaderParent,
// n.leader = leader,
// n.leaders = leaders