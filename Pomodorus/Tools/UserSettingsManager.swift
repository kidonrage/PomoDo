//
//  UserSettingsManager.swift
//  Pomodorus
//
//  Created by Vlad Eliseev on 31.08.2021.
//

import Foundation

final class UserSettingsManager {
    
    let workSessionDuration: TimeInterval = 30 * 60
    let restSessionDuration: TimeInterval = 5 * 60
    
    // MARK: - Public Methods
    func saveStartedTask(task: Task) {
        let encoder = JSONEncoder()
        
        if let encodedTask = try? encoder.encode(task) {
            UserDefaults.standard.setValue(encodedTask, forKey: "startedTask")
        }
    }
    
    func removeStartedTask() {
        UserDefaults.standard.removeObject(forKey: "startedTask")
    }
    
    func getStartedTask() -> Task? {
        guard let startedTaskData = UserDefaults.standard.data(forKey: "startedTask") else { return nil }
        
        let decoder = JSONDecoder()
        
        return try? decoder.decode(Task.self, from: startedTaskData)
    }
    
    func saveRestedTask(task: Task) {
        let encoder = JSONEncoder()
        
        if let encodedTask = try? encoder.encode(task) {
            UserDefaults.standard.setValue(encodedTask, forKey: "restedTask")
        }
    }
    
    func removeRestedTask() {
        UserDefaults.standard.removeObject(forKey: "restedTask")
    }
    
    func getRestedTask() -> Task? {
        guard let startedTaskData = UserDefaults.standard.data(forKey: "restedTask") else { return nil }
        
        let decoder = JSONDecoder()
        
        return try? decoder.decode(Task.self, from: startedTaskData)
    }
    
    
    // MARK: - Constants
    static let shared = UserSettingsManager()
}
