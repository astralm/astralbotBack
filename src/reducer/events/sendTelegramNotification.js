module.exports = modules => (resolve, reject, data) => {
	modules.telegram.sendNotifications(data.chats, data.message);
}