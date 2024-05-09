match (n:sFilament) return stDevP(n.size), percentileCont(n.size, 0.2), percentileCont(n.size, 0.5), percentileCont(n.size, 0.90),percentileCont(n.size, 0.99)

// -------------------- STRONG --------------------

// -------------------- sFilaments --------------------

match (n:sFilament) return
n.community,
n.conductance,
n.leader,
n.size,
n.leaders
order by n.size desc;

// -------------------- sFilaments --------------------


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

// -------------------- WEAK --------------------