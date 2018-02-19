module.exports = modules => (resolve, reject, data) => {
	modules.io.to(data.socket).send(data.data);
}