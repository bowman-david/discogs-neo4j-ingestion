WITH "https://api.discogs.com/users/bowman.david/collection/folders/0/releases?per_page=500" as initial_url
CALL apoc.load.json(initial_url) YIELD value AS discogs
WITH discogs.pagination as p
WITH range(p.page, p.pages) as page_range
UNWIND page_range as current_page  
WITH "https://api.discogs.com/users/bowman.david/collection/folders/0/releases?per_page=500&page="+current_page as url
CALL apoc.load.json(url) YIELD value AS discogs
WITH discogs, discogs.pagination AS pagination, discogs.releases AS releases
FOREACH (r in releases  |
    MERGE (a:Album {master_id: r.basic_information.master_id }) ON CREATE SET a.title=r.basic_information.title
    FOREACH(l in r.basic_information.labels |
        MERGE(la:Label {id: l.id}) ON CREATE SET la.name = l.name
        MERGE (a)-[:RELEASED_ON_LABEL]->(la)
    )
    FOREACH(art in r.basic_information.artists |
        MERGE(band:Artist {id: art.id}) ON CREATE SET band.name = art.name
        MERGE (band)-[:RELEASED_ALBUM]->(a)
    )
)
