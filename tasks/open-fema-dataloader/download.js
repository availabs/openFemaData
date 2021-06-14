const fetch = require('node-fetch');
const db = require('./db.js');
var sql = require('sql');
const tables = require('./open_fema_tables');
const Promise = require("bluebird");


const url = 'https://www.fema.gov/api/open/v1/FemaWebDisasterSummaries.json'
const camelToSnakeCase = str => str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);

let datasources = sql.define(tables.datasources)

db.promise(datasources.select().toQuery()).then(sources => {
	//console.log('sources', )
	sources
		.filter(d => [
			//'disaster_declarations_summaries_v2'
			//'fema_web_disaster_declarations_v1',
  			//'fema_web_disaster_summaries_v1',
  			// 'housing_assistance_owners_v2',
  			// 'housing_assistance_renters_v2',
  			'individuals_and_households_program_valid_registrations_v1'
			].includes(d.table.split('.')[1]))
		.forEach(source => {
			updateChunks(source)
				.then(d =>{
				console.log('finished',d.reduce((a,b) => a+b))
				db.end()
			})
		})
	//db.end()		
})

function updateChunks(source) {

	let skips = []
	let progress = 0
	// face test
	// source.record_count = 100000
	const [schema,table] = source.table.split('.')
	const sql_table = sql.define(tables[table])

	//console.log(sql_table.create().toQuery())
	//console.log('source', source)
	//return 
	for(let i=0; i < source.record_count; i+=1000){
		skips.push(i)
	}
	return Promise.map(skips,(skip =>{
		return new Promise((resolve,reject) => {
			console.time(`fetch skip ${skip}`)
			fetch(`${source.data_url}?$skip=${skip}`)
			.then(res => res.json())
			.then(res => {
				console.timeEnd(`fetch skip ${skip}`)
				let dataKey = source.data_url.split('/')[source.data_url.split('/').length-1]
				let data = res[dataKey]
				const newData = data.map((curr) => {
					return Object.keys(curr).reduce((snake, col) => {
						snake[camelToSnakeCase(col)] = curr[col]
						return snake
					},{})
					
				},{})
				console.log(newData[0])
				Promise.all(
					arrayChunk(newData,500)
					//.filter((k,i) => i < 1)
					.map(chunk =>{
						let query = sql_table
							.insert(Object.values(chunk)) // upsert datasources
							.onConflict({
						    	columns: tables[table].columns.filter(k => k.primaryKey).map(d => d.name),
						    	update: tables[table].columns.filter(k => !k.primaryKey).map(d => d.name)
					  		}).toQuery()
				  		
				  		//console.log(query.text, query.values.length, query.values)
						return db.query(query.text,query.values)
					})
				)
				.then(ins => {
			  		let rows = ins.reduce((a,b)=> {
			  			if(b.rowCount && !isNaN(+b.rowCount)){
			  				a += b.rowCount
			  			}
			  			return a
			  		},0)
			  		progress += rows
			  		console.log(progress, ((progress / source.record_count) * 100 ).toFixed(1), '%')
			  		resolve(rows)
			  	})
				
			})
		})
	}),{concurrency: 5})
}


function arrayChunk(arr, chunkSize) {
    const res = [];
    for (let i = 0; i < arr.length; i += chunkSize) {
        const chunk = arr.slice(i, i + chunkSize);
        res.push(chunk);
    }
    return res;
}