//
//  RestaurantListController.swift
//  Ass1_Restaurant
//
//  Created by crow on 5/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import CoreData

class RestaurantListController: UITableViewController, AddRestaurantDelegate, EditRestaurantDelegate {
    
    var managedObjectContext : NSManagedObjectContext
    var categoryName : String?
    var alertVC: UIAlertController?
    var restaurants = [Restaurant]()
    var settingButton : UIBarButtonItem?
    
    // init viewContext
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.categoryName
        settingButton = UIBarButtonItem(title: "Setting", style: .plain, target: self, action: #selector(settingPressed))
        self.navigationItem.rightBarButtonItem = settingButton
        
        // init views
        alertVC = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let addCategoryAlertAction = UIAlertAction(title: "Add New Restaurant", style: UIAlertActionStyle.destructive) { (UIAlertAction) -> Void in
            let vc = AddRestaurantViewController()
            vc.addRestaurantDelegate = self
            vc.category = self.categoryName
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let sortByNameAlertAction = UIAlertAction(title: "Sort by Name", style: UIAlertActionStyle.destructive) { (UIAlertAction) -> Void in
            // sort restaurant by name
            self.restaurants.sort { (restaurant, compareResturant) -> Bool in
                restaurant.name! < compareResturant.name!
            }
            self.tableView.reloadData()
        }
        let sortByRatingAlertAction = UIAlertAction(title: "Sort by Rating", style: UIAlertActionStyle.destructive) { (UIAlertAction) -> Void in
            // sort restaurant by name
            self.restaurants.sort { (restaurant, compareResturant) -> Bool in
                restaurant.rating > compareResturant.rating
            }
            self.tableView.reloadData()
        }
        let sortByDateAlertAction = UIAlertAction(title: "Sort by Date", style: UIAlertActionStyle.destructive) { (UIAlertAction) -> Void in
            // sort restaurant by name
            self.restaurants.sort { (restaurant, compareResturant) -> Bool in
                restaurant.dateAdded!.timeIntervalSince1970 > compareResturant.dateAdded!.timeIntervalSince1970
            }
            self.tableView.reloadData()
        }
        let reArrangeAlertAction = UIAlertAction(title: "Re-arrange Restaurants", style: UIAlertActionStyle.destructive) { (UIAlertAction) -> Void in
            // save current order to database
            for i in 0 ..< self.restaurants.count {
                self.restaurants[i].rownum = Int32(i)
            }
            self.saveRecords()
            self.settingButton?.title = "OK"
            self.tableView.reloadData()
            self.tableView.setEditing(true, animated: true)
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) -> Void in
        }
        
        alertVC?.addAction(addCategoryAlertAction)
        alertVC?.addAction(sortByNameAlertAction)
        alertVC?.addAction(sortByRatingAlertAction)
        alertVC?.addAction(sortByDateAlertAction)
        alertVC?.addAction(reArrangeAlertAction)
        alertVC?.addAction(cancelAlertAction)
        
        fetchData()
    }
    
    // finish add restaurant
    func addRestaurant(restaurant: Restaurant) {
        restaurants.insert(restaurant, at: 0)
        self.tableView.reloadData()
    }
    
    // finish edit restaurant
    func editRestaurant() {
        self.tableView.reloadData()
    }
    
    // fetch data
    func fetchData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
        fetchRequest.predicate = NSPredicate(format: "category == %@", categoryName!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rownum", ascending: true)]
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            if result.count != 0
            {
                self.restaurants = (result as? [Restaurant])!
                tableView.reloadData()
            }
        } catch {
            print(error as NSError)
        }
    }

    // setting button and finish editing button pressed
    func settingPressed(_ sender: Any) {
        if settingButton?.title == "Setting"
        {
            // setting
            self.present(alertVC!, animated: true, completion: nil)
        }
        else
        {
            // finish re-arrange
            settingButton?.title = "Setting"
            self.tableView.reloadData()
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // section number
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // row numebr
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    // tableview cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        cell.logoImageView.image = UIImage(data: restaurants[indexPath.row].logo! as Data)
        cell.nameLabel.text = restaurants[indexPath.row].name
        let fommater = DateFormatter()
        fommater.dateFormat = "dd-MM-yyyy"
        cell.ratingView.setRating(rating: CGFloat(restaurants[indexPath.row].rating))
        cell.addedDateLabel.text = fommater.string(from: restaurants[indexPath.row].dateAdded! as Date)
        cell.geoCodingLabel.text = "(\(restaurants[indexPath.row].lat), \(restaurants[indexPath.row].long))"
        return cell
    }
    
    // edit actions
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // delete
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete"){(action,indexPath)->Void in
            // reset row number
            for restaurant in self.restaurants {
                if restaurant.rownum > self.restaurants[indexPath.row].rownum
                {
                    restaurant.rownum -= 1
                }
            }
            self.managedObjectContext.delete(self.restaurants[indexPath.row])
            self.restaurants.remove(at: indexPath.row)
            self.saveRecords()
            self.tableView.reloadData()
        }
        // edit
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit"){(action,indexPath)->Void in
            let vc = AddRestaurantViewController()
            vc.editRestaurantDelegate = self
            vc.currentRestaurant = self.restaurants[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return [deleteAction, editAction]
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // tableview editing style
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if settingButton?.title == "Setting"
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
        
        let sourceRestaurant = self.restaurants[sourceNum] as Restaurant
        
        // re-set row number for other categories
        if sourceNum > destinationNum
        {
            for restaurant in restaurants {
                if restaurant.rownum >= Int32(destinationNum) && restaurant.rownum < Int32(sourceNum)
                {
                    restaurant.rownum += 1
                }
            }
        }
        else if destinationNum > sourceNum
        {
            for restaurant in restaurants {
                if restaurant.rownum > Int32(sourceNum) && restaurant.rownum <= Int32(destinationNum)
                {
                    restaurant.rownum -= 1
                }
            }
        }
        // set row number
        sourceRestaurant.rownum = Int32(destinationNum)
        saveRecords()
        // sort Restaurant array
        restaurants.sort { (restaurant, compareRestaurant) -> Bool in
            restaurant.rownum < compareRestaurant.rownum
        }
        self.tableView.reloadData()
    }
    
    // did select row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ViewRestaurantController()
        vc.restaurant = restaurants[indexPath.row]
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
