-- Den Familiennamen und den Vornamen aller maennlichen Spieler
SELECT Spieler_ID,Familienname,Vorname FROM Spieler
WHERE Weiblich = 0
ORDER BY Spieler_ID DESC
LIMIT 10;

-- Die Anzahl an Torhueter*innen, Verteidiger*innen, Mittelfeldspieler*innen und Stuermer*innen, bei denen der erste Familiennamen D anfaengt. 
SELECT CAST(SUM(Torhueter) AS INT128)  AS "Anzahl Torhueter", 
CAST(SUM(Verteidiger) AS INT128)  AS "Anzahl Verteidiger", 
CAST(SUM(Mittelfeldspieler) AS INT128)  AS "Anzahl Mittelfeldspieler",
CAST(SUM(Stuermer) AS INT128) AS "Anzahl Stuermer" 
FROM SPIELER 
WHERE Familienname LIKE 'D%'

-- Den Mannschaftsnamen und den Mannschaftscode aller europaeischen Teams.
SELECT Mannschafts_ID,Mannschaftsname, Mannschaftscode
FROM Mannschaften
WHERE Regionname = 'Europe'
ORDER BY Mannschafts_ID DESC
LIMIT 10

-- Alle Vor- und Nachnamen von Stuermer*innen, welche Turniere gespielt haben.
SELECT DISTINCT s.Turnieranzahl,s.Spieler_ID ,s.Familienname ,s.Vorname
FROM Spieler s
WHERE s.Stuermer = 1
ORDER BY s.Turnieranzahl DESC, s.Spieler_ID DESC
LIMIT 10;

-- Alle Spieler*innen, welche auf mehr als zwei Positionen (Torhueter, Verteidiger, Mittelfeldspieler, Stuermer) gespielt haben. 
-- Hinweis: Die Anzahl muss zu einem INT64 gecastet werden
SELECT Spieler_ID ,Familienname, Vorname,CAST(Torhueter + Verteidiger +Mittelfeldspieler +Stuermer
AS INT64) AS positions_played
FROM Spieler
WHERE positions_played > 2
ORDER BY Spieler_ID DESC, positions_played ASC
LIMIT 10

-- Den Mannschaftsnamen und den Mannschaftscode von allen Teams, welche eine Damen- und Herrenmannschaft haben.
SELECT Mannschafts_ID , Mannschaftsname, Mannschaftscode
FROM Mannschaften
WHERE Herrenmannschaft = 1 AND Damenmannschaft = 1
ORDER BY Mannschafts_ID ASC
LIMIT 10

-- Die Anzahl an Schiedsrichter*innen fuer jede Konfoederation.
SELECT ko.Konfoederationsname, COUNT(sc.Schiedsrichter_ID) AS "Anzahl an Schiedsrichter",
FROM Schiedsrichter sc 
JOIN 
Konfoederationen ko
USING (Konfoederations_ID)
GROUP BY ko.Konfoederationsname
ORDER BY ko.Konfoederationsname ASC

-- Alle Spieler*innen, welche mehr als 5 Spiele gespielt haben.
SELECT s.Spieler_ID , s.Familienname, s.Vorname, COUNT(a.Spiel_ID) AS Auftritte 
FROM Spieler s
JOIN 
Spielerauftritte a
USING (Spieler_ID)
GROUP BY s.Spieler_ID, s.Familienname, s.Vorname
HAVING COUNT(a.Spiel_ID) > 5
ORDER BY s.Spieler_ID DESC, Auftritte ASC
LIMIT 10

-- Die Anzahl an Toren pro Spieler*in, welche/r als Torhueter*in gespielt hat.
SELECT s.Spieler_ID, s.Familienname, s.Vorname, COUNT(t.Spiel_ID) AS scored_Tore 
FROM Spieler s
JOIN 
Tore t
USING (Spieler_ID)
WHERE s.Torhueter = 1
GROUP BY s.Spieler_ID, s.Familienname, s.Vorname
ORDER BY s.Spieler_ID DESC, scored_Tore DESC
LIMIT 10

-- Alle Spieler, welche in mind. einem Gruppenphasenspiel gespielt haben. Jeder Spieler soll nur einmal vorkommen
SELECT DISTINCT s.Spieler_ID ,s.Familienname, s.Vorname
FROM Spieler s
JOIN Spielerauftritte sa
USING(Spieler_ID)
JOIN
Spiele sp
USING(Spiel_ID)
WHERE Gruppenphase = 1
ORDER BY Spieler_ID DESC
LIMIT 10

--Die durchschnittliche (average) Anzahl (pro Turnier) an Spieler*innen pro Position (GK, LB, CB, RB, ...). 
--Mit der Position ist die genaue Position gemeint im Spiel, zum Beispiel CB, LB und NICHT nur Verteidiger.
SELECT Positionscode,SUM (Average)/(SELECT COUNT (Turnier_ID) AS Anzahl
FROM (SELECT DISTINCT Turnier_ID FROM 
Spielerauftritte)) AS Average FROM 
(SELECT Turnier_ID,Positionscode,COUNT(Spieler_ID) AS Average
FROM Spielerauftritte
GROUP BY Turnier_ID,Positionscode)
GROUP BY Positionscode 
ORDER BY Positionscode ASC
LIMIT 10

--Alle Turniere, in denen mehr Tore erzielt wurden als der Durchschnitt aller Turniere, aber mind. ein Tor erzielt wurde.
SELECT Turnier_ID, Anzahl as Tore_scored FROM 
(SELECT Count(Turnier_ID) AS Anzahl ,Turnier_ID FROM
(SELECT tu.Turnier_ID FROM Tore
JOIN 
Turniere tu
USING (Turnier_ID))
GROUP BY Turnier_ID)
WHERE Anzahl > (SELECT AVG(Anzahl) FROM
(SELECT Count(Turnier_ID) AS Anzahl ,Turnier_ID FROM
(SELECT tu.Turnier_ID FROM Tore
JOIN 
Turniere tu
USING (Turnier_ID))
GROUP BY Turnier_ID))  AND Anzahl >= 1
ORDER BY Turnier_ID DESC
LIMIT 10

-- Die Anzahl an erzielten Toren pro Spieler*innen und Turnier, welche an weniger als zwei Turnieren teilgenommen haben
SELECT DISTINCT * FROM
(SELECT sub.Spieler_ID, t.Turniername, sub.Familienname, sub.Vorname, sub.scored_Tore FROM 
(SELECT Turnier_ID,s.Spieler_ID, s.Familienname, s.Vorname, COUNT(t.Spiel_ID) AS scored_Tore FROM Spieler s
JOIN 
Tore t
USING(Spieler_ID)
GROUP BY Turnier_ID,s.Spieler_ID, s.Familienname, s.Vorname) sub
JOIN 
Turniere t
USING (Turnier_ID))s1

JOIN 

(SELECT s1.Spieler_ID FROM 
(SELECT Spieler_ID, COUNT (Turnier_ID) AS Anzahl_tur FROM
(SELECT DISTINCT s.Spieler_ID,t.Turnier_ID FROM Spieler s
JOIN 
Spielerauftritte t
USING(Spieler_ID))
GROUP BY Spieler_ID
HAVING COUNT (Turnier_ID)<2) s1
JOIN 
Tore t
USING (Spieler_ID)) s2
USING (Spieler_ID)
ORDER BY s1.Spieler_ID DESC, s1.Turniername ASC, s1.scored_Tore ASC
LIMIT 10

-- Die Anzahl an weiblichen Spielerinnen pro Region.
SELECT Regionname, CAST(SUM(s1.Anzahl) AS INT64) AS Anzahl FROM
(SELECT DISTINCT Mannschafts_ID, COUNT(s1.Spieler_ID) AS Anzahl FROM
(SELECT Spieler_ID FROM Spieler
WHERE Weiblich = 1) s1
JOIN 
Spielerauftritte s2
USING (Spieler_ID)
GROUP BY Mannschafts_ID) s1
JOIN 
Mannschaften s2
USING (Mannschafts_ID)
GROUP BY Regionname
ORDER BY Regionname ASC
Limit 10

-- Die ID der Spieler*innen mit den meisten Turniertoren pro Turnier. 
-- Hinweise: Zum Beispiel sollte unterschieden werden zwischen der WM 1990 und WM 1994.
SELECT s1.Turnier_ID ,s2.Spieler_ID,s1.Anzahl AS scored_Tore  FROM
(SELECT Turnier_ID, Max(Anzahl) AS Anzahl FROM
(SELECT Spieler_ID,Turnier_ID,Anzahl FROM
(SELECT Spieler_ID, Turnier_ID,COUNT(Turnier_ID) AS Anzahl FROM Tore
GROUP BY Spieler_ID,Turnier_ID))
GROUP BY Turnier_ID)s1
JOIN 
(SELECT Spieler_ID,Turnier_ID,Anzahl FROM
(SELECT Spieler_ID, Turnier_ID,COUNT(Turnier_ID) AS Anzahl FROM Tore
GROUP BY Spieler_ID,Turnier_ID)) s2
ON s1.Turnier_ID = s2.Turnier_ID AND s1.Anzahl = s2.Anzahl
ORDER BY s1.Turnier_ID DESC, s2.Spieler_ID DESC
LIMIT 10

--Geben Sie die Namen aller Spieler*innen, welche in allen Turnieren getroffen haben.
-- Hinweis: Gewollt sind NUR die Spieler*innen, welche sowohl bei dem maennlichen als auch den weiblichen Weltmeisterschaften getroffen haben.
SELECT s1.Spieler_ID, s2.Familienname, s2.Vorname 
FROM (
    SELECT s1.Spieler_ID
    FROM Tore s1
    JOIN Turniere s2
    USING (Turnier_ID)
    GROUP BY s1.Spieler_ID
    HAVING COUNT(DISTINCT s1.Turnier_ID) = (
        SELECT COUNT(*)
        FROM Turniere
    )
) s1
JOIN Spieler s2
ON s1.Spieler_ID = s2.Spieler_ID
ORDER BY s1.Spieler_ID ASC, s2.Familienname ASC, s2.Vorname ASC
LIMIT 10;

-- Geben Sie fuer alle Spieler*innen die Anzahl an erzielten Toren pro Turnier aus. 
-- Hinweise: Auch Spieler*innen, welche gespielt haben, aber keine Tore geschossen haben, sollen mit Null (0) Toren ausgegeben werden.
-- Spieler*innen sollten nur im Ergebnis auftauchen, wenn diese in mindestens einem Spiel in einem Turnier gespielt haben.
(SELECT DISTINCT t1.scored_Tore,t1.Spieler_ID,t1.Turnier_ID FROM
    (SELECT DISTINCT ifnull(goals.scored_Tore, 0) AS scored_Tore, sa.Spieler_ID, t.Turnier_ID
    FROM
    Spielerauftritte sa
    JOIN
    Turniere t ON sa.Turnier_ID = t.Turnier_ID
LEFT JOIN
    (SELECT Spieler_ID, Turnier_ID, COUNT(*) AS scored_Tore
    FROM
    Tore
    GROUP BY Spieler_ID, Turnier_ID
    ) AS goals
    ON sa.Spieler_ID = goals.Spieler_ID AND t.Turnier_ID = goals.Turnier_ID)t1)
UNION
(SELECT DISTINCT COUNT(*) AS scored_Tore,Spieler_ID,Turnier_ID FROM Tore
GROUP BY Spieler_ID,Turnier_ID)

ORDER BY scored_Tore ASC, Spieler_ID DESC, Turnier_ID ASC
LIMIT 10




