//
//  AddCategoryController.swift
//  Ass1_Restaurant
//
//  Created by crow on 1/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import ColorSlider
import Photos
import CoreData

protocol AddCategoryDelegate {
    func addCategory(category: Category)
}

protocol EditCategoryDelegate {
    func editCategory()
}

class AddCategoryController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var iconImageView : UIImageView!
    @IBOutlet weak var nameTextField : MyTextField!
    @IBOutlet weak var colorView : UIView!
    @IBOutlet weak var chooseColorLabel : UILabel!
    var photoPicker : UIImagePickerController!
    let colorSlider: ColorSlider!
    var iconData : Data?
    var managedObjectContext : NSManagedObjectContext
    var currentCategory : Category?
    
    var addCategoryDelegate: AddCategoryDelegate?
    var editCategoryDelegate: EditCategoryDelegate?
    
    // initialise colorslider and colorview
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        photoPicker =  UIImagePickerController()
        colorSlider = ColorSlider()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        colorSlider.previewEnabled = true
        colorSlider.orientation = .horizontal
        colorSlider.addTarget(self, action: #selector(didChangeColor), for: .touchUpOutside)
        colorSlider.addTarget(self, action: #selector(didChangeColor), for: .touchUpInside)
        self.view.addSubview(colorSlider)
        
        // set up text field
        nameTextField.textFieldName = "Category Name"
        nameTextField.maxLength = 20
        nameTextField.vc = self
        
        // default color
        colorView.backgroundColor = .black
        
        // save button
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePressed))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    // init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // save button pressed
    func savePressed() {
        if nameTextField.text == ""
        {
            showAlertMessage(message: "Please fill in category name")
            return
        }
        if iconData == nil
        {
            showAlertMessage(message: "Please select icon")
            return
        }
        if currentCategory == nil {
            let rownum = self.getCurrentRowNumber()
            let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: managedObjectContext) as? Category
            category?.title = self.nameTextField.text
            category?.icon = self.iconData! as NSData
            category?.color = self.colorView.backgroundColor
            category?.rownum = rownum
            addCategoryDelegate?.addCategory(category: category!)
        }
        else {
            if currentCategory?.title != self.nameTextField.text
            {
                // change all the restaurants in this category
                changeRestaurants()
            }
            currentCategory?.title = self.nameTextField.text
            currentCategory?.icon = self.iconData! as NSData
            currentCategory?.color = self.colorView.backgroundColor
            editCategoryDelegate?.editCategory()
        }
        saveRecords()
        self.navigationController?.popViewController(animated: true)
    }
    
    // change category of restaurants
    func changeRestaurants() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
        fetchRequest.predicate = NSPredicate(format: "category == %@", (currentCategory?.title!)!)
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            if result.count != 0
            {
                for restaurant in result as! [Restaurant] {
                    restaurant.category = self.nameTextField.text
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
        } catch {
        }
    }
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Category"
        photoPicker.delegate = self
    }
    
    // set current category
    func setCurrentCategory(category: Category) {
        currentCategory = category
        self.title = "Edit Category"
        self.nameTextField.text = currentCategory?.title
        self.colorView.backgroundColor = currentCategory?.color as? UIColor
        self.iconImageView.image = UIImage(data: (currentCategory?.icon as! Data))
        self.iconData = currentCategory?.icon as! Data
    }
    
    // choose icon pressed
    @IBAction func chooseIconPressed(_ sender: Any) {
        self.photoPicker.sourceType = .photoLibrary
        self.present(self.photoPicker, animated: true, completion: nil)
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
            self.iconData = imageData! as Data
            self.iconImageView.image = UIImage(data: imageData! as Data)
        })
    }
    
    // view did layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorSlider.frame = CGRect(x: 16, y: 167, width: self.view.bounds.width - 32, height: 12)
        colorView.layer.masksToBounds = true
        colorView.layer.cornerRadius = 12
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1
    }
    
    // get row num
    func getCurrentRowNumber() -> Int32 {
        // fetch largest rownum
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rownum", ascending: false)]
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            if result.count != 0
            {
                return (result[0] as! Category).rownum + 1
            }
        } catch {
            print(error as NSError)
        }
        return 0
    }
    
    // slider did change color
    func didChangeColor(_ slider: ColorSlider) {
        self.colorView.backgroundColor = slider.color
    }
}
