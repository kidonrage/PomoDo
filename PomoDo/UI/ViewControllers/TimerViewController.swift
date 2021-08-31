//
//  TimerViewController.swift
//  PomoDo
//
//  Created by Vlad Eliseev on 21.08.2021.
//

import UIKit

final class TimerViewController: UIViewController {
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sessionTypeLabel: UILabel!
    
    var task: Task!
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    private var timer: Timer?
    
    private let focusSpeeder: Double = 1.0
    
    private let focusTimeInMinutes: Double = 25
    private var focusTimeInSeconds: Double {
        return focusTimeInMinutes * 60
    }
    private var workSecondsElapsed: Double = 0 {
        didSet {
            let remainingSeconds = focusTimeInSeconds - workSecondsElapsed
            let minutes = (remainingSeconds / 60).rounded(.down)
            let seconds = remainingSeconds - minutes * 60
            timeLabel.text = String(format: "%02d:%02d", Int(minutes), Int(seconds))
        }
    }
    
    private let restTimeInMinutes: Double = 5
    private var restTimeInSeconds: Double {
        return restTimeInMinutes * 60
    }
    private var restSecondsElapsed: Double = 0 {
        didSet {
            let remainingSeconds = restTimeInSeconds - restSecondsElapsed
            let minutes = (remainingSeconds / 60).rounded(.down)
            let seconds = remainingSeconds - minutes * 60
            timeLabel.text = String(format: "%02d:%02d", Int(minutes), Int(seconds))
        }
    }
    
    private var isResting = false {
        didSet {
            sessionTypeLabel.text = isResting ? "Rest" : "Work"
            progressLayer.strokeColor = isResting ? #colorLiteral(red: 0.4431372549, green: 1, blue: 0.5450980392, alpha: 1).cgColor : #colorLiteral(red: 0.9921568627, green: 0.3019607843, blue: 0.2941176471, alpha: 1).cgColor
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = task.title
        
        navigationItem.setHidesBackButton(true, animated: true)
        
        workSecondsElapsed = 0
        
        setupTimerProgressBar()
        
        startWorkTimer()
    }
    
    // MARK: - IBActions
    @IBAction func stopButtonTapped(_ sender: Any) {
        timer?.invalidate()
        
        let ac = UIAlertController(title: "Are You sure?", message: "Stopping the timer will delete your progress in this focus session", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self]  _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            if self?.isResting ?? false {
                self?.continueRestTimer()
            } else {
                self?.continueWorkTimer()
            }
        }))
        
        present(ac, animated: true)
    }
    
    
    // MARK: - Private Methods
    private func checkElapsedTime() {
        if isResting {
            if restTimeInSeconds - restSecondsElapsed <= 0 {
                finishRestSession()
            }
        } else {
            if focusTimeInSeconds - workSecondsElapsed <= 0 {
                finishWorkSession()
            }
        }
    }
    
    private func finishWorkSession() {
        self.timer?.invalidate()
        
        TasksManager.shared.saveTask(task)
        
        let ac = UIAlertController(title: "Yay! You've done it!", message: "It's time for the short rest now", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Rest", style: .default, handler: { [weak self]  _ in
            self?.startRestTimer()
        }))
        ac.addAction(UIAlertAction(title: "Leave", style: .cancel, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        
        present(ac, animated: true)
    }
    
    private func finishRestSession() {
        self.timer?.invalidate()
        
        let ac = UIAlertController(title: "Resting is over!", message: "It's time for the next work session", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "I'm ready", style: .default, handler: { [weak self]  _ in
            self?.startWorkTimer()
        }))
        ac.addAction(UIAlertAction(title: "Leave", style: .cancel, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        
        present(ac, animated: true)
    }
    
    fileprivate func continueRestTimer() {
        self.progressLayer.strokeEnd = CGFloat(self.restSecondsElapsed / self.restTimeInSeconds)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / focusSpeeder, repeats: true, block: { [weak self] _ in
            guard let `self` = self else { return }
            self.restSecondsElapsed += 1.0
            self.progressLayer.strokeEnd = CGFloat(self.restSecondsElapsed / self.restTimeInSeconds)
            self.checkElapsedTime()
        })
    }
    
    private func startRestTimer() {
        restSecondsElapsed = 0
        isResting = true
        
        title = "\(task.title) – rest"
        
        continueRestTimer()
    }
    
    fileprivate func continueWorkTimer() {
        self.progressLayer.strokeEnd = CGFloat(self.workSecondsElapsed / self.focusTimeInSeconds)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / focusSpeeder, repeats: true, block: { [weak self] _ in
            guard let `self` = self else { return }
            self.workSecondsElapsed += 1.0
            self.progressLayer.strokeEnd = CGFloat(self.workSecondsElapsed / self.focusTimeInSeconds)
            self.checkElapsedTime()
        })
    }
    
    private func startWorkTimer() {
        workSecondsElapsed = 0
        isResting = false
        
        continueWorkTimer()
    }
    
    private func setupTimerProgressBar() {
        let circlePath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        // Add track layer
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1).cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        trackLayer.position = view.center
        
        view.layer.addSublayer(trackLayer)
        
        // Add progress layer
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        progressLayer.position = view.center
        progressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        view.layer.addSublayer(progressLayer)
    }

}
