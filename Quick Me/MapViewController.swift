//
//  MapViewController.swift
//  QuickMe
//
//  Created by Abdul Wahib on 6/7/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    var mOffer: Offer!
    var mRequest: Request!
    
    var otherUserLocationPin: MKPointAnnotation!

    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        
        
        if mRequest != nil {
            
            let locations = mRequest.location.componentsSeparatedByString(";")
            if locations.count == 2 {
                let lat = Double(locations[0])!
                let lng = Double(locations[1])!
                let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,lng)
                let objectAnnotation = MKPointAnnotation()
                objectAnnotation.coordinate = pinLocation
                objectAnnotation.title = "\(mRequest.name!), mobile: \(mRequest.phoneNumber!)"
                self.mapView.addAnnotation(objectAnnotation)
                
                let region = MKCoordinateRegion(center: pinLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                self.mapView.setRegion(region, animated: true)
                self.mapView.regionThatFits(region)
                
            }
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.notificationToReceivedLocationUpdate(_:)), name: NSNotificationTypeQuickMe.LOCATION_RECEIVED, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSNotificationTypeQuickMe.LOCATION_RECEIVED, object: nil)
    }
   
    // MARK: Helper Methods
    func notificationToReceivedLocationUpdate(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let json = userInfo as? [String: String] {
                if let locationString = json["location"] {
                    let locations = locationString.componentsSeparatedByString(";")
                    if locations.count == 2 {
                        if let lat = Double(locations[0]) {
                            if let lng = Double(locations[1]) {
                                if let offerId = json["offerId"] {
                                    otherUserLocationOnMap(lat, lng: lng, offerId: offerId)
                                }
                            }
                        }
                    }
                }
                print(json)
            }
        }
    }
    
    func otherUserLocationOnMap(lat: Double, lng: Double, offerId: String) {
        
        if mOffer.offerId != offerId {
            return
        }
        
        var anotationTitle = "Request Maker"
        
        if let userId = PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID) {
            if mOffer.serverId == userId {
                anotationTitle = "Offer Maker"
            }
        }
        
        // Drop a pin
        otherUserLocationPin = MKPointAnnotation()
        otherUserLocationPin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        otherUserLocationPin.title = anotationTitle
        mapView.addAnnotation(otherUserLocationPin)

    }

}
