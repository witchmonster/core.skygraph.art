// match (n:Constellation)-[r]-() delete r;
// match (n:Constellation) delete n;

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
and (n.optOut is null or n.optOut = false)
return n.community_nebula as leaderParent, n.handle as leader
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_constellation=community
and (n.optOut is null or n.optOut = false)
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