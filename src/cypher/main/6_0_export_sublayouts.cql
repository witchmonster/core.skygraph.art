:param graphVersion => 4;

//sub-layouts

// ----------------------- Gigaclusters -----------------------
with "
match (n:Gigacluster)
where n.size >=100
with n
order by n.size desc
call {
    with n
    match (a:Account)
    where a.community_gigacluster = n.community
    with distinct a.community_cluster as clustercommunity
    match (c:Cluster {community: clustercommunity})
    where c.size >= 100
    with c
    order by c.size desc
    return collect('c' + coalesce(c.community)) as overlay
}
with collect({name: n.name, community: 'f' + coalesce(n.community), overlay: overlay}) as communities
return $graphVersion as graphVersion, communities"
as query
call apoc.export.json.query(query, 'export/sub_layouts/filaments.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (n:Gigacluster)
// where n.community=89
where n.size >= 100
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_gigacluster: $community})
where a.weight > 100
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
call apoc.export.json.query(query, 'export/sub_layouts/filaments/graph_peacock_f'+ community +'.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion,
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Gigaclusters -----------------------



// ----------------------- Superclusters -----------------------

with "
match (n:Supercluster)
where n.size >=100
with n
order by n.size desc
call {
    with n
    match (a:Account)
    where a.community_supercluster = n.community
    with distinct a.community_cluster as clustercommunity
    match (c:Cluster {community: clustercommunity})
    where c.size >= 100
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
// where n.community=89
where n.size >= 100
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_supercluster: $community})
where a.weight > 100
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
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Superclusters -----------------------



// ----------------------- Clusters -----------------------

with "
match (n:Cluster)
where n.size >=100
with n
order by n.size desc
call {
    with n
    match (a:Account)
    where a.community_cluster = n.community
    with distinct a.community_nebula as nebulacommunity
    match (c:Nebula {community: nebulacommunity})
    where c.size >= 100
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
// where n.community=89
where n.size >= 100
with n
order by n.size desc
with n.community as community
with "
match (a:Account {community_cluster: $community})
where a.weight > 100
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
call apoc.export.json.query(query, 'export/sub_layouts/graph_peacock_c'+ community +'.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion,
    community:community}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Clusters -----------------------


// ----------------------- Nebulas -----------------------
with "
match (n:Cluster)
where n.size >=100
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
    return c as nebula
}
with distinct nebula
with collect({name: nebula.name, community: 'e' + coalesce(nebula.community)}) as communities
return $graphVersion as graphVersion, communities"
as query
call apoc.export.json.query(query, 'export/sub_layouts/nebulas.json', {jsonFormat: 'JSON', params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;
// ----------------------- Nebulas -----------------------
