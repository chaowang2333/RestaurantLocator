//
//  SearchAddressController.swift
//  Ass1_Restaurant
//
//  Created by crow on 5/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit
import MapKit

protocol FinishSelectAddressDelegate {
    func finishSelectAddress(coordinate: CLLocationCoordinate2D, address: String, placeMark: MKPlacemark)
}

class SearchAddressController: UITableViewController, UISearchResultsUpdating {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView?
    var finishSelectAddressDelegate: FinishSelectAddressDelegate?
    
    // view did load
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // update search results
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }

    // section count
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    // tableview cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let selectedItem = matchingItems[indexPath.row].placemark
        cell?.textLabel?.text = selectedItem.name
        cell?.detailTextLabel?.text = getAddress(selectedItem: selectedItem)
        return cell!
    }
    
    // did select row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        finishSelectAddressDelegate?.finishSelectAddress(coordinate: selectedItem.coordinate, address: getAddress(selectedItem: selectedItem), placeMark: selectedItem)
        self.navigationController?.popViewController(animated: true)
    }
    
    // get full address
    func getAddress(selectedItem:MKPlacemark) -> String {
        var address = ""
        var streetNum = ""
        var streetAddress = ""
        if selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil
        {
            streetNum = selectedItem.subThoroughfare! + " "
        }
        if selectedItem.thoroughfare != nil
        {
            streetAddress = selectedItem.thoroughfare!
        }
        address = streetNum + streetAddress
        
        if address != "" && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil)
        {
            address += ", "
        }
        if selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil
        {
            address = address + selectedItem.subAdministrativeArea! + " " + selectedItem.administrativeArea!
        }
        else if selectedItem.subAdministrativeArea != nil
        {
            address += selectedItem.subAdministrativeArea!
        }
        else if selectedItem.administrativeArea != nil
        {
            address += selectedItem.administrativeArea!
        }
        return address
    }
}
