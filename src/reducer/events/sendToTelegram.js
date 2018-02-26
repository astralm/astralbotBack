module.exports = modules => (resolve, reject, data) => {
	modules.telegram.sendMessage(data.bot_id, data.chats, data.message);
}