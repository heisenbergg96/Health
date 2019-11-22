//
//  SetGoalViewController.swift
//  FirebaseAuth
//
//  Created by Vikhyath on 10/10/18.
//

import UIKit
import Firebase

class SetGoalViewController: UIViewController {

    @IBOutlet weak var walkSlider: UISlider!
    @IBOutlet weak var walkLabel: UILabel!
    @IBOutlet weak var sleepSlider: UISlider!
    @IBOutlet weak var sleepLabel: UILabel!
    
    var sleepGoal: Int = 4
    var walkGoal: Int = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }

    @IBAction private func walkSliderAction(_ sender: UISlider) {
        walkGoal = Int(sender.value)
        walkLabel.text = "\(walkGoal) steps"
    }
    
    @IBAction private func sleepSliderAction(_ sender: UISlider) {
        sleepGoal = Int(sender.value)
        sleepLabel.text = "\(Int(sender.value)) hrs"
    }
    
    @IBAction private func doneTapped(_ sender: Any) {
        updateDatabase()
        let shared = UserDefaults.standard
        shared.set(sleepGoal, forKey: "sleep")
        shared.set(walkGoal, forKey: "walk")
        dismiss(animated: true, completion: nil)
    }
    
    func updateLabels() {
        
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        
        ref.child(message).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.hasChild("goal") else {
                self.walkSlider.value = Float(200)
                self.sleepSlider.value = Float(4)
                self.walkLabel.text = "200 steps"
                self.sleepLabel.text = "4 hrs"
                return
            }
            
            let data = snapshot.childSnapshot(forPath: "goal")
            guard let goalDictionary = data.value as? NSDictionary else {
                return
            }
            
            guard let previousSleep = goalDictionary["sleepgoal"] as? Int,
                let previousWalk = goalDictionary["walkgoal"] as? Int else {
                    return
            }
            self.sleepGoal = previousSleep
            self.walkGoal = previousWalk
            self.sleepLabel.text = "\(previousSleep)"
            self.walkLabel.text = "\(previousWalk)"
            self.sleepSlider.value = Float(previousSleep)
            self.walkSlider.value = Float(previousWalk)
        }
    }
    
    func updateDatabase() {
        
        let ref = Database.database().reference(fromURL: Urls.firebaseUrl)
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        let userReference = ref.child("Users").child(message).child("goal")
        let values = ["walkgoal": walkGoal, "sleepgoal": sleepGoal] as [String: Any]
        
        userReference.updateChildValues(values, withCompletionBlock: { error, _ in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            print("saved successfully")
            self.navigationController?.popViewController(animated: true)
        })
    }
}
