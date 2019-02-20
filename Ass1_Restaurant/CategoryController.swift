//
//  CategoryController.swift
//  Ass1_Restaurant
//
//  Created by crow on 28/8/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import CoreData

class CategoryController: UITableViewController, UIActionSheetDelegate, AddCategoryDelegate, EditCategoryDelegate {
   
    var managedObjectContext : NSManagedObjectContext

    @IBOutlet weak var settingButton: UIBarButtonItem!
    var alertVC: UIAlertController?
    var categories = [Category]()
    
    // init viewContext
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init views
        alertVC = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let addCategoryAlertAction = UIAlertAction(title: "Add New Category", style: UIAlertActionStyle.destructive) { (UIAlertAction) -> Void in
            let vc = AddCategoryController()
            vc.addCategoryDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let reArrangeAlertAction = UIAlertAction(title: "Re-arrange Categorys", style: UIAlertActionStyle.destructive) { (UIAlertAction) -> Void in
            self.settingButton.title = "OK"
            self.tableView.reloadData()
            self.tableView.setEditing(true, animated: true)
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) -> Void in
            //print("click Cancel")
        }
        
        alertVC?.addAction(addCategoryAlertAction)
        alertVC?.addAction(reArrangeAlertAction)
        alertVC?.addAction(cancelAlertAction)
        
        fetchData()
    }
    
    // fetch data
    func fetchData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rownum", ascending: true)]
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            if result.count != 0
            {
                self.categories = (result as? [Category])!
                tableView.reloadData()
            }
        } catch {
            print(error as NSError)
        }
    }
    
    // setting button and finish editing button pressed
    @IBAction func settingPressed(_ sender: Any) {
        if settingButton.title == "Setting"
        {
            // setting
            self.present(alertVC!, animated: true, completion: nil)
        }
        else
        {
            // finish re-arrange
            settingButton.title = "Setting"
            self.tableView.reloadData()
            self.tableView.setEditing(false, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // section count
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // tableview cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.iconImageView.image = UIImage(data: categories[indexPath.row].icon! as Data)
        cell.titleLabel.text = categories[indexPath.row].title
        cell.titleLabel.textColor = categories[indexPath.row].color as! UIColor
        return cell
    }
    
    // finish add category
    func addCategory(category: Category) {
        categories.append(category)
        self.tableView.reloadData()
    }
    
    // finish edit category
    func editCategory() {
        self.tableView.reloadData()
    }

    // edit actions
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // delete
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete"){(action,indexPath)->Void in
            self.deleteRestaurants(category: self.categories[indexPath.row].title!)
            self.managedObjectContext.delete(self.categories[indexPath.row])
            self.categories.remove(at: indexPath.row)
            
            for category in self.categories {
                if category.rownum > Int32(indexPath.row)
                {
                    category.rownum -= 1
                }
            }
            self.tableView.reloadData()
            self.saveRecords()
        }
        // edit
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit"){(action,indexPath)->Void in
            let vc = AddCategoryController()
            vc.editCategoryDelegate = self
            vc.setCurrentCategory(category: self.categories[indexPath.row]) 
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return [deleteAction, editAction]
    }
    
    // delete restaurants in this category
    func deleteRestaurants(category: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            if result.count != 0
            {
                for restaurant in result as! [Restaurant] {
                    self.managedObjectContext.delete(restaurant)
                }
            }
        } catch {
            print(error as NSError)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // tableview editing style
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if settingButton.title == "Setting"
        {
            // normal
            return .delete
        }
        else
        {
            // re-arrange
            return .none
        }
    }
    
    // tableview can move row
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // move row
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        let sourceNum = sourceIndexPath.row
        let destinationNum = destinationIndexPath.row
        
        let sourceCategory = self.categories[sourceNum] as Category
        
        // re-set row number for other categories
        if sourceNum > destinationNum
        {
            for category in categories {
                if category.rownum >= Int32(destinationNum) && category.rownum < Int32(sourceNum)
                {
                    category.rownum += 1
                }
            }
        }
        else if destinationNum > sourceNum
        {
            for category in categories {
                if category.rownum > Int32(sourceNum) && category.rownum <= Int32(destinationNum)
                {
                    category.rownum -= 1
                }
            }
        }
        // set row number
        sourceCategory.rownum = Int32(destinationNum)
        saveRecords()
        // sort category array
        categories.sort { (category, compareCategory) -> Bool in
            category.rownum < compareCategory.rownum
        }
        self.tableView.reloadData()
    }
    
    // did select row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RestaurantListController") as! RestaurantListController
        vc.categoryName = categories[indexPath.row].title
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // save records
    func saveRecords()
    {
        do {
            try self.managedObjectContext.save()
        } catch {
        }
    }
}
