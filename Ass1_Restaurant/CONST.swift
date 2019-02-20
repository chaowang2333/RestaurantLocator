//
//  CONST.swift
//  Ass1_Restaurant
//
//  Created by crow on 1/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//


struct CONST {
    static let MAIN_COLOR = "#FC4641"
    static let MAIN_GREY = "#A3A3A3"
    static let BACKGROUND_GREY = "#F5F5F5"
    
    static let TEXTFIELD_HEIGHT: CGFloat = 30
    
    static let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    static let OPEN_WEATHER_KEY = "9411dae41f0d93068ff72ba6ea7e3c4a"
    static let RADIUS_INDEX : [Int32:Int] = [50: 0, 250: 1, 500: 2, 1000: 3]
    
    // sample
    static let RESTAURANTARRAY = [["Name":"Caulfield Chinese Restaurant",
                                   "Address":"12 Sir John Monash Dr, Caulfield East VIC 3145",
                                   "Category":"Chinese Food",
                                   "Add date":"12-08-2017",
                                   "Logo":"CCRLogo",
                                   "Photo":["CCR1","CCR2","CCR3","CCR4","CCR5"],
                                   "Latitude":-37.876563,
                                   "Longitude":145.0420739],
                                  ["Name":"EC Kitchen Chinese Cafe Restaurant",
                                   "Address":"1 Sir John Monash Dr, Caulfield East VIC 3145",
                                   "Category":"Chinese Food",
                                   "Add date":"01-04-2017",
                                   "Logo":"ECKLogo",
                                   "Photo":["ECK1","ECK2","ECK3","ECK4","ECK5"],
                                   "Latitude":-37.877445,
                                   "Longitude":145.04299],
                                  ["Name":"Seng Hing Gourmet",
                                   "Address":"1 Derby Rd, Caulfield East VIC 3145",
                                   "Category":"Chinese Food",
                                   "Add date":"26-05-2017",
                                   "Logo":"SHGLogo",
                                   "Photo":["SHG1","SHG2","SHG3","SHG4","SHG5"],
                                   "Latitude":-37.8764093,
                                   "Longitude":145.041556],
                                  ["Name":"Glassy Junction",
                                   "Address":"833 Dandenong Rd, Malvern VIC 3145",
                                   "Category":"Indian Food",
                                   "Add date":"27-07-2017",
                                   "Logo":"GJLogo",
                                   "Photo":["GJ1","GJ2","GJ3","GJ4","GJ5"],
                                   "Latitude":-37.8747479,
                                   "Longitude":145.040713],
                                  ["Name":"Indian Harvest Restaurant",
                                   "Address":"111 Waverley Rd, Malvern East VIC 3145",
                                   "Category":"Indian Food",
                                   "Add date":"13-07-2017",
                                   "Logo":"IHRLogo",
                                   "Photo":["IHR1","IHR2","IHR3","IHR4","IHR5"],
                                   "Latitude":-37.87572,
                                   "Longitude":145.048582],
                                  ["Name":"Spice Village",
                                    "Address":"311 Waverley Rd, Malvern East VIC 3145",
                                    "Category":"Indian Food",
                                    "Add date":"5-06-2017",
                                    "Logo":"SVLogo",
                                    "Photo":["SV1","SV2","SV3","SV4","SV5"],
                                    "Latitude":-37.8771023,
                                    "Longitude":145.0589241],
                                  ["Name":"KFC Caulfield",
                                    "Address":"13/14 Sir John Monash Dr, Caulfield East VIC 3145",
                                    "Category":"Fast Food",
                                    "Add date":"30-06-2017",
                                    "Logo":"KFCLogo",
                                    "Photo":["KFC1","KFC2","KFC3","KFC4","KFC5"],
                                    "Latitude":-37.8766174,
                                    "Longitude":145.0423078],
                                  ["Name":"SumoSalad",
                                    "Address":"Building K, Monash University, Caulfield East VIC 3145",
                                    "Category":"Fast Food",
                                    "Add date":"09-01-2017",
                                    "Logo":"SSLogo",
                                    "Photo":["SS1","SS2","SS3","SS4","SS5"],
                                    "Latitude":-37.876373,
                                    "Longitude":145.044428],
                                  ["Name":"Zambrero",
                                    "Address":"K/900 Dandenong Rd, Caulfield East VIC 3145",
                                    "Category":"Fast Food",
                                    "Add date":"11-11-2016",
                                    "Logo":"ZBLogo",
                                    "Photo":["ZB1","ZB2","ZB3","ZB4","ZB5"],
                                    "Latitude":-37.8775782,
                                    "Longitude":145.0444889]]
    
    static let CATEGORYARRAY = ["Indian Food", "Chinese Food", "Fast Food"]
    static let CATEGORYCOLOR = ["F8602B", "F23A2E", "239F60"]
}
