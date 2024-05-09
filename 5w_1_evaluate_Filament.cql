// match (n:Filament)-[r]-() delete r;
// match (n:Filament) delete n;

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
return n.handle as leader
order by n.weight desc
limit 1}
call { with community match (n:Account)
where n.community_filament=community
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

// merge (n:Filament {community:community})
// on create
// set n.community = community,
// n.conductance = conductance,
// n.leader = leader,
// n.leaders = leaders,
// n.size = totalCount
// on match
// set
// n.leader = leader,
// n.leaders = leaders