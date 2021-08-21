//
//  TimerViewController.swift
//  PomoDo
//
//  Created by Vlad Eliseev on 21.08.2021.
//

import UIKit

class TimerViewController: UIViewController {
    
    var task: Task!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = task.name
    }

}
