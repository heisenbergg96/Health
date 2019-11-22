//
//  SignUpViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import ResearchKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var textFields: [UITextField]!
    
    var formIsValid = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        signUpButton.layer.cornerRadius = 7
        signUpButton.alpha = 0.5
        signUpButton.isEnabled = false
        activityIndicator.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clearTextFields()
    }
    
    func clearTextFields() {
        
        for textField in textFields {
            textField.text = ""
        }
        signUpButton.isEnabled = false
        signUpButton.alpha = 0.5
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func alertCreator(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .cancel) { (_: UIAlertAction) in
            self.clearTextFields()
        }
        alertController.addAction(action1)
        
        return alertController
    }
    
    @IBAction private func signUpButtonTapped(_ sender: Any) {

        startSignUpProcess()
    }
    
    func startSignUpProcess() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        guard let emailString = emailField.text else {
            return
        }
        Auth.auth().fetchProviders(forEmail: emailString, completion: { providers, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            } else if providers == nil {
                let taskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
                taskViewController.delegate = self
                self.present(taskViewController, animated: true, completion: nil)
            } else {
                let alert = self.alertCreator(title: "Sign Up Error", message: "EmailID already exists!")
                self.present(alert, animated: true, completion: nil)
                return
            }
        })
    }
    
    @IBAction private func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        if error != nil || reason != .completed {
            taskViewController.dismiss(animated: true, completion: nil)
            return
        }
        
        // handling results here
        guard let consentResult = taskViewController.result.results as? [ORKStepResult] else { taskViewController.dismiss(animated: true, completion: nil); return }
        
        //if consentResult.is
        print(consentResult)
        for stepResult in consentResult {
            if stepResult.identifier == "ConsentReviewStep" {
                let signatureResult = stepResult.results as? [ORKConsentSignatureResult]
                
                guard signatureResult?.first?.consented == true else {
                    taskViewController.dismiss(animated: true, completion: nil)
                    return
                }
                signUpTheUser(taskViewController: taskViewController) {
                    let userID = Auth.auth().currentUser?.uid
                    signatureResult?.first?.apply(to: consentDocument)
                    consentDocument.makePDF { data, _ in
                        guard let unwrappedData = data else {
                            return
                        }
                        let storageRef = Storage.storage().reference()
                        let consentDocRef = storageRef.child("consentDocs")
                        _ = consentDocRef.child("\(String(describing: userID)).pdf").putData(unwrappedData, metadata: nil, completion: { metadata, _ in
                                guard metadata != nil else {
                                return
                            }
                            print("Saved")
                        })
                    }
                }
            }
        }
        //taskViewController.dismiss(animated: true, completion: nil)
    }
    
    func signUpTheUser(taskViewController: ORKTaskViewController, completion: @escaping () -> Void) {
        
        guard let email = emailField.text, let pass = passwordField.text, let name = nameField.text else {
            print("Not all the fields are filled!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            
            if let error = error {
                
                let alert = self.alertCreator(title: "Sign Up Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                print(error.localizedDescription as Any)
                taskViewController.dismiss(animated: true, completion: nil)
                return
            }
            guard let uid = user?.user.uid else {
                return
            }
            guard let homeScreen = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as? HomeTabController else { return }
            self.navigationController?.pushViewController(homeScreen, animated: true)
            taskViewController.dismiss(animated: true, completion: nil)
            let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
            let userReference = ref.child("Users").child(uid)
            let values = ["name": name, "email": email]
            userReference.updateChildValues(values, withCompletionBlock: { updatingUserError, _ in
                
                if updatingUserError != nil {
                    return
                }
                print("saved user sucessfully")
                completion()
                return
            })
        }
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case emailField:
            nameField.becomeFirstResponder()
        case nameField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmPasswordField.becomeFirstResponder()
        default:
            confirmPasswordField.resignFirstResponder()
            if formIsValid {
                startSignUpProcess()
            }
        }
        return true
    }
    
    func validate(_ textField: UITextField) -> (Bool, String?) {
        
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if textField == passwordField {
            return (text.count >= 6, "Your password is too short.")
        }
        
        if textField == confirmPasswordField {
            return(textField.text == passwordField.text, "Password and confirm password doesn't match")
        }
        
        if textField == emailField {
            guard let email = textField.text else { return (false, "Field empty") }
            return(isValidEmail(testStr: email), "This is not a valid emailID")
        }
        
        return (!text.isEmpty, "This field cannot be empty.")
    }
    
    @objc func textDidChange(_ notification: Notification) {
        formIsValid = true
        
        for textField in textFields {
            let (valid, _) = validate(textField)
            
            guard valid else {
                formIsValid = false
                signUpButton.alpha = 0.3
                break
            }
        }
        
        signUpButton.isEnabled = formIsValid
        if formIsValid {
            signUpButton.alpha = 1.0
        }
    }
    
    func isValidEmail(testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
