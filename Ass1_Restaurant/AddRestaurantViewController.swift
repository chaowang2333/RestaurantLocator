//
//  AddRestaurantViewController.swift
//  Ass1_Restaurant
//
//  Created by crow on 5/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import MapKit
import Photos
import CoreData

protocol AddRestaurantDelegate {
    func addRestaurant(restaurant: Restaurant)
}

protocol EditRestaurantDelegate {
    func editRestaurant()
}

class AddRestaurantViewController: UIViewController, FinishGetAddressDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameTextField: MyTextField!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    var managedObjectContext: NSManagedObjectContext
    var photoPicker: UIImagePickerController!
    var logoData: Data?
    var address: String?
    var coordinate = CLLocationCoordinate2D(latitude: -37.87701, longitude: 145.044267)
    var isPickingLogo = false
    var photos = [UIImage]()
    var photoDatas = [Data]()
    var currentRestaurant: Restaurant?
    var category: String?
    var placeMark: MKPlacemark?

    var addRestaurantDelegate: AddRestaurantDelegate?
    var editRestaurantDelegate: EditRestaurantDelegate?
    
    // initialise colorslider and colorview
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        photoPicker =  UIImagePickerController()
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
        photoPicker.delegate = self
        
        // add choose address tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(searchAddress))
        addressLabel.addGestureRecognizer(tap)
        addressLabel.isUserInteractionEnabled = true
        
        // init views
        addressLabel.textColor = UIColor(hexString: CONST.MAIN_COLOR)
        ratingView.allowEdit = true
        
        // set up text field
        nameTextField.textFieldName = "Restaurant Name"
        nameTextField.maxLength = 20
        nameTextField.vc = self
        
        // collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:80,height:80)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5)
        collectionView.setCollectionViewLayout(layout, animated: true)
        // collection view delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        
        // save button
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePressed))
        self.navigationItem.rightBarButtonItem = saveButton
        
        // set values
        if currentRestaurant != nil
        {
            self.title = "Edit Restaurant"
            setCurrentRestaurant(restaurant: currentRestaurant!)
        }
        else
        {
            self.title = "Add Restaurant"
        }
    }
    
    // set current restaurant
    func setCurrentRestaurant(restaurant: Restaurant)
    {
        self.nameTextField.text = restaurant.name
        self.logoData = restaurant.logo! as Data
        self.logoImageView.image = UIImage(data: restaurant.logo! as Data)
        self.address = restaurant.address
        self.addressLabel.text = restaurant.address
        self.coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.long)
        self.ratingView.setRating(rating: CGFloat(restaurant.rating))
        self.photoDatas = restaurant.photos as! [Data]
        for data in photoDatas {
            photos.append(UIImage(data: data)!)
        }
        self.collectionView.reloadData()
    }
    
    // re-set address label placeholder
    override func viewWillAppear(_ animated: Bool) {
        if addressLabel.text == ""
        {
            addressLabel.text = "Press me to choose address..."
        }
    }
    
    // save button pressed
    func savePressed() {
        if nameTextField.text == ""
        {
            showAlertMessage(message: "Please fill in restaurant name")
            return
        }
        if address == "" || address == nil
        {
            showAlertMessage(message: "Please choose address")
            return
        }
        if logoData == nil
        {
            showAlertMessage(message: "Please select logo")
            return
        }
        if currentRestaurant == nil {
            setRestaurantsRownum()
            let restaurant = NSEntityDescription.insertNewObject(forEntityName: "Restaurant", into: managedObjectContext) as? Restaurant
            restaurant?.name = self.nameTextField.text
            restaurant?.logo = self.logoData! as NSData
            restaurant?.address = self.address
            restaurant?.lat = self.coordinate.latitude
            restaurant?.long = self.coordinate.longitude
            restaurant?.dateAdded = Date() as NSDate
            restaurant?.rating = Int32(self.ratingView.rating)
            restaurant?.notification = true
            restaurant?.radius = 50
            restaurant?.photos = self.photoDatas as NSObject
            restaurant?.rownum = 0
            restaurant?.category = category
            restaurant?.placeMark = placeMark
            addRestaurantDelegate?.addRestaurant(restaurant: restaurant!)
        }
        else {
            currentRestaurant?.name = self.nameTextField.text
            currentRestaurant?.logo = self.logoData! as NSData
            currentRestaurant?.address = self.address
            currentRestaurant?.lat = self.coordinate.latitude
            currentRestaurant?.long = self.coordinate.longitude
            currentRestaurant?.rating = Int32(self.ratingView.rating)
            currentRestaurant?.photos = self.photoDatas as NSObject
            currentRestaurant?.placeMark = placeMark
            editRestaurantDelegate?.editRestaurant()
        }
        saveRecords()
        self.navigationController?.popViewController(animated: true)
    }
    
    // set other restaurants' row num
    func setRestaurantsRownum() {
        // fetch largest rownum
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
        fetchRequest.predicate = NSPredicate(format: "category == %@", category!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rownum", ascending: false)]
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            if result.count != 0
            {
                for restaurant in result {
                    (restaurant as! Restaurant).rownum += 1
                }
            }
        } catch {
            print(error as NSError)
        }
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
    
    // select logo button pressed
    @IBAction func selectLogoPressed(_ sender: Any) {
        self.photoPicker.sourceType = .photoLibrary
        isPickingLogo = true
        self.present(self.photoPicker, animated: true, completion: nil)
    }
 
    // add photo button pressed
    @IBAction func addPhotoPressed(_ sender: Any) {
        self.photoPicker.sourceType = .photoLibrary
        self.present(self.photoPicker, animated: true, completion: nil)
    }
    
    // search address
    func searchAddress() {
        let vc = SearchAddressMainController()
        vc.finishGetAddressDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // finish get address
    func finishGetAddress(coordinate: CLLocationCoordinate2D, address: String, placeMark: MKPlacemark) {
        self.coordinate = coordinate
        self.address = address
        self.placeMark = placeMark
        addressLabel.text = address
    }
    
    // did finish picking photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        let referenceUrl = info[UIImagePickerControllerReferenceURL] as? URL
        let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceUrl!], options: nil)
        let asset = assets.firstObject
        asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
            let imageFile = contentEditingInput?.fullSizeImageURL
            var imageData = NSData(contentsOf: imageFile!)
            let image = UIImage(data: imageData! as Data)
            imageData = self.compressImageSize(image: image!)
            if self.isPickingLogo
            {
                self.isPickingLogo = false
                self.logoData = imageData! as Data
                self.logoImageView.image = UIImage(data: imageData! as Data)
            }
            else
            {
                self.photoDatas.append(imageData! as Data)
                self.photos.append(UIImage(data: imageData as! Data)!)
                self.collectionView.reloadData()
            }
        })
    }
    
    // did select item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // delete photo
        showAlertMessageWithAction(message: "Remove this photo?") { (action) in
            self.photos.remove(at: indexPath.row)
            self.photoDatas.remove(at: indexPath.row)
            self.collectionView.reloadData()
        }
    }
    
    // collection view count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath)  as! PhotoCollectionViewCell
        cell.photoImageView.image =  photos[indexPath.row]
        return cell
    }
}
