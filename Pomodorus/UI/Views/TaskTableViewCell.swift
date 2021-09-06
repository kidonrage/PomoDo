//
//  TaskTableViewCell.swift
//  Pomodorus
//
//  Created by Vlad Eliseev on 21.08.2021.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with taskViewModel: TaskViewModel) {
        taskLabel.text = taskViewModel.taskTitle
    }
    
    static let cellId = "TaskTableViewCell"
    
}
