const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const messagesRef = db.collection('messages');

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