//
//  BinuLocation.swift
//  Binu
//
//  Created by Xminds on 08/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import UIKit

class BinuLocation: NSObject, CLLocationManagerDelegate {
    var locLatitude:Double = 0.0
    var locLongtitude:Double = 0.0
    var locTime:Int = 0
    var locAccuracy:Float = 0.0
    var locCountry:String = ""
    var locLanguage:String = ""
    var locTimeZone:String = ""
    var locationManager = CLLocationManager()
    
    override init(){
        super .init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func ToString()->String{
        return String(format:"[%.2f,%.2f,%@,%@,%@,%d,0.00]",locLatitude,locLongtitude,locCountry,locLanguage,locTimeZone,locTime)
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
           
        case .denied:
            self.locationManager.stopUpdatingLocation()
            
        default:
            break
        }
    }
    
    internal func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        self.locLatitude = location.coordinate.latitude
        self.locLongtitude = location.coordinate.latitude
        self.fetchCityAndCountry(from: location) { city, country, error in
            guard let country = country, error == nil else { return }
            self.locCountry = country
            var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
            self.locTimeZone = localTimeZoneAbbreviation
            self.locLanguage = Locale.current.languageCode!
            self.locTime = ServiceManager.shared.mUtility.getTime()
        }
    }
    
}


