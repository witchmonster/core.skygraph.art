// leiden runs are non-deterministic, every run even on stable gamma will generate slightly different communities
:param graphVersion => 5;

// FLR - follows, likes, replies

// NOAGGR - no aggregation applied

// COUNT - weight of each input edge A->B is defined as total count of interactions of this type between A and B

// UDSUM - aggregation function for directed->undirected graph Leiden transformation
// i.e. input edges for the Leiden is r, where A-[r:FOLLOWS:LIKED:REPLIED]->B, weight is r.count and aggregation method is {aggregation:'SUM'}

// WPSLOGSUM - interactions between A and B are aggregated using a weighted logarithmic sum with personal significance.
// wpslogsum(f,l.count,r.count)=sum(fw*fs*log(2) + lw*ls*log(l.count)+ rw*rs*log(r.count))
// weights: fw=7, lw=31, rw=62;
// personal significanse: fs=1-1/sum(f,l.count,r.count), ls=1-l.count/sum(f,l.count,r.count), rs=1-r/sum(f,l.count,r.count))
// i.e. edges r, A-[r:FOLLOWS:LIKED:REPLIED]->B, are aggregated to new edges ar, where A-[ar:WEIGHTED]->B and ar.weight = wpslogsum(f,l.count,r.count)

// MOOTHAVG - weight of each input edge is defined as harmonic average, applied to mutual interactions
// e.g.: if A-[rAB:WEIGHTED]->B, arAB.weight = 10 and  B-[arBA:WEIGHTED]->A, arBA.weight = 1, set harmonicWeight=1.8182	to both arAB and arBA
// note: setting the same weight to both relationships effectively pre-renders graph as "undirected", since edge weight from A to B in either direction are either zero or equals to the one in opposite direction

// UDMAX - aggregation function for directed->undirected graph Leiden transformation
// i.e. input edges for the Leiden is r, where A-[ar:WEIGHTED]->B, weight is ar.harmonicWeight and aggregation method is {aggregation:'MAX'}
// notes: given previous MOOTHAVG weight aggregation and weights both directions are already equal, it does not matter whether you use MAX, MIN or SUM here.
// if you'd like to skip the costly step of harmonic weight calculation,
// you could skip MOOTHAVG and only use MAX on Leiden. this will produce similar results, since harmonicAverage() function is very close to max() function

// Supergalactic entities
// https://en.wikipedia.org/wiki/Galaxy_filament
// https://en.wikipedia.org/wiki/Supercluster
// https://en.wikipedia.org/wiki/Galaxy_cluster

// non-galactic entities
// https://en.wikipedia.org/wiki/Globular_cluster
// https://en.wikipedia.org/wiki/Super_star_cluster
// https://en.wikipedia.org/wiki/Open_cluster
// https://en.wikipedia.org/wiki/Embedded_cluster

// other entities
// https://en.wikipedia.org/wiki/Dark_galaxy

// galactic entities
// https://en.wikipedia.org/wiki/Galaxy


// subgalactic non-astronomic formations

// https://en.wikipedia.org/wiki/Nebula
// https://en.wikipedia.org/wiki/Constellation



// ---------------- mode: WEAK (FLR->NOAGGR->COUNT->UDSUM) -------------------
//non-mutual interactions count towards gravity

// galaxy filaments
// https://en.wikipedia.org/wiki/Galaxy_filament
// enourmous formations, largest in the universe e.g. Japanese language cluster (over 1.3 mil accounts)
// used to guide filaments only, real filaments will be built as groups of superclusters
:param filamentGamma => 1;
// enormous formations
// filaments - ~80% of accounts reside in filaments

// unused
// :param galaxyUnderlayGamma => 30;
// ---------------- mode: WEAK (FLR->NOAGGR->COUNT->UDSUM) -------------------


// ---------------- mode: STRONG (FLR->WSLOGSUM->MOOTHAVG->UDMAX) -------------------

// ~40% of accounts reside in strong communities
// https://lexx.fandom.com/wiki/Giga_Shadow
// “It is the end, and the beginning.” — His Divine Shadow
:param gigaclusterGamma => 1;
// https://en.wikipedia.org/wiki/Supercluster
:param superclusterGamma => 5;
// https://en.wikipedia.org/wiki/Galaxy_cluster
:param clusterGamma => 10;
// https://en.wikipedia.org/wiki/Galaxy
:param galaxyGamma => 24;
// https://en.wikipedia.org/wiki/Nebula
:param nebulaGamma => 100;
// https://en.wikipedia.org/wiki/Constellation
:param constellationGamma => 200;

// ---------------- mode: STRONG (FLR->WSLOGSUM->MOOTHAVG->UDMAX) -------------------

// -------------------- Filaments --------------------

call gds.graph.drop('undirected_filament', false);
CALL gds.graph.project(
  'undirected_filament',
  'Account',
// {
//   FOLLOWS: {
//     orientation: 'UNDIRECTED' },
//   REPLIED: {
//     orientation: 'UNDIRECTED',
//     properties: {count: {aggregation:'SUM'}}},
//   LIKED: {
//     orientation: 'UNDIRECTED',
//     properties: {count: {aggregation:'SUM'}}}
// }
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {weight: {aggregation:'SUM'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// call gds.graph.nodeProperties.drop('undirected_filament', 'community_filament');
CALL gds.leiden.mutate('undirected_filament', { mutateProperty: 'community_filament', gamma: $filamentGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_filament', 'community_filament');

// -------------------- Filaments --------------------

// -------------------- Galaxy underlays --------------------

// call gds.graph.drop('undirected_galaxyunderlay', false);
// CALL gds.graph.project(
//   'undirected_galaxyunderlay',
//   'Account',
// {
//   FOLLOWS: {
//     orientation: 'UNDIRECTED' },
//   REPLIED: {
//     orientation: 'UNDIRECTED',
//     properties: {count: {aggregation:'SUM'}}},
//   LIKED: {
//     orientation: 'UNDIRECTED',
//     properties: {count: {aggregation:'SUM'}}}
// }
// )
// YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// // call gds.graph.nodeProperties.drop('undirected_galaxyunderlay', 'community_galaxyunderlay');
// CALL gds.leiden.mutate('undirected_galaxyunderlay', { mutateProperty: 'community_galaxyunderlay', gamma: $galaxyUnderlayGamma })
// YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
// call gds.graph.nodeProperties.write('undirected_galaxyunderlay', 'community_galaxyunderlay');

// -------------------- Galaxy underlays --------------------

// ---------------------------------------------------------- WEAK ^ -----------------------------------------


// ---------------------------------------------------------- STRONG -----------------------------------------

// -------------------- Gigaclusters --------------------

// Create graph
call gds.graph.drop('undirected_gigacluster', false);
CALL gds.graph.project(
  'undirected_gigacluster',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// Run Leiden
// call gds.graph.nodeProperties.drop('undirected_gigacluster', 'community_gigacluster');
CALL gds.leiden.mutate('undirected_gigacluster', { mutateProperty: 'community_gigacluster', relationshipWeightProperty: 'harmonicWeight', gamma: $gigaclusterGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_gigacluster', 'community_gigacluster');

// -------------------- Gigaclusters --------------------



// -------------------- Superclusters --------------------

// Create graph
call gds.graph.drop('undirected_supercluster', false);
CALL gds.graph.project(
  'undirected_supercluster',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// Run Leiden
// call gds.graph.nodeProperties.drop('undirected_supercluster', 'community_supercluster');
CALL gds.leiden.mutate('undirected_supercluster', { mutateProperty: 'community_supercluster', relationshipWeightProperty: 'harmonicWeight', gamma: $superclusterGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_supercluster', 'community_supercluster');

// -------------------- Superclusters --------------------



// -------------------- Clusters --------------------

// Create graph
call gds.graph.drop('undirected_cluster', false);
CALL gds.graph.project(
  'undirected_cluster',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// Run Leiden
// call gds.graph.nodeProperties.drop('undirected_cluster', 'community_cluster');
CALL gds.leiden.mutate('undirected_cluster', { mutateProperty: 'community_cluster', relationshipWeightProperty: 'harmonicWeight', gamma: $clusterGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_cluster', 'community_cluster');

// -------------------- Clusters --------------------

// -------------------- Galaxies --------------------

// Create graph
call gds.graph.drop('undirected_galaxy', false);
CALL gds.graph.project(
  'undirected_galaxy',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)
YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// Run Leiden
// call gds.graph.nodeProperties.drop('undirected_galaxy', 'community_galaxy');
CALL gds.leiden.mutate('undirected_galaxy', { mutateProperty: 'community_galaxy', relationshipWeightProperty: 'harmonicWeight', gamma: $galaxyGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_galaxy', 'community_galaxy');

// -------------------- Galaxies --------------------


// -------------------- Nebulas --------------------

call gds.graph.drop('undirected_nebula', false);
CALL gds.graph.project(
  'undirected_nebula',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)

YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// call gds.graph.nodeProperties.drop('undirected_nebula', 'community_nebula');
CALL gds.leiden.mutate('undirected_nebula', { mutateProperty: 'community_nebula', relationshipWeightProperty: 'harmonicWeight', gamma: $nebulaGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_nebula', 'community_nebula');

// -------------------- Nebulas --------------------


// -------------------- Constellations --------------------

call gds.graph.drop('undirected_constellation', false);
CALL gds.graph.project(
  'undirected_constellation',
  'Account',
  {WEIGHTED: {
    orientation: 'UNDIRECTED',
    properties: {harmonicWeight: {aggregation:'MAX'}}}}
)

YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// call gds.graph.nodeProperties.drop('undirected_constellation', 'community_constellation');
CALL gds.leiden.mutate('undirected_constellation', { mutateProperty: 'community_constellation', relationshipWeightProperty: 'harmonicWeight', gamma: $constellationGamma })
YIELD didConverge, ranLevels, modularity, communityCount, modularities, communityDistribution;
call gds.graph.nodeProperties.write('undirected_constellation', 'community_constellation');

// -------------------- Constellations --------------------