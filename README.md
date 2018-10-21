# dublin-bus-visualization

Group project for GEOM90007\_2018\_SM2: Spatial Visualisation

## Prerequisites

[Processing2](https://processing.org/download/). Please note that you should download `Processing2` rather than `Processing3`.


[unfolding](https://github.com/tillnagel/unfolding) library. Please download and put it to your processing `Sketchbook lcation`.

## Directory tree structure
```
.
|____README.md
|____.gitignore
|____data
| |____stops.csv
| |____line_summary.json
| |____population.csv
| |____congestion.csv
| |____lineID.csv
| |____lines.csv
| |____district.geojson
|____src
| |____visualization
| | |____readElements.pde
| | |____visualization.pde
| | |____initMapSetting.pde
| | |____controlPanel.pde
| | |____showElements.pde
| |____.DS_Store
| |____data_processing.py
``` 

## How to run

### 1. Process the raw data 
**[Note: the outcome has been put in the ```data/``` dirctory], you don't need to do the following steps again.]**


1) Install Python packages: pandas, progressbar2

```
pip install pandas progressbar2
```
2) Prepare data

Create a data directory names `data/raw`.

Download [Dublin-bus](https://drive.google.com/file/d/1H6GdnppX5Emd2sT8Eid4iEVe2lrLV-o6/view?usp=sharing) dataset, unzip and put files into `data/raw/` directory. If you do not have access, download it [here](https://data.dublinked.ie/dataset/dublin-bus-gps-sample-data-from-dublin-city-council-insight-project/).

3) Run data processing code

```
cd src/
python data_processing.py
```

**Note**: please modify the `main` funtion in [data.py](https://github.com/haonan-li/dublin-bus-visulization/blob/master/src/data.py) by disabling and enabling particular function, to determine what data processing you want to do.

### 2. Run Processing sketch

Run [visualization.pde](https://github.com/haonan-li/dublin-bus-visualization/blob/master/src/visulization/visulization.pde) with `Processing2`.

## Reference

1. **[Dubline-bus](https://data.dublinked.ie/dataset/dublin-bus-gps-sample-data-from-dublin-city-council-insight-project/) dataset:**  
https://data.dublinked.ie/dataset/dublin-bus-gps-sample-data-from-dublin-city-council-insight-project/  
2. **[Population Density and Area Size by Electoral Division of Ireland](https://www.cso.ie/px/pxeirestat/Statire/SelectVarVal/Define.asp?maintable=CD115&PLanguage=0) database:**  
https://www.cso.ie/px/pxeirestat/Statire/SelectVarVal/Define.asp?maintable=CD115&PLanguage=0  
3. **[2006 Census Enumeration Areas Boundaries of Ireland](http://census.cso.ie/censusasp/saps/boundaries/ED%20Disclaimer.htm) dataset:**  
http://census.cso.ie/censusasp/saps/boundaries/ED%20Disclaimer.htm 
4. **[Boundary File Dataset Guidance](https://www.cso.ie/en/census/census2016reports/census2016boundaryfiles/) dataset:**  
https://www.cso.ie/en/census/census2016reports/census2016boundaryfiles/

## Authors

* **[Haonan Li](https://github.com/haonan-li)**
* **[Wenyi Zhao](https://github.com/PeggyZWY)**
* **[Sisi Liu](https://github.com/thinine)** 
* **[Xiao Ding](https://github.com/NeoDing)**



