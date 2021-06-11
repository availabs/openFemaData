const fetch = require('node-fetch');
const db = require('./db.js')
var sql = require('sql');

sql.setDialect('postgres');


const url = 'https://www.fema.gov/api/open/v1/OpenFemaDataSets'
const camelToSnakeCase = str => str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);


let datasets = [
  // 'data_set_fields_v1',
  // 'data_sets_v1',
  // 'disaster_declarations_summaries_v1',
  'disaster_declarations_summaries_v2',
  // 'emergency_management_performance_grants_v1',
  // 'fema_regions_v1',
  // 'fema_regions_v2',
  // 'fema_web_declaration_areas_v1',
  'fema_web_disaster_declarations_v1',
  'fema_web_disaster_summaries_v1',
  // 'fima_nfip_claims_v1',
  // 'fima_nfip_policies_v1',
  // 'hazard_mitigation_assistance_mitigated_properties_v1',
  'hazard_mitigation_assistance_mitigated_properties_v2',
  // 'hazard_mitigation_assistance_projects_by_nfip_crs_communities_v1',
  // 'hazard_mitigation_assistance_projects_v1',
  'hazard_mitigation_assistance_projects_v2',
  // 'hazard_mitigation_grant_program_disaster_summaries_v1',
  // 'hazard_mitigation_grant_program_property_acquisitions_v1',
  // 'hazard_mitigation_grants_v1',
  // 'hazard_mitigation_plan_statuses_v1',
  // 'housing_assistance_owners_v1',
  'housing_assistance_owners_v2',
  // 'housing_assistance_renters_v1',
  'housing_assistance_renters_v2',
  'individual_assistance_housing_registrants_large_disasters_v1',
  'individuals_and_households_program_valid_registrations_v1',
  // 'ipaws_archived_alerts_v1',
  // 'mission_assignments_v1',
  // 'non_disaster_assistance_firefighter_grants_v1',
  'public_assistance_applicants_v1',
  'public_assistance_funded_projects_details_v1',
  // 'public_assistance_funded_projects_summaries_v1',
  // 'registration_intake_individuals_household_programs_v1',
  'registration_intake_individuals_household_programs_v2'
]

//datasets = ['fema_web_disaster_summaries_v1']

var type_map = {
	number: 'numeric',
	string: 'text',
	date: 'timestamp with time zone',
	boolean: 'boolean'
}

var datasources = {
  	name: 'datasources',
  	schema: 'public',
  	columns: [
  		{'name':'id', dataType:'serial PRIMARY KEY'},
		{'name':'title', dataType:'varchar(64)'},
		{'name':'description', dataType:'text'},
		{'name':'table', dataType:'varchar(128)', unique: true},
		{'name':'data_url', dataType:'text'},
		{'name':'data_dictionary', dataType:'text'},
		{'name':'landing_page', dataType:'text'},
		{'name':'publisher', dataType:'varchar(64)'},
		{'name':'last_refresh', dataType:'timestamp with time zone'},
		{'name':'start_date', dataType:'timestamp with time zone'},
		{'name':'end_date', dataType:'timestamp with time zone'},
		{'name':'record_count', dataType: 'integer'}
  	]
};




fetch(url)
.then(res => res.json())
.then(data => {
	let metadata = data.OpenFemaDataSets
	let current_total = 0
	const newData = metadata.reduce((out,curr) => {
		out[camelToSnakeCase(curr.name).substr(1)+'_v'+curr.version] = Object.keys(curr).reduce((snake, col) => {
			snake[camelToSnakeCase(col)] = curr[col]
			return snake
		},{})
		out[camelToSnakeCase(curr.name).substr(1)+'_v'+curr.version].metadata_url = `https://www.fema.gov/api/open/v1/OpenFemaDataSetFields?$filter=openFemaDataSet%20eq%20%27${curr.name}%27%20and%20datasetVersion%20eq%20${curr.version}`
		return out
	},{})
	
	let inserts = datasets.map(key => {
		const {
			title,
			description,
			web_service,
			data_dictionary,
			landing_page,
			publisher,
			last_refresh,
			metadata_url,
			record_count
		} = newData[key]

		return {
			title,
			description: description.split('\n').join(''),
			table: `open_fema_data.${key}`,
			data_url: web_service,
			data_dictionary,
			landing_page,
			publisher,
			last_refresh,
			record_count

		}
	})

	Promise.all(
		datasets.map(k => {
			return fetch(newData[k].metadata_url)
				.then(res => res.json())
				.then(dict => {
					return {
						name:k,
						schema: 'open_fema_data',
						columns: dict.OpenFemaDataSetFields.map(d => {
							return {
								name: camelToSnakeCase(d.name),
								dataType: type_map[d.type.trim()],
								primaryKey: d.primaryKey ? true: false			
							}
						})
					}
				})
		})
	).then(values => {
		let queries = [
			sql.define(datasources).create().ifNotExists().toQuery(), //create datasources
			
		]
		let tables = values.reduce((out, table) => {
			out[table.name] = table
			//console.log('table create', table.name)
			queries.push(sql.define(table).create().ifNotExists().toQuery())
			return out
		},{})
		
		Promise
			.all(queries.map(q => db.promise(q.text,q.values)))
			.then(d => {
				console.log('tables created', d)
				db.query(...Object.values(sql.define(datasources).insert(inserts) // upsert datasources
				.onConflict({
				    columns: ['table'],
				    update: ['last_refresh','record_count']
			  	}).toQuery()))
			  	.then(ins => {
			  		console.log('datasources upserted', ins)
			  		db.end()
			  	})
				
			})

		
		// to export table structures
		
		// using sql.define adds to table object
		// to export 
		//console.log(JSON.stringify(tables,null,3))
	})
})



/*CREATE TABLE public.datasources
(
  id serial PRIMARY KEY,
  title nvarchar,
  description text,
  table nvarchar,
  data_url nvarchar,
  data_dictionary nvarchar,
  landing_page nvarchar,
  publisher nvarchar
  last_refresh timestamp with time zone
  start_date timestamp with time zone,
  end_date timestamp with time zone,
)*/

// {
//   identifier: 'openfema-1',
//   name: 'PublicAssistanceFundedProjectsSummaries',
//   title: 'Public Assistance Funded Project Summaries',
//   description: 'FEMA provides supplemental Federal disaster grant assistance for debris removal, emergency protective measures, and the repair, replacement, or restoration of disaster-damaged, publicly owned facilities and the facilities of certain Private Non-Profit (PNP) organizations through the Public Assistance (PA) Program (CDFA Number 97.036). The PA Program also encourages protection of these damaged facilities from future events by providing assistance for hazard mitigation measures during the recovery process.\n' +
//     '\n' +
//     "This dataset lists all public assistance recipients (sub-grantees) and a summary of the funded program support. This is raw, unedited data from FEMA's National Emergency Management Information System (NEMIS) and as such is subject to a small percentage of human error. The financial information is derived from NEMIS and not FEMA's official financial systems.\n" +
//     '\n' +
//     'Due to differences in reporting periods, status of obligations, and how business rules are applied, this financial information may differ slightly from official publication on public websites such as usaspending.gov; this dataset is not intended to be used for any official federal financial reporting.\n' +
//     '\n' +
//     "If you have media inquiries about this dataset please email the FEMA News Desk FEMA-News-Desk@dhs.gov or call (202) 646-3272.  For inquiries about FEMA's data and Open government program please contact the OpenFEMA team via email OpenFEMA@fema.dhs.gov.",
//   distribution: [
//     {
//       accessURL: 'https://www.fema.gov/api/open/v1/PublicAssistanceFundedProjectsSummaries.csv',
//       format: 'csv',
//       datasetSize: 'small (10MB - 50MB)'
//     },
//     {
//       accessURL: 'https://www.fema.gov/api/open/v1/PublicAssistanceFundedProjectsSummaries.json',
//       format: 'json',
//       datasetSize: 'medium (50MB - 500MB)'
//     },
//     {
//       accessURL: 'https://www.fema.gov/api/open/v1/PublicAssistanceFundedProjectsSummaries.jsona',
//       format: 'jsona',
//       datasetSize: 'medium (50MB - 500MB)'
//     }
//   ],
//   webService: 'https://www.fema.gov/api/open/v1/PublicAssistanceFundedProjectsSummaries',
//   dataDictionary: 'https://www.fema.gov/openfema-data-page/public-assistance-funded-projects-summaries-v1',
//   keyword: [ 'public, assistance, disaster, grant, funding, sub-grantees' ],
//   modified: '2019-05-30T04:00:00.000Z',
//   publisher: 'Federal Emergency Management Agency',
//   contactPoint: 'OpenFEMA',
//   mbox: 'openfema@fema.gov',
//   accessLevel: 'public',
//   landingPage: 'https://www.fema.gov/assistance/public',
//   temporal: '1980-02-01/',
//   api: true,
//   version: 1,
//   bureauCode: [ '024:70' ],
//   programCode: [ '024:039' ],
//   accessLevelComment: '',
//   license: '',
//   spatial: '',
//   theme: 'Public Assistance',
//   dataQuality: 'true',
//   accrualPeriodicity: 'R/P1D',
//   language: 'en-US',
//   primaryITInvestmentUII: '',
//   references: [],
//   issued: '2010-01-21T05:00:00.000Z',
//   systemOfRecords: '',
//   deprecated: false,
//   hash: 'bd507ed0181bba91866372a0a5d3c3e4',
//   lastRefresh: '2021-06-07T16:36:14.391Z',
//   recordCount: 167551,
//   depApiMessage: '',
//   depDate: null,
//   depNewURL: '',
//   depWebMessage: '',
//   lastDataSetRefresh: '2021-06-07T16:36:14.391Z',
//   id: '5dd723598ca22d24d423eb6f'
