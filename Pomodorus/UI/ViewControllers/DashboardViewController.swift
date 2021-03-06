//
//  DashboardViewController.swift
//  Pomodorus
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
    
    private lazy var dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
    private var isAlreadyStartedTaskSelected = false
    private var isAlreadyRestedTaskSelected = false
    private var selectedTask: Task?
    
    private var tasks: [Task]?
    private var sectionsToDisplay: [Dictionary<String, [TaskViewModel]>.Element]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardGesture.delegate = self
        
        setupTable()
        setupUI()
        
        updateTasks()
        
        if let alreadyStartedTask = UserSettingsManager.shared.getStartedTask() {
            selectedTask = alreadyStartedTask
            isAlreadyStartedTaskSelected = true
            isAlreadyRestedTaskSelected = false
            performSegue(withIdentifier: "toFocus", sender: self)
        } else if let alreadyRestedTask = UserSettingsManager.shared.getRestedTask() {
            selectedTask = alreadyRestedTask
            isAlreadyStartedTaskSelected = false
            isAlreadyRestedTaskSelected = true
            performSegue(withIdentifier: "toFocus", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTasks()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toFocus") {
            guard
                let vc = segue.destination as? TimerViewController,
                let selectedTask = selectedTask
            else { return }
            
            vc.taskTitle = selectedTask.title
            if isAlreadyStartedTaskSelected {
                vc.workSessionStartTime = selectedTask.executionTimeStamp
            } else if isAlreadyRestedTaskSelected {
                vc.restSessionStartTime = selectedTask.executionTimeStamp
            }
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
    
    @objc private func dismissKeyboard() {
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
        isAlreadyStartedTaskSelected = false
        isAlreadyRestedTaskSelected = false
        
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
    
    private func updateTasks() {
        guard let allTasks = TasksManager.shared.getAllTasks()?.sorted(by: { $0.executionTimeStamp > $1.executionTimeStamp }) else { return }
        
        var dict: [String: [Task]] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd.yyyy"
        dateFormatter.locale = Locale(identifier: "en-EN")
        
        let today = Date().startOfDay
        
        let todayTasksKey = "Recent"
        
        allTasks.forEach { (task) in
            if dateFormatter.string(from: Date(timeIntervalSince1970: task.executionTimeStamp)) == dateFormatter.string(from: today) {
                var applicationsForToday = dict[todayTasksKey] ?? []
                applicationsForToday.append(task)
                dict[todayTasksKey] = applicationsForToday
            } else {
                let dateStringToDisplay = dateFormatter.string(from: Date(timeIntervalSince1970: task.executionTimeStamp))

                var applications = dict[dateStringToDisplay] ?? []
                applications.append(task)
                dict[dateStringToDisplay] = applications
            }
        }
        
        var updatedSectionsToDisplay = [String : [TaskViewModel]]()
        
        dict
            .forEach { (dateKey, tasksForDate) in
                var tasksTimeWorked: [String: (TimeInterval, TimeInterval)] = [:]
                
                tasksForDate
                    .sorted(by: { $0.executionTimeStamp < $1.executionTimeStamp })
                    .forEach { task in
                        tasksTimeWorked[task.title] = ((tasksTimeWorked[task.title]?.0 ?? 0) + UserSettingsManager.shared.workSessionDuration, task.executionTimeStamp)
                    }
                
                tasksTimeWorked.forEach { (taskTitle, taskWorkedTime) in
                    updatedSectionsToDisplay[dateKey] = (updatedSectionsToDisplay[dateKey] ?? []) + [TaskViewModel(taskTitle: taskTitle, workedTime: taskWorkedTime.0, lastExecutionTimestamp: taskWorkedTime.1)]
                }
            }
        
        self.sectionsToDisplay = updatedSectionsToDisplay
            .sorted(by: { (keyValueA, keyValueB) in
                if keyValueA.key == todayTasksKey {
                    return true
                } else if keyValueB.key == todayTasksKey {
                    return false
                }

                let dateA = dateFormatter.date(from: keyValueA.key)!
                let dateB = dateFormatter.date(from: keyValueB.key)!

                return dateA < dateB
            })
            .map({ (key, value) in
                return (key: key, value: value.sorted(by: { $0.lastExecutionTimestamp > $1.lastExecutionTimestamp }))
            })
        
        if
            let secionsToDisplay = self.sectionsToDisplay,
            secionsToDisplay.count > 0,
            let todayWorkedTasks = self.sectionsToDisplay?[0].value, self.sectionsToDisplay?[0].key == todayTasksKey
        {
            updateTodayWorkedHours(tasksExecutedToday: todayWorkedTasks)
        } else {
            updateTodayWorkedHours(tasksExecutedToday: [])
        }

        tasksTableView.reloadData()
    }
    
    private func updateTodayWorkedHours(tasksExecutedToday: [TaskViewModel]) {
        let secondsWorkedToday = tasksExecutedToday.reduce(0.0) { result, task in result + (task.workedTime) }
        updateTodayWorkHours(withWorkedSecondsAmount: Int(secondsWorkedToday))
    }
    
    private func updateTodayWorkHours(withWorkedSecondsAmount secondsAmount: Int) {
        let string = NSMutableAttributedString(string: "Today you worked ")
        
        let hours = Int(secondsAmount / 3600)
        let minutes = Int((secondsAmount - (hours * 3600)) / 60)
        
        string.append(NSAttributedString(string: "\(hours)h", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        ]))
        
        if minutes > 0 {
            string.append(NSAttributedString(string: " \(minutes)m", attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
            ]))
        }
        
        todayWorkedLabel.attributedText = string
    }
    
    private func setupTable() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        tasksTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: TaskTableViewCell.cellId)
        
        tasksTableView.separatorStyle = .none
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tasksTableView.addGestureRecognizer(dismissKeyboardGesture)
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsToDisplay?[section].value.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsToDisplay?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.cellId) as? TaskTableViewCell,
            let taskViewModel = sectionsToDisplay?[indexPath.section].value[indexPath.row]
        else {
            return UITableViewCell()
        }
        
        cell.configure(with: taskViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 48)))
        view.backgroundColor = .systemBackground
        
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 16, y: 4), size: CGSize(width: view.frame.width - 32, height: 44)))
        label.text = sectionsToDisplay?[section].key
        label.font = .boldSystemFont(ofSize: 16)
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let taskViewModel = sectionsToDisplay?[indexPath.section].value[indexPath.row] else { return }
        
        selectedTask = Task(title: taskViewModel.taskTitle, executionTimeStamp: Date().timeIntervalSince1970)
        isAlreadyStartedTaskSelected = false
        
        dismissKeyboard()
        
        performSegue(withIdentifier: "toFocus", sender: self)
    }
}


extension DashboardViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isKind(of: UITableView.self) ?? true {
            return true
        }
        return false
    }
    
}
