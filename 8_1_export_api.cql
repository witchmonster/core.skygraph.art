match (n:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster|Filament)
set n.propertyName = case
        when n:Filament then 'community_filament'
        when n:Gigacluster then 'community_gigacluster'
        when n:Supercluster then 'community_supercluster'
        when n:Cluster then 'community_cluster'
        when n:Galaxy then 'community_galaxy'
        when n:Nebula then 'community_nebula'
        when n:Constellation then 'community_constellation'
end
set n.prefix = case
        when n:Filament then 'wf'
        when n:Gigacluster then 'f'
        when n:Supercluster then 's'
        when n:Cluster then 'c'
        when n:Galaxy then 'g'
        when n:Nebula then 'e'
        when n:Constellation then 'o'
end
set n.type = case
        when n:Filament then 'Filament'
        when n:Gigacluster then 'Gigacluster'
        when n:Supercluster then 'Supercluster'
        when n:Cluster then 'Cluster'
        when n:Galaxy then 'Galaxy'
        when n:Nebula then 'Nebula'
        when n:Constellation then 'Constellation'
end
set n.resolution = case
        when n:Filament then '1'
        when n:Gigacluster then '1'
        when n:Supercluster then '5'
        when n:Cluster then '10'
        when n:Galaxy then '24'
        when n:Nebula then '100'
        when n:Constellation then '200'
end
set n.algo = case
        when n:Filament then 'weak'
        when n:Gigacluster then 'strong'
        when n:Supercluster then 'strong'
        when n:Cluster then 'strong'
        when n:Galaxy then 'strong'
        when n:Nebula then 'strong'
        when n:Constellation then 'strong'
end;

match (n:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster|Filament)
with n
match (leader:Account)
where n.leader = leader.handle
set n.did = n.prefix + '_' + leader.did
set n.name = n.prefix + '_' + leader.handle;

:auto
with "
match (n:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster|Filament) where n.community is not null
with n
with collect(n) as nodepool, collect({did: n.did, handle: n.name, cType: labels(n)[0], community: n.prefix + coalesce(n.community), size: n.size}) as nodes
unwind nodepool as from
with nodepool, nodes, from
call {
    with from, nodepool
    match (from)-[r:(IS_PARENT_FILAMENT|IS_PARENT_GIGACLUSTER|IS_PARENT_SUPERCLUSTER|IS_PARENT_CLUSTER|IS_PARENT_GALAXY|IS_PARENT_NEBULA)]->(to:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster|Filament)
    where from <> to
        and to in nodepool
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return r.accountsIn as weight
    }
    with * where weight > 0
    with from, to, weight order by weight desc
    // limit 100
    return from.did as from_did, to.did as to_did, weight
} in transactions of 100 rows
with nodes, from, from_did, to_did, weight where weight > 0
with nodes, collect({source: from_did, target: to_did, weight: weight}) as rels
return $graphVersion as graphVersion, 'communities-to-parent-communities' as type, nodes, rels" as query
// call apoc.export.json.query(query, '/export/api/graph_peacock.json', {jsonFormat: 'JSON', params: {
call apoc.export.json.query(query, '/export/api/graph_peacock.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
with "
match (n:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster) where n.community is not null
with n
with collect(n) as nodepool, collect({did: n.did, handle: n.name, cType: labels(n)[0], community: n.prefix + coalesce(n.community), size: n.size}) as nodes
unwind nodepool as from
with nodepool, nodes, from
call {
    with from, nodepool
    match (from)-[r:(IS_PARENT_GIGACLUSTER|IS_PARENT_SUPERCLUSTER|IS_PARENT_CLUSTER|IS_PARENT_GALAXY|IS_PARENT_NEBULA)]->(to:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster)
    where from <> to
        and to in nodepool
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return r.accountsIn as weight
    }
    with * where weight > 0
    with from, to, weight order by weight desc
    // limit 100
    return from.did as from_did, to.did as to_did, weight
} in transactions of 100 rows
with nodes, from, from_did, to_did, weight where weight > 0
with nodes, collect({source: from_did, target: to_did, weight: weight}) as rels
return $graphVersion as graphVersion, 'communities-to-parent-communities' as type, nodes, rels" as query
call apoc.export.json.query(query, '/export/api/graph_pawprints.json', {jsonFormat: 'JSON', params: {
// call apoc.export.json.query(query, '/export/api/graph_pawprints.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
with "
    match (c:Gigacluster|Supercluster|Cluster|Galaxy|Nebula|Constellation)
    with c
    order by c.name
    with collect({
        name: c.name,
        size: c.size,
        type: c.type,
        prefix: c.prefix,
        resolution: c.resolution,
        algo: c.algo,
        conductance: c.conductance,
        community: c.prefix + coalesce(c.community) }) as nodes
    return $graphVersion as graphVersion, 'communities-metadata' as type, nodes
" as query
call apoc.export.json.query(query, '/export/api/communities.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

match (p:DidPrefix)
delete p;
match (n:Account)
with distinct left(n.did, 11) as didPrefix
create (p:DidPrefix {value:didPrefix});
match (p:DidPrefix)
where size(p.value) < 3
or size(right(p.value,3)) < 3
or right(p.value,3) contains ":"
delete p;

:auto
with "
match (p:DidPrefix)
with p
with collect(right(p.value,3)) as nodes
return $graphVersion as graphVersion, 'did-plc-prefixes' as type, nodes
" as query
call apoc.export.json.query(query, '/export/api/user/did_plc_prefixes.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (p:DidPrefix)
with p
with "
call {
    match (n:Account)
    where n.did starts with $prefix
    and n.weight > 0
    and n.optOut is null
    with n
    order by n.did
    call {
        with n
        match (f:Gigacluster {community: n.community_gigacluster})
        optional match (s:Supercluster {community: n.community_supercluster})
        optional match (c:Cluster {community: n.community_cluster})
        optional match (g:Galaxy {community: n.community_galaxy})
        optional match (e:Nebula {community: n.community_nebula})
        optional match (o:Constellation {community: n.community_constellation})
        with collect('f' + coalesce(f.community)) + collect('s' + coalesce(s.community)) + collect('c' + coalesce(c.community)) + collect('g' + coalesce(g.community)) + collect('e' + coalesce(e.community)) + collect('o' + coalesce(o.community)) as communities where size(communities) > 0
        return communities
    }
    with collect({did: n.did, communities: communities }) as nodes
    return $graphVersion as graphVersion, 'did-plc-prefix-to-dids' as type, nodes
} in transactions
return graphVersion, nodes
" as query, p
call apoc.export.json.query(query, '/export/api/user/byDidPlcPrefix/did_plc_' + right(p.value, 3) + '.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion,
prefix:p.value}} )
yield file, rows, time, done
return file, rows, time, done;

match (p:Prefix)
delete p;
match (n:Account)
with distinct left(n.handle, 3) as prefix
create (p:Prefix {value:prefix});

:auto
with "
match (p:Prefix)
with p
with collect(p.value) as nodes
return $graphVersion as graphVersion, nodes
" as query
call apoc.export.json.query(query, '/export/search/prefixes.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (p:Prefix)
with p
with "
call {
    match (n:Account)
    where n.handle starts with $prefix
    and n.weight > 0
    and not to.optOut=true
    with n
    order by n.handle
    call {
        with n
        match (f:Gigacluster {community: n.community_gigacluster})
        optional match (s:Supercluster {community: n.community_supercluster})
        optional match (c:Cluster {community: n.community_cluster})
        optional match (g:Galaxy {community: n.community_galaxy})
        optional match (e:Nebula {community: n.community_nebula})
        optional match (o:Constellation {community: n.community_constellation})
        with collect('f' + coalesce(f.community)) + collect('s' + coalesce(s.community)) + collect('c' + coalesce(c.community)) + collect('g' + coalesce(g.community)) + collect('e' + coalesce(e.community)) + collect('o' + coalesce(o.community)) as communities where size(communities) > 0
        return communities
    }
    with collect({did: n.did, handle: n.handle, communities: communities }) as nodes
    return $graphVersion as graphVersion, nodes
} in transactions
return graphVersion, nodes
" as query, p
call apoc.export.json.query(query, '/export/api/user/byHandlePrefix/search_' + p.value + '.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion,
prefix:p.value}} )
yield file, rows, time, done
return file, rows, time, done;

// ------------------------------------------------- SKYFEED -------------------------------------------------

//communities to users
//wf[:_]Filament      =>f[:_]Gigacluster             =>s[:_]Supercluster             =>c[:_]Cluster              =>g[:_]Galaxy        =>e[:_]Nebula        =>o[:_]Constellation
//wf                   =>f                          =>s                              =>c                          =>g                  =>e                  =>o
//community_filament   =>community_gigacluster   =>community_supercluster   => community_cluster   =>community_galaxy   =>community_nebula   =>community_constellation

:auto
match (c:Gigacluster)
with c
with "
call {
        match (a:Account {community_gigacluster:$c.community})
        where a.weight > 0
        and a.optOut is null
        with a
        with collect(a.did) as dids where size(dids) > 0
        return dids, $c.community as community
} in transactions
with collect({ community: $c.prefix + coalesce(community), dids: dids}) as nodes
return $graphVersion as graphVersion, 'community-to-did' as type, nodes
" as query, c
call apoc.export.json.query(query, '/export/api/community/' + c.prefix + c.community + '.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion,
c:c}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (c:Supercluster)
with c
with "
call {
        match (a:Account {community_supercluster:$c.community})
        where a.weight > 0
        and a.optOut is null
        with a
        with collect(a.did) as dids where size(dids) > 0
        return dids, $c.community as community
} in transactions
with collect({ community: $c.prefix + coalesce(community), dids: dids}) as nodes
return $graphVersion as graphVersion, 'community-to-did' as type, nodes
" as query, c
call apoc.export.json.query(query, '/export/api/community/' + c.prefix + c.community + '.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion,
c:c}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (c:Cluster)
with c
with "
call {
        match (a:Account {community_cluster:$c.community})
        where a.weight > 0
        and a.optOut is null
        with a
        with collect(a.did) as dids where size(dids) > 0
        return dids, $c.community as community
} in transactions
with collect({ community: $c.prefix + coalesce(community), dids: dids}) as nodes
return $graphVersion as graphVersion, 'community-to-did' as type, nodes
" as query, c
call apoc.export.json.query(query, '/export/api/community/' + c.prefix + c.community + '.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion,
c:c}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (c:Galaxy)
with c
with "
call {
        match (a:Account {community_galaxy:$c.community})
        where a.weight > 0
        and a.optOut is null
        with a
        with collect(a.did) as dids where size(dids) > 0
        return dids, $c.community as community
} in transactions
with collect({ community: $c.prefix + coalesce(community), dids: dids}) as nodes
return $graphVersion as graphVersion, 'community-to-did' as type, nodes
" as query, c
call apoc.export.json.query(query, '/export/api/community/' + c.prefix + c.community + '.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion,
c:c}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (c:Nebula)
with c
with "
call {
        match (a:Account {community_nebula:$c.community})
        where a.weight > 0
        and a.optOut is null
        with a
        with collect(a.did) as dids where size(dids) > 0
        return dids, $c.community as community
} in transactions
with collect({ community: $c.prefix + coalesce(community), dids: dids}) as nodes
return $graphVersion as graphVersion, 'community-to-did' as type, nodes
" as query, c
call apoc.export.json.query(query, '/export/api/community/' + c.prefix + c.community + '.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion,
c:c}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
match (c:Constellation)
with c
with "
call {
        match (a:Account {community_constellation:$c.community})
        where a.weight > 0
        and a.optOut is null
        with a
        with collect(a.did) as dids where size(dids) > 0
        return dids, $c.community as community
} in transactions
with collect({ community: $c.prefix + coalesce(community), dids: dids}) as nodes
return $graphVersion as graphVersion, 'community-to-did' as type, nodes
" as query, c
call apoc.export.json.query(query, '/export/api/community/' + c.prefix + c.community + '.json', {jsonFormat: 'JSON', params: {
graphVersion:$graphVersion,
c:c}} )
yield file, rows, time, done
return file, rows, time, done;

//export top moots
:auto
with "
match (from:Account)
where from.weight > 0
and from.optOut is null
with from
order by from.weight desc
// limit 1000
call {
    with from
    match (from)-[r:(WEIGHTED)]->(to:Account)
    where from <> to
    and r.harmonicWeight > 0
    and to.weight > 0
    and to.optOut is null
    with from, to, r
    order by r.harmonicWeight desc
    limit 20
    return from.did as from_did, collect({toDid: to.did, weight: r.harmonicWeight}) as topMoots
} in transactions of 100 rows
with collect({source: from_did, topMoots: topMoots}) as nodes
return $graphVersion as graphVersion, 'did-to-top20mootdids' as type, nodes" as query
call apoc.export.json.query(query, '/export/shared/topMoots_all_20_per_user.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;


//deprecated

// match (p:Prefix)
// delete p;
// match (n:Account)
// with distinct left(n.handle, 3) as prefix
// create (p:Prefix {value:prefix});

// :auto
// with "
// match (p:Prefix)
// with p
// with collect(p.value) as nodes
// return $graphVersion as graphVersion, nodes
// " as query
// call apoc.export.json.query(query, '/export/api/user/byHandlePrefix/prefixes.json', {jsonFormat: 'JSON', params: {
// graphVersion:$graphVersion}} )
// yield file, rows, time, done
// return file, rows, time, done;

// :auto
// match (p:Prefix)
// with p
// with "
// call {
//     match (n:Account)
//     where n.handle starts with $prefix
//     and n.weight > 0
//     and n.optOut is null
//     with n
//     order by n.handle
//     call {
//         with n
//         match (f:Gigacluster {community: n.community_gigacluster})
//         optional match (s:Supercluster {community: n.community_supercluster})
//         optional match (c:Cluster {community: n.community_cluster})
//         optional match (g:Galaxy {community: n.community_galaxy})
//         optional match (e:Nebula {community: n.community_nebula})
//         optional match (o:Constellation {community: n.community_constellation})
//         with collect('f' + coalesce(f.community)) + collect('s' + coalesce(s.community)) + collect('c' + coalesce(c.community)) + collect('g' + coalesce(g.community)) + collect('e' + coalesce(e.community)) + collect('o' + coalesce(o.community)) as communities where size(communities) > 0
//         return communities
//     }
//     with collect({did: n.did, handle: n.handle, communities: communities }) as nodes
//     return $graphVersion as graphVersion, nodes
// } in transactions
// return graphVersion, nodes
// " as query, p
// call apoc.export.json.query(query, '/export/api/user/byHandlePrefix/search_' + p.value + '.json', {jsonFormat: 'JSON', params: {
// graphVersion:$graphVersion,
// prefix:p.value}} )
// yield file, rows, time, done
// return file, rows, time, done;