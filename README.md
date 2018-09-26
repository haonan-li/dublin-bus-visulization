# dublin-bus-visulization

Group project for GEOM90007\_2018\_SM2: Spatial Visualisation

## Prerequisites

[Processing2](https://processing.org/download/): Take care not to use `Processing3`

[Dublin-bus](https://data.dublinked.ie/dataset/dublin-bus-gps-sample-data-from-dublin-city-council-insight-project/) dataset, downlaod and put it into dublin\_data directory

[unfolding](https://github.com/tillnagel/unfolding) library: download it and put it to your processing `Sketchbook lcation`

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

Then run data preprocessing

```
cd src/
python data.py
```

You can choose to run a part of data processing by disabling and enabling the source code in `main` funtion in [data.py](https://github.com/haonan-li/dublin-bus-visulization/blob/master/src/data.py)


Finally, run [processing2\_src.pde](https://github.com/haonan-li/dublin-bus-visulization/tree/master/processing2_src/processing2_src.pde) with processing2


## Authors

* **[Haonan Li](https://github.com/haonan-li)**
* **[Wenyi Zhao](https://github.com/PeggyZWY)**
* **[Sisi Liu](https://github.com/thinine)** 
* **[]Xiao Ding](https://github.com/NeoDing)**



