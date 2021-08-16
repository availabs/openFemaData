const  fs = require('fs');
const _ = require('lodash');
const db = require('../open-fema-dataloader/db.js');
var sql = require('sql');
const {tables} = require('./tables')
// const Promise = require("bluebird");

sql.setDialect('postgres');

const details = sql.define(tables[process.argv[2]])

const loadFiles = (table) => {
    console.log('uploading', process.argv[2])
    let files = fs.readdirSync(table).filter(f => f.substr(0, 1) !== '.'); // filtering any open files

    return files
        .reduce(async (acc, file, fileI) => {
            // if(fileI < 48) return Promise.resolve();
            await acc;
            return new Promise((resolve, reject) => {
                console.log(`file ${++fileI} of ${files.length} ${fileI*100/files.length}% ${file}`)
                fs.readFile(table + '/' + file, 'utf8', (err,d) => {
                    let headers = d.split(/\r?\n/).slice(0, 1)[0].split('|').map(h => h.toLowerCase());

                    let values =
                        d.split(/\r?\n/)
                            .slice(1, d.split(/\r?\n/).length)
                            .map(d1 => d1.split('|'))
                            .filter(d2 => d2.length > 1)
                            .map((d2) => {
                                return d2.reduce((acc, value, index) => {
                                    acc[headers[index]] =
                                            (tables[table].numericColumns || []).includes(headers[index]) && [null, '', ' ', undefined].includes(value) ?
                                                0 :
                                                (tables[table].dateColumns || []).includes(headers[index]) && [0, '0'].includes(value) ?
                                                    null :
                                                    (tables[table].numericColumns || []).includes(headers[index]) && typeof value !== "number" && value ?
                                                        parseInt(value) :
                                                            (tables[table].floatColumns || []).includes(headers[index]) && typeof value !== "number" && value ?
                                                                parseFloat(value) :
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

loadFiles(process.argv[2])