const  fs = require('fs');
const _ = require('lodash');
const db = require('../open-fema-dataloader/db.js');
var sql = require('sql');
const {tables} = require('./tables')
const {index} = require("cheerio/lib/api/traversing");

sql.setDialect('postgres');

const nri = sql.define(tables.nri)
console.log(nri.create().ifNotExists().toQuery())

const converToBool = (value) =>
    value === '0.0' ? false :
    value === '1.0' ? true : value

const formatValue = (value) => value.trim().replace(/\0/g, ``)

const loadFiles = async (table = 'nri') => {
    console.warn('for bigger files:  node --max-old-space-size=8192 upload.js ')
    console.log('Creating Table', table)

    await db.query(nri.create().ifNotExists().toQuery());

    console.log('uploading')

    let dataFolder = './data/'
    let files = fs.readdirSync(dataFolder).filter(f => f.substr(0, 1) !== '.'); // filtering any open files

    return files
        .reduce(async (acc, file, fileI) => {
            await acc;
            return new Promise((resolve, reject) => {

                console.log(`file ${++fileI} of ${files.length} ${fileI*100/files.length}% ${file}`)
                fs.readFile(dataFolder + file, 'utf8', (err,d) => {

                    let headers = d.split(/\r?\n/).slice(0, 1)[0].split(',')

                    let boolCols = tables[table].booleanColumns
                    let numCols = tables[table].numericColumns
                    let dateCols = tables[table].dateColumns
                    let floatCols = tables[table].floatColumns

                    let lines = d.split(/\r?\n/).slice(1, d.split(/\r?\n/).length)

                    resolve(
                        _.chunk(lines, 1500)
                            .reduce(async (accLines, currLines, linesIndex) => {

                                // if (linesIndex < 2 ) return Promise.resolve();

                                await accLines;
                                console.log(linesIndex, `${linesIndex*1500} / ${lines.length}`, (linesIndex*1500*100)/lines.length)

                                let values =
                                    currLines
                                        .map(d1 => d1.split(','))
                                        .filter(d2 => d2.length > 1)
                                        .map((d2) => {
                                            return d2.reduce((acc, value, index) => {
                                                // console.log(headers[index], tables[table].orig_columns)
                                                if(tables[table].orig_columns.includes(headers[index])){
                                                    acc[headers[index].toLowerCase()] =
                                                        (numCols || []).includes(headers[index]) && [null, '', ' ', undefined].includes(value) ?
                                                            0 :
                                                            (floatCols || []).includes(headers[index]) && [null, '', ' ', undefined].includes(value) ?
                                                                0.0 :
                                                                (dateCols || []).includes(headers[index]) && [0, '0'].includes(value) ?
                                                                    null :
                                                                    (numCols || []).includes(headers[index]) && typeof value !== "number" && value ?
                                                                        parseInt(value) :
                                                                        (floatCols || []).includes(headers[index]) && typeof value !== "number" && value ?
                                                                            parseFloat(value) :
                                                                            (boolCols || []).includes(headers[index]) ? converToBool(value) :
                                                                                formatValue(value)
                                                }
                                                return acc;
                                            }, {})
                                        })
                                        .filter(d2 => d2);

                                let query = nri.insert(values).toQuery();
                                return db.query(query.text,query.values)
                            }, Promise.resolve())
                    )
                })
            })
    }, Promise.resolve())

}

const datasourceEntry = async () => {
    const sql = `
        INSERT INTO public.datasources(
            title,
            description, "table",
            data_url, data_dictionary,
            landing_page, publisher,
            last_refresh,
            start_date, end_date, record_count)

        SELECT 'National Risk Index' title,
               '' description, 'open_fema_data.nri' "table",
               'https://hazards.fema.gov/nri/data-resources' data_url, '' data_dictionary,
               'https://hazards.fema.gov/nri/' landing_page, 'Federal Emergency Management Agency' publisher,
               (SELECT NOW()) last_refresh,
               null start_date, null end_date,
               (select count(1) record_count from open_fema_data.nri) record_count
        ON CONFLICT ON CONSTRAINT datasources_table_key
            DO UPDATE
            SET
--                 title = 'National Risk Index' ,
--                 description = '',
--                 "table" = 'open_fema_data.nri',
--                 data_url = 'https://hazards.fema.gov/nri/data-resources',
--                 data_dictionary = '',
--                 landing_page = 'https://hazards.fema.gov/nri/',
--                 publisher = 'Federal Emergency Management Agency',
                last_refresh = (SELECT NOW()),
--                 start_date = null,
--                 end_date = null,
                record_count = (select count(1) record_count from open_fema_data.nri)
        WHERE public.datasources."table" = 'open_fema_data.nri'
        `

    await db.query(sql)
}


loadFiles().then(() => datasourceEntry())