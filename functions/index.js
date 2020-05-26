const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();
const messagesRef = db.collection('messages');
const chatroomsRef = db.collection('chatrooms');
const usersRef = db.collection('users');

exports.chatroomDeleted = functions.firestore.document('/chatrooms/{chatroomID}')
.onDelete((_snapshot, context) => {
    const chatroomID = context.params.chatroomID;
    return new Promise((resolve, reject) => {
        deleteChatroomMessages(chatroomID, resolve, reject);
    });      
});

function deleteChatroomMessages(chatroomID, resolve, reject) {
    let query = messagesRef.where('chatroomID', '==', chatroomID).limit(100);

    query.get()
    .then((snapshot) => {
        // When there are no documents left, we are done
        if (snapshot.size === 0) {
            return 0;
        }

        // Delete documents in a batch
        let batch = db.batch();
        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        return batch.commit().then(() => {
            return snapshot.size;
        });
    }).then((numDeleted) => {
        if (numDeleted === 0) {
            resolve();
            return;
        }

        // Recurse on the next process tick, to avoid exploding the stack.
        process.nextTick(() => {
            deleteChatroomMessages(chatroomID, resolve, reject);
        });
    })
    .catch(reject);
}

exports.newMessageInChatroom = functions.firestore.document('/messages/{messageID}')
.onCreate((snapshot, context) => {
    const message = snapshot.data();

    return new Promise((resolve, reject) => {
        sendNotificationForMessage(message, resolve, reject);
    });      
});

function sendNotificationForMessage(message, resolve, reject) {
    const senderID = message.sender;
    const chatroomID = message.chatroomID;
    const text = message.text;

    let chatroomRef = chatroomsRef.doc(chatroomID);
    chatroomRef.get().then( function(chatroom) {
        if (chatroom.exists){
            const chatroomData = chatroom.data();
            const title = "New message in " + chatroomData.title;
            var users = chatroomData.users;

            const senderIndex = users.indexOf(senderID);
            users.splice(senderIndex, 1);

            notifyUsers(users, chatroomID, title, text);

            resolve();

          } else {
            console.log("Chatroom does not exist.")
            reject();
          }
    }).catch( function(error) {
        console.log('Error getting chatroom document: ', error);
        reject();
    });
}

function notifyUsers(users, chatroomID, title, text) {
    users.forEach( function(userID) {
        let userRef = usersRef.doc(userID);
        userRef.get().then( function(user) {
            if (user.exists) {
                const userData = user.data();
                const devices = userData.devices;
                const userText = userData.username + ": " + text;
                
                devices.forEach( function(device) {
                    sendNotification(device, chatroomID, title, userText);
                });

              } else {
                console.log("User does not exist.")
              }
        }).catch( function(error) {
            console.log('Error getting user document: ', error);
        });
    });
}

function sendNotification(deviceFCMToken, chatroomID, title, text) {
    // const payload = {
    //     "aps" : {
    //         "alert" : {
    //           "body" : text,
    //           "title" : title,
    //         },
    //         "badge" : 1,
    //       },
    //       "chatroomID" : chatroomID
    // };
    const payload = { 
        "notification": {
            "title": title,
            "body": text
        },
        "data": {
            "chatroomID" : chatroomID
        }
    };

    messaging.sendToDevice(deviceFCMToken, payload);
}