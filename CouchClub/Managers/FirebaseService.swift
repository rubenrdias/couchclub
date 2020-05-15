//
//  FirebaseService.swift
//  CouchClub
//
//  Created by Ruben Dias on 14/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    
    static let shared = FirebaseService()
    
    private init() {}
    
    // MARK: - Users
    
    func createUser(_ username: String, _ email: String, _ password: String, completion: @escaping (_ uid: String?, _ error: Error?)->()) {
        // TODO: make user creation a Transaction
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Firebase Auth | Error creating user: \(error.localizedDescription)")
                // TODO: handle error
                completion(nil, error)
                return
            }
            
            Firestore.firestore().collection("users").document(result!.user.uid).setData([
                "username": username
            ]) { (error) in
                if let error = error {
                    print("Firebase Firestore | Error creating user data: \(error.localizedDescription)")
                    // TODO: retry later
                }
                
                completion(result!.user.uid, nil)
            }
        }
    }
    
    func signIn(_ email: String, _ password: String, completion: @escaping (_ error: Error?)->()) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if let error = error {
                print("Firebase Auth | Error creating user: \(error.localizedDescription)")
                // TODO: handle error
            }
            
            completion(error)
        }
    }
    
    // MARK: - Watchlists
    
    func createWatchlist(_ watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        let watchlistDict = [
            "owner": Auth.auth().currentUser!.uid,
            "title": watchlist.title,
            "type": watchlist.type
        ]
        
        Firestore.firestore().collection("watchlists").document(watchlist.id.uuidString).setData(watchlistDict) { (error) in
            if let error = error {
                print("Firebase Firestore | Error creating watchlist: \(error.localizedDescription)")
            }
            
            completion(error)
        }
    }
    
    func add(_ item: Item, to watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        Firestore.firestore().collection("watchlists").document(watchlist.id.uuidString).updateData([
            "items": FieldValue.arrayUnion([item.id])
        ]) { (error) in
            if let error = error {
                print("Firebase Firestore | Error when adding an item to watchlist: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func remove(_ item: Item, from watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        Firestore.firestore().collection("watchlists").document(watchlist.id.uuidString).updateData([
            "items": FieldValue.arrayRemove([item.id])
        ]) { (error) in
            if let error = error {
                print("Firebase Firestore | Error when removing an item from watchlist: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
}
