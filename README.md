# dublin-bus-visulization

Group project for GEOM90007\_2018\_SM2: Spatial Visualisation

## Prerequisites

[Processing2](https://processing.org/download/), Please note that you should download `Processing2` rather than `Processing3`.


[unfolding](https://github.com/tillnagel/unfolding) library, download and put it to your processing `Sketchbook lcation`.

## Install

pandas

```
pip install pandas
```

## Data prepare

Create a data directory names `dublin_data`.

Download [Dublin-bus](https://drive.google.com/file/d/1H6GdnppX5Emd2sT8Eid4iEVe2lrLV-o6/view?usp=sharing) dataset, unzip and put files into `dublin\_data` directory. If you do not have access, download it [here](https://data.dublinked.ie/dataset/dublin-bus-gps-sample-data-from-dublin-city-council-insight-project/).

## Running 

Run data preprocessing

```
cd src/
python data.py
```

**Note**: please modify the `main` funtion in [data.py](https://github.com/haonan-li/dublin-bus-visulization/blob/master/src/data.py) by disabling and enabling particular function, to determine what data processing you want to do.

Finally, run [processing2\_src.pde](https://github.com/haonan-li/dublin-bus-visulization/tree/master/processing2_src/processing2_src.pde) with `processing2`.


## Authors

* **[Haonan Li](https://github.com/haonan-li)**
* **[Wenyi Zhao](https://github.com/PeggyZWY)**
* **[Sisi Liu](https://github.com/thinine)** 
* **[Xiao Ding](https://github.com/NeoDing)**



