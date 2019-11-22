//
//  ActivityListViewController.swift
//  Health
//
//  Created by Vikhyath on 25/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ActivityListViewController: UIViewController {
    
    var activityList: [WalkSleep] = []
    var didLoad: Bool = false
    let userID = Auth.auth().currentUser?.uid
    var iswalk = true
    var activityIndicator: UIActivityIndicatorView?
    var walkGoal = 200
    var sleepGoal = 4 * 3600
    
    @IBOutlet weak var placeHolderText: UILabel!
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var walkButtonView: UIView!
    @IBOutlet weak var sleepButtonView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        placeHolderText.isHidden = true
        placeholder.isHidden = true
        retrieveGoal()
        setActivityIndicator()
        setUpViews()
        fetch()
        populateList(activity: "Walk", property: "steps")
        sort()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setActivityIndicator() {
        
        activityIndicator = {
            
            let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            activity.center = view.center
            activity.style = UIActivityIndicatorView.Style.gray
            activity.center = view.center
            activity.hidesWhenStopped = true
            return activity
        }()
        guard let unwrappedActivityIndicator = activityIndicator else {
            return
        }
        tableView.addSubview(unwrappedActivityIndicator)
    }
    
    func setUpViews() {
        
        walkButton.backgroundColor = Colors.orange
        sleepButton.backgroundColor = Colors.orange
        sleepButtonView.backgroundColor = Colors.orange
        headerView.backgroundColor = Colors.orange
        walkButtonView.backgroundColor = .white
        walkButton.layer.borderWidth = 0
        sleepButton.layer.borderWidth = 0
        tableView.backgroundColor = UIColor.clear
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveGoal()
        if didLoad {
            if iswalk {
                 populateList(activity: "Walk", property: "steps")
                 sort()
            } else {
                populateList(activity: "Sleep", property: "duration")
                sort()
            }
            tableView.reloadData()
        }
        didLoad = true
    }
    
    func retrieveGoal() {
        
        let ref = Database.database().reference(fromURL: Urls.userurl)
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        
        ref.child(message).observeSingleEvent(of: .value, with: { data in
            
            guard data.hasChild("goal") else {
                self.walkGoal = 200
                self.sleepGoal = 4 * 3600
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
            self.walkGoal = previousWalk
            self.sleepGoal = previousSleep
        })
    }
    
    func populateList(activity: String, property: String) {
        
        activityList.removeAll()
        let ref = Database.database().reference(fromURL: Urls.userurl)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.hasChild("Activity") {
                self.view.isUserInteractionEnabled = true
                self.placeholder.isHidden = !self.activityList.isEmpty
                return
            }
        }
        fetch()
        FireBaseHelper.isConnectedToFireBase { isConnected in
            if isConnected {
                self.callAPI(activity: activity, property: property)
            } else {
                self.fetch()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func callAPI(activity: String, property: String) {
        
        guard  let userID = userID else {
            return
        }
        
        let ref = Database.database().reference(fromURL: Urls.userurl)
            ref.child(userID).child("Activities").child(activity).observeSingleEvent(of: .value, with: { snapshot in
            guard let days = snapshot.value as? NSDictionary else { self.tableView.reloadData(); return }
            self.activityList.removeAll()
            self.activityIndicator?.startAnimating()
            for ( _, value) in days {
                
                guard let walkDetails = value as? NSDictionary,
                    let tempDate = walkDetails["date"] as? String,
                    let propertyTemp = walkDetails[property] as? Int else { return }
                let date = Date.stringToDate(str: tempDate)
                self.activityList.append(WalkSleep(duration: 0, steps: propertyTemp, date: date))
            }
            self.addToCoreData()
            self.fetch()
            self.activityIndicator?.stopAnimating()
        })
    }
    
    private func sort() {
        activityList = activityList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    @IBAction private func walkButtonTapped(_ sender: Any) {
        
        if iswalk {
            return
        }
        fetch()
        iswalk = !iswalk
        view.isUserInteractionEnabled = false
        activityList.removeAll()
        populateList(activity: "Walk", property: "steps")
        walkButtonView.backgroundColor = .white
        sleepButtonView.backgroundColor = Colors.orange
    }
    
    @IBAction private func sleepButtonTapped(_ sender: Any) {
        
        if !iswalk {
            return
        }
        fetch()
        iswalk = !iswalk
        placeholder.isHidden = true
        view.isUserInteractionEnabled = false
        activityList.removeAll()
        populateList(activity: "Sleep", property: "duration")
        sleepButtonView.backgroundColor = .white
        walkButtonView.backgroundColor = Colors.orange
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ActivityListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableCell", for: indexPath) as? ActivityTableCell
        
        let row = activityList[indexPath.row]
        cell?.dateLabel.text = Date.dateToString(date: row.date)
        
        var temp: String = ""
        if iswalk {
            temp = "Steps: \(row.steps)"
            if row.steps >= walkGoal {
                cell?.statusImage.tintColor = .green
                cell?.statusImage.image = UIImage(named: "icons8-checkmark-96")
                cell?.durationLabel.textColor = Colors.green
            } else {
                cell?.statusImage.tintColor = .red
                cell?.statusImage.image = UIImage(named: "icons8-high-priority-48")
                cell?.durationLabel.textColor = .red
            }
            cell?.durationLabel.text = temp
            
        } else {
            if row.steps >= (sleepGoal * 3600) {
                cell?.statusImage.tintColor = .green
                cell?.statusImage.image = UIImage(named: "icons8-checkmark-96")
                cell?.durationLabel.textColor = Colors.green
            } else {
                cell?.statusImage.tintColor = .red
                cell?.statusImage.image = UIImage(named: "icons8-high-priority-48")
                cell?.durationLabel.textColor = .red
            }
            let hour = row.steps / 3600
            let minutes = (row.steps / 60) % 60
            let seconds = row.steps % 60
            temp = "\(hour)h : \(minutes)min : \(seconds)sec"
            cell?.durationLabel.text = temp
        }
        cell?.selectionStyle = .none
        cell?.backgroundColor = UIColor.clear
        guard let unwrappedCell = cell else {
            return UITableViewCell()
        }
        return unwrappedCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activityList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}

extension ActivityListViewController {
    
    func addToCoreData() {
        if iswalk {
            WalkDetail.deleteObject()
            for activity in activityList {
                WalkDetail.insertObjects(walkObject: activity)
            }
        } else {
            SleepDetail.deleteObject()
            for activity in activityList {
                SleepDetail.insertObjects(sleepObject: activity)
            }
        }
    }
    
    func fetch() {
        
        activityList.removeAll()
        if iswalk {
            activityList = WalkDetail.fetchWalkDetail()
            self.sort()
            tableView.reloadData()
            placeholder.isHidden = !activityList.isEmpty
            tableView.isHidden = activityList.isEmpty
            placeHolderText.isHidden = !self.activityList.isEmpty
        } else {
            activityList = SleepDetail.fetchSleepDetail()
            self.sort()
            tableView.reloadData()
            placeholder.isHidden = !activityList.isEmpty
            tableView.isHidden = activityList.isEmpty
            placeHolderText.isHidden = !self.activityList.isEmpty
        }
    }
}
