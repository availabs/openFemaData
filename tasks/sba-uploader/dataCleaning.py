import pandas as pd
import sys
from os import listdir
from os.path import isfile, join


def intersection(lst1, lst2):
    return list(set(lst1) & set(lst2))


def process():
    print 'cleaning data...'

    path = './data' + '/'
    files = [f for f in listdir(path) if (isfile(join(path, f)) and f.endswith("xlsx") or f.endswith("xls"))]
    years = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20']
    columns = ['sbaphysicaldeclarationnumber', 'sbaeidldeclarationnumber', 'femadisasternumber', 'sbadisasternumber',
               'damagedpropertycityname', 'damagedpropertyzipcode', 'damagedpropertycounty/parishname', 'damagedpropertystatecode',
               'totalverifiedloss', 'verifiedlossrealestate', 'verifiedlosscontent', 'totalapprovedloanamount', 'approvedamountrealestate',
               'approvedamountcontent', 'approvedamounteidl']

    for fileNameI, fileName in enumerate(files):
        print str(fileNameI * 100 / len(files)) + '%'

        xls = pd.ExcelFile(path + fileName)

        home = [f for f in xls.sheet_names if 'fy' in f.lower() and 'home' in f.lower()][0]
        business = [f for f in xls.sheet_names if 'fy' in f.lower() and 'business' in f.lower()][0]
        year = [int('20' + f) for f in years if f in home][0]
        print(year)
        for loan_type in [home, business]:
            suffix = ('_H' if loan_type is home else '_B')

            df = pd.read_excel(path + fileName, sheet_name=loan_type, header=None)#.iloc[:, 0:(14 if loan_type is home else 15)]
            df = df.dropna(thresh=3) # drop any row with less tan 3 values. cleaning up comments.

            # set header
            new_header = df.iloc[0]
            df = df[1:]


            df.columns = new_header  # [f for f in new_header if f.lower().replace(' ', '') in columns]

            # set meta
            df['year'] = year
            df['loan_type'] = 'Business' if loan_type is business else 'Home'

            df.to_csv(path_or_buf=path + fileName + suffix + 'clean.csv', sep='|', index=False, encoding='utf-8')


if __name__ == '__main__':
    process()
