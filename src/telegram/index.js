module.exports = function(telegram, apiai, reducer, actions, io, subject, notification){
	telegram.on("message", function(message){
		var connection = telegram.connections.find(function(connection){
			return connection.hash == message.chat.id;
		});
		if(!connection){
			connection = telegram.connections[telegram.connections.push({hash: subject + message.chat.id, bot: true, error: false}) - 1];
			reducer(actions.SET_SESSION({
				hash: subject + message.chat.id, type:"telegram", 
				subject: subject, 
				organization_id: "1"
			}), function(){
				reducer(actions.GET_SESSION_ID(subject + message.chat.id), function(response){
					connection.session_id = response[0].session_id;
					reducer(actions.SET_CLIENT({
						client_name: message.from.first_name + " " + message.from.last_name,
						client_username: message.from.username,
						session_id: connection.session_id,
						organization_id: "1"
					}), function(responce){
						io.broadcastGetClients("1");
						io.broadcastGetSessions("1");
						io.broadcastGetSessionInfo(connection.session_id);
					});
				});
			});
		}
		if(!connection.active){
			reducer(actions.SET_ACTIVE({session_hash: subject + message.chat.id}), function(){
				io.broadcastGetSessions("1");
				io.broadcastGetSessionInfo(connection.session_id);
				message.active = true;
			});
		}
		if(connection.timeout_id){
			clearTimeout(connection.timeout_id);
		}
		connection.timeout_id = setTimeout(function(){
			reducer(actions.SET_INACTIVE({session_hash: subject + message.chat.id}), function(){
				io.broadcastGetSessions("1");
				io.broadcastGetSessionInfo(connection.session_id);
				message.active = false;
			});
		}, 600000);
		reducer(actions.SET_QUESTION({
			message: message.text,
			hash: subject + message.chat.id
		}));
		io.broadcastGetSessionsDialog({session_hash: subject + message.chat.id});
		io.broadcastGetSessions("1");
		var request = apiai.textRequest(message.text, {sessionId: subject + message.chat.id});
		request.on('response', function(response){
			reducer(actions.GET_BOT_STATUS({session_hash: subject + message.chat.id}), function(data){
				data = data[0];
				if(data.bot_work){
					reducer(actions.SET_ANSWER({hash: subject + message.chat.id, message: response.result.fulfillment.speech}));
					reducer(actions.GET_SESSION_INFO(connection.session_id), function(session){
						session = session[0] || {};
						if(session.session_error && response.result.action != 'input.unknown'){
							reducer(actions.REMOVE_ERROR_SESSION(session.session_hash), function(){
								io.broadcastGetSessions("1");
								io.broadcastGetSessionInfo(session.session_id);
							});
						} else if(!session.session_error && response.result.action == 'input.unknown'){
							reducer(actions.SET_ERROR_SESSION(session.session_hash), function(){
								io.broadcastGetSessions("1");
								io.broadcastGetSessionInfo(session.session_id);
								reducer(actions.GET_NOTIFICATIONS_USERS(session.organization_id), function(responce){
									if(responce && responce.length > 0){
										for(var i = 0; i < responce.length; i++){
											reducer(actions.GET_CLIENT_ID(session.session_id), (function(number, client_id){
												notification.sendMessage(responce[number].user_notification_chat, "Бот не смог подобрать ответ в сессии " + session.session_id + "; \nСсылка на диалог: https://astralbot.ru/#/app/dialog:" + session.session_id + "\nСсылка на клиента: https://astralbot.ru/#/app/client:" + client_id[0].client_id + "\nСообщение: \""+message.text+"\"");
											}).bind(this, i));
											io.broadcastNotification(session.organization_id, {
												title: "Сессия " + session.session_id,
												body: "Бот не смог подобрать ответ",
												session_id: session.session_id,
												requireInteraction: true
											});
										}
									}
								});
							});
						}
					});
					if(response.result.fulfillment.speech){
						telegram.sendMessage(message.chat.id, response.result.fulfillment.speech);
					}
					io.broadcastGetSessionsDialog({session_hash: subject + message.chat.id});
					io.broadcastGetSessionInfo(connection.session_id);
					io.broadcastGetSessions("1");
				}
			});
		});
		setTimeout(function(){
			request.end();
		}, 7000);
	});
}