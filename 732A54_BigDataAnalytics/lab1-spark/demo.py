
from pyspark import SparkContext

# create a SparkContext
sc = SparkContext(appName = "exercise 1")
# This path is to the file on hdfs
# create distributed dataset from the file
temperature_file = sc.textFile("BDA/input/temperature-readings.csv")
lines = temperature_file.map(lambda line: line.split(";"))

# (key, value) = (year,(station, temperature)))
# x[1][0:4] as the key
year_temperature = lines.map(lambda x: (x[1][0:4], (x[0],float(x[3]))))

#filter 
year_temperature = year_temperature.filter(lambda x: int(x[0])>=1950 and int(x[0])<=2014)

##########   Question 1  ##########
#Get max
# reduceByKey will return a max (station, temperature) for a certain key
max_temperatures = year_temperature.reduceByKey(lambda a,b: (a[0], max(a[1], b[1])))
max_temperatures = max_temperatures.sortBy(lambda k: k[1][1], ascending=False)

# print the result
#print('List of max temperatures:')
#print(max_temperatures.collect())
max_temperatures.saveAsTextFile("BDA/output/Q1_max_temperatures")


#Get min
#reduceByKey will return a min (station, temperature) for a certain key
min_temperatures = year_temperature.reduceByKey(lambda a,b: (a[0], min(a[1], b[1])))
min_temperatures = min_temperatures.sortBy(lambda k: k[1][1], ascending = True)

# print the result
#print('List of min temperatures:')
#print(min_temperatures.collect())

# Following code will save the result into /user/ACCOUNT_NAME/BDA/output folder
min_temperatures.saveAsTextFile("BDA/output/Q1_min_temperatures")

##########   Question 2  ##########
# (key, value) = ((year, month, station), temperature))
month_temperature = lines.map(lambda x: ((x[1][0:4], x[1][5:7], x[0]), float(x[3])))

#filter 
month_filtered_temperature = month_temperature.filter(lambda x: int(x[0][0])>=1950 and int(x[0][0])<=2014)
month_filtered_temperature = month_filtered_temperature.filter(lambda x: x[1]>=10)

#distinct, only keep the first (year, month, station)
month_temperature = month_filtered_temperature.map(lambda x: x[0]).distinct()

#  map to ((year, month), 1)
month_count = month_temperature.map(lambda a: ((a[0], a[1]), 1))
# sum up the counts for each (year, month) pair
month_count = month_count.reduceByKey(lambda a,b: a+b)

month_count = month_count.sortBy(lambda k: (k[0][0], k[0][1]), ascending=True)

#count
month_count.saveAsTextFile("BDA/output/Q2_month_temperatures")

##########   Question 3  ##########
month_temperature = lines.map(lambda x: ((x[1][0:4], x[1][5:7], x[0]), float(x[3])))
month_filtered_temperature = month_temperature.filter(lambda x: int(x[0][0])>=1960 and int(x[0][0])<=2014)

# (key, value) = ((year, month, station), temperature))
average_temperature_count = month_filtered_temperature.map(lambda x: ((x[0]), (x[1], 1)))

# reduceByKey will return a sum (temp, count)
average_temperature = average_temperature_count.reduceByKey(lambda a,b: (a[0]+b[0],a[1]+b[1]))
average_temperature = average_temperature.map(lambda x: (x[0], x[1][0]/x[1][1]))
average_temperature = average_temperature. sortBy(lambda x: (x[0][0], x[0][1], x[0][2]))

average_temperature.saveAsTextFile("BDA/output/Q3_month_avg_temperatures")

##########   Question 4  ##########

temperature_file = sc.textFile("BDA/input/temperature-readings.csv")
precipitation_file = sc.textFile("BDA/input/precipitation-readings.csv")

lines = temperature_file.map(lambda line: line.split(";"))
precipitation_lines = precipitation_file.map(lambda line: line.split(";"))

# (key, value) = (station, temperature))
# station as the key
# sort out stations with temperature 
station_temperature = lines.map(lambda x: ((x[0]), float(x[3])))
max_temperatures_by_station = station_temperature.reduceByKey(lambda a,b: max(a, b))
filtered_max_temperatures_by_station = max_temperatures_by_station.filter(lambda x: x[1] >= 25 and x[1] <= 30)

#sort out stations with precipitation 
# (key, value) = ((station, date), precipitation)

station_precipitation = precipitation_lines.map(lambda x: ((x[0], x[1]), float(x[3])))
station_precipitation_by_day = station_precipitation.reduceByKey(lambda a,b: a+b)

# map to (station, precipitation)
station_precipitation_by_day = station_precipitation_by_day.map(lambda x: (x[0][0], x[1]))
station_max_precipitation_by_day = station_precipitation_by_day.reduceByKey(lambda a,b: max(a,b))
filtered_station_max_precipitation_by_day = station_max_precipitation_by_day.filter(lambda x: x[1] >= 100 and x[1] <= 200)


filtered_stations = filtered_max_temperatures_by_station.join(filtered_station_max_precipitation_by_day)

filtered_stations.saveAsTextFile("BDA/output/Q4_filtered_station_max_precipitation_by_day")

##########   Question 5  ##########

precipitation_file = sc.textFile("BDA/input/precipitation-readings.csv")
ostergotland_file = sc.textFile("BDA/input/stations-Ostergotland.csv")

precipitation_lines = precipitation_file.map(lambda line: line.split(";"))
ostergotland_lines = ostergotland_file.map(lambda line: line.split(";"))

ostergotland_stations = ostergotland_lines.map(lambda line: line[0]) # station as the key
station_ids_broadcast = sc.broadcast(set(ostergotland_stations.collect()))

ostergotland_precipitation_by_station = precipitation_lines.filter (
    lambda x: x[0] in station_ids_broadcast.value)

# (key, value) = ((station, year, month), precipitation)
station_precipitation = ostergotland_precipitation_by_station.map(lambda x: ((x[0], x[1][:4], x[1][5:7]), float(x[3])))
station_precipitation = station_precipitation.filter(lambda x: int(x[0][1]) >= 1993 and int(x[0][1]) <= 2016)
monthly_precipitation_precipitation = station_precipitation.reduceByKey(lambda a,b: a+b)

# (key, value) = ((year, month), precipitation)
monthly_precipitation = monthly_precipitation_precipitation.map(lambda x: ((x[0][1], x[0][2]), x[1])) 
monthly_precipitation_sum = monthly_precipitation.reduceByKey(lambda a,b: a+b)

# stations recorded in the month
# (key, value) = ((station，year, month), 1)
monthly_station_count = station_precipitation.map(lambda x: ((x[0][0], x[0][1], x[0][2]), 1))
# remove duplicates 
monthly_station_count = monthly_station_count.distinct()

# (key, value) = ((year, month), 1)
monthly_station_count = monthly_station_count.map(lambda x: ((x[0][1], x[0][2]), 1))
monthly_station_count = monthly_station_count.reduceByKey(lambda a,b: a+b)

monthly_average = monthly_precipitation_sum.join(monthly_station_count).mapValues(lambda x: x[0] / x[1])
monthly_average = monthly_average.sortByKey()

monthly_average.saveAsTextFile("BDA/output/Q5_ostergotland_monthly_avg_precipitation")
