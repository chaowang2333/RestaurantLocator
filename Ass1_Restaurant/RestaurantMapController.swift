//
//  RestaurantMapController.swift
//  Ass1_Restaurant
//
//  Created by wc on 21/08/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RestaurantMapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var radiusSegmentControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var selectedRestaurant: RestaurantLocationAnnotation? = nil
    var managedObjectContext : NSManagedObjectContext
    var restaurants = [Restaurant]()
    var annotations = [RestaurantLocationAnnotation]()
    var circularRegion: CLCircularRegion?
    
    // init viewContext
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        radiusSegmentControl.tintColor = UIColor(hexString: CONST.MAIN_COLOR)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self
    }
    
    // fetch data
    func fetchData() {
        if circularRegion == nil
        {
            return
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
        
        mapView.removeAnnotations(mapView.annotations)
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            if result.count != 0
            {
                annotations.removeAll()
                self.restaurants = (result as? [Restaurant])!
                for restaurant in self.restaurants {
                    let coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.long)
                    // check if inside the region
                    if (circularRegion?.contains(coordinate))!
                    {
                        let restaurantAnnotation = RestaurantLocationAnnotation(newRestaurant: restaurant, newCoordinate: coordinate)
                        annotations.append(restaurantAnnotation)
                        mapView.addAnnotation(restaurantAnnotation)
                    }
                }
            }
        } catch {
            print(error as NSError)
        }
    }
    
    // move to current location
    @IBAction func resetCurrentLocation(_ sender: Any) {
        locationManager.requestLocation()
        fetchData()
    }
    
    // refresh annotations
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    // segment select changed
    @IBAction func segmentValueChanged(_ sender: Any) {
        if circularRegion == nil
        {
            return
        }
        circularRegion = CLCircularRegion(center: (circularRegion?.center)!, radius: Double(radiusSegmentControl.titleForSegment(at: radiusSegmentControl.selectedSegmentIndex)!)!, identifier: "currentRegion")
        fetchData()
    }
    
    // location manager request authorization
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    // current location updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            circularRegion = CLCircularRegion(center: location.coordinate, radius: Double(radiusSegmentControl.titleForSegment(at: radiusSegmentControl.selectedSegmentIndex)!)!, identifier: "currentRegion")
            mapView.setRegion(region, animated: true)
            fetchData()
        }
    }
    
    // locationManager failed
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
    
    // view for annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "restaurantAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        annotationView?.annotation = annotation
        
        annotationView?.canShowCallout = true
        
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 30, height: 30)))
        button.setBackgroundImage(UIImage(named: "direction"), for: .normal)
        button.addTarget(self, action: #selector(showDirection), for: .touchUpInside)
        annotationView?.leftCalloutAccessoryView = button
        
        let detailButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 30, height: 30)))
        detailButton.setBackgroundImage(UIImage(named: "info"), for: .normal)
        detailButton.addTarget(self, action: #selector(showRestaurantDetail), for: .touchUpInside)
        annotationView?.rightCalloutAccessoryView = detailButton
       
        // logo image
        var logoImage = UIImage(data: (annotation as! RestaurantLocationAnnotation).restaurant?.logo as! Data)
        let sizeChange = CGSize(width: 20,height: 20)
        UIGraphicsBeginImageContextWithOptions(sizeChange, false, 0.0)
        logoImage?.draw(in: CGRect(origin: (annotationView?.frame.origin)!, size: sizeChange))
        logoImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = logoImage

        return annotationView
    }
    
    // show restaurant detail
    func showRestaurantDetail() {
        if selectedRestaurant != nil
        {
            let vc = ViewRestaurantController()
            vc.restaurant = selectedRestaurant?.restaurant
            self.navigationController?.show(vc, sender: true)
        }
    }
    
    // did select annotation 
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedRestaurant = view.annotation as? RestaurantLocationAnnotation
    }
    
    // direction
    func showDirection(){
        if let selectedRestaurant = selectedRestaurant
        {
            var placeMark = selectedRestaurant.restaurant?.placeMark
            if selectedRestaurant.restaurant?.placeMark == nil {
                placeMark = MKPlacemark(coordinate: selectedRestaurant.coordinate)
            }
            let mapItem = MKMapItem(placemark: placeMark as! MKPlacemark)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}
