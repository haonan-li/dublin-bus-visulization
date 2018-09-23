import os
import sys
import pandas as pd
import json

header = ['Timestamp','Line_ID','Direction','Journey_Pattern_ID','Time_Frame','Vehicle_Journey_ID', \
         'Operator','Congestion','Lon','Lat','Delay','Block_ID','Vehicle_ID','Stop_ID','At_Stop']

data_dir = '../dublin_data/'

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

# Extract all stops
def stops(data_file):
    df = pd.read_csv(data_dir + data_file, header=None, names=header)
    cols = ['Lon','Lat','At_Stop']
    ndf = keep_cols(df,cols)
    nndf = keep_rows(ndf,'At_Stop',larger,1)
    output(nndf,'stop/',data_file)

# Extract line's route
def route(data_file):
    df = pd.read_csv(data_dir + data_file, header=None, names=header)
    cols = ['Timestamp','Line_ID','Vehicle_ID','Lon','Lat']
    ndf = keep_cols(df,cols)
    nndf = ndf[~ndf.Line_ID.isnull()]
    line_ids = set(nndf['Line_ID'].values)
    ldf = []
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

# Generate a json file contains all line_ids of all files
def line2json(files):
    lines = dict()
    for data_file in files:
        df = pd.read_csv(data_dir + data_file, header=None, names=header)
        ndf = df[~df.Line_ID.isnull()]
        line_ids = [str(i) for i in set(ndf['Line_ID'].values)]
        lines[data_file] = line_ids
    with open(data_dir + 'route/lines.txt','w') as f:
        f.write(json.dumps(lines, indent=4))

def main():
    files = os.listdir(data_dir)
    files = [item for item in files if (item[:4]=='siri')]

    line2json(files)

    for item in files:
        route(item)
        # stops(item)
        # congestion(item)


if __name__ == '__main__':
    main()

