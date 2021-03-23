//
//  ProfileViewModel.swift
//  groupCycle
//
//  Created by River McCaine on 3/23/21.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
} // END OF ENUM

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
} // END OF STRUCT
