from typing import Any
from isda_streaming.data_stream import (
    DataStream,
    TimedStream,
    WindowedStream,
    KeyedStream,
)
from isda_streaming.synopsis import CountMinSketch, BloomFilter, ReservoirSample 

# Implementieren Sie die Funktion lkw_ratio, die eine Dataflow-Pipeline mit folgendem Ergebnis erstellt:
# Den Anteil der LKWs an allen Fahrzeugen pro Spur lane in Prozent. 
# Berechnen Sie den Anteil nur für die erste und zweite Spur und runden Sie die Prozentzahl, mit Hilfe der round(Zahl, Nachkommastellen) Funktion von Python, auf zwei Nachkommastellen.
def filter_lkw(x):
    if x[2] == 'lkw':
        return True
    return False
def get_first(x):
    return x[0]
def get_percent(x):
    global num_car_1,num_lkw_1,num_car_2,num_lkw_2
    if x[0] == 1.0:
        num_car_1 += 1
        if x[2] == 'lkw':
            num_lkw_1 += 1
        return round(num_lkw_1*100/num_car_1,2)
    num_car_2 += 1
    if x[2] == 'lkw':
        num_lkw_2 += 1
    return round(num_lkw_2*100/num_car_2,2)
def filter_3(x):
    if x[0] == 3.0:
        return False
    return True

def lkw_ratio(input_stream: TimedStream) -> Any:
    global num_car_1,num_lkw_1,num_car_2,num_lkw_2
    num_car_1 = 0
    num_lkw_1 = 0
    num_car_2 = 0
    num_lkw_2 = 0
    return input_stream.filter(filter_3).key_by(get_first).map(get_percent)
num_car_1 = 0
num_lkw_1 = 0
num_car_2 = 0
num_lkw_2 = 0