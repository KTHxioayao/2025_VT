# Distributed Spatio-Temporal Kernel Regression with PySpark

> Course project for **732A54 Big Data Analytics** at Linköping University

## Overview

A distributed kernel regression model that predicts hourly temperatures at arbitrary locations and dates in Sweden, implemented entirely with PySpark RDD transformations. The model combines three Gaussian kernels (spatial, temporal, diurnal) to weight historical weather observations, and compares additive vs. multiplicative kernel composition strategies.

## Method

Given a query point (latitude, longitude, date, hour), the model computes a weighted average of historical temperature readings:

```
T̂(lat, lon, date, hour) = Σ wᵢ · Tᵢ  /  Σ wᵢ
```

where the weight `wᵢ` for each historical observation is determined by three Gaussian kernels:

| Kernel | Smoothing factor (h) | Measures |
|--------|---------------------|----------|
| **Spatial** | 300,000 | Haversine distance between station and query point |
| **Date** | 40 | Day-of-year difference (captures seasonality) |
| **Hour** | 2 | Hour-of-day difference (captures diurnal cycle) |

Two combination strategies are compared:

- **Additive**: `w = k_spatial + k_date + k_hour`
- **Multiplicative**: `w = k_spatial × k_date × k_hour`

## Results

Predictions for **2013-07-04** at coordinates (58.4274, 14.826), sampled every 2 hours from 4:00 to 24:00:

| Method | Temperature range | Behavior |
|--------|------------------|----------|
| **Multiplicative** | 11.2 – 17.2 °C | Clear diurnal cycle, peak at noon |
| **Additive** | ~7 – 8 °C | Nearly flat curve, weak time-of-day signal |

The multiplicative kernel produces more realistic predictions because it enforces that an observation must be close in *all three* dimensions simultaneously to receive a high weight. The additive kernel allows a strong match in any single dimension to dominate, washing out the diurnal pattern.

## Implementation

The pipeline runs on PySpark RDDs:

1. **Broadcast** station metadata (coordinates) to all workers
2. **Filter** temperature readings to exclude future observations relative to the query date
3. **Map** each observation through the three Gaussian kernels
4. **Reduce** to compute the weighted average temperature

```python
# Pseudocode
stations_bc = sc.broadcast(stations)
predictions = (
    temperatures_rdd
    .filter(lambda r: r.date < query_date)
    .map(lambda r: (kernel_spatial(r) ⊕ kernel_date(r) ⊕ kernel_hour(r), r.temp))
    .map(lambda (w, t): (w * t, w))
    .reduce(lambda a, b: (a[0]+b[0], a[1]+b[1]))
)
T_hat = predictions[0] / predictions[1]
```

## How to Run

```bash
# Requires PySpark and a Spark cluster or local mode
jupyter notebook Lab3_report.ipynb
```

Requires PySpark, NumPy. The notebook includes all code, kernel decay visualizations, and prediction plots.

## Key Takeaways

- Kernel bandwidth selection matters: too narrow → noisy, too wide → over-smoothed
- Multiplicative kernels are better suited for spatio-temporal prediction because they enforce joint proximity
- PySpark's broadcast + RDD filter/map/reduce pattern handles large-scale weather datasets efficiently
- The spatial kernel with h=300,000 gives reasonable decay over distances typical of Swedish weather station spacing

## Authors

**Xiaochen Liu** & **Liuxi Mei** — Linköping University  
xiali125@student.liu.se
