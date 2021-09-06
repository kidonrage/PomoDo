//
//  CircularProgressView.swift
//  Pomodorus
//
//  Created by Vlad Eliseev on 22.08.2021.
//

import UIKit

final class CircularProgressView: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    var progressColor: UIColor = .systemGreen {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor: UIColor = .black {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        createCircularPath()
    }
    
    private func createCircularPath() {
        let circlePath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        // Add track layer
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.systemBackground.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        trackLayer.position = center
        
        layer.addSublayer(trackLayer)
        
        // Add progress layer
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.systemBackground.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.5
        progressLayer.position = center
        
        layer.addSublayer(progressLayer)
    }
    
}
