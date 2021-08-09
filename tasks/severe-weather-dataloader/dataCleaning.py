import pandas as pd
from os import listdir
from os.path import isfile, join

def process():
    path = 'details/'
    files = [f for f in listdir(path) if (isfile(join(path, f)) and f.endswith("csv"))]
    for fileNameI, fileName in enumerate(files):
        print str(fileNameI * 100 / len(files) )+ '%'
        csv = pd.read_csv('details/' + fileName)
        csv = csv.fillna('0')

        numeric_columns = [
            'begin_yearmonth', 'begin_day', 'begin_time', 'episode_id', 'event_id',
            'end_yearmonth', 'end_day', 'end_time', 'state_fips', 'year',
            'cz_fips', 'injuries_direct', 'injuries_indirect', 'deaths_direct', 'deaths_indirect',
            'begin_range', 'end_range'

        ]

        floating_columns = ['tor_length', 'tor_width', 'magnitude', 'begin_lat', 'begin_lon', 'end_lat', 'end_lon']

        other = ['begin_date_time', 'end_date_time']

        convert_dict = {}
        for col in numeric_columns:
            convert_dict[col.upper()] = int

        for col in floating_columns:
            convert_dict[col.upper()] = float

        csv.astype(convert_dict)
        csv['EVENT_NARRATIVE'] = csv['EVENT_NARRATIVE'].astype('string').str.replace('\n', ' ').str.replace('|', '')
        csv['EPISODE_NARRATIVE'] = csv['EPISODE_NARRATIVE'].astype('string').str.replace('\n', ' ').str.replace('|', '')

        csv.to_csv(path_or_buf='details/' + 'clean_' + fileName, sep='|', index=False)

if __name__ == '__main__':
    process()
