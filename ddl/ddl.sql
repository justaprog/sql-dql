CREATE TABLE Ärzt_in(
    LANR VARCHAR(9) NOT NULL CHECK (LENGTH(LANR) = 9),
    Fachgebiet VARCHAR NOT NULL ,
    Name STRUCT(Titel VARCHAR, Vorname VARCHAR, Nachname VARCHAR) NOT NULL,
    Sprachen VARCHAR[] NOT NULL,
    Geburtsdatum DATE NOT NULL,
    PRIMARY KEY (LANR),
    CHECK ((YEAR(DATE '2024-05-17') - YEAR(Geburtsdatum)>0) OR
           (YEAR(DATE '2024-05-17') - YEAR(Geburtsdatum)=0 AND MONTH(DATE '2024-05-17') - MONTH(Geburtsdatum)>0) OR 
           (YEAR(DATE '2024-05-17') - YEAR(Geburtsdatum)=0 AND MONTH(DATE '2024-05-17') - MONTH(Geburtsdatum)=0 AND
           DAY(DATE '2024-05-17') - DAY(Geburtsdatum)>0)
          ),
    CHECK ((YEAR(DATE '2024-05-17') - YEAR(Geburtsdatum)<68) OR
           (YEAR(DATE '2024-05-17') - YEAR(Geburtsdatum)=68 AND MONTH(DATE '2024-05-17') - MONTH(Geburtsdatum)<0) OR 
           (YEAR(DATE '2024-05-17') - YEAR(Geburtsdatum)=68 AND MONTH(DATE '2024-05-17') - MONTH(Geburtsdatum)=0 AND 
            DAY(DATE '2024-05-17') - DAY(Geburtsdatum)<0)
          )
);
CREATE TABLE Patient_in(
    Versichertennummer CHAR(10) PRIMARY KEY,
    Name STRUCT(Titel VARCHAR, Vorname VARCHAR, Nachname VARCHAR) NOT NULL,
    Geburtsdatum DATE NOT NULL,
    Beschäftigung VARCHAR,
    Geschlecht CHAR(1) CHECK (Geschlecht = 'd' OR Geschlecht = 'w' OR Geschlecht = 'm' OR Geschlecht IS NULL)
    CHECK (LENGTH(Versichertennummer) = 10 AND SUBSTRING(Versichertennummer,1,1) GLOB '[A-Z]' AND CAST(SUBSTRING(Versichertennummer,2,9) AS INTEGER) )
);
CREATE TABLE Diagnose(
    ICD CHAR(3) NOT NULL,
    Zusatzinformation CHAR(1) NOT NULL,
    Beschreibung VARCHAR,
    PRIMARY KEY (ICD),
    CHECK (Zusatzinformation = 'G' OR Zusatzinformation = 'V' OR Zusatzinformation = 'A' OR Zusatzinformation = 'L' OR Zusatzinformation = 'R' 
    OR Zusatzinformation = 'B'),
    CHECK ((SUBSTRING(ICD,1,1) GLOB '[ABCFGIJLMNOQRZU]'AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)<=99) OR
           (SUBSTRING(ICD,1,1) GLOB '[D]'AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)<=89) OR
           (SUBSTRING(ICD,1,1) GLOB 'H'AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)<=95) OR
           (SUBSTRING(ICD,1,1) GLOB '[E]'AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)<=90)OR
           (SUBSTRING(ICD,1,1) GLOB '[K]'AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)<=93)OR
           (SUBSTRING(ICD,1,1) GLOB '[P]'AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)<=96) OR 
           (SUBSTRING(ICD,1,1) GLOB '[TWXY]'AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)<=98) OR 
           (SUBSTRING(ICD,1,1) GLOB '[V]'AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)<=98 AND CAST(SUBSTRING(ICD,2,2) AS INTEGER))>=01),
    CHECK (LENGTH(ICD) = 3 AND CAST(SUBSTRING(ICD,2,2) AS INTEGER)>=0)
);
CREATE TABLE stellt(
    LANR VARCHAR(9) NOT NULL,
    ICD CHAR(3) NOT NULL,
    Zeitpunkt DATETIME NOT NULL,  
    UNIQUE (LANR,Zeitpunkt),
    PRIMARY KEY(LANR,ICD),
    FOREIGN KEY (LANR) REFERENCES Ärzt_in(LANR),
    FOREIGN KEY (ICD) REFERENCES Diagnose(ICD)
);
CREATE SEQUENCE ID_sq START WITH 1 INCREMENT BY 1 MAXVALUE 3000000;
CREATE TABLE Termin(
    ID UINTEGER DEFAULT nextval('ID_sq'),
    Zeitpunkt DATETIME NOT NULL,
    Zusatzgebühren DECIMAL(5,2) DEFAULT 0 NOT NULL,
    ist_Neupatient_in BOOLEAN NOT NULL,
    LANR VARCHAR(9) NOT NULL,
    UNIQUE (Zeitpunkt,LANR),
    PRIMARY KEY (ID),
    FOREIGN KEY (LANR) REFERENCES Ärzt_in(LANR),
    CHECK(Zusatzgebühren <= 500 AND Zusatzgebühren >=0)
);
CREATE TABLE hat(
    ID UINTEGER  NOT NULL,
    ICD CHAR(3) NOT NULL,
    Versichertennummer CHAR(11) NOT NULL,
    PRIMARY KEY (ID,ICD),
    FOREIGN KEY (ID) REFERENCES Termin(ID),
    FOREIGN KEY (ICD) REFERENCES Diagnose(ICD),
    FOREIGN KEY (Versichertennummer) REFERENCES Patient_in(Versichertennummer)
);
CREATE TABLE Gesundheitseinrichtung(
    SteuerID VARCHAR NOT NULL CHECK(LENGTH(SteuerID) = 11), 
    Name VARCHAR NOT NULL,
    Bundesland CHAR(5) NOT NULL CHECK(LENGTH(Bundesland) = 5),
    Adresse VARCHAR NOT NULL,
    Umsatz DECIMAL(15,2) NOT NULL,
    Typ TEXT NOT NULL,
    Betten USMALLINT,
    Bettenauslastung FLOAT,
    ist_privatisiert BOOLEAN,
    ist_Universitätsklinikum BOOLEAN,
    Fachrichtung VARCHAR,
    Zahlungsart VARCHAR,
    PRIMARY KEY(SteuerID,Name),
    CHECK (Bundesland = 'DE-BW'  OR Bundesland = 'DE-BY' OR Bundesland = 'DE-BE' OR Bundesland = 'DE-BB'
	OR Bundesland = 'DE-HB' OR Bundesland = 'DE-HH' OR Bundesland = 'DE-HE' OR Bundesland = 'DE-MV' OR 
	Bundesland = 'DE-NI' OR Bundesland = 'DE-NW' OR Bundesland = 'DE-RP' OR Bundesland = 'DE-SL' OR Bundesland = 'DE-SN' OR
	Bundesland = 'DE-ST' OR Bundesland = 'DE-SH' OR Bundesland = 'DE-TH'),
    CHECK (CAST(SUBSTRING(SteuerID,3,9) AS INTEGER) AND SteuerID LIKE 'DE_________'),
    CHECK (Umsatz <= 9999999999999.99 AND Umsatz >=0),
    CHECK((Typ = 'Gesundheitseinrichtung' AND ist_privatisiert IS NULL AND Betten IS NULL AND Bettenauslastung IS NULL AND 
           ist_Universitätsklinikum IS NULL AND Fachrichtung IS NULL AND Zahlungsart IS NULL) OR 
           (Typ = 'Krankenhaus' AND Fachrichtung IS NULL AND Zahlungsart IS NULL AND Betten IS NOT NULL AND (Bettenauslastung <= 1 AND Bettenauslastung >=0)
           AND (Betten <= 1500) AND (Betten >=0) AND Bettenauslastung IS NOT NULL AND ist_privatisiert IS NOT NULL AND ist_Universitätsklinikum IS NOT NULL) OR 
           (Typ = 'Privatpraxis' AND BETTEN IS NULL AND Bettenauslastung IS NULL AND ist_privatisiert IS NULL AND ist_Universitätsklinikum IS NULL
           AND (Fachrichtung IS NOT NULL) AND (Zahlungsart = 'Versichert' OR Zahlungsart = 'Selbstzahler') AND Zahlungsart IS NOT NULL))
);
CREATE TABLE angestellt(
    LANR VARCHAR(9) NOT NULL,
    SteuerID VARCHAR NOT NULL, 
    Name VARCHAR NOT NULL,
    Einstellungsdatum DATE NOT NULL,
    Gehalt DECIMAL(7,2) NOT NULL,
    PRIMARY KEY(LANR,SteuerID,Name),
    FOREIGN KEY (LANR) REFERENCES Ärzt_in(LANR),
    FOREIGN KEY (SteuerID,Name) REFERENCES Gesundheitseinrichtung(SteuerID,Name),
    CHECK(Gehalt >= 5288.32 AND Gehalt <= 11019.20),
    CHECK(LENGTH(LANR) = 9),
    CHECK(SUBSTRING(strftime(Einstellungsdatum,'%d.%m.%Y'),1,6) NOT IN ('01.01.', '08.03.', '01.05.', '03.10.', '25.12.','26.12.'))
);
CREATE SEQUENCE ID_raum START WITH 1 INCREMENT BY 1 MAXVALUE 20;
CREATE TABLE 'OP-Saal'(
    Raumnummer UTINYINT  DEFAULT nextval('ID_raum')-1,
    SteuerID VARCHAR NOT NULL ,
    Name VARCHAR NOT NULL ,
    PRIMARY KEY (Raumnummer,SteuerID,Name),
    FOREIGN KEY (SteuerID,Name) REFERENCES Gesundheitseinrichtung(SteuerID,Name)
);
CREATE TABLE OP(
    Nummer UUID NOT NULL,
    Dringlichkeit VARCHAR NOT NULL,
    ist_Vollnarkose BOOLEAN NOT NULL,
    Raumnummer UTINYINT NOT NULL,
    SteuerID VARCHAR NOT NULL,
    Name VARCHAR NOT NULL,
    Versichertennummer CHAR(10), 
    Datum DATE NOT NULL,
    Startzeit TIME NOT NULL,
    Endzeit TIME NOT NULL,
    PRIMARY KEY (Nummer),
    FOREIGN KEY (Raumnummer,SteuerID,Name) REFERENCES 'OP-Saal'(Raumnummer,SteuerID,Name),
    FOREIGN KEY (Versichertennummer) REFERENCES Patient_in(Versichertennummer),
    CHECK (Dringlichkeit = 'Notoperation' OR Dringlichkeit = 'frühelektive Operation'  OR Dringlichkeit = 'elektive Operation' OR 
           Dringlichkeit = 'dringliche Operation'),
    CHECK(((hour(Endzeit) - hour(Startzeit)>0) AND (hour(Endzeit) - hour(Startzeit)<9)) OR 
          ((hour(Endzeit) - hour(Startzeit)=0) AND (minute(Endzeit) - minute(Startzeit)>=15)) OR 
          ((hour(Endzeit) - hour(Startzeit)=9) AND (minute(Endzeit) - minute(Startzeit)<=0)) OR
          ((hour(Endzeit) - hour(Startzeit)<0) AND (hour(Endzeit) +24 - hour(Startzeit)<9)) OR 
          ((hour(Endzeit) +24 - hour(Startzeit)=9) AND (minute(Endzeit) - minute(Startzeit)<=0))
          )
);