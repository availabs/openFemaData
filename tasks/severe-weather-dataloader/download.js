const https = require('https')
const fs = require('fs')
const execSync = require('child_process').execSync;
const {getFiles} = require('./scrapper')

const url = 'https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/'

const fetchFileList = (fileName, currTable) => {
	console.log('fetching...', url + fileName)
	if(!fs.existsSync(currTable)){
		fs.mkdirSync(currTable)
	}
	const file = fs.createWriteStream(currTable + '/' + fileName);
	return new Promise((resolve, reject) => {
		https.get(url + fileName, response => {
			response.pipe(file);
			console.log('got: ', url + fileName)
			file.on('finish', f => {
				file.close();
				file.once('close', () => {
					file.removeAllListeners();
				});

				resolve(execSync(`gunzip ${currTable + '/' + fileName}`, { encoding: 'utf-8' }));
			})
		})
	})
}

const main = async () => {
	let files = await getFiles();
	console.log('downloading', process.argv[2])
	await [process.argv[2]] /*Object.keys(files)*/
		.reduce(async (accTable, currTable) => {
			await accTable;

			return files[currTable]
				.reduce(async (acc, curr) => {
					await acc;
					return fetchFileList(curr, currTable)
				}, Promise.resolve())
		}, Promise.resolve())
}

main().then(() => console.log('download complete!'));
