//
//  PhotoViewController.swift
//  Ass1_Restaurant
//
//  Created by crow on 8/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    var imageData : Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(moveBack))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tap)
        
        if imageData != nil
        {
            photoImageView.image = UIImage(data: imageData!)
        }
    }
    
    // move back to last screen
    func moveBack() {
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.popViewController(animated: true)
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
