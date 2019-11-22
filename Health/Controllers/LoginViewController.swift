//
//  LoginViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ilabel: UILabel!
    @IBOutlet var textFields: [UITextField]!
    
    var isSignUp: Bool = true
    var formIsValid = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.alpha = 0.5
        signInButton.layer.cornerRadius = 7
        activityIndicator.isHidden = true
        signInButton.isEnabled = false
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        activityIndicator.center = signInButton.center
    }
    
    @IBAction private func signInButtonTapped(_ sender: Any) {
        startLoginProcess()
    }
    
    func startLoginProcess() {
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        guard let user = userName.text, let password = passwordField.text else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            return
        }
        Auth.auth().signIn(withEmail: user, password: password) { _, error in
            
            if let error = error {
                let alert = self.alertCreator(title: "Authentication Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("User logged in successfuly!")
                let homeScreen = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as? HomeTabController
                guard let unwrappedhomeScreen = homeScreen else {
                    return
                }
                self.navigationController?.pushViewController(unwrappedhomeScreen, animated: true)
            }
        }
    }
    
    @IBAction private func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func alertCreator(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "OK", style: .cancel) { (_: UIAlertAction) in
            self.clearForm()
        }
        alertController.addAction(action1)
        
        return alertController
    }
    
    func clearForm() {
        
        userName.text = ""
        passwordField.text = ""
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        signInButton.alpha = 0.5
        signInButton.isEnabled = false
    }
    
    @IBAction private func forgotPasswordTapped(_ sender: UIButton) {
        
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { textField in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { _ in
            guard let resetEmail = forgotPasswordAlert.textFields?.first?.text else {
                return
            }
            Auth.auth().sendPasswordReset(withEmail: resetEmail, completion: { error in
               
                DispatchQueue.main.async {
                    
                    if let error = error {
                        let resetFailedAlert = UIAlertController(title: "Reset Failed", message: error.localizedDescription, preferredStyle: .alert)
                        resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetFailedAlert, animated: true, completion: nil)
                    } else {
                        let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                        resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetEmailSentAlert, animated: true, completion: nil)
                    }
                }
            })
        }))
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userName:
            passwordField.becomeFirstResponder()
        default:
            passwordField.resignFirstResponder()
            if formIsValid {
                startLoginProcess()
            }
        }
        return true
    }
    
    func validate(_ textField: UITextField) -> (Bool, String?) {
        
        guard let text = textField.text else {
            return (false, nil)
        }
        
        return (!text.isEmpty, "This field cannot be empty.")
    }
    
    @objc func textDidChange(_ notification: Notification) {
        formIsValid = true
        
        for textField in textFields {
            let (valid, _) = validate(textField)
            
            guard valid else {
                formIsValid = false
                signInButton.alpha = 0.3
                break
            }
        }
        
        signInButton.isEnabled = formIsValid
        if formIsValid {
            signInButton.alpha = 1.0
        }
    }
}
