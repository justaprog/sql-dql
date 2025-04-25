import duckdb

#-----------------------------------------------------------------
con = duckdb.connect("world_cup.db")
# SQL query example from dql.sql file
query ="""
SELECT DISTINCT ifnull(goals.scored_Tore, 0) AS scored_Tore, s.Spieler_ID, goals.Turnier_ID
    FROM
    Spieler s
LEFT JOIN
    (SELECT Spieler_ID, Turnier_ID, COUNT(*) AS scored_Tore
    FROM
    Tore
    GROUP BY Spieler_ID, Turnier_ID
    ) AS goals
    ON s.Spieler_ID = goals.Spieler_ID
WHERE 
s.Turnieranzahl > 0
ORDER BY goals.scored_Tore ASC, s.Spieler_ID DESC, goals.Turnier_ID ASC
LIMIT 10

"""
result = con.sql(query)
print(result)

con.close() 

