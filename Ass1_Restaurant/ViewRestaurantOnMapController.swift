//
//  ViewRestaurantOnMapController.swift
//  Ass1_Restaurant
//
//  Created by crow on 6/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import MapKit

class ViewRestaurantOnMapController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var restaurant: Restaurant?
    var currentAnnotation: RestaurantLocationAnnotation?
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.title = restaurant?.name
        
        currentAnnotation = RestaurantLocationAnnotation(newRestaurant: restaurant!, newCoordinate: CLLocationCoordinate2D(latitude: (restaurant?.lat)!, longitude: (restaurant?.long)!))
        mapView.addAnnotation(currentAnnotation!)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake((currentAnnotation?.coordinate)!, span)
        mapView.setRegion(region, animated: true)
        mapView.selectAnnotation(currentAnnotation!, animated: true)
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
    
    // direction
    func showDirection(){
        if let selectedRestaurant = currentAnnotation
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
