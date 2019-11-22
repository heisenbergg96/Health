//
//  WelcomeScreenViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase

class WelcomeScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func signUpButtonTapped(_ sender: Any) {
        print("Sign up tapped")
        guard let signUpScreen = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else {
            print("something is wrong")
        return
        }
        navigationController?.pushViewController(signUpScreen, animated: true)
    }
    
    @IBAction private func signInButtonTapped(_ sender: Any) {
        guard let signInScreen = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            return
        }
        navigationController?.pushViewController(signInScreen, animated: true)
    }
    
}
