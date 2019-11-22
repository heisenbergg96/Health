//
//  TrackWalkViewController.swift
//  Health
//
//  Created by Vikhyath on 24/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import CoreMotion

class TrackWalkViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var stepGoal: UILabel!
    
    var ref: DatabaseReference?
    let activity = CMMotionActivityManager()
    let pedometer = CMPedometer()
    
    var time = 0
    var timer = Timer()
    var startTime: Date?
    var endTime: Date?
    var presentDistance: String?
    var stepCount: Int = 0
    var isStart: Bool = false
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var goal: Int = 200
    var thisInterval: Int = 0
    
    let percentageLabel: UILabel = {
        
        let label = UILabel()
        label.text = "0%"
        label.textColor = Colors.orange
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(20))
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.layer.borderWidth = 1.0
        startButton.layer.borderColor = Colors.orange.cgColor
        setUpProgressView()
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        updateUIwithWalkDetails()
        doneButton.isEnabled = false
        doneButton.alpha = 0.5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIwithWalkDetails()
        updateGoalLabel()
    }
    
    func updateGoalLabel() {
        
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        
        ref.child(message).observeSingleEvent(of: .value, with: { data in
            
            guard data.hasChild("goal") else {
                self.stepGoal.text = "Goal 200 steps"
                self.goal = 200
                return
            }
            let goalValue = data.childSnapshot(forPath: "goal")
            guard let goalDictionary = goalValue.value as? NSDictionary else {
                return
            }
            guard let previousWalk = goalDictionary["walkgoal"] as? Int else {
                return
            }
            self.stepGoal.text = "Goal \(previousWalk) steps"
            let percent = CGFloat(self.stepCount) / CGFloat(previousWalk)
            self.percentageLabel.text = "\(Int(percent * 100))%"
            self.shapeLayer.strokeEnd = percent
            self.goal = previousWalk
        })
    }
    
    func updateUIwithWalkDetails() {
        
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        var previousWalkDetails = 0
        let ref = Database.database().reference(fromURL: Urls.userurl)
        ref.child(message).child("Activities").child("Walk").observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.hasChild(Date.getKeyFromDate()) {
                let snapshotData = snapshot.childSnapshot(forPath: Date.getKeyFromDate())
                guard let sleepDetails = snapshotData.value as? NSDictionary else { print("error"); return }
                previousWalkDetails = sleepDetails["steps"] as? Int ?? 0
                print("Inside \(previousWalkDetails)")
                self.timeLabel.text = String(previousWalkDetails)
                self.stepCount = previousWalkDetails
                let percent = CGFloat(previousWalkDetails) / CGFloat(self.goal)
                self.shapeLayer.strokeEnd = CGFloat(percent)
                self.percentageLabel.text = "\(Int(percent * 100))%"
                return
            } else {
                self.timeLabel.text = String(previousWalkDetails)
                return
            }
        }
        print("Outside \(previousWalkDetails)")
    }
    
    func setUpProgressView() {
        
        let center = view.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = Colors.lightorange.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = Colors.orange.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
    }
    
    private func startCountingSteps() {
        pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else {
                print("error updating step count")
                return
            }
            let str = pedometerData.numberOfSteps.stringValue
            DispatchQueue.main.async {
                if let steps = Int(str) {
                    self!.thisInterval += steps
                    self?.timeLabel.text = "\(steps + self!.stepCount)"
                    let percent = CGFloat(steps + self!.stepCount) / CGFloat(self!.goal)
                    self?.shapeLayer.strokeEnd = CGFloat(percent)
                    self?.percentageLabel.text = "\(Int(percent * 100))%"
                }
            }
            if let steps = Int(str) {
                if steps == self!.goal {
                    self!.addRewardPoints(points: 20)
                }
            }
        }
    }
    
    func addRewardPoints(points: Int) {
        
        let (status, userID) = FireBaseHelper.getUserID()
        guard status else {
            print(userID)
            return
        }
        
        retrivePreviousReward { previousCount in
            
            let ref = Database.database().reference(fromURL: Urls.userurl).child(userID)
            let tot = points + previousCount
            var value = [String: Int]()
            value["rewardpoints"] = tot
            ref.updateChildValues(value, withCompletionBlock: { error, _ in
                
                if error != nil {
                    print("error saving rewards")
                    return
                }
                print("reward saved successfully")
            })
        }
    }
    
    func retrivePreviousReward(completion: @escaping (Int) -> Void) {
        
        let (status, userID) = FireBaseHelper.getUserID()
        guard status else {
            print(userID)
            return
        }
        let ref = Database.database().reference(fromURL: Urls.userurl).child(userID)
        ref.observeSingleEvent(of: .value) { datasnapshot in
            
            if datasnapshot.hasChild("rewardpoints") {
                guard let reward = datasnapshot.childSnapshot(forPath: "rewardpoints").value as? Int else { return }
                completion(reward)
            } else {
                completion(0)
                return
            }
        }
    }
    
    private func startUpdating() {
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        }
    }

    @IBAction private func startButtonTapped(_ sender: Any) {
        
        doneButton.isEnabled = true
        doneButton.alpha = 1
        
        if !isStart {
            startButton.backgroundColor = Colors.orange
            startButton.setTitle("Stop", for: .normal)
            startButton.setTitleColor(Colors.white, for: .normal)
            startUpdating()
            isStart = !isStart
        } else {
            startButton.backgroundColor = Colors.white
            activity.stopActivityUpdates()
            startButton.setTitleColor(Colors.orange, for: .normal)
            startButton.setTitle("Start", for: .normal)
            guard let unwrappedtimeLabel = timeLabel.text else {
                return
            }
            if let integerValue = Int(unwrappedtimeLabel) {
                stepCount = integerValue
            }
            isStart = !isStart
            pedometer.stopUpdates()
        }
    }
    
    @objc func action() {
        time += 1
        timeLabel.text = String(time)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        pedometer.stopUpdates()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        
        guard let unwrappedTimeLabel = timeLabel.text else {
            return
        }
        if let integerValue = Int(unwrappedTimeLabel) {
            stepCount = integerValue
        }
        timer.invalidate()
        updateDatabase(stepCount: stepCount)
        if stepCount >= goal {
            
        }
        ProfileDataStore.saveStepCountSample(steps: thisInterval, date: Date())
        pedometer.stopUpdates()
        navigationController?.popViewController(animated: true)
    }
    
    func getPreviousWalkCount() {
        
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        var previousWalkDetails = 0
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        ref.child(message).child("Activities").child("Walk").observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.hasChild(Date.getKeyFromDate()) {
                let snapshotData = snapshot.childSnapshot(forPath: Date.getKeyFromDate())
                guard let sleepDetails = snapshotData.value as? NSDictionary else { print("error"); return }
                previousWalkDetails = sleepDetails["steps"] as? Int ?? 0
                print("Inside \(previousWalkDetails)")
                self.stepCount += previousWalkDetails
                self.updateDatabase(stepCount: self.stepCount)
                return
            } else {
                self.updateDatabase(stepCount: self.stepCount)
                return
            }
        }
        print("Outside \(previousWalkDetails)")
    }
    
    func updateDatabase(stepCount: Int) {
        
        ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
        let key = Date.getKeyFromDate()
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        let userReference = ref?.child("Users").child(message).child("Activities").child("Walk").child(key)
        let values = ["duration": 0, "date": Date.dateToString(date: Date()), "steps": stepCount] as [String: Any]
        
        userReference?.updateChildValues(values, withCompletionBlock: { error, _ in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            print("saved successfully")
            self.dismiss(animated: true, completion: nil)
        })
    }
}
