//
//  ViewControllerExtension.swift
//  Ass1_Restaurant
//
//  Created by crow on 5/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit


extension UIViewController {
    
    //show succeed MBProgressHUD message
    func showSucceedMessage(view: UIView, message: String) {
        showProgressWithImageName(view:view, message:message, imageName:"tick")
    }
    
    //show fail MBProgressHUD message
    func showFailMessage(view: UIView, message: String) {
        showProgressWithImageName(view:view, message:message, imageName:"cross")
    }
    
    //show MBProgressHUD with image
    func showProgressWithImageName(view: UIView, message: String, imageName: String) {
        let hud = MBProgressHUD.showAdded(to:view, animated: true)
        hud.mode = MBProgressHUDMode.customView
        hud.customView = UIImageView(image: UIImage(named: imageName)!)
        hud.detailsLabel.text = message
        hud.hide(animated: true, afterDelay: 1)
    }
    
    //show alert
    func showAlertMessage(message: NSString) {
        let alertVC = UIAlertController(title: "Alert", message: message as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .default, handler:nil)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //show alert with action
    func showAlertMessageWithAction(message: NSString, okHandler : ((UIAlertAction) -> Swift.Void)? = nil) {
        let alertVC = UIAlertController(title: "Alert", message: message as String, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler:okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // compress image
    func compressImageSize(image: UIImage) -> NSData{
        let originalImgSize = (UIImagePNGRepresentation(image)! as NSData?)?.length
        var zipImageData : NSData? = nil
        if originalImgSize!>1500 {
            zipImageData = UIImageJPEGRepresentation(image,0.1)! as NSData?
        }else if originalImgSize!>600 {
            zipImageData = UIImageJPEGRepresentation(image,0.2)! as NSData?
        }else if originalImgSize!>400 {
            zipImageData = UIImageJPEGRepresentation(image,0.3)! as NSData?
        }else if originalImgSize!>300 {
            zipImageData = UIImageJPEGRepresentation(image,0.4)! as NSData?
        }else if originalImgSize!>200 {
            zipImageData = UIImageJPEGRepresentation(image,0.5)! as NSData?
        }
        return zipImageData!
    }
}
