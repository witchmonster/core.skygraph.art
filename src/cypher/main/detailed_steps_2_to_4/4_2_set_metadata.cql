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
set n.did = n.type + '_' + leader.did
set n.name = n.type + '_' + leader.handle;

match (n:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster|Filament)
with n
match (leader:Account)
where n.leader = leader.handle
set n.leader_did = leader.did;

match (n:Constellation|Nebula|Galaxy|Cluster|Supercluster|Gigacluster|Filament)
set n.version = 'v5';