const  fs = require('fs');
const _ = require('lodash');
const db = require('../open-fema-dataloader/db.js');
var sql = require('sql');
const {tables} = require('./tables')
// const Promise = require("bluebird");

sql.setDialect('postgres');

const details = sql.define(tables['sba_disaster_loan_data_new'])

const loadFiles = () => {
    console.log('uploading');

    let dataFolder = './data/',
        table = 'sba_disaster_loan_data_new';

    let files = fs.readdirSync(dataFolder).filter(f => f.substr(0, 1) !== '.' && f.includes('clean')); // filtering any open files
    // naming: assumes business file to have _B, Home to have _H in them

    return files
        .reduce(async (acc, file, fileI) => {
            await acc;
            return new Promise((resolve, reject) => {

                console.log(`file ${++fileI} of ${files.length} ${fileI*100/files.length}% ${file}`)

                fs.readFile(dataFolder + file, 'utf8', (err,d) => {

                    let headers =
                        d.split(/\r?\n/)
                            .slice(0, 1)[0].split('|')
                            .map(h => h.toLowerCase()
                                .replace(/ /g, '_')
                                .replace(/\//g, '_or_'))

                    headers.push('loan_type')

                    let values =
                        d.split(/\r?\n/)
                            .slice(1, d.split(/\r?\n/).length)
                            .map(d1 => d1.split('|'))
                            .filter(d2 => d2.length > 2)
                            .map((d2) => {
                                return d2.reduce((acc, value, index) => {

                                    if(tables[table].floatColumns.includes(headers[index])){
                                        value = value.replace(/,/g, '')
                                        // console.log(value, value.replace(/,/g, ''), parseFloat(value))
                                    }
                                    if(tables[table].columns.includes(headers[index])){ //discarding extra columns
                                        acc[headers[index]] =
                                            ([...tables[table].numericColumns, ...tables[table].floatColumns]).includes(headers[index]) && [null, '', ' ', undefined].includes(value) ?
                                                0 :
                                                (tables[table].dateColumns || []).includes(headers[index]) && [0, '0'].includes(value) ?
                                                    null :
                                                    (tables[table].numericColumns || []).includes(headers[index]) && typeof value !== "number" && value ?
                                                        parseInt(value) :
                                                        (tables[table].floatColumns || []).includes(headers[index]) && typeof value !== "number" && value ?
                                                            parseFloat(value) :
                                                            value
                                    }
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

loadFiles()