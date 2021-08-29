//
//  DashboardViewController.swift
//  PomoDo
//
//  Created by Vlad Eliseev on 21.08.2021.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var todayWorkedLabel: UILabel!
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var newTaskField: UITextField!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var playNewTaskButton: UIButton!
    
    private var selectedTask: Task?
    
    private var tasks: [Task]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupUI()
        
        getTasks()
        
        updateTodayWorkHours(withHoursAmount: 4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toFocus") {
            guard
                let vc = segue.destination as? TimerViewController,
                let selectedTask = selectedTask
            else { return }
            
            vc.task = selectedTask
        }
    }
    
    // MARK: - IBACtions
    @IBAction func taskNameDidChanged(_ sender: UITextField) {
        if sender.text?.isEmpty ?? true {
            playNewTaskButton.isEnabled = false
            playNewTaskButton.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        } else {
            playNewTaskButton.isEnabled = true
            playNewTaskButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    @IBAction func tableTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func executeNewTaskTapped(_ sender: Any) {
        guard
            let newTaskTitle = newTaskField.text,
            !newTaskTitle.isEmpty
        else {
            return
        }
        
        let newTask = Task(title: newTaskTitle, executionTimeStamp: Date().timeIntervalSince1970)
        selectedTask = newTask
        
        view.endEditing(true)
        
        performSegue(withIdentifier: "toFocus", sender: self)
        
        newTaskField.text = nil
    }
    
    // MARK: - Private Methods
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - view.safeAreaInsets.bottom
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    private func getTasks() {
        tasks = TasksManager.shared.getAllTasks()
    }
    
    private func updateTodayWorkHours(withHoursAmount hoursAmount: Int) {
        let string = NSMutableAttributedString(string: "Сегодня вы работали ")
        
        string.append(NSAttributedString(string: "\(hoursAmount)ч", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        ]))
        
        todayWorkedLabel.attributedText = string
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
        return tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let tasks = tasks,
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.cellId) as? TaskTableViewCell
        else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        
        cell.configure(with: task)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tasks = tasks else { return }
        
        selectedTask = tasks[indexPath.row]
        performSegue(withIdentifier: "toFocus", sender: self)
    }
}
