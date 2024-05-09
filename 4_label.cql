//clear all labels
match (n:Account) where n.communityNameGigacluster is not null remove n.communityNameGigacluster;
match (n:Account) where n.communityNameSupercluster is not null remove n.communityNameSupercluster;
match (n:Account) where n.communityNameCluster is not null remove n.communityNameNebula;
match (n:Account) where n.communityNameGalaxy is not null remove n.communityNameGalaxy;
match (n:Account) where n.communityNameNebula is not null remove n.communityNameNebula;
match (n:Account) where n.communityNameNebula is not null remove n.communityNameNebula;

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

//new since ver.2
match (n:Account {handle: 'jaz.bsky.social'})
match (m:Account {community_galaxy: n.community_galaxy})
set m.communityNameGalaxy = 'jaz-harmonic';

//--------- test nebulas ------------
match (n:Account {handle: 'bsky.church'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-church';

match (n:Account {handle: 'mohican.tech'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-fun';

match (n:Account {handle: 'gniv.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-artists';

match (n:Account {handle: 'kanadenka.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-write';

match (n:Account {handle: 'holyagnostic.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-gamers';

match (n:Account {handle: 'isimon.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-tech1';

match (n:Account {handle: 'kgirlkkk.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-kpop';

match (n:Account {handle: 'kcher.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-books1';

match (n:Account {handle: 'psyhfuck.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-books2';

match (n:Account {handle: 'asaminana.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-books3';

match (n:Account {handle: 'hradspain.com'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-books4';

match (n:Account {handle: 'bookpleasure.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-books5';

match (n:Account {handle: 'kukukhagoodbye.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-books6';

match (n:Account {handle: 'sixteen.cats.ukr.blue'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-sixteencats';

match (n:Account {handle: 'ivanko.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-tech2';

match (n:Account {handle: 'paula4.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-mytsi1';

match (n:Account {handle: 'thousandblossom.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-mytsi2';

match (n:Account {handle: 'eklesa.ukr.blue'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-mytsi3';

match (n:Account {handle: 'kyivskyiolen.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-mytsi4';

match (n:Account {handle: 'elfes.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-mytsi5';

match (n:Account {handle: 'die-bitches-die.today'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-dids';

match (n:Account {handle: 'wolfigelkott.crimea.ua'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'ua-woof';

//test some other nebulas
match (n:Account {handle: 'jaz.bsky.social'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'jaz-detailed';

match (n:Account {handle: 'pfrazee.com'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'pfrazee-detailed';

match (n:Account {handle: 'retr0.id'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'retroid-detailed';

match (n:Account {handle: 'why.bsky.team'})
match (m:Account {community_nebula: n.community_nebula})
set m.communityNameNebula = 'why-detailed';