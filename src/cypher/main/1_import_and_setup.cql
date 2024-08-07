// Setup: 32GB RAM min, 64GB recommended
// 100GB free space, 500GB recommended
// 6-core CPU min, 8 core recommended
// NVME SSD - a MUST unless you're ready to wait a few days for the queries to finish

// NOTE: run each step carefully, don't try to copy-paste and run this whole file :P
// it will take up to 3 hours to get everything done if you have good hardware
// grab some tea/something to play or watch while waiting for imports to get done

// Install Neo4j Desktop: https://neo4j.com/download
// DO NOT USE Neo4j with Docker or any of the enterprise versions! Community edition only. Read the license carefully otherwise.
// min Neo4j version: 5.19.0

// Add lines from `neo4j.conf` and `apoc.conf` to your Neo4j settings

// Install Plugins:
// APOC (Install through Neo4j desktop)
// Graph Data Science Library (Install through Neo4j desktop)
// APOC-extended: Download and copy to Plugins folder https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/5.19.0/apoc-5.19.0-extended.jar

// you'll need data dumps (up to 15GB per file for full import and up to 2GB for monthly, files are not included):
// follows.csv
// like_counts.csv
// post_counts.csv
// handles.csv
// optout.csv
// dids.csv
// timestamp.csv

// you may use Bsky Relay or other Bsky indexers to get the exports
// csv headers must be:
// :START_ID, :END_ID - for follows.csv
// :START_ID, :END_ID, count:long - for like_counts.csv and post_counts.csv
// did:ID, - for dids.csv
// handle, did:ID - for handles.csv
// export_start - for timestamp.csv
// did - for optout.csv

// It is strongly recommended to weigh like and reply counts on a temporal basis with a 360 day cutoff
// here's an SQL snippet on how to do it, use this:
    count(*) FILTER (WHERE records.created_at > CURRENT_DATE - INTERVAL '30' DAY) * 10 +
    count(*) FILTER (WHERE records.created_at > CURRENT_DATE - INTERVAL '60' DAY) * 5 +
    count(*) FILTER (WHERE records.created_at > CURRENT_DATE - INTERVAL '90' DAY) * 3 +
    count(*) FILTER (WHERE records.created_at > CURRENT_DATE - INTERVAL '360' DAY) * 1 as "count:long"
// instead of `count(*)` in your export queries for like and reply counts
// it will prevent formation of bad quality communities due to older users with too many interactions, that are no longer relevant

// ------------------------------ BULK IMPORT CSVS (few minutes) ------------------------------

cd $NEO4J_HOME/import

// If using Neo4j Desktop, create dbs (`monthlyv6`, `fullv6`) through Neo4j Desktop UI first, before using neo4j-admin
// note: for Windows, replace `./bin/neo4j-admin` with `..\bin\neo4j-admin.bat `

// Shutdown Neo4j and run full import:
./bin/neo4j-admin database import full --nodes Timestamp=import/timestamp.csv --nodes Account=import/dids.csv --relationships FOLLOWS=import/follows.csv --relationships LIKED=import/like_counts.csv --relationships REPLIED=import/post_counts.csv --overwrite-destination fullv6

//import monthly data into a separate db
./bin/neo4j-admin database import full --nodes Timestamp=import/monthly/timestamp.csv --nodes Account=import/monthly/dids.csv --relationships FOLLOWS=import/monthly/follows.csv --relationships LIKED=import/monthly/like_counts.csv --relationships REPLIED=import/monthly/post_counts.csv --overwrite-destination monthlyv6

// ------------------------------ BULK IMPORT CSVS ------------------------------



// ------------------------------ AGGREGATE INTERACTIONS (minutes) ------------------------------

// Start Neo4j DB

// run all cypher queries for both dbs. switch between dbs:
:use fullv6
:use monthlyv6


//--------------IMPORTANT!----------------

// Make sure you turn off wsl and set neo4j.conf default listen address to 0.0.0.0 ------------------------------
// more info here: https://stackoverflow.com/questions/78331154/why-is-my-neo4j-server-now-10x-slower-since-switching-to-wsl-and-then-back-to-wi


//--------------IMPORTANT!----------------


// create necessary indexes for aggregation
CREATE CONSTRAINT account_unique IF NOT EXISTS
FOR (n:Account)
REQUIRE n.did IS UNIQUE;
create index interactions IF NOT EXISTS for (n:Account) on (n.interactions);
create index replies IF NOT EXISTS for (n:Account) on (n.replies);
create index likes IF NOT EXISTS for (n:Account) on (n.likes);
create index follows IF NOT EXISTS for (n:Account) on (n.follows);

//apparently somehow empty dids are now possible (could be non-plc did?)
match (n:Account)
where n.did=''
detach delete n;

// Count likes, posts, follows of each user (can take up to 15 min)
:auto match (n:Account)
call {
  with n
  with n, count {(n)-[:FOLLOWS]->()} as follows
  call { with n match (n)-[r:LIKED]->() return sum(r.count) as likes}
  call { with n match (n)-[r:REPLIED]->() return sum(r.count) as replies}
  set n.interactions = follows + likes + replies,
  n.follows = follows,
  n.likes = likes,
  n.replies = replies
} in transactions;

//--------------IMPORTANT!----------------

// If it runs longer than a minute to update first 300k nodes - you have a networking issue described above!

//--------------IMPORTANT!----------------

// ------------------------------ AGGREGATE INTERACTIONS ------------------------------



// ------------------------------ EXPORT WEIGHTS (few hours) ------------------------------

// run 0_lib.cql

// Calculate harmonicWeights (up to 3 hours for full dataset)
// update: with non-NVME SSD - can take up to a few days
:use fullv6
:auto call custom.calculateWeights('weights.csv') yield filename, rows, time;

//same for monthlyv6
:use monthlyv6
:auto call custom.calculateWeights('monthly/weights.csv') yield filename, rows, time;

// ------------------------------ EXPORT WEIGHTS ------------------------------



// ------------------------------ RE-IMPORT WITH WEIGHTS (up to half an hour) ------------------------------

// bulk import is the fastest way to do this, don't try the LOAD CSV stuff, it will take forever

// Shut down Neo4j, run the import again with new relationships for both dbs
// note: for Windows, replace `./bin/neo4j-admin` with `..\bin\neo4j-admin.bat `

//in case if you need FOLLOWS LIKES and REPLIES as separate relationships, it will slow down the database significantly and will double it's size
./bin/neo4j-admin database import full --nodes Timestamp=import/timestamp.csv --nodes Account=import/dids.csv --relationships FOLLOWS=import/follows.csv --relationships LIKED=import/like_counts.csv --relationships REPLIED=import/post_counts.csv --relationships WEIGHTED=import/weights.csv --overwrite-destination fullv6
//otherwise it's recommended to run it with only weighted rels:
./bin/neo4j-admin database import full --nodes Timestamp=import/timestamp.csv --nodes Account=import/dids.csv --relationships WEIGHTED=import/weights.csv --overwrite-destination fullv6

// same for monthly
./bin/neo4j-admin database import full --nodes Timestamp=import/monthly/timestamp.csv --nodes Account=import/monthly/dids.csv --relationships FOLLOWS=import/monthly/follows.csv --relationships LIKED=import/monthly/like_counts.csv --relationships REPLIED=import/monthly/post_counts.csv --relationships WEIGHTED=import/monthly/weights.csv --overwrite-destination fullv6
//no likes/follows/replies, only weighted
./bin/neo4j-admin database import full --nodes Timestamp=import/monthly/timestamp.csv --nodes Account=import/monthly/dids.csv --relationships WEIGHTED=import/monthly/weights.csv --overwrite-destination monthlyv6

// And start Neo4j again

// ------------------------------ RE-IMPORT WITH WEIGHTS ------------------------------



// ------------------------------ CREATE INDEXES (few minutes) ------------------------------

//add indexes (same for both dbs)
:use fullv6
:use monthlyv6

CREATE CONSTRAINT account_unique IF NOT EXISTS
FOR (n:Account)
REQUIRE n.did IS UNIQUE;

CREATE CONSTRAINT filament_unique IF NOT EXISTS
FOR (n:Filament)
REQUIRE n.community IS UNIQUE;
CREATE CONSTRAINT gigacluster_unique IF NOT EXISTS
FOR (n:Gigacluster)
REQUIRE n.community IS UNIQUE;
CREATE CONSTRAINT supercluster_unique IF NOT EXISTS
FOR (n:Supercluster)
REQUIRE n.community IS UNIQUE;
CREATE CONSTRAINT cluster_unique IF NOT EXISTS
FOR (n:Cluster)
REQUIRE n.community IS UNIQUE;
CREATE CONSTRAINT galaxy_unique IF NOT EXISTS
FOR (n:Galaxy)
REQUIRE n.community IS UNIQUE;
CREATE CONSTRAINT nebula_unique IF NOT EXISTS
FOR (n:Nebula)
REQUIRE n.community IS UNIQUE;
CREATE CONSTRAINT constellation_unique IF NOT EXISTS
FOR (n:Constellation)
REQUIRE n.community IS UNIQUE;

CREATE CONSTRAINT weighted_unique IF NOT EXISTS
FOR ()-[r:WEIGHTED]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT is_parent_filament IF NOT EXISTS
FOR ()-[r:IS_PARENT_FILAMENT]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT IS_PARENT_GIGACLUSTER IF NOT EXISTS
FOR ()-[r:IS_PARENT_GIGACLUSTER]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT is_parent_supercluster IF NOT EXISTS
FOR ()-[r:IS_PARENT_SUPERCLUSTER]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT IS_PARENT_CLUSTER IF NOT EXISTS
FOR ()-[r:IS_PARENT_CLUSTER]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT is_parent_galaxy IF NOT EXISTS
FOR ()-[r:IS_PARENT_GALAXY]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT is_parent_nebula IF NOT EXISTS
FOR ()-[r:IS_PARENT_NEBULA]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE INDEX rel_index_is_parent_filament IF NOT EXISTS FOR ()-[r:IS_PARENT_FILAMENT]->() ON (r.portion);
CREATE INDEX rel_index_IS_PARENT_GIGACLUSTER IF NOT EXISTS FOR ()-[r:IS_PARENT_GIGACLUSTER]->() ON (r.portion);
CREATE INDEX rel_index_is_parent_supercluster IF NOT EXISTS FOR ()-[r:IS_PARENT_SUPERCLUSTER]->() ON (r.portion);
CREATE INDEX rel_index_IS_PARENT_CLUSTER IF NOT EXISTS FOR ()-[r:IS_PARENT_CLUSTER]->() ON (r.portion);
CREATE INDEX rel_index_is_parent_galaxy IF NOT EXISTS FOR ()-[r:IS_PARENT_GALAXY]->() ON (r.portion);
CREATE INDEX rel_index_is_parent_nebula IF NOT EXISTS FOR ()-[r:IS_PARENT_NEBULA]->() ON (r.portion);

CREATE INDEX rel_index_weighted_weight IF NOT EXISTS FOR ()-[r:WEIGHTED]->() ON (r.weight);
CREATE INDEX rel_index_hweighted_weight IF NOT EXISTS FOR ()-[r:WEIGHTED]->() ON (r.harmonicWeight);

// add index for handle
create index handle IF NOT EXISTS  for (n:Account) on (n.handle);
create index weight IF NOT EXISTS  for (n:Account) on (n.weight);
create index optOut IF NOT EXISTS  for (n:Account) on (n.optOut);

// only if you added FOLLOWS, LIKES and REPLIES to your second full import
create index interactions IF NOT EXISTS for (n:Account) on (n.interactions);
create index replies IF NOT EXISTS for (n:Account) on (n.replies);
create index likes IF NOT EXISTS for (n:Account) on (n.likes);
create index follows IF NOT EXISTS for (n:Account) on (n.follows);

//probably unused
// create index community IF NOT EXISTS for (n:Account) on (n.community);

create index communityFilament IF NOT EXISTS for (n:Account) on (n.community_filament);
create index communityGigacluster IF NOT EXISTS for (n:Account) on (n.community_gigacluster);
create index communitySupecluster IF NOT EXISTS for (n:Account) on (n.community_supercluster);
create index communityCluster IF NOT EXISTS for (n:Account) on (n.community_cluster);
create index communityGalaxy IF NOT EXISTS for (n:Account) on (n.community_galaxy);
create index communityNebula IF NOT EXISTS for (n:Account) on (n.community_nebula);
create index communityConstellation IF NOT EXISTS for (n:Account) on (n.community_constellation);

//optional, needed for labeling only
// create index communityNameFilament IF NOT EXISTS for (n:Account) on (n.communityNameFilament);
// create index communityNameGigacluster IF NOT EXISTS for (n:Account) on (n.communityNameGigacluster);
// create index communityNameSupercluster IF NOT EXISTS for (n:Account) on (n.communityNameSupercluster);
// create index communityNameCluster IF NOT EXISTS for (n:Account) on (n.communityNameCluster);
// create index communityNameGalaxy IF NOT EXISTS for (n:Account) on (n.communityNameGalaxy);
// create index communityNameNebula IF NOT EXISTS for (n:Account) on (n.communityNameNebula);
// create index communityNameConstellation IF NOT EXISTS for (n:Account) on (n.communityNameConstellation);

// ------------------------------ CREATE INDEXES ------------------------------



// ------------------------------ IMPORT HANDLES (up to 10-15 minutes) ------------------------------

// Import handles to full
:use fullv6
:auto load csv with headers from 'file:///handles.csv' as row
call {
  with row
  match (n:Account {did: row["did:ID"]})
  where n.handle is null
  set n.handle=row.handle
} in transactions;

// to fix corrupted handles:
// grep -v '\\\\\\' handles.csv > temp && mv temp handles.csv

grep -v '\\\\\\' handles.csv > handles_fixed.csv

// Import handles to monthly
:use monthlyv6
:auto load csv with headers from 'file:///monthly/handles.csv' as row
call {
  with row
  match (n:Account {did: row["did:ID"]})
  where n.handle is null
  set n.handle=row.handle
} in transactions;

// ------------------------------ IMPORT HANDLES ------------------------------



// ------------------------------ CALCULATE TOTAL PERSONAL WEIGHTS (up to an hour) ------------------------------

// Set weight to each node (can take up to an hour)
// run below queries for both dbs
:use fullv6
:use monthlyv6

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
} in transactions
return count(from);

match (n:Account)
where n.weight is null
set n.weight = 0;

// ------------------------------ CALCULATE TOTAL PERSONAL WEIGHTS ------------------------------



// ------------------------------ IMPORT OPTOUTS (very fast) ------------------------------

//Import optouts
CALL apoc.load.csv('optout.csv') YIELD list
unwind list as item
match (node:Account {did: item})
set node.optOut = true;

// ------------------------------ IMPORT OPTOUTS ------------------------------



// ------------------------------ IMPORT BLOCKS (up to an hour) ------------------------------

:auto load csv with headers from 'file:///blocks.csv' as row
call {
  with row
  match (c:Account {did: row[":START_ID"]})
  match (n:Account {did: row[":END_ID"]})
  MERGE (c)-[:BLOCKS]->(n)
} in transactions;

// ------------------------------ IMPORT BLOCKS ----------------------------------------------