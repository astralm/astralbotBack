module.exports = modules => (resolve, reject, data) => {
	modules.telegram.deleteBots(data.bots);
}