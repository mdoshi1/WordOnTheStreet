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
