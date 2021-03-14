//
//  DatabaseManager.swift
//  groupCycle
//
//  Created by River McCaine on 3/14/21.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    

} // END OF CLASS

struct GroupCycleUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    // let profilePictureURL: String
    
} // END OF STRUCT

// MARK: - Extensions
extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        database.child(email).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Inserts new user to databse
    public func insertUser(with user: GroupCycleUser) {
        database.child(user.emailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }

} // END OF EXTENSION

