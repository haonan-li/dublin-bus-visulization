# dublin-bus-visulization

Group project for GEOM90007\_2018\_SM2: Spatial Visualisation

## Prerequisites

[processing3](https://processing.org/download/)

[Dublin-bus](https://data.dublinked.ie/dataset/dublin-bus-gps-sample-data-from-dublin-city-council-insight-project/) dataset, downlaod and put it into dublin\_data directory

## Install

pandas

```
pip install pandas
```

## Data prepare

create a data directory on the root, put all data into the `dublin_data` directory

```
mkdir dublin_data
```

## Running 

First unzip all gz files

```
cd dublin_data/
chmod +x unzip.sh
./unzip.sh
```

Then run data preprocessing

```
cd src/
python data.py
```

You can choose to run a part of data processing through disable and enable the source code in `main` funtion in [data.py](https://github.com/haonan-li/dublin-bus-visulization/blob/master/src/data.py)


Finally, run processing\_src.pde with processing


## Authors

* **[Haonan Li](https://github.com/haonan-li)**
* **[Wenyi Zhao](https://github.com/PeggyZWY)**
* **Sisi Liu** 
* **Xiao Ding**



