//
//  HomeScreenViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import HealthKit
import UserNotifications
import ResearchKit
import CoreData

class HomeScreenViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var flabel: UILabel!
    @IBOutlet weak var ilabel: UILabel!
    @IBOutlet weak var tlabel: UILabel!
    
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    let userHealthProfile = UserHealthProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveUserDetail()
        accessHealthKit()
        UNUserNotificationCenter.current().delegate = self
        setUpNotification()
        createNotification()
        view.setGradientBackground(colorOne: Colors.blue, colorTwo: Colors.white)
        pageControl.pageIndicatorTintColor = Colors.lightorange
        pageControl.currentPageIndicatorTintColor = Colors.brightOrange
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        headerView.setGradientBackground(colorOne: Colors.lightorange, colorTwo: Colors.brightOrange)
        collectionView.reloadData()
        flabel.textColor = Colors.progressBlue
        tlabel.textColor = Colors.progressBlue
        ilabel.textColor = Colors.progressBlue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func accessHealthKit() {
        
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                
            return
        }
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        stepCount,
                                                        HKObjectType.workoutType()]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       stepCount,
                                                       HKObjectType.workoutType()]
        
        if #available(iOS 12.0, *) {
            HKHealthStore().getRequestStatusForAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { requestStatus, _ in
                print(requestStatus)
                if requestStatus == .shouldRequest {
                    let alert = UIAlertController(title: "Permission", message: "We need to accesss you health repo", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.authorizeHealthKit()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { _, error in
                print(error as Any)
            }
        }
    }

    func setUpNotification() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if error != nil {
                print("error registering notification")
            }
            let viewAction = UNNotificationAction(identifier: "ViewAction",
                                                  title: "Take Survey",
                                                  options: [.foreground])
            let category = UNNotificationCategory(identifier: "categoryIdentyifier",
                                                  actions: [viewAction],
                                                  intentIdentifiers: [],
                                                  options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            print("No error")
        }
    }
    
    func createNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Health"
        content.subtitle = "Its survey time"
        content.body = "Please answer few questions for research purposes"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "Identifier", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in
            print("This is title \(request.content.title)")
        }
    }
    
    private func authorizeHealthKit() {
        
        HealthKitSetupAssistant.authorizeHealthKit { authorized, error in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                return
            }
            print("HealthKit Successfully Authorized.")
        }
    }
    
    func retrieveGoal(completion: @escaping (Int, Int) -> Void) {
        
        var goalWalk = 200
        var goalSleep = 4 * 3600
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            completion(goalWalk, goalSleep)
            return
        }
        
        ref.child(message).observeSingleEvent(of: .value, with: { data in
            
            guard data.hasChild("goal") else {
                goalWalk = 200
                goalSleep = 4 * 3600
                completion(goalWalk, goalSleep)
                return
            }
            let goalValue = data.childSnapshot(forPath: "goal")
            guard let goalDictionary = goalValue.value as? NSDictionary else {
                return
            }
            guard let previousWalk = goalDictionary["walkgoal"] as? Int else {
                return
            }
            guard let previousSleep = goalDictionary["sleepgoal"] as? Int else {
                return
            }
            goalWalk = previousWalk
            goalSleep = previousSleep
            completion(goalWalk, goalSleep)
        })
    }
    
    func fetchSleepWalkDetails(activity: String, property: String, completion: @escaping (Int) -> Void) {
        
        var previousWalkDetails = 0
        
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        ref.child(message).child("Activities").child(activity).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.hasChild(Date.getKeyFromDate()) {
                let snapshotData = snapshot.childSnapshot(forPath: Date.getKeyFromDate())
                guard let sleepDetails = snapshotData.value as? NSDictionary else { print("error"); return }
                previousWalkDetails = sleepDetails[property] as? Int ?? 0
                completion(previousWalkDetails)
                return
            } else {
                completion(previousWalkDetails)
            }
        }
        print("Outside \(previousWalkDetails)")
        completion(previousWalkDetails)
    }
}

extension HomeScreenViewController: UNUserNotificationCenterDelegate, ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        if reason == .completed {
            addRewardPoints(points: 20)
        }
        guard let results = taskViewController.result.results as? [ORKStepResult] else { return }
        var values = [String: String]()
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        for stepResult: ORKStepResult in results {
            guard let stepResultCast = stepResult.results else {
                return
            }
            for result in stepResultCast {
                if let questionResult = result as? ORKQuestionResult {
                    if questionResult.isMember(of: ORKChoiceQuestionResult.self) {
                        if let choiceAnswers = questionResult.answer as? NSArray {
                            let choiceIs = choiceAnswers.firstObject as? String
                            values[questionResult.identifier] = choiceIs
                        }
                    } else {
                        values[questionResult.identifier] = questionResult.answer as? String
                    }
                }
            }
        }
        print(values)
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        ref.child(message).child("survey").child(Date.getKeyFromDate()).updateChildValues(values) { error, _ in
            if error != nil {
                print("error saing user data!")
                taskViewController.dismiss(animated: true, completion: nil)
                return
            }
            print("Successfull saved survey details")
        }
        taskViewController.dismiss(animated: true, completion: nil)
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let taskViewController = ORKTaskViewController(task: QuestionTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeScreenCVCell", for: indexPath) as? HomeScreenCVCell
        if indexPath.row == 0 {
            retrieveGoal { walkGoal, _ in
                self.fetchSleepWalkDetails(activity: "Walk", property: "steps", completion: { stepCount in
                    let percent = CGFloat(stepCount) / CGFloat(walkGoal)
                    cell?.percentageLabel.text = "\(Int(percent * 100))%"
                    cell?.sleepWalkCountLabel.text = "\(stepCount) steps"
                    cell?.shapeLayer.strokeEnd = percent
                })
            }
        } else {
            retrieveGoal { _, sleepGoal in
                self.fetchSleepWalkDetails(activity: "Sleep", property: "duration", completion: { sleepCount in
                    let percent = CGFloat(sleepCount) / CGFloat(sleepGoal * 3600)
                    cell?.percentageLabel.text = "\(Int(percent * 100))%"
                    let hrs = sleepCount / 3600
                    let min = (sleepCount / 60) % 60
                    let sec = sleepCount % 60
                    cell?.sleepWalkCountLabel.text = "\(hrs)hrs:\(min)min:\(sec)sec"
                    cell?.shapeLayer.strokeEnd = percent
                })
            }
        }
        guard let unwrappedCell = cell else {
            return UICollectionViewCell()
        }
        return unwrappedCell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.x
        if contentOffset < UIScreen.main.bounds.width {
            pageControl.currentPage = 0
        } else {
            pageControl.currentPage = 1
        }
        print(contentOffset)
    }
    
}

extension HomeScreenViewController {
    
    func saveUserDetail() {
        
        let (status, userID) = FireBaseHelper.getUserID()
        guard status else {
            print(userID)
            return
        }
        
        let ref = Database.database().reference(fromURL: Urls.userurl).child(userID)
        ref.observeSingleEvent(of: .value) { data in
            if data.hasChild("userdetail") {
                return
            } else {
                self.populateWithHealthKit()
            }
        }
    }
    
    func populateWithHealthKit() {
        
        loadAndDisplayAgeSexAndBloodType()
        loadAndDisplayMostRecentWeight()
        loadAndDisplayMostRecentHeight()
    }
    
    private func loadAndDisplayAgeSexAndBloodType() {
        
        do {
            let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
            userHealthProfile.age = userAgeSexAndBloodType.age
            userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
            userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
        } catch let error {
            print("error fetching age sex and blood: \(error)")
        }
    }
    
    private func loadAndDisplayMostRecentWeight() {
        
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: weightSampleType) { sample, error in
            
            guard let sample = sample else {
                
                if let error = error {
                    print("weight sample not available: \(error)")
                }
                self.userHealthProfile.weightInKilograms = nil
                self.updateDatabase()
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKilograms = weightInKilograms
            guard let bmi = self.userHealthProfile.bodyMassIndex else {
                return
            }
            ProfileDataStore.saveBodyMassIndexSample(bodyMassIndex: bmi, date: Date())
            self.updateDatabase()
        }
    }
    
    private func loadAndDisplayMostRecentHeight() {
        
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: heightSampleType) { sample, error in
            
            guard let sample = sample else {
                
                if let error = error {
                    print("error fetching height details: \(error)")
                }
                self.userHealthProfile.heightInMeters = nil
                self.updateDatabase()
                return
            }
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
            guard let bmi = self.userHealthProfile.bodyMassIndex else {
                return
            }
            ProfileDataStore.saveBodyMassIndexSample(bodyMassIndex: bmi, date: Date())
            self.updateDatabase()
        }
    }
    
    func updateDatabase() {
        
        let (status, userID) = FireBaseHelper.getUserID()
        guard status else {
            print(userID)
            return
        }
        //print(userHealthProfile)
        var values = [String: String]()
        let ref = Database.database().reference(fromURL: Urls.userurl).child(userID)
        
        if let age = userHealthProfile.age {
            values["Age"] = "\(age)"
        } else {
            values["Age"] = "unknown"
        }
        if let blood = userHealthProfile.bloodType {
            values["Blood Type"] = blood.stringRepresentation
        } else {
            values["Blood Type"] = "unknown"
        }
        if let biologicalSex = userHealthProfile.biologicalSex {
            values["Gender"] = biologicalSex.stringRepresentation
        } else {
             values["Gender"] = "unknown"
        }
        if let height = userHealthProfile.heightInMeters {
            values["Height"] = "\(height)"
        } else {
            values["Height"] = "unknown"
        }
        if let weight = userHealthProfile.weightInKilograms {
            values["Weight"] = "\(weight)"
        } else {
            values["Weight"] = "unknown"
        }
        if let bmi = userHealthProfile.bodyMassIndex {
            values["Bmi"] = String(format: "%.2f", bmi)
        } else {
            values["Bmi"] = "unknown"
        }
        
        ref.child("userdetail").updateChildValues(values) { error, _ in
            
            if let error = error {
                print(error.localizedDescription as Any)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksIdentifierCell") as? TasksIdentifierCell
        if indexPath.row == 0 {
            cell?.taskLabel.text = "Walk Tracker"
            cell?.imageView?.image = UIImage(named: "group6")
        } else {
            cell?.taskLabel.text = "Sleep Tracker"
            cell?.imageView?.image = UIImage(named: "group11")
        }
        cell?.selectionStyle = .none
        guard let unwrappedCell = cell else {
            return UITableViewCell()
        }
        return unwrappedCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            guard let walk = storyboard?.instantiateViewController(withIdentifier: "TrackWalkViewController") as? TrackWalkViewController else { return }
            walk.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(walk, animated: true)
        } else {
            guard let sleep = storyboard?.instantiateViewController(withIdentifier: "SleepViewController") as? SleepViewController else { return }
            sleep.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(sleep, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100.0
    }
}
