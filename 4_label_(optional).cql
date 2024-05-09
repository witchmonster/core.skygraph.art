//clear all labels
match (n:Account) where n.communityNameGigacluster is not null remove n.communityNameGigacluster;
match (n:Account) where n.communityNameSupercluster is not null remove n.communityNameSupercluster;
match (n:Account) where n.communityNameCluster is not null remove n.communityNameNebula;
match (n:Account) where n.communityNameGalaxy is not null remove n.communityNameGalaxy;
match (n:Account) where n.communityNameNebula is not null remove n.communityNameNebula;
match (n:Account) where n.communityNameNebula is not null remove n.communityNameNebula;

//--------- test galaxies ------------
match (n:Account {handle: 'killustration.bsky.social'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'artists';

match (n:Account {handle: 'jalpari.bsky.social'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'writers';

match (n:Account {handle: 'cactimutt.bsky.social'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'furry';

match (n:Account {handle: 'malwarejake.bsky.social'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'infosec';

match (n:Account {handle: 'lookitup.baby'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'tech';

match (n:Account {handle: 'pfrazee.com'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'startup';

match (n:Account {handle: 'gamedevlist.bsky.social'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'gamedev';

match (n:Account {handle: 'onsu.re'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'web3';

match (n:Account {handle: 'jaz.bsky.social'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'jaz-galaxy';

//--------- test nebulas ------------
match (n:Account {handle: 'jaz.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'jaz-nebula';

match (n:Account {handle: 'pfrazee.com'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'pfrazee-nebula';

match (n:Account {handle: 'retr0.id'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'retroid-nebula';

match (n:Account {handle: 'why.bsky.team'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'why-nebula';