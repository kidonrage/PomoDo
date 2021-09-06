//
//  TasksManager.swift
//  Pomodorus
//
//  Created by Vlad Eliseev on 29.08.2021.
//

import Foundation

final class TasksManager {
    
    private let tasksKey = "tasks"
        
    func getAllTasks() -> [Task]? {
        guard let tasksData = UserDefaults.standard.data(forKey: tasksKey) else { return [] }
        
        let decoder = JSONDecoder()
    
        guard let tasks = try? decoder.decode([Task].self, from: tasksData) else {
            return nil
        }
        
        return tasks
    }
    
    func saveTask(_ task: Task) {
        guard var tasksToUpdate = getAllTasks() else { return }
        
        tasksToUpdate.append(task)
        
        saveTasks(tasksToUpdate)
    }
    
    private func saveTasks(_ tasks: [Task]) {
        let encoder = JSONEncoder()
        
        guard let tasksData = try? encoder.encode(tasks) else {
            return
        }
        
        UserDefaults.standard.setValue(tasksData, forKey: tasksKey)
    }
    
    // MARK: - Constants
    static let shared = TasksManager()
    
}
