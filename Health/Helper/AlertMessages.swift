//
//  AlertMessages.swift
//  FirebaseAuth
//
//  Created by Vikhyath on 05/10/18.
//

import Foundation
import UIKit

class AlertMessages {
    
    static func alertCreator(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Default", style: .default) { (_: UIAlertAction) in
            print("You've pressed default")
        }
        alertController.addAction(action1)
        
        return alertController
    }
        
}
