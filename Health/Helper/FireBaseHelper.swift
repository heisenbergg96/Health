//
//  FireBaseHelper.swift
//  Health
//
//  Created by Vikhyath on 27/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import Firebase

class FireBaseHelper {
    
    static func getUserID() -> (Bool, String) {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return (false, "Error fetching user Id")
        }
        return (true, userID)
    }
    
    static func isConnectedToFireBase(completion: @escaping (Bool) -> Void) {
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
               //connected
                completion(true)
            } else {
               //not connected
                completion(false)
            }
        })
    }
}
