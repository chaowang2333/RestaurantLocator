//
//  ViewRestaurantController.swift
//  Ass1_Restaurant
//
//  Created by crow on 6/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import CoreData

class ViewRestaurantController: UIViewController, EditRestaurantDelegate {
    
    @IBOutlet weak var bannerView: SMCycleBannerView!
    var restaurant: Restaurant?
    @IBOutlet weak var radiusSegment: UISegmentedControl!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var dateAddedLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    var managedObjectContext: NSManagedObjectContext
    
    // init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init views
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(showMap))
        let addressImageViewTap = UITapGestureRecognizer(target: self, action: #selector(showMap))
        addressLabel.isUserInteractionEnabled = true
        addressImageView.isUserInteractionEnabled = true
        addressImageView.addGestureRecognizer(addressImageViewTap)
        addressLabel.addGestureRecognizer(addressTap)
        radiusSegment.tintColor = UIColor(hexString: CONST.MAIN_COLOR)
        radiusSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        notificationSwitch.tintColor = UIColor(hexString: CONST.MAIN_COLOR)
        notificationSwitch.onTintColor = UIColor(hexString: CONST.MAIN_COLOR)
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged), for: .valueChanged)
        addressLabel.textColor = UIColor(hexString: CONST.MAIN_COLOR)
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPressed))
        self.navigationItem.rightBarButtonItem = editButton
        
        // display info
        displayViewValues()
    }
    
    // did layout subviews
    override func viewDidLayoutSubviews() {
        // set up banner
        setupBanner()
    }
    
    // set up banner
    func setupBanner() {
        self.bannerView.initCycleBanner()
        self.bannerView.configureTimeInterval(timeInterval: 4.0)
        self.bannerView.configureImageViews(
            getImageList(),
            autoScroll: true,
            didClickEventClosure: {(index) in
                let photoDataArray = self.restaurant?.photos as! Array<Any>
                if photoDataArray.count > 0
                {
                    let photoViewController = PhotoViewController()
                    photoViewController.imageData = photoDataArray[index] as? Data
                    self.navigationController?.pushViewController(photoViewController, animated: true)
                }
        })
    }
    
    // segment select changed
    func segmentChanged() {
        restaurant?.radius = Int32(radiusSegment.titleForSegment(at: radiusSegment.selectedSegmentIndex)!)!
        saveRecords()
    }
    
    // notification switch select changed
    func notificationSwitchChanged() {
        restaurant?.notification = notificationSwitch.isOn
        saveRecords()
    }
    
    // display values
    func displayViewValues() {
        self.title = restaurant?.name
        radiusSegment.selectedSegmentIndex = CONST.RADIUS_INDEX[(restaurant?.radius)!]!
        notificationSwitch.isOn = (restaurant?.notification)!
        addressLabel.text = restaurant?.address
        categoryLabel.text = restaurant?.category
        let fommater = DateFormatter()
        fommater.dateFormat = "dd-MM-yyyy"
        dateAddedLabel.text = fommater.string(from: (restaurant?.dateAdded)! as Date)
        ratingView.setRating(rating: CGFloat((restaurant?.rating)!))
        logoImageView.image = UIImage(data: restaurant?.logo as! Data)
    }
    
    // edit restaurant
    func editPressed() {
        let vc = AddRestaurantViewController()
        vc.editRestaurantDelegate = self
        vc.currentRestaurant = restaurant
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // finish edit restaurant
    func editRestaurant() {
        displayViewValues()
        setupBanner()
    }
    
    // show map
    func showMap() {
        let vc = ViewRestaurantOnMapController()
        vc.restaurant = restaurant
        self.navigationController?.show(vc, sender: self)
    }
    
    // set image list to banner
    func getImageList() -> [UIImage] {
        var images = [UIImage]()
        
        for data in restaurant?.photos as! [Data] {
            images.append(UIImage(data: data)!)
        }
        return images
    }
    
    // save to database
    func saveRecords()
    {
        do {
            try self.managedObjectContext.save()
            (UIApplication.shared.delegate as? AppDelegate)?.monitorRestaurants()
        } catch {
        }
    }
}
