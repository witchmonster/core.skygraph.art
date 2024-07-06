:param graphVersion => 6;

:param minWeightGigaclusters => 100;
:param minWeightSuperclusters => 50;
:param minWeightClusters => 10;
:param minWeightGalaxies => 0;
:param minWeightNebulas => 0;
:param minWeightConstellations => 0;

//sub-layouts

// ----------------------- Gigaclusters -----------------------
with "
match (n:Gigacluster)
where n.size >=10
with n
order by n.size desc
call {
    with n
    match (a:Account)
    where a.community_gigacluster = n.community
    with distinct a.community_cluster as clustercommunity
    match (c:Cluster {community: clustercommunity})
    where c.size >= 10
    with c
    order by c.size desc
    return collect('c' + coalesce(c.community)) as overlay
}
with collect({name: n.name, community: 'f' + coalesce(n.community), overlay: overlay}) as communities
return $graphVersion as graphVersion, communities"
as query
call apoc.export.json.query(query, 'export/sub_layouts/gigaclusters.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (n:Gigacluster)
where n.size >= 10
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_gigacluster: $community})
where a.weight > $minWeightGigaclusters
with collect(a) as nodepool, collect({did: a.did, handle: a.handle, cType:labels(a)[0], community: 'c' + coalesce(a.community_cluster), size: a.weight}) as nodes
unwind nodepool as from
with nodepool, nodes, from
call {
    with from, nodepool
    match (from)-[r:WEIGHTED]->(to:Account)
    where from <> to
    and r.harmonicWeight > 20
    and to in nodepool
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return r.weight as weight
    }
    with * where weight > 0
    with from, to, weight order by weight desc
    return from.did as from_did, to.did as to_did, weight
}
with nodes, from, from_did, to_did, weight where weight > 0
with nodes, collect({source: from_did, target: to_did, weight: weight}) as rels
return $graphVersion as graphVersion, nodes, rels" as query, community
call apoc.export.json.query(query, 'export/sub_layouts/gigaclusters/graph_peacock_f'+ community +'.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion,
    minWeightGigaclusters:$minWeightGigaclusters,
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Gigaclusters -----------------------



// ----------------------- Superclusters -----------------------

with "
match (n:Supercluster)
where n.size >=10
with n
order by n.size desc
call {
    with n
    match (a:Account)
    where a.community_supercluster = n.community
    with distinct a.community_cluster as clustercommunity
    match (c:Cluster {community: clustercommunity})
    where c.size >= 10
    with c
    order by c.size desc
    return collect('c' + coalesce(c.community)) as overlay
}
with collect({name: n.name, community: 's' + coalesce(n.community), overlay: overlay}) as communities
return $graphVersion as graphVersion, communities"
as query
call apoc.export.json.query(query, 'export/sub_layouts/superclusters.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (n:Supercluster)
where n.size >= 10
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_supercluster: $community})
where a.weight > $minWeightSuperclusters
with collect(a) as nodepool, collect({did: a.did, handle: a.handle, cType:labels(a)[0], community: 'c' + coalesce(a.community_cluster), size: a.weight}) as nodes
unwind nodepool as from
with nodepool, nodes, from
call {
    with from, nodepool
    match (from)-[r:WEIGHTED]->(to:Account)
    where from <> to
    and r.harmonicWeight > 20
    and to in nodepool
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return r.weight as weight
    }
    with * where weight > 0
    with from, to, weight order by weight desc
    return from.did as from_did, to.did as to_did, weight
}
with nodes, from, from_did, to_did, weight where weight > 0
with nodes, collect({source: from_did, target: to_did, weight: weight}) as rels
return $graphVersion as graphVersion, nodes, rels" as query, community
call apoc.export.json.query(query, 'export/sub_layouts/superclusters/graph_peacock_s'+ community +'.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion,
    minWeightSuperclusters:$minWeightSuperclusters,
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Superclusters -----------------------



// ----------------------- Clusters -----------------------

with "
match (n:Cluster)
where n.size >=10
with n
order by n.size desc
call {
    with n
    match (a:Account)
    where a.community_cluster = n.community
    with distinct a.community_nebula as nebulacommunity
    match (c:Nebula {community: nebulacommunity})
    where c.size >= 10
    with c
    order by c.size desc
    return collect('e' + coalesce(c.community)) as overlay
}
with collect({name: n.name, community: 'c' + coalesce(n.community), overlay: overlay}) as communities
return $graphVersion as graphVersion, communities"
as query
call apoc.export.json.query(query, 'export/sub_layouts/clusters.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (n:Cluster)
where n.size >= 10
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_cluster: $community})
where a.weight > $minWeightClusters
with collect(a) as nodepool, collect({did: a.did, handle: a.handle, cType:labels(a)[0], community: 'e' + coalesce(a.community_nebula), size: a.weight}) as nodes
unwind nodepool as from
with nodepool, nodes, from
call {
    with from, nodepool
    match (from)-[r:WEIGHTED]->(to:Account)
    where from <> to
    and r.harmonicWeight > 20
    and to in nodepool
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return r.weight as weight
    }
    with * where weight > 0
    with from, to, weight order by weight desc
    return from.did as from_did, to.did as to_did, weight
}
with nodes, from, from_did, to_did, weight where weight > 0
with nodes, collect({source: from_did, target: to_did, weight: weight}) as rels
return $graphVersion as graphVersion, nodes, rels" as query, community
call apoc.export.json.query(query, 'export/sub_layouts/clusters/graph_peacock_c'+ community +'.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion,
    minWeightClusters:$minWeightClusters,
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Clusters -----------------------



// ----------------------- Galaxies -----------------------
with "
match (n:Galaxy)
where n.size >=10
with n
order by n.size desc
call {
    with n
    match (a:Account)
    where a.community_galaxy = n.community
    with distinct a.community_nebula as nebulacommunity
    match (c:Nebula {community: nebulacommunity})
    where c.size >= 10
    with c
    order by c.size desc
    return collect('e' + coalesce(c.community)) as overlay
}
with collect({name: n.name, community: 'g' + coalesce(n.community), overlay: overlay}) as communities
return $graphVersion as graphVersion, communities"
as query
call apoc.export.json.query(query, 'export/sub_layouts/galaxies.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (n:Galaxy)
where n.size >= 10
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_galaxy: $community})
where a.weight > $minWeightGalaxies
with collect(a) as nodepool, collect({did: a.did, handle: a.handle, cType:labels(a)[0], community: 'e' + coalesce(a.community_nebula), size: a.weight}) as nodes
unwind nodepool as from
with nodepool, nodes, from
call {
    with from, nodepool
    match (from)-[r:WEIGHTED]->(to:Account)
    where from <> to
    and r.harmonicWeight > 20
    and to in nodepool
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return r.weight as weight
    }
    with * where weight > 0
    with from, to, weight order by weight desc
    return from.did as from_did, to.did as to_did, weight
}
with nodes, from, from_did, to_did, weight where weight > 0
with nodes, collect({source: from_did, target: to_did, weight: weight}) as rels
return $graphVersion as graphVersion, nodes, rels" as query, community
call apoc.export.json.query(query, 'export/sub_layouts/galaxies/graph_peacock_c'+ community +'.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion,
    minWeightGalaxies:$minWeightGalaxies,
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Galaxies -----------------------



// ----------------------- Nebulas -----------------------
with "
match (n:Nebula)
where n.size >=10
with n
order by n.size desc
call {
    with n
    match (a:Account)
    where a.community_nebula = n.community
    with distinct a.community_nebula as constellationcommunity
    match (c:Constellation {community: constellationcommunity})
    where c.size >= 10
    with c
    order by c.size desc
    return collect('o' + coalesce(c.community)) as overlay
}
with collect({name: n.name, community: 'e' + coalesce(n.community), overlay: overlay}) as communities
return $graphVersion as graphVersion, communities"
as query
call apoc.export.json.query(query, 'export/sub_layouts/nebulas.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (n:Nebula)
where n.size >= 10
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_nebula: $community})
where a.weight > $minWeightNebulas
with collect(a) as nodepool, collect({did: a.did, handle: a.handle, cType:labels(a)[0], community: 'o' + coalesce(a.community_constellation), size: a.weight}) as nodes
unwind nodepool as from
with nodepool, nodes, from
call {
    with from, nodepool
    match (from)-[r:WEIGHTED]->(to:Account)
    where from <> to
    and r.harmonicWeight > 20
    and to in nodepool
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return r.weight as weight
    }
    with * where weight > 0
    with from, to, weight order by weight desc
    return from.did as from_did, to.did as to_did, weight
}
with nodes, from, from_did, to_did, weight where weight > 0
with nodes, collect({source: from_did, target: to_did, weight: weight}) as rels
return $graphVersion as graphVersion, nodes, rels" as query, community
call apoc.export.json.query(query, 'export/sub_layouts/nebulas/graph_peacock_c'+ community +'.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion,
    minWeightNebulas:$minWeightNebulas,
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Nebulas -----------------------



// ----------------------- Constellations -----------------------
with "
match (n:Constellation)
where n.size >=10
with n
order by n.size desc
with collect({name: n.name, community: 'o' + coalesce(n.community)}) as communities
return $graphVersion as graphVersion, communities"
as query
call apoc.export.json.query(query, 'export/sub_layouts/constellations.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (n:Constellation)
where n.size >= 10
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_constellation: $community})
where a.weight > $minWeightConstellations
with collect(a) as nodepool, collect({did: a.did, handle: a.handle, cType:labels(a)[0], community: 'o' + coalesce(a.community_constellation), size: a.weight}) as nodes
unwind nodepool as from
with nodepool, nodes, from
call {
    with from, nodepool
    match (from)-[r:WEIGHTED]->(to:Account)
    where from <> to
    and r.harmonicWeight > 20
    and to in nodepool
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return r.weight as weight
    }
    with * where weight > 0
    with from, to, weight order by weight desc
    return from.did as from_did, to.did as to_did, weight
}
with nodes, from, from_did, to_did, weight where weight > 0
with nodes, collect({source: from_did, target: to_did, weight: weight}) as rels
return $graphVersion as graphVersion, nodes, rels" as query, community
call apoc.export.json.query(query, 'export/sub_layouts/constellations/graph_peacock_c'+ community +'.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion,
    minWeightConstellations:$minWeightConstellations,
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Constellations -----------------------
