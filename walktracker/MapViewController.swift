//
//  MapViewController.swift
//  walktracker
//
//  Created by Kevin VanderLugt on 1/9/15.
//  Copyright (c) 2015 Alpine Pipeline. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, UIToolbarDelegate, MKMapViewDelegate {
    var locationManager: CLLocationManager!
    var totalDistance: CLLocationDistance = 0.0 {
        didSet {
            titleItem.title = String(format: "%.02f km", totalDistance/1000.0)
        }
    }
    
    var trackedLocations: Array<CLLocation> = []
    
    var isTracking: Bool = false
    
    @IBOutlet weak var walkButton: UIBarButtonItem!
    
    @IBOutlet weak var titleItem: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.activityType = .Fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction func trashPressed(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Walk",
                                    message: "Are you sure you want to trash your current route?",
                                preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                        style: UIAlertActionStyle.Default,
                                        handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete",
                                        style: UIAlertActionStyle.Destructive)
            { (action) in
                self.trackedLocations = []
                self.totalDistance = 0.0
                self.mapView.removeOverlays(self.mapView.overlays)
            }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        self.presentViewController(alert,
            animated: true, completion: nil)
    }
    
    @IBAction func walkPressed(sender: UIBarButtonItem) {
        if isTracking {
            sender.title = "Start"
            locationManager.stopUpdatingLocation()
        } else {
            sender.title = "Stop"
            locationManager.startUpdatingLocation()
        }
        isTracking = !isTracking
        mapView.showsUserLocation = isTracking
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        for location in locations {
            if let newLocation = location as? CLLocation {
                if newLocation.horizontalAccuracy > 0 {
                    
                    // Only set the location on and region on the first try
                    // This may change in the future
                    if trackedLocations.count <= 0 {
                        mapView.setCenterCoordinate(newLocation.coordinate, animated: true)
                        
                        let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000)
                        mapView.setRegion(region, animated: true)
                    }
                    
                    if let oldLocation = trackedLocations.last as CLLocation? {
                        let delta: Double = newLocation.distanceFromLocation(oldLocation)
                        totalDistance += delta
                    }
                    
                    trackedLocations.append(newLocation)
                    
                    mapView.removeOverlays(mapView.overlays)
                    mapView.addOverlay(polyLine())
                }
                else {
                    let alert = UIAlertController(title: "Horizontal Accuracy Failed",
                        message: "Accuracy \(newLocation.horizontalAccuracy) below 20",
                        preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "Okay",
                        style: UIAlertActionStyle.Default, handler: nil)
                    
                    alert.addAction(alertAction)
                    self.presentViewController(alert,
                                                animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func polyLine() -> MKPolyline {
        var coordinates = trackedLocations.map({ (location: CLLocation) ->
            CLLocationCoordinate2D in
            return location.coordinate
        })
        
        return MKPolyline(coordinates: &coordinates, count: trackedLocations.count)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polyLine = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyLine)
            renderer.strokeColor = UIColor.purpleColor()
            renderer.lineWidth = 3
            return renderer
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }

}

