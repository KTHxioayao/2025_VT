from __future__ import division
from math import radians, cos, sin, asin, sqrt, exp
from datetime import datetime
from pyspark import SparkContext


sc = SparkContext(appName="lab_kernel")
def haversine(lon1, lat1, lon2, lat2):
        ### Calculate the great circle distance between two points
        ### on the earth (specified in decimal degrees)

        ### convert decimal degrees to radians
        lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
        # haversine formula
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a))
        km = 6367 * c
        return km   


def gaussian_kernel(x, y, h):
    return exp(- ((x - y) ** 2) / (2 * h ** 2))

def day_of_year(y, m, d):
    return datetime(y, m, d).timetuple().tm_yday


### self defined parameters
### the location to be predicted

h_distance = 300000 # Up to you
h_date = 40 # Up to you
h_time = 2 # Up to you

# the location, time to be predicted
a = 58.4274 # latitude , Up to you 
b = 14.826 # longitude, Up to you

date = "2013-07-04" # Up to you
year, month, day = map(int, date.split("-"))
target_date = (year, month, day)

### Load the data

stations = sc.textFile("BDA/input/stations-Ostergotland.csv")
temps = sc.textFile("BDA/input/temperature-readings.csv")


# map the station to a tuple
station_lines = stations.map(lambda line: line.split(";"))

#(key, values)
# (key = station, (latitude, longitude))
statReadingsRow = station_lines.map(lambda p:  (p[0],(float(p[3]),float(p[4])))).collectAsMap()

# broadcast and collects the RDD to the driver as a Python dictionary
station_broadcast = sc.broadcast(statReadingsRow)


# map the temp to a tuple
Templines = temps.map(lambda line: line.split(";"))

# (station, year, month, date, time, temperature)
tempReadingsRow = Templines.map(lambda p: ( p[0], int(p[1].split("-")[0]), int(p[1].split("-")[1]), int(p[1].split("-")[2]), int(p[2].split(":")[0]),float(p[3])))

# filter the stations with temperature information in ostergotland
temp_data = tempReadingsRow.filter (
    lambda x: x[0] in station_broadcast.value.keys())

# filter out the temp after defined date
temp_data = temp_data.filter (
    lambda x: (x[1], x[2], x[3]) < (target_date))

# map the station to a tuple
temp_data = temp_data.map(lambda p: ( p[0],station_broadcast.value[p[0]][0], station_broadcast.value[p[0]][1], p[1], p[2], p[3], p[4], p[5]))\
.cache() 
# (station, latitude, longitude, year, month, date, time, temperature)

# sample from the data 
temp_data = temp_data.sample(False, 0.1)


### kernel prediction
all_predictions = []

for target_time in ["24:00:00", "22:00:00", "20:00:00", "18:00:00", "16:00:00", "14:00:00",
"12:00:00", "10:00:00", "08:00:00", "06:00:00", "04:00:00"]:
    target_hour = int(target_time.split(":")[0]) % 24  # convert to 24-hour format
    def compute_weighted_temp(record):
        _, lat, lon, year, month, day, hour_obs, temp = record
        
        #space kernel
        d_space = haversine(lon, lat, b, a)
        k_space = gaussian_kernel(0, d_space, h_distance)

        #date kernel
        target_day= day_of_year(*target_date) # days since 1st Jan 1970
        current_day = day_of_year(year, month, day) 
        d_date = min(abs(current_day - target_day), 365 - abs(current_day - target_day))  #recurrent year
        k_date = gaussian_kernel(0, d_date, h_date)

        # time kernel
        d_time = min(abs(hour_obs - target_hour), 24 - abs(hour_obs - target_hour))  # handle 23 vs 1
        k_time = gaussian_kernel(0, d_time, h_time)
    
        weight_sum = k_space + k_date + k_time  
        weight_mult = k_space * k_date * k_time  # use product instead for Q2

        return ((d_space,k_space), (d_date, k_date), (d_time, k_time), (weight_sum * temp, weight_sum), (weight_mult * temp, weight_mult))
    
    results = temp_data.map(compute_weighted_temp)
    #reduce part
    # reduce to get the sum of the weights
    pred_sum = results.map(lambda x: x[3]).reduce(lambda a, b: (a[0]+b[0], a[1]+b[1]))
    prediction_sum = pred_sum[0] / pred_sum[1] if pred_sum[1] != 0 else None
    


    # reduce to get the mult of the weights
    pred_mult = results.map(lambda x: x[4]).reduce(lambda a, b: (a[0]+b[0], a[1]+b[1]))
    prediction_mult = pred_mult[0] / pred_mult[1] if pred_mult[1] != 0 else None

    #save the prediction for each time
    all_predictions.append((target_time, prediction_sum, prediction_mult))

    #data part for visualization
    if target_time == "24:00:00": # save only the data for this time
        results.map(lambda x: x[0]).saveAsTextFile("BDA/output/distance_and_kernel")
        results.map(lambda x: x[1]).saveAsTextFile("BDA/output/date_and_kernel")
        results.map(lambda x: x[2]).saveAsTextFile("BDA/output/time_and_kernel")


sc.parallelize(all_predictions).saveAsTextFile("BDA/output/predictions_all_times")



