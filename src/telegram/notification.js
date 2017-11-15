module.exports = function(reducer, actions, telegram, io){
	telegram.on("message", function(message){
		if(message.entities){
			if(message.entities[0].type == "bot_command"){
				switch(message.text) {
					case "/unbindme": 
						reducer(actions.GET_USER_BY_TELEGRAM_CHAT_ID(message.chat.id), function(response){
							if(response && response[0]){
								reducer(actions.UNBIND_USER_NOTIFICATIONS(message.chat.id), function(){
									telegram.sendMessage(message.chat.id, "Оповещения отключены");
									io.broadcastGetUser(response[0].organization_id, response[0].user_email);
								});
							} else {
								telegram.sendMessage(message.chat.id, "Вы не зарегестрированы в системе. Для регистрации пришлите мне ваш ключ из административной панели (раздел профиль)");
							}
						});
						break;
					case "/bindme":
						reducer(actions.GET_USER_BY_TELEGRAM_CHAT_ID(message.chat.id), function(response){
							if(response && response[0]){
								reducer(actions.BIND_USER_TO_NOTIFICATIONS({
									user_id: response[0].user_id, 
									chat_id: message.chat.id
								}), function(){
									telegram.sendMessage(message.chat.id, "Подписка на оповещения включена");
									io.broadcastGetUser(response[0].organization_id, response[0].user_email);
								});
							} else {
								telegram.sendMessage(message.chat.id, "Вы не зарегестрированы в системе. Для регистрации пришлите мне ваш ключ из административной панели (раздел профиль)");
							}
						});
						break;
					default:
						telegram.sendMessage(message.chat.id, "Такой команды не существует");
						break;
				}
			}
		} else {
			if(message.text.length == 32){
				reducer(actions.GET_USER_BY_NOTIFICATIONS_HASH(message.text), function(responce){
					if(responce && responce[0]){
						reducer(actions.BIND_USER_TO_NOTIFICATIONS({
							user_id: responce[0].user_id, 
							chat_id: message.chat.id
						}), function(){
							telegram.sendMessage(message.chat.id, "Подписка на оповещения включена");
							io.broadcastGetUser(responce[0].organization_id, responce[0].user_email);
						});
					} else {
						telegram.sendMessage(message.chat.id, "Пользователь с таким ключем не зарегестрирован в системе");
					}
				});
			} else {
				telegram.sendMessage(message.chat.id, "Формат ключа не поддерживается");
			}
		}
	});
}