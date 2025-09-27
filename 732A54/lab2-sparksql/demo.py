
from pyspark import SparkContext
from pyspark.sql import SQLContext, Row
from pyspark.sql import functions as F
from pyspark.sql.window import Window

# create a SparkContext
sc = SparkContext(appName = "exercise 1")
SQLContext = SQLContext(sc)

########   Q1 ##########
# create distributed dataset from the file
temperature_file = sc.textFile("BDA/input/temperature-readings.csv")
lines = temperature_file.map(lambda line: line.split(";"))
tempReadingsRow = lines.map(lambda p: (p[0],  int(p[1].split("-")[0]), float(p[3])))
tempReadingsString = ['station', 'year', 'temperature']
schemaTempReadings = SQLContext.createDataFrame(tempReadingsRow, tempReadingsString)


stationMax = schemaTempReadings.filter((F.col('year') >= 1950) & (F.col('year') < 2014))

w = Window.partitionBy( "year")

# max
yearMax = stationMax.withColumn('maxvalue', F.max('temperature').over(w))

yearMaxstation = yearMax.filter(F.col('temperature') == F.col('maxvalue'))

year_station__maxtemp_selected = yearMaxstation.select("year", "station", "maxvalue").\
    orderBy("maxvalue", ascending=False)

year_station__maxtemp_selected.coalesce(1).write.csv("BDA/output/Q1_max")

# min
yearMin = stationMax.withColumn('minvalue', F.min('temperature').over(w))

yearMinstation = yearMin.filter(F.col('minvalue') == F.col('temperature'))

year_station__mintemp_selected = yearMinstation.select("year", "station", "minvalue").\
    orderBy("minvalue", ascending=False)

year_station__mintemp_selected.coalesce(1).write.csv("BDA/output/Q1_min")


########   Q2 ##########
tempReadingsRow = lines.map(lambda p: ( p[0], int(p[1].split("-")[0]), int(p[1].split("-")[1]), float(p[3])))
tempReadingsString = ['station', 'year', 'month', 'temperature']
schemaTempReadings = SQLContext.createDataFrame(tempReadingsRow, tempReadingsString)

# sort the data by year and temperature
# max
data_unfiltered = schemaTempReadings.filter((F.col('year') >= 1950) & (F.col('year') <= 2014) & (F.col('temperature') > 10))\

# don't select unique year, month, conmbination
year_month_count = data_unfiltered. groupby(['year','month']).agg(F.count('station').alias('count')).orderBy(F.col('count').desc())

year_month_count.coalesce(1).write.csv("BDA/output/Q2_max")    


# select unique year, month, conmbination 
data_filtered = data_unfiltered.select('year', 'month', 'station').distinct()

# count 
year_month_count_distinct = data_filtered. groupby(['year','month']).agg(F.count('station').alias('count')).orderBy(F.col('count').desc())

year_month_count_distinct.coalesce(1).write.csv("BDA/output/Q2_max_distinct")    

    
########   Q3 ##########
tempReadingsRow = lines.map(lambda p: ( p[0], int(p[1].split("-")[0]), int(p[1].split("-")[1]), float(p[3])))
tempReadingsString = ['station', 'year', 'month', 'temperature']
schemaTempReadings = SQLContext.createDataFrame(tempReadingsRow, tempReadingsString)

# sort the data by year and temperature
# max
data_filtered = schemaTempReadings.filter((F.col('year') >= 1960) & (F.col('year') <= 2014))

# count 
year_month_avg = data_filtered. groupby(['year','month','station']).agg(F.avg('temperature').alias('average_temp')).orderBy(F.col('average_temp').desc())

year_month_avg.coalesce(1).write.csv("BDA/output/Q3_avg")    

########   Q4 ##########

# create distributed dataset from the file
temperature_file = sc.textFile("BDA/input/temperature-readings.csv")
precipitation_file = sc.textFile("BDA/input/precipitation-readings.csv")
lines = temperature_file.map(lambda line: line.split(";"))
precipitation_lines = precipitation_file.map(lambda line: line.split(";"))

# create temp reading dataframe
tempReadingsRow = lines.map(lambda p: ( p[0], int(p[1].split("-")[0]), int(p[1].split("-")[1]), float(p[3])))
tempReadingsString = ['station', 'year', 'month', 'temperature']
schemaTempReadings = SQLContext.createDataFrame(tempReadingsRow, tempReadingsString)

# create temp precipitation dataframe
precReadingsRow = precipitation_lines.map(lambda p: ( p[0], int(p[1].split("-")[0]), int(p[1].split("-")[1]), int(p[1].split("-")[2]), float(p[3])))
precReadingsString = ['station', 'year', 'month', 'day', 'precipitation']
schemaPrecpReadings = SQLContext.createDataFrame(precReadingsRow, precReadingsString)


# sort the max temp 
temp_filtered =schemaTempReadings.groupby('station').agg(F.max('temperature').alias('max_temp'))
temp_filtered = temp_filtered.filter((F.col('max_temp') >= 25) & (F.col('max_temp') <= 30))

# sort the target precipitation
prec_filtered = schemaPrecpReadings.groupby (['station', 'year', 'month', 'day']).agg(F.sum('precipitation').alias('daily_prec'))
prec_filtered_daily_station = prec_filtered.filter((F.col('daily_prec') >= 100) & (F.col('daily_prec') <= 200)).groupby('station').agg(F.max('daily_prec').alias('max_daily'))

station_maxTemp_maxPrec = temp_filtered.join (prec_filtered_daily_station, 
                                                on="station",  # Use the column name directly when it's the same in both DataFrames
                                                how="inner").orderBy("station")

station_maxTemp_maxPrec.coalesce(1).write.csv("BDA/output/Q4")

########   Q5 ##########

# create distributed dataset from the file
precipitation_file = sc.textFile("BDA/input/precipitation-readings.csv")
precipitation_lines = precipitation_file.map(lambda line: line.split(";"))

station_file = sc.textFile("BDA/input/stations-Ostergotland.csv")
station_lines = station_file.map(lambda line: line.split(";"))

# create precipitation dataframe
precReadingsRow = precipitation_lines.map(lambda p: ( p[0], int(p[1].split("-")[0]), int(p[1].split("-")[1]), int(p[1].split("-")[2]), float(p[3])))
precReadingsString = ['station', 'year', 'month', 'day', 'precipitation']
schemaPrecpReadings = SQLContext.createDataFrame(precReadingsRow, precReadingsString)

# create station  precipitation dataframe
statReadingsRow = station_lines.map(lambda p: ( p[0],))
statReadingsString = ['station']
schemaStations = SQLContext.createDataFrame(statReadingsRow, statReadingsString)

# 
ostergotland_prec = schemaPrecpReadings.join (schemaStations, on = 'station', how = 'inner').filter((F.col('year') >= 1993) & (F.col('year') <= 2016))

# First calculate the monthly sum for each station
station_monthly_totals = ostergotland_prec.groupby(['station', 'year', 'month']).agg(
    F.sum('precipitation').alias('station_Month_prec')
)

# Then calculate the average of these totals across stations for each year/month
ostergotland_monthly_prec = station_monthly_totals.groupby(['year', 'month']).agg(
    F.avg('station_Month_prec').alias('region_monthly_prec')
).orderBy(['year', 'month'] )

ostergotland_monthly_prec.coalesce(1).write.csv("BDA/output/Q5")