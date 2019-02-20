//
//  AppDelegate.swift
//  Ass1_Restaurant
//
//  Created by wc on 21/08/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // set the status bar to white
        application.statusBarStyle = .lightContent
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        monitorRestaurants()
        
        if  UserDefaults.standard.bool(forKey: "EverLaunched") == false
        {
            // launch first time
            UserDefaults.standard.set(true, forKey: "EverLaunched")
            
            // add sample data
            let managedObjectContext = persistentContainer.viewContext
            for i in 0..<CONST.CATEGORYARRAY.count
            {
                let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: managedObjectContext) as? Category
                category?.title = CONST.CATEGORYARRAY[i]
                category?.icon = UIImageJPEGRepresentation(UIImage(named: "\(CONST.CATEGORYARRAY[i]).jpg")!, 0.8) as NSData?
                category?.color = UIColor(hexString: CONST.CATEGORYCOLOR[i])
                category?.rownum = Int32(i)
            }
            for i in 0..<CONST.RESTAURANTARRAY.count
            {
                let restaurantDictionary = CONST.RESTAURANTARRAY[i]
                let restaurant = NSEntityDescription.insertNewObject(forEntityName: "Restaurant", into: managedObjectContext) as? Restaurant
                restaurant?.name = restaurantDictionary["Name"] as? String
                restaurant?.logo = UIImageJPEGRepresentation(UIImage(named: "\(restaurantDictionary["Logo"]!).jpg")!, 0.8) as NSData?
                restaurant?.address = restaurantDictionary["Address"] as? String
                restaurant?.lat = restaurantDictionary["Latitude"] as! Double
                restaurant?.long = restaurantDictionary["Longitude"] as! Double
                let fomatter = DateFormatter()
                fomatter.dateFormat = "dd-MM-yyyy"
                restaurant?.dateAdded = fomatter.date(from: restaurantDictionary["Add date"] as! String) as NSDate?
                restaurant?.rating = Int32((arc4random_uniform(3)) + 3)
                restaurant?.notification = true
                restaurant?.radius = 250
                let photos = restaurantDictionary["Photo"] as! [String]
                var photoDatas = [NSData]()
                for photo in photos {
                   photoDatas.append((UIImageJPEGRepresentation(UIImage(named: "\(photo).jpg")!, 0.8) as NSData?)!)
                }
                restaurant?.photos = photoDatas as NSObject
                restaurant?.rownum = Int32(i % 3)
                restaurant?.category = restaurantDictionary["Category"] as? String
                restaurant?.placeMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (restaurant?.lat)!, longitude: (restaurant?.long)!))
            }
            do {
                try managedObjectContext.save()
            } catch {
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // monitor restaurants
    func monitorRestaurants() {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
        }
        
        let managedObjectContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            if result.count != 0
            {
                for restaurant in result as! [Restaurant] {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.long)
                    // get region
                    let region = CLCircularRegion(center: coordinate, radius: CLLocationDistance(restaurant.radius), identifier: restaurant.objectID.uriRepresentation().absoluteString)
                    region.notifyOnEntry = true
                    locationManager.stopMonitoring(for: region)
                    if restaurant.notification
                    {
                        // start monitor restaurant region
                        locationManager.startMonitoring(for: region)
                    }
                }
            }
        } catch {
            print(error as NSError)
        }
    }
    
    // did enter region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            if UIApplication.shared.applicationState == .active {
                // alert
                guard let message = getMessage(fromRegionIdentifier: region.identifier) else { return }
                window?.rootViewController?.showAlertMessage(message: message as NSString)
            } else {
                // notification
                let notification = UILocalNotification()
                var message = getMessage(fromRegionIdentifier: region.identifier)
                if message == nil
                {
                    message = "1 restaurant nearby~"
                }
                notification.alertBody = message
                notification.soundName = "Default"
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
        }
    }
    
    // get display message
    func getMessage(fromRegionIdentifier identifier: String) -> String? {
        let managedObjectContext = self.persistentContainer.viewContext
        do {
            var identifier = identifier
            if identifier.contains("<")
            {
                var range = identifier.range(of: "<")
                identifier = identifier.substring(from: (range?.upperBound)!)
                range = identifier.range(of: ">")
                identifier = identifier.substring(to: (range?.lowerBound)!)
            }
            let url = URL(string: identifier)
            if url == nil
            {
                return nil
            }
            let managementObjectID = persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url!)
            if managementObjectID == nil
            {
                return nil
            }
            let restaurant = managedObjectContext.object(with: managementObjectID!)
            return (restaurant as! Restaurant).name! + " nearby~"
        } catch {
            print(error as NSError)
        }
        
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
//        fetchRequest.predicate = NSPredicate(format: "objectID == %@", identifier)
//        
//        do {
//            let result = try managedObjectContext.fetch(fetchRequest) as! [Restaurant]
//            if result.count != 0
//            {
//                return result[0].name! + " nearby~"
//            }
//        } catch {
//            print(error as NSError)
//        }
        return nil
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Restaurant")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

