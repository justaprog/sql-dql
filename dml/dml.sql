ALTER TABLE Hotel RENAME Column_5 TO Anz_Zimmer;
ALTER TABLE MitarbeiterIn ADD COLUMN Gehalt UINTEGER;


CREATE TABLE Ort(
    OrtID UUID NOT NULL PRIMARY KEY,
    Straße VARCHAR NOT NULL,
    Hausnummer VARCHAR NOT NULL,
    PLZ VARCHAR(5) NOT NULL,
    Stadt VARCHAR NOT NULL,
    CHECK (PLZ ~ '^[0-9]{5}$')
);
INSERT INTO Ort VALUES ('473746ea-f1bb-4aa7-8ab2-e44ae24066f9', 'Albrechtstraße', '5', '10117','Berlin');
INSERT INTO Ort VALUES ('97056f4b-a796-487a-938e-9d7ce3fb24e2', 'Müllerstraße', '151a', '13353','Berlin');
INSERT INTO Ort VALUES ('acded9bf-5ea8-411d-a617-b95d099288e2', 'Bjoernsonstraße', '10', '10439','Berlin');
INSERT INTO Ort VALUES ('22067ad3-ec19-47f8-97b4-2c62c2b5ab8e', 'Willy-Brandt-Platz', '3', '81829','München');
INSERT INTO Ort VALUES ('0596dd3f-d5a0-4940-a589-94571527a704', 'Albrechtstraße', '13', '80636','München');

ALTER TABLE Hotel DROP Adresse;
ALTER TABLE Hotel ADD COLUMN OrtID UUID;
UPDATE Hotel SET OrtID = '473746ea-f1bb-4aa7-8ab2-e44ae24066f9' WHERE HotelID = 1001;
UPDATE Hotel SET OrtID = '97056f4b-a796-487a-938e-9d7ce3fb24e2' WHERE HotelID = 1002;
UPDATE Hotel SET OrtID = '97056f4b-a796-487a-938e-9d7ce3fb24e2' WHERE HotelID = 1003;
UPDATE Hotel SET OrtID = 'acded9bf-5ea8-411d-a617-b95d099288e2' WHERE HotelID = 1004;
UPDATE Hotel SET OrtID = '22067ad3-ec19-47f8-97b4-2c62c2b5ab8e' WHERE HotelID = 1005;
UPDATE Hotel SET OrtID = '0596dd3f-d5a0-4940-a589-94571527a704' WHERE HotelID = 1006;

CREATE TABLE ManagerIn(
    PersID VARCHAR(8) NOT NULL PRIMARY KEY,
    Letzte_Fortbildung DATE,
    Nächste_Fortbildung DATE NOT NULL,
    Bonus DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (PersID) REFERENCES MitarbeiterIn(PersID),     
    CHECK (Letzte_Fortbildung IS NULL OR (Letzte_Fortbildung IS NOT NULL AND ((YEAR(Nächste_Fortbildung) - YEAR(Letzte_Fortbildung)>0) OR
           (YEAR(Nächste_Fortbildung) - YEAR(Letzte_Fortbildung)=0 AND MONTH(Nächste_Fortbildung) - MONTH(Letzte_Fortbildung)>0) OR 
           (YEAR(Nächste_Fortbildung) - YEAR(Letzte_Fortbildung)=0 AND MONTH(Nächste_Fortbildung) - MONTH(Letzte_Fortbildung)=0 AND
           DAY(Nächste_Fortbildung) - DAY(Letzte_Fortbildung)>0)))),
    CHECK (LENGTH(PersID)=8 AND PersID LIKE 'em3%' AND CAST(SUBSTRING(PersID,3,6) AS INTEGER))
);
UPDATE MitarbeiterIn SET Gehalt = 2000 WHERE Abteilung = 'Sicherheit';
UPDATE MitarbeiterIn SET Gehalt = 2200 WHERE Abteilung = 'Reinigung';
UPDATE MitarbeiterIn SET Gehalt = 2600 WHERE Abteilung = 'Rezeption';
UPDATE MitarbeiterIn SET Gehalt = 3200 WHERE Abteilung = 'Management';


INSERT INTO ManagerIn VALUES ('em300003',DATE '2023-10-21',DATE'2024-06-12',936.50);
INSERT INTO ManagerIn VALUES ('em300004',DATE '2024-01-13',DATE'2024-09-02',0);
INSERT INTO ManagerIn VALUES ('em300011',DATE '2023-11-14',DATE'2024-06-12',1500);
INSERT INTO ManagerIn VALUES ('em300013',DATE '2024-01-13',DATE'2024-09-02',345.78);
INSERT INTO ManagerIn VALUES ('em300016',DATE '2023-11-14',DATE'2024-07-27',0.0);
INSERT INTO ManagerIn VALUES ('em300021',DATE '2024-01-13',DATE'2024-07-27',0.0);

UPDATE MitarbeiterIn SET Angestellt_am = replace(Angestellt_am,Angestellt_am,SUBSTRING(Angestellt_am,7,4)||SUBSTRING(Angestellt_am,3,3)||'-'||SUBSTRING(Angestellt_am,1,2));
ALTER TABLE MitarbeiterIn ALTER COLUMN Angestellt_am TYPE DATE;
DELETE FROM MitarbeiterIn WHERE PersID = 'em300025';