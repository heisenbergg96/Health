////
////  WalkViewController.swift
////  Health
////
////  Created by Vikhyath on 24/09/18.
////  Copyright © 2018 Vikhyath. All rights reserved.
////
//
//import UIKit
//import FirebaseDatabase
//import Firebase
//
//class WalkViewController: UIViewController {
//
//    var ref: DatabaseReference?
//    var databasehandler: DatabaseHandle?
//    var walkTask: WalkTask!
//    
//    @IBOutlet weak var goalLabel: UILabel!
//    @IBOutlet weak var coveredLabel: UILabel!
//    @IBOutlet weak var tobeCoveredLabel: UILabel!
//    @IBOutlet weak var progressBar: UIProgressView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Tasks")
//        _ = assignTask()
//        view.setGradientBackground(colorOne: Colors.blue, colorTwo: Colors.white)
//        updateTaskLabels()
//        updateCoveredLabel()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        updateCoveredLabel()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        updateTaskLabels()
//    }
//    
//    func updateTaskLabels() {
//        
//        ref?.child("Task1").observeSingleEvent(of: .value, with: { (snapshot) in
//            let dict = snapshot.value as? NSDictionary
//            print(dict as Any)
//            
//            if let duration = dict?["duration"] as? Int {
//                self.goalLabel.text = "\(duration)"
//            }
//        })
//    }
//    
//    func updateCoveredLabel() {
//        
//        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
//        let uid = Auth.auth().currentUser?.uid
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "ddMMyyyy"
//        let today = formatter.string(from: date)
//        
//        ref.child(uid!).child("Activities").child(today).observeSingleEvent(of: .value, with: { (snapshot) in
//            if let dict = snapshot.value as? NSDictionary {
//                if let covered = dict["Walk"] as? Double {
//                    self.coveredLabel.text = String(covered.rounded())
//                } else {
//                    print("Cannot convert")
//                }
//            } else {
//                self.coveredLabel.text = "0.0"
//                print("Error")
//            }
//        })
//    }
//    
//    @IBAction func handleCancel(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    func assignTask() -> String {
//        return "Task1"
//    }
//    
//    @IBAction func walkTapped(_ sender: UIButton) {
//        let nextScreen = storyboard?.instantiateViewController(withIdentifier: "TrackWalkViewController") as? TrackWalkViewController
//        nextScreen?.presentDistance = coveredLabel.text
//        present(nextScreen!, animated: true)
//    }
//}
