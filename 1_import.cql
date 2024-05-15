//Use `neo4j.conf` and `apoc.conf` for your Neo4j Desktop setup\
// min Neo4j version: 5.18.1

// you'll need data dumps (up to 15GB per file for full import and up to 2GB for monthly, files are not included):
// follows.csv
// like_counts.csv
// post_counts.csv
// handles.csv
// optout.csv
// dids.csv
// timestamp.csv

// note: for Windows, replace `./bin/neo4j-admin` with `..\bin\neo4j-admin.bat `

// Shutdown Neo4j and run full import:
./bin/neo4j-admin database import full --nodes Timestamp=import/timestamp.csv --nodes Account=import/dids.csv --relationships FOLLOWS=import/follows.csv --relationships LIKED=import/like_counts.csv --relationships REPLIED=import/post_counts.csv --overwrite-destination fullv4

//import monthly data into a separate db
./bin/neo4j-admin database import full --nodes Timestamp=import/monthly/timestamp.csv --nodes Account=import/monthly/dids.csv --relationships FOLLOWS=import/monthly/follows.csv --relationships LIKED=import/monthly/like_counts.csv --relationships REPLIED=import/monthly/post_counts.csv --overwrite-destination monthlyv4

//add indexes (same for both dbs)
start database fullv4
:use fullv4

// start database monthlyv4
// :use monthlyv4

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
create index interactions IF NOT EXISTS for (n:Account) on (n.interactions);
create index replies IF NOT EXISTS for (n:Account) on (n.replies);
create index likes IF NOT EXISTS for (n:Account) on (n.likes);
create index follows IF NOT EXISTS for (n:Account) on (n.follows);
create index community IF NOT EXISTS for (n:Account) on (n.community);

create index communityNameFilament IF NOT EXISTS for (n:Account) on (n.communityNameFilament);
create index communityNameGigacluster IF NOT EXISTS for (n:Account) on (n.communityNameGigacluster);
create index communityNameSupercluster IF NOT EXISTS for (n:Account) on (n.communityNameSupercluster);
create index communityNameCluster IF NOT EXISTS for (n:Account) on (n.communityNameCluster);
create index communityNameGalaxy IF NOT EXISTS for (n:Account) on (n.communityNameGalaxy);
create index communityNameNebula IF NOT EXISTS for (n:Account) on (n.communityNameNebula);
create index communityNameConstellation IF NOT EXISTS for (n:Account) on (n.communityNameConstellation);

create index communityFilament IF NOT EXISTS for (n:Account) on (n.community_filament);
create index communityGigacluster IF NOT EXISTS for (n:Account) on (n.community_gigacluster);
create index communitySupecluster IF NOT EXISTS for (n:Account) on (n.community_supercluster);
create index communityCluster IF NOT EXISTS for (n:Account) on (n.community_cluster);
create index communityGalaxy IF NOT EXISTS for (n:Account) on (n.community_galaxy);
create index communityNebula IF NOT EXISTS for (n:Account) on (n.community_nebula);
create index communityConstellation IF NOT EXISTS for (n:Account) on (n.community_constellation);

// run lib.cql

// Count likes, posts, follows of each user
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

// Calculate harmonicWeights (up to 2 hours for full dataset)
// update: with non NVME SSD - can take up to a few days
:auto call custom.calculateWeights('weights.csv') yield filename, rows, time;

// Shut down Neo4j, run the import again with new relationships
./bin/neo4j-admin database import full --nodes Timestamp=import/timestamp.csv --nodes Account=import/dids.csv --relationships FOLLOWS=import/follows.csv --relationships LIKED=import/like_counts.csv --relationships REPLIED=import/post_counts.csv --relationships WEIGHTED=import/weights.csv --overwrite-destination fullv4

//same for monthlyv4
:use monthlyv4
:auto call custom.calculateWeights('monthly/weights.csv') yield filename, rows, time;

// Shut down Neo4j, run the import again with new relationships
./bin/neo4j-admin database import full --nodes Timestamp=import/monthly/timestamp.csv --nodes Account=import/monthly/dids.csv --relationships FOLLOWS=import/monthly/follows.csv --relationships LIKED=import/monthly/like_counts.csv --relationships REPLIED=import/monthly/post_counts.csv --relationships WEIGHTED=import/monthly/weights.csv --overwrite-destination monthlyv4


// optional and experimental (instead of full import above)
// a fake file empty.csv in the import dir with just one line:
// did:ID{label:Account}
// ./bin/neo4j-admin database import incremental --force --relationships WEIGHTED=import/weights.csv --nodes Account=import/empty.csv fullv4

// ./bin/neo4j-admin database import incremental --force --relationships WEIGHTED=import/monthly/weights.csv --nodes Account=import/empty.csv monthlyv4


// And start Neo4j again

// Import handles to full
:auto load csv with headers from 'file:///handles.csv' as row
call {
  with row
  match (n:Account {did: row["did:ID"]}) set n.handle=row.handle
} in transactions;

// Import handles to monthly
:use monthlyv4
:auto load csv with headers from 'file:///monthly/handles.csv' as row
call {
  with row
  match (n:Account {did: row["did:ID"]}) set n.handle=row.handle
} in transactions;