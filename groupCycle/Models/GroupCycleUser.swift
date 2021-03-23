//
//  GroupCycleUser.swift
//  groupCycle
//
//  Created by River McCaine on 3/23/21.
//

import Foundation

struct GroupCycleUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
} // END OF STRUCT
