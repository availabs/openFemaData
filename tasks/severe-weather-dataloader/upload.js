const  fs = require('fs');
const _ = require('lodash');
const db = require('../open-fema-dataloader/db.js');
var sql = require('sql');
const {tables} = require('./tables')
// const Promise = require("bluebird");

sql.setDialect('postgres');

const details = sql.define(tables.details)

const loadFiles = (table) => {
    let files = fs.readdirSync(table).filter(f => f.substr(0, 1) !== '.' && f.includes('clean_')); // filtering any open files
    // const files = ['StormEvents_details-ftp_v1.0_d1995_c20210803.csv']
    // files = [files[0]]

    return files
        .reduce(async (acc, file, fileI) => {
            // if(fileI < 65) return Promise.resolve();

        await acc;
        return new Promise((resolve, reject) => {
            console.log(`file ${++fileI} of ${files.length} ${fileI*100/files.length}% ${file}`)
            fs.readFile(table + '/' + file, 'utf8', (err,d) => {
                let headers = d.split(/\r?\n/).slice(0, 1)[0].split('|').map(h => h.toLowerCase());

                let values =
                    d.split(/\r?\n/)
                        .slice(1, d.split(/\r?\n/).length)
                        .map(d1 =>
                            d1
                                // .replace('|Muhlenberg', 'Muhlenberg') // typos
                                /*.replace(/\|/g, 'REPLACEME')*/
                                .split('|')
                        )
                        .filter(d2 => d2.length > 1)
                        // .filter(d2 => d2.length > 51)
                        .map((d2) => {
                            return d2.reduce((acc, value, index) => {
                                acc[headers[index]] =
                                        [...tables[table].numericColumns,...tables[table].other].includes(headers[index]) && [null, '', ' ', undefined].includes(value) ?
                                            0 :
                                            tables[table].numericColumns.includes(headers[index]) && typeof value !== "number" && value ?
                                                parseInt(value) :
                                                value
                                return acc;
                            }, {})
                        });
                resolve(_.chunk(values, 500)
                        .reduce(async (accChunk, chunk, chunkI) => {
                            await accChunk;
                            let query = details.insert(chunk).toQuery();
                            return db.query(query.text,query.values)
                        }, Promise.resolve()))
            })
        })
    }, Promise.resolve())

}

loadFiles('details')