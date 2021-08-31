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
    
    var task: Task!
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    private var timer: Timer?
    
    private let focusSpeeder: Double = 100.0
    private let focusTimeInMinutes: Double = 25
    private var focusTimeInSeconds: Double {
        return focusTimeInMinutes * 60
    }
    private var secondsElapsed: Double = 0 {
        didSet {
            let remainingSeconds = focusTimeInSeconds - secondsElapsed
            let minutes = (remainingSeconds / 60).rounded(.down)
            let seconds = remainingSeconds - minutes * 60
            timeLabel.text = String(format: "%02d:%02d", Int(minutes), Int(seconds))
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = task.title
        
        navigationItem.setHidesBackButton(true, animated: true)
        
        secondsElapsed = 0
        
        setupTimerProgressBar()
        
        startWorkTimer()
    }
    
    // MARK: - IBActions
    @IBAction func stopButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Are You sure?", message: "Stopping the timer will delete your progress in this focus session", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self]  _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.startWorkTimer()
        }))
        
        present(ac, animated: true) { [weak self] in
            self?.timer?.invalidate()
        }
    }
    
    
    // MARK: - Private Methods
    private func checkElapsedTime() {
        if focusTimeInSeconds - secondsElapsed <= 0 {
            finishWorkSession()
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
    
    private func startRestTimer() {
        
    }
    
    private func startWorkTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / focusSpeeder, repeats: true, block: { [weak self] _ in
            guard let `self` = self else { return }
            self.secondsElapsed += 1.0
            self.progressLayer.strokeEnd = CGFloat(self.secondsElapsed / self.focusTimeInSeconds)
            self.checkElapsedTime()
        })
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
        progressLayer.strokeColor = #colorLiteral(red: 0.4431372549, green: 1, blue: 0.5450980392, alpha: 1).cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        progressLayer.position = view.center
        progressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        view.layer.addSublayer(progressLayer)
    }

}
