//
//  MyTabBarController.swift
//  Ass1_Restaurant
//
//  Created by crow on 3/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.tintColor = UIColor(hexString: CONST.MAIN_COLOR)
        for item in self.tabBar.items! {
            let barItem = item as UITabBarItem
            // set tabbaritem image in center
            barItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
