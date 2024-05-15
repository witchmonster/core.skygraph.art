:param graphVersion => 4;

:auto
with "
match (n:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster|Filament) where n.community is not null
with n
with collect(n) as nodepool, collect({did: n.did, handle: n.name, cType: labels(n)[0], community: case
        when n:Filament then 'wf'
        when n:Gigacluster then 'f'
        when n:Supercluster then 's'
        when n:Cluster then 'c'
        when n:Galaxy then 'g'
        when n:Nebula then 'e'
        when n:Constellation then 'o'
    end + coalesce(n.community), size: n.size}) as nodes
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
return $graphVersion as graphVersion, nodes, rels" as query
// call apoc.export.json.query(query, '/export/graph_peacock.json', {jsonFormat: 'JSON', params: {
call apoc.export.json.query(query, '/export/shared/graph_peacock.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
    graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
with "
    match (c:Gigacluster|Supercluster|Cluster|Galaxy|Nebula|Constellation)
    with c
    order by c.name
    with collect({name: c.name, community:
    case c.prefix + coalesce(c.community) }) as nodes
    return $graphVersion as graphVersion, nodes
" as query
// call apoc.export.json.query(query, '/search/communities.json', {jsonFormat: 'JSON', params: {
call apoc.export.json.query(query, '/export/shared/communities.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

//communities to users
:auto
with "
match (f:Gigacluster)
call {
        with f
        match (a:Account {community_gigacluster:f.community})
        where a.weight > 0
        and a.optOut is null
        with a, f
        with f.community as community, collect(a.did) as dids where size(dids) > 0
        return dids, community
} in transactions
with collect({ community: 'f' + coalesce(community), dids: dids}) as fdids
return $graphVersion as graphVersion, fdids as communities
" as query
call apoc.export.json.query(query, '/export/shared/communities_to_user_f_Gigacluster.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
with "
match (s:Supercluster)
call {
        with s
        match (a:Account {community_supercluster:s.community})
        where a.weight > 0
        and a.optOut is null
        with a, s
        with s.community as community, collect(a.did) as dids where size(dids) > 0
        return dids, community
} in transactions
with collect({ community: 's' + coalesce(community), dids: dids}) as sdids
return $graphVersion as graphVersion, sdids as communities
" as query
call apoc.export.json.query(query, '/export/shared/communities_to_user_s_Supercluster.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
with "
match (c:Cluster)
call {
        with c
        match (a:Account {community_cluster:c.community})
        where a.weight > 0
        and a.optOut is null
        with a, c
        with c.community as community, collect(a.did) as dids where size(dids) > 0
        return dids, community
} in transactions
with collect({ community: 'c' + coalesce(community), dids: dids}) as cdids
return $graphVersion as graphVersion, cdids as communities
" as query
call apoc.export.json.query(query, '/export/shared/communities_to_user_c_Cluster.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
with "
match (g:Galaxy)
call {
        with g
        match (a:Account {community_galaxy:g.community})
        where a.weight > 0
        and a.optOut is null
        with a, g
        with g.community as community, collect(a.did) as dids where size(dids) > 0
        return dids, community
} in transactions
with collect({ community: 'g' + coalesce(community), dids: dids}) as gdids
return $graphVersion as graphVersion, gdids as communities
" as query
call apoc.export.json.query(query, '/export/shared/communities_to_user_g_Galaxy.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
with "
match (e:Nebula)
call {
        with e
        match (a:Account {community_nebula:e.community})
        where a.weight > 0
        and a.optOut is null
        with a, e
        with e.community as community, collect(a.did) as dids where size(dids) > 0
        return dids, community
} in transactions
with collect({ community: 'e' + coalesce(community), dids: dids}) as edids
return $graphVersion as graphVersion, edids as communities
" as query
call apoc.export.json.query(query, '/export/shared/communities_to_user_e_Nebula.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;

:auto
with "
match (o:Constellation)
call {
        with o
        match (a:Account {community_constellation:o.community})
        where a.weight > 0
        and a.optOut is null
        with a, o
        with o.community as community, collect(a.did) as dids where size(dids) > 0
        return dids, community
} in transactions
with collect({ community: 'o' + coalesce(community), dids: dids}) as odids
return $graphVersion as graphVersion, odids as communities
" as query
call apoc.export.json.query(query, '/export/shared/communities_to_user_o_Constellation.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
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
with collect({source: from_did, topMoots: topMoots}) as topMoots
return $graphVersion as graphVersion, topMoots" as query
call apoc.export.json.query(query, '/export/shared/topMoots_all.json.gz', {jsonFormat: 'JSON', compression: "GZIP", params: {
graphVersion:$graphVersion}} )
yield file, rows, time, done
return file, rows, time, done;