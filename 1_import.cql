// Shutdown Neo4j and run full import (you might need to re-run indexes):
// min Neo4j version: 5.18.1

./bin/neo4j-admin database import full --nodes Timestamp=import/timestamp.csv --nodes Account=import/dids.csv --relationships FOLLOWS=import/follows.csv --relationships LIKED=import/like_counts.csv --relationships REPLIED=import/post_counts.csv --overwrite-destination neo4j

//add indexes

//reminder to rename properties community_xxxx with the next re-import

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

CREATE CONSTRAINT is_parent_supercluster IF NOT EXISTS
FOR ()-[r:IS_PARENT_SUPERCLUSTER]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT is_parent_cluster IF NOT EXISTS
FOR ()-[r:IS_PARENT_CLUSTER]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT is_parent_galaxy IF NOT EXISTS
FOR ()-[r:IS_PARENT_GALAXY]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE CONSTRAINT is_parent_nebula IF NOT EXISTS
FOR ()-[r:IS_PARENT_NEBULA]->()
REQUIRE (r.start, r.end) IS RELATIONSHIP UNIQUE;

CREATE INDEX rel_index_is_parent_filament IF NOT EXISTS FOR ()-[r:IS_PARENT_FILAMENT]->() ON (r.portion);
CREATE INDEX rel_index_is_parent_gigacluster IF NOT EXISTS FOR ()-[r:IS_PARENT_GIGACLUSTER]->() ON (r.portion);
CREATE INDEX rel_index_is_parent_supercluster IF NOT EXISTS FOR ()-[r:IS_PARENT_SUPERCLUSTER]->() ON (r.portion);
CREATE INDEX rel_index_is_parent_cluster IF NOT EXISTS FOR ()-[r:IS_PARENT_CLUSTER]->() ON (r.portion);
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

// Calculate harmonicWeights (up to 2 hours)
// update: with non NVME SSD - can take up to a few days
:auto call custom.calculateWeights('weights.csv') yield filename, rows, time;

// Shut down Neo4j, run the import again with new relationships
./bin/neo4j-admin database import full --nodes Timestamp=import/timestamp.csv --nodes Account=import/dids.csv --relationships FOLLOWS=import/follows.csv --relationships LIKED=import/like_counts.csv --relationships REPLIED=import/post_counts.csv --relationships WEIGHTED=import/weights.csv --overwrite-destination neo4j

// And start Neo4j again

// Import handles
:auto load csv with headers from 'file:///handles.csv' as row
call {
  with row
  match (n:Account {did: row["did:ID"]}) set n.handle=row.handle
} in transactions;