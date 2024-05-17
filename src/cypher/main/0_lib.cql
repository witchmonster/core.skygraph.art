// harmonicWeight
call apoc.custom.declareProcedure('calculateWeights(
    filename::STRING,

    followWeight=7::INT?,
    repliesWeight=62::INT?,
    likesWeight=31::INT?,

    batchSize=100::INT?)::(filename::STRING, time::INT, rows::INT, done::BOOLEAN)',
'with "match (from:Account)
where from.interactions > 0
call {
    with from
    match (from)-[r:(FOLLOWS|REPLIED|LIKED)]-(to:Account)
    where from <> to
        // and to.interactions <> 0
        and id(from) < id(to)
    with from, to, collect(r) as rels
    call {
        with from, rels
        with from, rels, toFloat(from.follows) as follows, toFloat(from.likes) as likes, toFloat(from.replies) as replies, toFloat(from.interactions) as interactions
        unwind rels as r
        with * where startNode(r) = from
        return sum(case

            when r:FOLLOWS then log(2) * (1 - follows/interactions) * "+toString($followWeight)+"
            when r:REPLIED then log(r.count + 1) * (1 - replies/interactions) * "+toString($repliesWeight)+"
            when r:LIKED then log(r.count + 1) * (1 - likes/interactions) * "+toString($likesWeight)+"

        end) as fromWeight
    }
    call {
        with to, rels
        with to, rels, toFloat(to.follows) as follows, toFloat(to.likes) as likes, toFloat(to.replies) as replies, toFloat(to.interactions) as interactions
        unwind rels as r
        with * where startNode(r) = to
        return sum(case

            when r:FOLLOWS then log(2) * (1 - follows/interactions) * "+toString($followWeight)+"
            when r:REPLIED then log(r.count + 1) * (1 - replies/interactions) * "+toString($repliesWeight)+"
            when r:LIKED then log(r.count + 1) * (1 - likes/interactions) * "+toString($likesWeight)+"

        end) as toWeight
    }
    with * where fromWeight + toWeight > 0
    with from, to, fromWeight, toWeight,
        (2*fromWeight*toWeight / (fromWeight + toWeight)) as harmonicWeight

    return from.did as from_did, to.did as to_did, harmonicWeight, fromWeight, toWeight
} in transactions of "+toString($batchSize)+" rows
with from_did, to_did, harmonicWeight, fromWeight, toWeight where fromWeight + toWeight > 0
unwind [
    {from: from_did, to: to_did, weight: fromWeight, harmonicWeight: harmonicWeight},
    {from: to_did, to: from_did, weight: toWeight, harmonicWeight: harmonicWeight}
] as edge
with edge where edge.weight > 0
return edge.from as `:START_ID`, edge.to as `:END_ID`, edge.harmonicWeight as `harmonicWeight:double`, edge.weight as `weight:double`" as query
call apoc.export.csv.query(query, $filename, {stream: true, quotes: "ifNeeded"})
yield file, time, rows, done
with * where done = true
return file as filename, time, rows, done',
'read',
'Calculates relationship weights between all pairs of nodes that have any and writes them to a file.

1) assigns global weights* to likes, replies, follows
2) for each interaction, multiply by personal significance ratio*: (1 - from.replies/from.interactions) and take a logarithm on count
3) take a sum of all weighted logarithmic interations

*more here, need to request full text https://www.researchgate.net/publication/283025686_Using_the_interaction_on_social_networks_to_predict_real_life_friendship

');
