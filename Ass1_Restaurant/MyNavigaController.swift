//
//  MyNavigaController.swift
//  Ass1_Restaurant
//
//  Created by crow on 1/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit


class MyNavigaController: UINavigationController {
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor(hexString: CONST.MAIN_COLOR)
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    // pop view controller
    func pop() {
        self.popViewController(animated: true)
    }
    
    // push view controller
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0
        {
            // set back button image for each view controller
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pop))
        }
        viewController.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
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
