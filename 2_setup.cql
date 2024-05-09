// Set weight to each node
:auto
match (from:Account)
where from.weight is null
with from
call {
    with from
    match (from)-[r:WEIGHTED]->(to:Account)
    where from <> to
    and r.harmonicWeight > 0
    with from, to, r
    order by r.harmonicWeight desc
    with from, to, collect(distinct r) as rels
    call {
        with from, rels
        unwind rels as r
        with * where startNode(r) = from
        return sum(r.harmonicWeight) as perFriendWeight
    }
    with from, sum(perFriendWeight) as weight
    set from.weight = weight
} in transactions of 100000 rows
return count(from);

match (n:Account)
where n.weight is null
set n.weight = 0;

CALL apoc.load.csv('optout.csv') YIELD list
unwind list as item
match (node:Account {did: item})
set node.optOut = true;