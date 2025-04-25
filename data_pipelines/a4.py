from typing import Any
from isda_streaming.data_stream import (
    DataStream,
    TimedStream,
    WindowedStream,
    KeyedStream,
)
from isda_streaming.synopsis import CountMinSketch, BloomFilter, ReservoirSample 

# Implementieren Sie die Funktion traffic_density, die eine Dataflow-Pipeline mit folgendem Ergebnis erstellt:
# Die Verkehrsdichte traffic_density, also die Anzahl der Fahrzeuge pro Kilometer. 
# Die Verkehrsdichte lässt sich mithilfe der Verkehrsstärke (traffic_intensity) berechnen, welche die Anzahl der Fahrzeuge pro Stunde angibt. 
# Zusammen mit der durchschnittlichen Geschwindigkeit (avg_velocity) dieser Fahrzeuge, kann die Verkehrsdichte berechnet werden (traffic_density = traffic_intensity / avg_velocity). 
# Die entsprechende Statistik soll alle 60 Minuten aktualisiert werden.
#Erwartete Elementstruktur im Ausgabestrom: (traffic_density, window_start, window_end)
def get_vel(x):
    return x[1]
def convert_mean(x):
    global list_mean 
    list_mean.append(x[0])
    return x
def cal(x):
    global index
    result = x[0]/list_mean[index]
    index = index +1
    return (result,x[1],x[2])
def traffic_density(input_stream: TimedStream) -> Any:
    global index,list_mean
    index = 0
    list_mean = []
    traffic_intensity = input_stream.map(get_vel).tumbling_time_window(3600.0).aggregate("count")
    avg_velocity = input_stream.map(get_vel).tumbling_time_window(3600.0).aggregate("mean").map(convert_mean)

    return traffic_intensity.map(cal)
list_mean= []
index = 0