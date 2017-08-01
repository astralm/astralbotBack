module.exports = function(telegram, apiai, reducer, actions, io){
	telegram.on("message", function(message){
		if(telegram.connections.filter(function(connection){return connection.hash == message.chat.id;}).length == 0){
			telegram.connections.push({hash: message.chat.id, bot: true});
			reducer(actions.SET_SESSION(message.chat.id));
		}
		reducer(actions.SET_QUESTION({
			message: message.text,
			hash: message.chat.id
		}));
		io.broadcastGetSessionsDialog({session_hash: message.chat.id});
		io.broadcastGetSessions();
		var request = apiai.textRequest(message.text, {sessionId: message.chat.id});
		request.on('response', function(response){
			if(telegram.connections.find(function(connection){return connection.hash == message.chat.id;}).bot){
				reducer(actions.SET_ANSWER({hash: message.chat.id, message: response.result.fulfillment.speech}));
				telegram.sendMessage(message.chat.id, response.result.fulfillment.speech);
				io.broadcastGetSessionsDialog({session_hash: message.chat.id});
				io.broadcastGetSessions();
			}
		});
		request.end();
	});
}