//
//  EditProfileViewController.swift
//  Health
//
//  Created by Vikhyath on 18/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userDetail: [String] = []
    var labels: [String] = []
    var age: String = ""
    var weight: String = ""
    var height: String = ""
    var inputTextField: UITextField?
    var pickerViewDataSource: [String] = []
    var bloodType: [String] = ["A+", "B+", "O+", "A-", "B-", "O-", "AB+", "AB-"]
    var gender: [String] = ["Male", "Female", "Other"]
    var index: Int = 0
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        pickerView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        headerView.setGradientBackground(colorOne: Colors.orange, colorTwo: Colors.brightOrange)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserDetailsFromFirebase()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func fetchUserDetailsFromFirebase() {
        userDetail.removeAll()
        let (status, userID) = FireBaseHelper.getUserID()
        guard status else {
            print(userID)
            return
        }
        let ref = Database.database().reference(fromURL: Urls.userurl).child(userID).child("userdetail")
        ref.observeSingleEvent(of: .value, with: { data in
            
            guard let userDetails = data.value as? NSDictionary else {
                return
            }
            if let age = userDetails["Age"] as? String {
                self.userDetail.append(age)
                self.labels.append("Age")
            }
            if let gender = userDetails["Gender"] as? String {
                self.userDetail.append(gender)
                self.labels.append("Gender")
            }
            if let bloodtype = userDetails["Blood Type"] as? String {
                self.userDetail.append(bloodtype)
                self.labels.append("Blood Type")
            }
            if let weight = userDetails["Weight"] as? String {
                self.userDetail.append("\(weight)")
                self.labels.append("Weight")
            }
            if let height = userDetails["Height"] as? String {
                self.userDetail.append("\(height)")
                self.labels.append("Height")
            }
            self.tableView.reloadData()
        })
    }
    
    private func saveChangedUserDetails() {
        
        let (status, userID) = FireBaseHelper.getUserID()
        guard status else {
            print(userID)
            return
        }
        let ref = Database.database().reference(fromURL: Urls.userurl).child(userID).child("userdetail")
        var values = [String: String]()
        let valuelabels = ["Age", "Gender", "Blood Type", "Weight", "Height"]
        for index in 0...userDetail.count - 1 {
            values[valuelabels[index]] = userDetail[index]
        }
        guard let height = (values["Height"] as NSString?)?.doubleValue else {
            return
        }
        guard let weight = (values["Weight"] as NSString?)?.doubleValue else {
            return
        }
        let bmi = weight / (height * height)
        values["Bmi"] = String(format: "%.2f", bmi)
        ref.updateChildValues(values) { error, _ in
            if error != nil {
                print("Error saving user details!")
                return
            }
            print("User details changed successfully!")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        saveChangedUserDetails()
    }
    @IBAction private func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDelegate,UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource
extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell") as? EditProfileCell
        cell?.labelField.text = labels[indexPath.row]
        if indexPath.row == 3 {
            cell?.valuefield.text = "\(userDetail[indexPath.row]) kg"
        } else if indexPath.row == 4 {
            cell?.valuefield.text = "\(userDetail[indexPath.row]) m"
        } else {
            cell?.valuefield.text = "\(userDetail[indexPath.row])"
        }
        
        guard let unwrappedCell = cell else {
            return UITableViewCell()
        }
        unwrappedCell.selectionStyle = .none
        return unwrappedCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 4 {
            index = indexPath.row
            pickerView.isHidden = true
            let alert = UIAlertController(title: "Edit \(labels[indexPath.row])", message: "Current value \(userDetail[indexPath.row])", preferredStyle: .alert)
            alert.addTextField(configurationHandler: numberField)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.okhandler()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        } else {
            pickerView.isHidden = false
            index = indexPath.row
            pickerView.selectRow(getIndex(row: indexPath.row), inComponent: 0, animated: true)
            if indexPath.row == 1 {
                pickerViewDataSource = gender
                pickerView.reloadAllComponents()
            } else {
                pickerViewDataSource = bloodType
                pickerView.reloadAllComponents()
            }
        }

    }
    
    func getIndex(row: Int) -> Int {
        
        if row == 1 {
            guard let pickerIndex = gender.firstIndex(of: userDetail[row]) else {
                return 0
            }
            return pickerIndex
        } else {
            guard let pickerIndex = bloodType.firstIndex(of: userDetail[row]) else {
                return 0
            }
            return pickerIndex
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userDetail[index] = pickerViewDataSource[row]
        tableView.reloadData()
    }
    
    func numberField(textField: UITextField) {
        inputTextField = textField
        inputTextField?.keyboardType = .decimalPad
    }
    
    func okhandler() {
        
        guard let text = inputTextField?.text else {
            print("No input")
            return
        }
        if text != "" {
            userDetail[index] = "\(text)"
            tableView.reloadData()
        }
    }
}
