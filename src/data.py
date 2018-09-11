import pandas as pd

header = ['Timestamp','Line_ID','Direction','Journey_Pattern_ID','Time_Frame','Vehicle_Journey_ID', \
         'Operator','Congestion','Lon','Lat','Delay','Block_ID','Vehicle_ID','Stop_ID','At_Stop']

# output a dataframe to specific file
def output(df,outfile):
	outfile = '../dublin_data' + outfile 
    df.to_csv(outfile, index=False)

# keep columns by column names
def keep_cols(df,cols):
    drops = header[:]
    [drops.remove(i) for i in cols]
    ndf = df.drop(drops, axis=1)
    return ndf

# keep rows by condition
def keep_rows(df,col,satisfy):
    ndf = df[satisfy(df,col)]
    return ndf

# Return true if col value equal or larger then threshold
def larger(df,col,threshold=1):
    return df[col] >= threshold

def main():
    df = pd.read_csv('../dublin_data/siri.20130101.csv', header=None, names=header)
    cols = ['Congestion','Lon','Lat']
    ndf = keep_cols(df,cols)
    nndf = keep_rows(ndf,'Congestion',larger)
    output(nndf,'congestion.csv')

if __name__ == '__main__':
    main()
    
