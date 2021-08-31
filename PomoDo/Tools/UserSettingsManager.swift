//
//  UserSettingsManager.swift
//  PomoDo
//
//  Created by Vlad Eliseev on 31.08.2021.
//

import Foundation

final class UserSettingsManager {
    
    let workSessionDuration: TimeInterval = 25 * 60
    let restSessionDuration: TimeInterval = 5 * 60
    
    // MARK: - Constants
    static let shared = UserSettingsManager()
}
