//
//  DashboardViewController.swift
//  PomoDo
//
//  Created by Vlad Eliseev on 21.08.2021.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var newTaskField: UITextField!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var playNewTaskButton: UIButton!
    
    private var tasks: [Task] = [
        Task(name: "Курить"),
        Task(name: "Шабить"),
        Task(name: "Дрочить"),
    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
        setupUI()
    }
    
    private func setupTable() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        tasksTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: TaskTableViewCell.cellId)
        
        tasksTableView.separatorStyle = .none
    }
    
    private func setupUI() {
        
    }

}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.cellId) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        
        cell.configure(with: task)
        
        return cell
    }
    
}
