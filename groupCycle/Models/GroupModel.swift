//
//  GroupModel.swift
//  groupCycle
//
//  Created by River McCaine on 3/23/21.
//

import Foundation

struct Group {
    let id: String
    let name: String
    var otherUserEmail: String
    let latestMessage: LatestMessage
} // END OF STRUCT

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
} // END OF STRUCT
