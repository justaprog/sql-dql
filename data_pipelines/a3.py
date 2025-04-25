from typing import Any
from isda_streaming.data_stream import (
    DataStream,
    TimedStream,
    WindowedStream,
    KeyedStream,
)
from isda_streaming.synopsis import CountMinSketch, BloomFilter, ReservoirSample 

# Implementieren Sie die Funktion lane_2_min_mean_velocity_100_cars, die eine Dataflow-Pipeline mit folgendem Ergebnis erstellt:
# Der minimale Wert der durchschnittlichen Geschwindigkeiten (mean_velocity) von 10 Autos auf der mittleren Fahrspur aus den letzten 100 Autos. 
# Diese Statistik soll alle 50 Autos aktualisiert werden.
def filter_2(x):
    if x[0] == 2.0:
        return True
    return False
def cal(x):
    car_list = []
    for i in range(100):
        car_list.append(x[i][1])
    sum_vel = 0.0
    x = 0
    y = 10
    mean_list =[]
    while y<=100:
        sum_vel = 0.0
        for i in range(x,y):
            sum_vel = sum_vel + car_list[i]
        
        mean_list.append(sum_vel/10)
        x = x +10
        y = y +10
           
    return min(mean_list)
def get_vel(x):
    return x[0]
def lane_2_min_mean_velocity_100_cars(input_stream: TimedStream) -> Any:
    input_stream = input_stream.filter(filter_2)
    w1 = input_stream.sliding_tuple_window(100, 50)
    w2 = w1.apply(cal)
    return w2.map(get_vel)
