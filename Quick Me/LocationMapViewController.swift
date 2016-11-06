//
//  MapViewController.swift
//  QuickMe
//
//  Created by Abdul Wahib on 6/9/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


protocol LocationMapViewControllerDelegate{
    func showLocationDetails(latitude: Double?, longitude: Double?, locationName: String?, radius: Double)
}

class LocationMapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    
    var delegate : LocationMapViewControllerDelegate!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusField: UITextField!
    
    var locationManager : CLLocationManager!
    let regionRadius: CLLocationDistance = 1000
    var objectAnnotation: MKPointAnnotation!
    var circle = MKCircle()
    
    var latitude : Double!
    var longitude : Double!
    var locationName : String!
    var editable: Bool = true
    
    var sendLocationName: String = ""
    var circlueRadius = 1000.0 // Meters
    
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        
        radiusField.text = "\(circlueRadius/1000)"
        
        if editable {
            mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(LocationMapViewController.getCoordinates(_:))))
            if (CLLocationManager.locationServicesEnabled())
            {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (latitude != nil && longitude != nil){
            let initialLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
            addRadiusCircle(initialLocation)
            if locationName != nil {
                self.title = locationName
            }
            centerMapOnLocation(initialLocation)
            
            // Add Pin at location
            let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = pinLocation
            objectAnnotation.title = locationName
            self.mapView.addAnnotation(objectAnnotation)
            
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Helper Methods
    func setUpNavigationBar() {
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(LocationMapViewController.searchButtonClick))
    }
    
    func addRadiusCircle(location: CLLocation){
        self.mapView.removeOverlays([circle])
        self.mapView.delegate = self
        circle = MKCircle(centerCoordinate: location.coordinate, radius: circlueRadius as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.blueColor()
            circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    // MARK: IBActions
    @IBAction func setRadiusClick(sender: AnyObject) {
        radiusField.resignFirstResponder()
        if let radius = Double(radiusField.text!) {
            circlueRadius = radius * 1000
            if (latitude != nil && longitude != nil){
                let initialLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
                addRadiusCircle(initialLocation)
            }
        }
    }
    
    @IBAction func setLocationClick(sender: AnyObject) {
        self.delegate?.showLocationDetails(latitude, longitude: longitude, locationName: sendLocationName, radius: circlueRadius)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func searchButtonClick(sender: AnyObject) {
        print("Search Button Click")
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
    }
    // MARK: Map Related Methods
    func centerMapOnLocation(location: CLLocation){
        locationManager?.stopUpdatingLocation()
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getCoordinates(sender: UILongPressGestureRecognizer){
        
        if sender.state != UIGestureRecognizerState.Began { return }
        let touchLocation = sender.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        
        self.latitude = locationCoordinate.latitude
        self.longitude = locationCoordinate.longitude
        
        if objectAnnotation != nil{
            self.mapView.removeAnnotation(objectAnnotation)
        }
        
        getLocationName(locationCoordinate)
        
        addRadiusCircle(CLLocation(latitude: self.latitude,longitude: self.longitude))
        
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude)
        objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Selected Location"
        self.mapView.addAnnotation(objectAnnotation)
        
    }
    
    func getLocationName(locationCoordinate: CLLocationCoordinate2D){
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // Address dictionary
            //            print(placeMark.addressDictionary)
            self.locationName = ""
            self.sendLocationName = ""
            // Location name
            if let name = placeMark.addressDictionary?["Name"] as? NSString
            {
                self.locationName.appendContentsOf(name as String)
                print(name)
                self.sendLocationName = name as String
            }
            
            // Street address
            if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString
            {
                //                self.locationName.appendContentsOf(", ")
                //                self.locationName.appendContentsOf(street as String)
                print(street)
            }
            
            // City
            if let city = placeMark.addressDictionary?["City"] as? NSString
            {
                self.locationName.appendContentsOf(", ")
                self.locationName.appendContentsOf(city as String)
                self.sendLocationName.appendContentsOf(", \(city as String)")
                print(city)
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary?["ZIP"] as? NSString
            {
                print(zip)
            }
            
            // Country
            if let country = placeMark.addressDictionary?["Country"] as? NSString
            {
                self.locationName.appendContentsOf(", ")
                self.locationName.appendContentsOf(country as String)
                print(country)
            }
            self.title = self.locationName
        }
    }
    
    // MARK: LocationManagerDelegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        print("\(lat), \(long)")
        centerMapOnLocation(userLocation)
    }
    
    // MARK: SearchBar Delegate Methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            //3
            
            self.latitude = localSearchResponse!.boundingRegion.center.latitude
            self.longitude = localSearchResponse!.boundingRegion.center.longitude
            
            self.getLocationName(localSearchResponse!.boundingRegion.center)
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    
}
