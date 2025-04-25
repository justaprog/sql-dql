# Ausgangssituation
Sie sind Datenanalyst*in beim Bundesministerium für Digitales und Verkehr und arbeiten an einem System zur intelligenten Verkehrssteuerung auf   Autobahnen mittels Echtzeitdaten. Ihre Hauptaufgabe besteht darin, Dataflow-Pipelines zu definieren, die verschiedene kontinuierliche Abfragen   bestmöglich repräsentieren.  
Um Dataflow-Pipelines zu implementieren, benutzt ihre Abteilung die ISDA Streaming API. Bei Fragen zu der API können Sie die offizielle Dokumentation zu Rate ziehen.  

# Informationen zum Eingabestrom
In den folgenden Aufgaben verwenden wir einen Datenstrom eines Verkehrsüberwachungssystems, das eine 3-spurige Autobahn überwacht. Dieser Datenstrom ist ein TimedStream, bei dem jedes Element ein vom System erkanntes Fahrzeug repräsentiert. Der Timestamp der Elemente ist als Unixzeit in Sekunden codiert. Die Stromelemente sind als Python Tuple mit folgender Struktur implementiert:  
(lane, velocity, type, brand)  

lane: Autobahnspur, auf der das Fahrzeug fährt. Diese sind numeriert von 1 bis 3 (z.B. 1 für rechte Fahrspur).  
velocity: Gemessene Geschwindigkeit des Fahrzeugs in km/h.  
type: Art des Fahrzeugs (lkw oder pkw).  
brand: Marke des Fahrzeugs (z.B. Volvo).  

Wir erwarten, dass Ihre Dataflow-Pipelines für den gesamten Strom immer die erwartete Ausgabe erzeugen. Allerdings testen wir Ihre Lösungen in verschiedenen Teilbereichen des Datenstroms, um die Testergebnisse übersichtlicher zu gestalten. In allen sichtbaren Tests wird die erwartete Ausgabe sowie der getestete Indexbereich angegeben. Dies soll Ihnen helfen, Fehler einfacher zu finden. Beachten Sie jedoch, dass wir auch weitere versteckte Tests durchführen, in denen größere Abschnitte getestet werden.

Sie können Ihre Lösungen lokal testen, indem Sie die CSV-Datei aus dem ISDA-Git-Repository herunterladen, die notwendigen Objekte aus isda_streaming importieren und einen TimedStream initialisieren:
input_stream = TimedStream()
input_stream.from_csv("../resources/autobahn.csv", start, end)

Dabei sind start und end die Indizes des getesteten Bereichs.

# Parameter für Datenzusammenfassungsstrukturen (Synopsen)
Falls Sie Datenzusammenfassungsstrukturen erstellen möchten, verwenden Sie bitte die folgenden Parameter:

Reservoir Sample: sample_size = 100
Bloom Filter: n_bits = 12, n_hash_functions = 3
Count-Min Sketch: width = 40, depth = 3
Wenn Sie andere Parameter verwenden, wird Ihre Lösung nicht mit dem erwarteten Ergebnis vergleichbar sein und Sie erhalten keine Punkte.

# Allgemeine Hinweise
Alle nötigen Pakete sowie die ISDA Streaming API werden automatisch importiert.
Sie dürfen keine weiteren Python-Pakete importieren.
Sie können Ihre Lösung bei Bedarf zunächst lokal testen. Dafür stellen wir Ihnen den Datensatz sowie ein Jupyter Notebook als Vorlage im ISDA Git-Repository zur Verfügung.
Sie können bei der Erstellung Zeit-basierter Fenster stets davon ausgehen, dass das erste Fenster mit dem Beginn des Stroms startet. Sie müssen sich also nur über die Breite und ggf. den Versatz, nicht aber den Startpunkt des ersten Fensters, Gedanken machen.
Wenden Sie stets alle anwendbaren Filter an, bevor Sie einen Strom mittels Fensters diskretisieren. Andernfalls kann Ihre Lösung mehr (letztendlich leere) Fenster als die Musterlösung produzieren.
