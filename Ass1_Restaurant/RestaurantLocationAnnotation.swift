//
//  RestaurantLocationAnnotation.swift
//  Ass1_Restaurant
//
//  Created by wc on 21/08/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import MapKit

class RestaurantLocationAnnotation: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var restaurant: Restaurant?
    
    // init
    init( newRestaurant: Restaurant, newCoordinate: CLLocationCoordinate2D){
        restaurant = newRestaurant
        title = restaurant?.name
        if (restaurant?.notification)!
        {
            let radius = restaurant?.radius
            subtitle = "Notification within \(radius!) metres"
        }
        else
        {
            subtitle = "Notification off"
        }
        //subtitle = restaurant?.address
        coordinate = newCoordinate
    }
}
