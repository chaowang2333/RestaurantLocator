//
//  SearchAddressMainController.swift
//  Ass1_Restaurant
//
//  Created by crow on 5/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import MapKit

protocol FinishGetAddressDelegate {
    func finishGetAddress(coordinate: CLLocationCoordinate2D, address: String, placeMark: MKPlacemark)
}

class SearchAddressMainController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FinishSelectAddressDelegate {
    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController?
    var finishGetAddressDelegate: FinishGetAddressDelegate?

    @IBOutlet weak var mapView: MKMapView!
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // search controller
        let locationSearchTable = SearchAddressController()
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.finishSelectAddressDelegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self
        
        // search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search restaurant address"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        resultSearchController?.navigationItem.leftBarButtonItem = nil
        definesPresentationContext = true
   
        locationSearchTable.mapView = mapView
    }
    
    // finish select address
    func finishSelectAddress(coordinate: CLLocationCoordinate2D, address: String, placeMark: MKPlacemark) {
        finishGetAddressDelegate?.finishGetAddress(coordinate: coordinate, address: address, placeMark: placeMark)
        self.navigationController?.popViewController(animated: false)
    }
    
    // did change authorisation
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    // did updated location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
}
