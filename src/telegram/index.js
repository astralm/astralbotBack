module.exports = function(telegram, apiai, reducer, actions, io){
	telegram.on("message", function(message){
		var connection = telegram.connections.find(function(connection){
			return connection.hash == message.chat.id;
		});
		if(!connection){
			connection = telegram.connections[telegram.connections.push({hash: message.chat.id, bot: true, error: false}) - 1];
			reducer(actions.SET_SESSION(message.chat.id));
			reducer(actions.GET_SESSION_ID(message.chat.id), function(response){
				connection.session_id = response[0].session_id;
			});
		}
		if(!connection.active){
			reducer(actions.SET_ACTIVE({session_hash: message.chat.id}), function(){
				io.broadcastGetSessions();
				io.broadcastGetSessionInfo(connection.session_id);
				message.active = true;
			});
		}
		if(connection.timeout_id){
			clearTimeout(connection.timeout_id);
		}
		connection.timeout_id = setTimeout(function(){
			reducer(actions.SET_INACTIVE({session_hash: message.chat.id}), function(){
				io.broadcastGetSessions();
				io.broadcastGetSessionInfo(connection.session_id);
				message.active = false;
			});
		}, 600000);
		reducer(actions.SET_QUESTION({
			message: message.text,
			hash: message.chat.id
		}));
		io.broadcastGetSessionsDialog({session_hash: message.chat.id});
		io.broadcastGetSessions();
		var request = apiai.textRequest(message.text, {sessionId: message.chat.id});
		request.on('response', function(response){
			reducer(actions.GET_BOT_STATUS({session_hash: message.chat.id}), function(data){
				data = data[0];
				if(data.bot_work){
					reducer(actions.SET_ANSWER({hash: message.chat.id, message: response.result.fulfillment.speech}));
					reducer(actions.GET_SESSION_INFO(connection.session_id), function(session){
						session = session[0] || {};
						if(session.session_error && response.result.action != 'input.unknown'){
							reducer(actions.REMOVE_ERROR_SESSION(session.session_hash), function(){
								io.broadcastGetSessions();
								io.broadcastGetSessionInfo(session.session_id);
							});
						} else if(!session.session_error && response.result.action == 'input.unknown'){
							reducer(actions.SET_ERROR_SESSION(session.session_hash), function(){
								io.broadcastGetSessions();
								io.broadcastGetSessionInfo(session.session_id);
							});
						}
					});
					// if(response.result.action == 'input.unknown' && connection.error == false){
					// 	reducer(actions.SET_ERROR_SESSION(message.chat.id));
					// 	connection.error = true;
					// } else if (response.result.action != 'input.unknown' && connection.error == true){
					// 	reducer(actions.REMOVE_ERROR_SESSION(message.chat.id));
					// 	connection.error = false;
					// }
					if(response.result.fulfillment.speech){
						telegram.sendMessage(message.chat.id, response.result.fulfillment.speech);
					}
					io.broadcastGetSessionsDialog({session_hash: message.chat.id});
					io.broadcastGetSessionInfo(connection.session_id);
					io.broadcastGetSessions();
				}
			});
		});
		setTimeout(function(){
			request.end();
		}, 7000);
	});
}