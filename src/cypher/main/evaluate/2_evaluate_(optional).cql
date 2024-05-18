//top moots ideas
match (n:Account {handle:'skygraph.art'})<-[r:WEIGHTED]-(m:Account)
with n, r, m
match (n)-[rf:WEIGHTED]->(m)
match (n)-[fnm:FOLLOWS]->(m)
match (n)<-[fmn:FOLLOWS]-(m)
optional match (n)-[bnm:BLOCKS]->(m)
optional match (n)<-[bmn:BLOCKS]-(m)
with *
where type(bmn) is null
and type(bnm) is null
// and rf.weight > r.weight
with *,
rf.weight-r.weight as lovegap
with * where lovegap < 100 and lovegap > -100
with n, rf, m.community_constellation as friendConstellation, m.handle as handle, r.harmonicWeight as hw, rf.weight as fromWeight, r.weight as toWeight,
type(fnm) as from, type(fmn) as to,
type(bnm) as blocks, type(bmn) as isBlocked, lovegap
order by rf.weight + lovegap desc limit 50
with distinct friendConstellation, n
match (com:Constellation {community:friendConstellation})
match (n)-[w:WEIGHTED]->(l:Account {handle: com.leader})
with com, w
limit 50
return com.name, com.size, w.weight order by w.weight desc;

match (n:Gigacluster) return stDevP(n.size), percentileCont(n.size, 0.2), percentileCont(n.size, 0.5), percentileCont(n.size, 0.90),percentileCont(n.size, 0.99)

// -------------------- STRONG --------------------

// -------------------- Gigaclusters --------------------

match (n:Gigacluster) return
n.community,
n.conductance,
n.leader,
n.size,
n.leaders
order by n.size desc;

// -------------------- Gigaclusters --------------------


// -------------------- Superclusters --------------------

match (n:Supercluster)
call {
    with n
    match (m:Filament)-[r]-(n)
    with m, r
    order by r.portion desc
    return collect(coalesce(m.community,"") + ":" + coalesce(r.portion,"")) as parents
}
return
n.community,
n.leaderParent,
n.topParent,
n.topParentPortion,
n.conductance,
n.leader,
n.size,
n.leaders
parents
order by n.size desc;

// -------------------- Superclusters --------------------


// -------------------- Clusters --------------------

evaluate from nodes
match (n:Cluster)
call {
    with n
    match (m:Supercluster)-[r]-(n)
    with m, r
    order by r.portion desc
    return collect(coalesce(m.community,"") + ":" + coalesce(r.portion,"")) as parents
}
n.community,
n.leaderParent,
n.topParent,
n.topParentPortion,
n.conductance,
n.leader,
n.size,
n.leaders
parents
order by n.size desc;

// -------------------- Clusters --------------------



// -------------------- Galaxies --------------------

evaluate from nodes
match (n:Galaxy)
call {
    with n
    match (m:Cluster)-[r]-(n)
    with m, r
    order by r.portion desc
    return collect(coalesce(m.community,"") + ":" + coalesce(r.portion,"")) as parents
}
return
n.community,
n.leaderParent,
n.topParent,
n.topParentPortion,
n.conductance,
n.leader,
n.size,
n.leaders
parents
order by n.size desc;

// -------------------- Galaxies --------------------


// -------------------- Nebulas --------------------

evaluate from nodes
match (n:Nebula)
call {
    with n
    match (m:Galaxy)-[r]-(n)
    with m, r
    order by r.portion desc
    return collect(coalesce(m.community,"") + ":" + coalesce(r.portion,"")) as parents
}
return
n.community,
n.leaderParent,
n.topParent,
n.topParentPortion,
n.conductance,
n.leader,
n.size,
n.leaders
parents
order by n.size desc;

// -------------------- Nebulas --------------------


// -------------------- Constellations --------------------

evaluate from nodes
match (n:Constellation)
call {
    with n
    match (m:Nebula)-[r]-(n)
    with m, r
    order by r.portion desc
    return collect(coalesce(m.community,"") + ":" + coalesce(r.portion,"")) as parents
}
return
n.community,
n.leaderParent,
n.topParent,
n.topParentPortion,
n.conductance,
n.leader,
n.size,
n.leaders
parents
order by n.size desc;

// -------------------- Constellations --------------------

// -------------------- STRONG --------------------


// -------------------- WEAK --------------------

// -------------------- Filaments --------------------

match (n:Filament) return
n.community,
n.conductance,
n.leader,
n.size,
n.leaders
order by n.size desc;

// -------------------- Filaments --------------------

// -------------------- WEAK --------------------