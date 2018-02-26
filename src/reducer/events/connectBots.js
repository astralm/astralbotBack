module.exports = modules => (resolve, reject, data) => {
	modules.telegram.connectBots(data.bots);
}