from typing import Any
from isda_streaming.data_stream import (
    DataStream,
    TimedStream,
    WindowedStream,
    KeyedStream,
)
from isda_streaming.synopsis import CountMinSketch, BloomFilter, ReservoirSample 

# Implementieren Sie die Funktion sample_cars_above_130, die eine Dataflow-Pipeline mit folgendem Ergebnis erstellt:
# Eine Stichprobe aller Fahrzeuge seit Beginn der Analyse, die mit einer Geschwindigkeit (velocity) 
# über der Richtgeschwindigkeit von 130 km/h gefahren sind. 
# Diese Statistik soll alle 60 Minuten aktualisiert werden.

def filter_130(x):
    if x[1] > 130:
        return True
    return False
def fill_re(x):
    rs = ReservoirSample(100)
    for element in x:
        rs.update(element)
    return rs

def sample_cars_above_130(input_stream: TimedStream) -> DataStream:
    stream_1 = input_stream.filter(filter_130).landmark_time_window(3600.0).apply(fill_re)
    return stream_1
def cal_car(x):
    global global_brand,num_brand,num_car
    rs = x[0].get_sample()
    num_car = len(rs)
    for element in rs:
        if element[3] == global_brand:
            num_brand = num_brand +1
    result = round(num_brand*100/num_car,2)
    num_brand = 0
    num_car = 0
    return (result,x[1],x[2]) 
def query_brand_above_130(sample_cars_above_130_output: DataStream, brand: str) -> Any:
    global num_brand,num_car,global_brand
    num_brand = 0
    num_car = 0
    global_brand = brand
    stream_1 = sample_cars_above_130_output.map(cal_car)
    return stream_1
num_brand = 0
num_car = 0
global_brand = ""

start = 0
end = 300
input_stream = TimedStream()
input_stream.from_csv("../resources/09_data_streams/autobahn.csv", start, end)

print(query_brand_above_130(sample_cars_above_130(input_stream),"Porsche"))