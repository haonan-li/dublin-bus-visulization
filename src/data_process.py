import os
import sys
import pandas as pd
import json
import progressbar

header = ['Timestamp','Line_ID','Direction','Journey_Pattern_ID','Time_Frame','Vehicle_Journey_ID', \
         'Operator','Congestion','Lon','Lat','Delay','Block_ID','Vehicle_ID','Stop_ID','At_Stop']

data_dir = '../data/'
raw_data_dir = data_dir + 'raw/'

# output a dataframe to specific file
def output(df,out_dir,out_file):
    if not os.path.isdir(data_dir + out_dir):
        os.mkdir(data_dir + out_dir)
    out_file = data_dir + out_dir + out_file
    df.to_csv(out_file, index=False)
    print (out_file + '\t\t Done!')

# keep columns by column names
def keep_cols(df,cols):
    drops = header[:]
    [drops.remove(i) for i in cols]
    ndf = df.drop(drops, axis=1)
    return ndf

# keep rows by condition
def keep_rows(df,col,satisfy,threshold=1):
    ndf = df[satisfy(df,col,threshold)]
    return ndf

# Return true if col value equal or larger then threshold
def larger(df,col,threshold):
    return df[col] >= threshold

# Extract congestion information
def congestion(data_file):
    df = pd.read_csv(data_dir + data_file, header=None, names=header)
    cols = ['Congestion','Lon','Lat']
    ndf = keep_cols(df,cols)
    nndf = keep_rows(ndf,'Congestion',larger,1)
    output(nndf,'congestion/',data_file)

# Count stops for each bus line
def line_stop(files):
    # Concat all files to a big dataframe
    ldf = list()
    with progressbar.ProgressBar(max_value=len(files)) as bar:
        i = 0
        for data_file in files:
            i += 1
            bar.update(i)
            df = pd.read_csv(raw_data_dir + data_file, header=None, names=header)
            cols = ['Lon','Lat','At_Stop', 'Line_ID']
            ndf = keep_cols(df,cols)
            nndf = keep_rows(ndf,'At_Stop',larger,1)
            ldf.append(nndf)
    odf = pd.concat(ldf)
    lines = set(odf['Line_ID'].values)
    # For all lines
    ldf = list()
    with progressbar.ProgressBar(max_value=len(lines)) as bar:
        i = 0
        for line in lines:
            i += 1
            bar.update(i)
            # Grab one line's data
            ndf = odf[odf['Line_ID']==line]
            # Group all stops and count the duplicated stops
            # (If one position have more duplicates, it is more likely to be a exact stop)
            cndf = ndf.groupby(ndf.columns.tolist()).size().reset_index().rename(columns={0:'count'})
            # Sort by count and keep top 500 stops
            scndf = cndf.sort_values(by=['count'],ascending=False)[0:500]
            mscndf = merge_near_pos(scndf)
            ldf.append(mscndf)
    odf = pd.concat(ldf)
    output(odf,'./','stops.csv')

# square distance
def distance(x1,y1,x2,y2):
    return (x1-x2)**2+(y1-y2)**2

# keep points far away each other
def merge_near_pos(df):
    df['keep'] = 1
    df = df.reset_index()
    ndim = df.shape[0]
    for i in range(0,ndim-1):
        for j in range(i+1,ndim):
            if (df.loc[i,'keep'] == 1 and df.loc[j,'keep'] == 1 and \
                    distance(df.loc[i,'Lon'],df.loc[i,'Lat'],df.loc[j,'Lon'],df.loc[j,'Lat']) < 1e-5):
                df.loc[j,'keep'] = 0
    ndf = df[df['keep']==1]
    return ndf

# Extract line's route
def route(data_file):
    df = pd.read_csv(data_dir + data_file, header=None, names=header)
    cols = ['Timestamp','Line_ID','Vehicle_ID','Lon','Lat']
    ndf = keep_cols(df,cols)
    nndf = ndf[~ndf.Line_ID.isnull()]
    line_ids = set(nndf['Line_ID'].values)
    ldf = list()
    line = dict()

    for line_id in line_ids:
        sndf = ndf[ndf.Line_ID == line_id]
        vehicle_ids = set(sndf['Vehicle_ID'].values)
        # For a specific line_id, find the vehicle_id has largest data point
        for vehicle_id in vehicle_ids:
            tsndf = sndf[sndf.Vehicle_ID == vehicle_id]
            if line_id in line.keys():
                if line[line_id].shape[0] < tsndf.shape[0]:
                    line[line_id] = tsndf
            else:
                line[line_id] = tsndf
        # Make lines (from points)
        lsndf = sndf.copy()
        sndf.drop(sndf.index[-1],inplace=True)
        lsndf.drop(lsndf.index[0],inplace=True)
        sndf['toLon'] = lsndf['Lon'].values
        sndf['toLat'] = lsndf['Lat'].values
    # Combine all lines to a dataframe
    for line_id in line.keys():
        ldf.append(line[line_id])
    odf = pd.concat(ldf)
    output(odf,'route/',data_file)

# Generate a json file contains all line_ids for all days
def bus_line_summary(files):
    lines = dict()
    for data_file in files:
        df = pd.read_csv(data_dir + data_file, header=None, names=header)
        ndf = df[~df.Line_ID.isnull()]
        line_ids = [str(i) for i in set(ndf['Line_ID'].values)]
        lines[data_file] = line_ids
    with open(data_dir + 'line_summary.json','w') as f:
        f.write(json.dumps(lines, indent=4))

def main():
    # Raw data files
    files = os.listdir(raw_data_dir)
    files = [item for item in files if (item[:4]=='siri')]

    # Count everyday's bus lineID
    # bus_line_summary(files)

    # Count the stops for each bus line
    line_stop(files)

    # Everyday's congestion may different, so process separately
    # congestion(item)
    # Everyday's bus line may different, so process separately
    # route(item)


if __name__ == '__main__':
    main()

