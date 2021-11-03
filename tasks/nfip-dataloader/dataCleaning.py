import pandas as pd
import sys
from os import listdir
from os.path import isfile, join


def intersection(lst1, lst2):
    return list(set(lst1) & set(lst2))


def process():
    print 'cleaning data...'

    path = './'
    files = [f for f in listdir(path) if (isfile(join(path, f)) and f.endswith("csv"))]
    for fileNameI, fileName in enumerate(files):
        print str(fileNameI * 100 / len(files)) + '%'
        csv = pd.read_csv(path + fileName)
        csv = csv.fillna('0')

        csv.to_csv(path_or_buf= 'FimaNfipClaims_' + 'clean.csv', sep='|', index=False, encoding='utf-8')


if __name__ == '__main__':
    process()
