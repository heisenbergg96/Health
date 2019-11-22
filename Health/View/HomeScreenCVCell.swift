//
//  HomeScreenCVCell.swift
//  FirebaseAuth
//
//  Created by Vikhyath on 09/10/18.
//

import UIKit
import Firebase

class HomeScreenCVCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var pageController: UIView!
    @IBOutlet weak var sleepWalkCountLabel: UILabel!
    
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    let percentageLabel = UILabel()
    var goalWalk = 200
    var goalSleep = 4 * 3600
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpProgressView(containerView: self)
        setUpPercentageLabel()
    }
    
    func setUpProgressView(containerView: UIView) {
        
        let center = containerView.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 50, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = Colors.white.cgColor
        trackLayer.lineWidth = 5
        trackLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = Colors.progressBlue.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        
        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(shapeLayer)
    }
    
    func setUpPercentageLabel() {
        
        percentageLabel.text = "0%"
        percentageLabel.textColor = Colors.white
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(15))
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        percentageLabel.center = self.center
        
        self.addSubview(percentageLabel)
    }
}
