//
//  CredentialManager.swift
//  WOTS
//
//  Created by Max Freundlich on 5/12/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation
import UIKit

class CredentialManager {
    static let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                   identityPoolId: Constants.APIServices.AWSPoolId)

}

func onSignIn (_ success: Bool) {
    
    if (success) {
        // handle successful sign in
        // Perform operations like showing Welcome message
        //        DispatchQueue.main.async(execute: {
        //            let alert = UIAlertController(title: "Welcome",
        //                                          message: "Sign In Successful",
        //                                          preferredStyle: .alert)
        //            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        //            self.present(alert, animated: true, completion:nil)
        //        })
    } else {
        // handle cancel operation from user
    }
}
