import os
import sys
import pandas as pd
import json
import progressbar

header = ['Timestamp','Line_ID','Direction','Journey_Pattern_ID','Time_Frame','Vehicle_Journey_ID', \
         'Operator','Congestion','Lon','Lat','Delay','Block_ID','Vehicle_ID','Stop_ID','At_Stop']

data_dir = '../data/'
raw_data_dir = data_dir + 'raw/'

# ---------------------------------- Tools ----------------------------------- #

# output a dataframe to specific file
def output(df,out_dir,out_file):
    if not os.path.isdir(data_dir + out_dir):
        os.mkdir(data_dir + out_dir)
    out_file = data_dir + out_dir + out_file
    df.to_csv(out_file, index=False)

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

# square distance
def distance(x1,y1,x2,y2):
    return (x1-x2)**2+(y1-y2)**2


# ------------------------------ Congestion --------------------------------- #

# Extract congestion information
def extract_congestion(files):
    # Concat all files to a big dataframe
    ldf = list()
    with progressbar.ProgressBar(max_value=len(files)) as bar:
        i = 0
        for data_file in files:
            i += 1
            bar.update(i)
            df = pd.read_csv(raw_data_dir + data_file, header=None, names=header)
            cols = ['Congestion','Lon','Lat']
            ndf = keep_cols(df,cols)
            nndf = keep_rows(ndf,'Congestion',larger,1)
            ldf.append(nndf)
    odf = pd.concat(ldf)
    odf['Lon2'] = odf.apply(lambda row: round(row.Lon,5),axis=1)
    odf['Lat2'] = odf.apply(lambda row: round(row.Lat,5),axis=1)
    codf = odf.drop(['Lon','Lat'], axis=1)
    ccodf = codf.groupby(codf.columns.tolist()).size().reset_index().rename(columns={0:'count'})
    sccodf = ccodf.sort_values(by=['count'],ascending=False)[0:50]
    output(sccodf,'./','congestion.csv')


# ---------------------------------- Stops ----------------------------------- #

# Count stops for each bus line
def extract_stops(files):
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
            mscndf = merge_near_pos(scndf,1e-5)
            ldf.append(mscndf)
    odf = pd.concat(ldf)
    output(odf,'./','stops.csv')

# keep points far away each other
def merge_near_pos(df, threshold):
    df['keep'] = 1
    df = df.reset_index()
    ndim = df.shape[0]
    for i in range(0,ndim-1):
        for j in range(i+1,ndim):
            if (df.loc[i,'keep'] == 1 and df.loc[j,'keep'] == 1 and \
                    distance(df.loc[i,'Lon'],df.loc[i,'Lat'],df.loc[j,'Lon'],df.loc[j,'Lat']) < threshold):
                df.loc[j,'keep'] = 0
    ndf = df[df['keep']==1]
    return ndf


# ---------------------------------- Routes ---------------------------------- #

# Extract line's route
def extract_routes(files):
    # Concat all files as a big dataframe
    ldf = list()
    with progressbar.ProgressBar(max_value=len(files)) as bar:
        i = 0
        for data_file in files:
            i += 1
            bar.update(i)
            df = pd.read_csv(raw_data_dir + data_file, header=None, names=header)
            cols = ['Line_ID','Vehicle_ID','Lon','Lat']
            ndf = keep_cols(df,cols)
            nndf = ndf[~ndf.Line_ID.isnull()]
            ldf.append(nndf)
    odf = pd.concat(ldf)
    lines = set(nndf['Line_ID'].values)

    # For all lines
    ldf = list()
    with progressbar.ProgressBar(max_value=len(lines)) as bar:
        i = 0
        for line in lines:
            i += 1
            bar.update(i)
            # Grab one line's data
            sndf = ndf[ndf['Line_ID'] == line]
            # Group all data points and count the duplicated coordinate
            cndf = sndf.groupby(ndf.columns.tolist()).size().reset_index().rename(columns={0:'count'})
            # Sort by count and keep top 500 stops
            scndf = cndf.sort_values(by=['count'],ascending=False)[0:2000]
            mscndf = merge_near_pos(scndf,1e-6)
            rdf = point2line(mscndf)
            ldf.append(rdf)
    odf = pd.concat(ldf)
    output(odf,'./','lines.csv')

def point2line(df):
    df = df.reset_index()
    ndim = df.shape[0]
    lineID = df.loc[1,'Line_ID']
    lheader = ['line_ID','lon1','lat1','lon2','lat2']
    ndf = pd.DataFrame(columns=lheader)
    for i in range(0,ndim):
        nearest = -1
        nearest2 = -1
        min_dis = 99999
        min_dis2 = 99999
        for j in range(0,ndim):
            if (i != j):
                dis = distance(df.loc[i,'Lon'],df.loc[i,'Lat'],df.loc[j,'Lon'],df.loc[j,'Lat'])
                if (dis < min_dis2):
                    min_dis2 = dis
                    nearest2 = j
                    if min_dis2 < min_dis:
                        min_dis,min_dis2 = min_dis2,min_dis
                        nearest,nearest2 = nearest2,nearest
        s = pd.Series([lineID,df.loc[i,'Lon'],df.loc[i,'Lat'],df.loc[nearest,'Lon'],df.loc[nearest,'Lat']],index=lheader)
        s2 = pd.Series([lineID,df.loc[i,'Lon'],df.loc[i,'Lat'],df.loc[nearest2,'Lon'],df.loc[nearest2,'Lat']],index=lheader)
        ndf = ndf.append(s,ignore_index=True)
        ndf = ndf.append(s2,ignore_index=True)
    return ndf


# Generate a json file contains all line_ids for all days
def line_summary(files):
    lines = dict()
    for data_file in files:
        df = pd.read_csv(raw_data_dir + data_file, header=None, names=header)
        ndf = df[~df.Line_ID.isnull()]
        line_ids = [str(i) for i in set(ndf['Line_ID'].values)]
        lines[data_file] = line_ids
    with open(data_dir + 'line_summary.json','w') as f:
        f.write(json.dumps(lines, indent=4))


# ---------------------------------- Main ------------------------------------ #

def main():
    # Raw data files
    files = os.listdir(raw_data_dir)
    files = [item for item in files if (item[:4]=='siri')]

    # # Count everyday's bus lineID
    # print ('Begin line summary ... ')
    # line_summary(files)
    # print ('Done !')

    # # Extract stops for each bus line
    # print ('Begin extract stops ... ')
    # extract_stops(files)
    # print ('Done !')

    # # Extract routes for each bus line
    # print ('Begin extract routes ... ')
    # extract_routes(files)
    # print ('Done !')

    # Congestion
    extract_congestion(files)


if __name__ == '__main__':
    main()

