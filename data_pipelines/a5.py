from typing import Any
from isda_streaming.data_stream import (
    DataStream,
    TimedStream,
    WindowedStream,
    KeyedStream,
)
from isda_streaming.synopsis import CountMinSketch, BloomFilter, ReservoirSample 

# Implementieren Sie die Funktion approx_brand_count, die eine Dataflow-Pipeline mit folgendem Ergebnis erstellt:
# Eine Schätzung für die Anzahl der PKWs pro Spur (lane) und PKW Marke (brand) pro Stunde. 
# Diese Statistik muss alle 30 Minuten aktualisiert werden.
#Das Erkennungsmerkmal für ein Fahrzeug ist ein String und soll dabei folgender Maßen aufgebaut werden: "brand_lane".
#Beispiel:Das Fahrzeug mit dem Tupel (2.0, 180.0, "pkw", "VW") hat das Erkennungsmerkmal "VW_2".
def brand_lane(x):
    return x[3]+"_" + str(int(x[0]))
def filter_pkw(x):
    if x[2] == 'pkw':
        return True
    return False
def hash_cms(x):
    cm = CountMinSketch(width=40, depth=3)
    for element in x:
        cm.update(element)
    return cm
def approx_brand_count(input_stream: TimedStream) -> DataStream:
    
    stream_1 = input_stream.filter(filter_pkw).map(brand_lane).sliding_time_window(3600.0,1800.0).apply(hash_cms)
    return stream_1
def get_cm(x):
    list_cm.append(x[0])
    return x
def query_cm(x):
    global brand_lane_str
    return (x[0].query(brand_lane_str),x[1],x[2])
def query_brand_and_lane(approx_brand_count: DataStream, brand: str, lane: int) -> Any:
    global brand_lane_str
    brand_lane_str = brand + "_" + str(lane)
    global list_cm 
    list_cm = []
    approx_brand_count = approx_brand_count.map(get_cm)
    return approx_brand_count.map(query_cm)
list_cm = []
brand_lane_str = ""
