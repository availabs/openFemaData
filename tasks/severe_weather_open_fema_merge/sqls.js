const db = require('../open-fema-dataloader/db.js');
const reformat_swd = require('./reformat_swd');
const swd_datasource_entry = require('./swd_datasource_entry');
const reformat_open_fema_ihp = require('./reformat_open_fema_ihp');
const reformat_open_fema_pa = require('./reformat_open_fema_pa');
const open_fema_update_sba = require('./open_fema_update_sba')
const open_fema_update_geoid = require('./open_fema_update_geoid');

const runAll = async () => {
    let table = process.argv[2];
    let sba = process.argv[3];

    // await db.query(reformat_swd);
    // await db.query(swd_datasource_entry);
    await db.query(reformat_open_fema_ihp(table, sba));
    console.log('0')
    await db.query(open_fema_update_geoid(table));
    console.log('1')
    await db.query(reformat_open_fema_pa(table));
    console.log('2')
    if(sba){
        await db.query(open_fema_update_sba(table))
        console.log('3')
    }
    console.log('Done!', process.argv[3])
}

runAll()