const  fs = require('fs');
const _ = require('lodash');
const db = require('../open-fema-dataloader/db.js');
var sql = require('sql');
const {tables} = require('./tables')

sql.setDialect('postgres');

const details = sql.define(tables.nfip_claims)
console.warn('for bigger files:  node --max-old-space-size=8192 upload.js ')
console.log(details.create().ifNotExists().toQuery())

const converToBool = (value) =>
    value === '0.0' ? false :
    value === '1.0' ? true : value
const loadFiles = async (table = 'nfip_claims') => {
    console.log('Creating Table', table)
    await db.query(details.create().ifNotExists().toQuery());

    console.log('uploading')
    let fileName = 'FimaNfipClaims_clean.csv'
    let files = ['FimaNfipClaims_clean.csv'] //fs.readdirSync(fileName).filter(f => f.substr(0, 1) !== '.'); // filtering any open files

    return files
        .reduce(async (acc, file, fileI) => {
            await acc;
            return new Promise((resolve, reject) => {
                console.log(`file ${++fileI} of ${files.length} ${fileI*100/files.length}% ${file}`)
                fs.readFile(fileName, 'utf8', (err,d) => {

                    let headers = d.split(/\r?\n/).slice(0, 1)[0].split('|')
                        .map(h =>
                            h === 'basementEnclosureCrawlspace' ? 'basementEnclosureCrawlspaceType' :
                            h === 'reportedZipcode' ? 'reportedZipCode'
                                : h)
                        .map(h => h.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`))

                    let boolCols = tables[table].booleanColumns.map(h => h.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`))
                    let numCols = tables[table].numericColumns.map(h => h.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`))
                    let dateCols = tables[table].dateColumns.map(h => h.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`))
                    let floatCols = tables[table].floatColumns.map(h => h.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`))

                    let lines = d.split(/\r?\n/).slice(1, d.split(/\r?\n/).length)

                    resolve(
                        _.chunk(lines, 1500)
                            .reduce(async (accLines, currLines, linesIndex) => {

                                // if (linesIndex > 1) return Promise.resolve();

                                await accLines;
                                console.log(linesIndex, `${linesIndex*1500} / ${lines.length}`, (linesIndex*1500*100)/lines.length)

                                let values =
                                    currLines
                                        .map(d1 => d1.split('|'))
                                        .filter(d2 => d2.length > 1)
                                        .map((d2) => {
                                            return d2.reduce((acc, value, index) => {
                                                acc[headers[index]] =
                                                    (numCols || []).includes(headers[index]) && [null, '', ' ', undefined].includes(value) ?
                                                        0 :
                                                        (dateCols || []).includes(headers[index]) && [0, '0'].includes(value) ?
                                                            null :
                                                            (numCols || []).includes(headers[index]) && typeof value !== "number" && value ?
                                                                parseInt(value) :
                                                                (floatCols || []).includes(headers[index]) && typeof value !== "number" && value ?
                                                                    parseFloat(value) :
                                                                    (boolCols || []).includes(headers[index]) ? converToBool(value) :
                                                                    value
                                                return acc;
                                            }, {})
                                        });

                                let query = details.insert(values).toQuery();
                                return db.query(query.text,query.values)
                            }, Promise.resolve())
                    )
                })
            })
    }, Promise.resolve())

}

loadFiles()