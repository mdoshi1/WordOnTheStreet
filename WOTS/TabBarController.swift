//
//  TabBarController.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 4/29/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import Flurry_iOS_SDK

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Instrumentation: log tab clicked
        switch(item.tag) {
        case 0:
            // Review
            Flurry.logEvent("Tab_Review")
            break
        case 1:
            // Explore
            Flurry.logEvent("Tab_Explore")
            break
        case 2:
            Flurry.logEvent("Tab_Me")
            break
        default:
            break
        }

    }

}


