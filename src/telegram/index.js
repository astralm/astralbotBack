const telegram = require('node-telegram-bot-api');
let Then = require('../then/'),
		Err = require('../err/');
class Telegram {
	constructor(env, reducer){
		this.reducer = reducer;
		this.notificationBot = new telegram(env.token, {polling: true});
		this.notificationBot.on("message", (data) => {
			if(data.text && data.text.length == 32){
				this.reducer.dispatch({
					type: "Query",
					data: {
						query: "loginTelegram",
						values: [
							data.text,
							data.chat.id,
							data.from.username
						]
					}
				}).then(Then).catch(Err);
			} else {
				if(data.text){
					switch(data.text){
						case "/bindme":
							this.reducer.dispatch({
								type: "Query",
								data: {
									query: "userTelegramState",
									values: [
										data.chat.id,
										1
									]
								}
							}).then(Then).catch(Err);
						break;
						case "/unbindme":
							this.reducer.dispatch({
								type: "Query",
								data: {
									query: "userTelegramState",
									values: [
										data.chat.id,
										0
									]
								}
							}).then(Then).catch(Err);
						break;
						case "/start":
							this.notificationBot.sendMessage(data.chat.id, "Здравствуйте! Для того чтобы авторизовать ваш телеграм в системе astralbot необходимо отправить в этот чат ключ авторизации. Он находиться в разделе 'профиль' - https://astralbot.ru/#/app/profile").
						break;
						default:
							this.notificationBot.sendMessage(data.chat.id, "Извините, такой команды не существует.");
						break;
					}
				}
			}
		});
		this.usersBots = {};
	}
	connectBots(bots){
		for (let i = 0; i < bots.length; i++) {
			let bot = bots[i];
			let botTelegram = new telegram(bot.bot_telegram_key, {polling: true});
			botTelegram.on("message", (data) => {
				this.reducer.dispatch({
					type: "Query",
					data: {
						query: "clientMessageTelegram",
						values: [
							data.chat.id,
							bot.bot_id,
							data.text,
							`${data.from.first_name} ${data.from.last_name}`,
							data.from.username
						]
					}
				}).then(Then).catch(Err);
			});
			this.usersBots[bot.bot_id] = botTelegram;
		}
	}
	sendMessage(bot_id, chats, message){
		if (this.usersBots[bot_id] && chats && message) {
			let bot = this.usersBots[bot_id];
			for(let i = 0; i < chats.length; i++){
				let chat = chats[i];
				bot.sendMessage(chat, message);
			}
		}
	}
	deleteBots(bots){
		for (let i = 0; i < bots.length; i++) {
			let bot_id = bots[i];
			if (this.usersBots[bot_id]) {
				this.usersBots[bot_id].stopPolling({cancel: true});
			}
		}
	}
	sendNotifications(chats, message){
		for(let i = 0; i < chats.length; i++){
			let chat = chats[i];
			this.notificationBot.sendMessage(chat, message);
		}
	}
}
module.exports = (env, reducer) => {
	Then = Then.bind(this, reducer);
	return new Telegram(env, reducer);
}