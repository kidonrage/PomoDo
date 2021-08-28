//
//  TimerViewController.swift
//  PomoDo
//
//  Created by Vlad Eliseev on 21.08.2021.
//

import UIKit

final class TimerViewController: UIViewController {
    
    @IBOutlet weak var stopButton: UIButton!
    
    var task: Task!
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    private var timer: Timer?
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = task.name
        
        navigationItem.setHidesBackButton(true, animated: true)
        
        
        setupTimerProgressBar()
        
        timer = Timer.scheduledTimer(withTimeInterval: 20 * 60, repeats: true, block: { _ in
            self.progressLayer.strokeEnd += 0.1
        })
    }
    
    // MARK: - IBActions
    @IBAction func stopButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Stopping the timer will delete your progress in this focus session", message: "Are You sure?", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self]  _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true)
    }
    
    
    // MARK: - Private Methods
    private func setupTimerProgressBar() {
        let circlePath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        // Add track layer
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.black.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        trackLayer.position = view.center
        
        view.layer.addSublayer(trackLayer)
        
        // Add progress layer
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemGreen.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        progressLayer.position = view.center
        progressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        view.layer.addSublayer(progressLayer)
    }

}
