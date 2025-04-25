from typing import Any
from isda_streaming.data_stream import (
    DataStream,
    TimedStream,
    WindowedStream,
    KeyedStream,
)
from isda_streaming.synopsis import CountMinSketch, BloomFilter, ReservoirSample 

# Implementieren Sie die Funktion pkw_max_velocity_per_lane, die eine Dataflow-Pipeline mit folgendem Ergebnis erstellt:
# Die laufende maximale Geschwindigkeit eines PKWs pro Autobahnspur.
def filter_pkw(x):
    if x[2] == 'pkw':
        return True
    return False
def get_max(x,y):
    if x > y:
        max = x
        return x
    return y
def filter_max(x):
    if x == max:
        return True
    return False
def key_by_lane(x):
    return x[0]
def get_vel(x):
    return x[1]
def pkw_max_velocity_per_lane(input_stream: TimedStream) -> Any:
    return input_stream.filter(filter_pkw).key_by(key_by_lane).map(get_vel).reduce(get_max)

start = 0
end = 300
input_stream = TimedStream()
input_stream.from_csv("../resources/09_data_streams/autobahn.csv", start, end)


