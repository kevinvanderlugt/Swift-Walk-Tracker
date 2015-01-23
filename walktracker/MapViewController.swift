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
    
    let walkStore: WalkStore = WalkStore.sharedInstance
    
    var isTracking: Bool = false
    
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
                self.mapView.removeOverlays(self.mapView.overlays)
                self.walkStore.stopWalk()
            }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        self.presentViewController(alert,
            animated: true, completion: nil)
    }
    
    @IBAction func walkPressed(sender: UIButton) {
        sender.selected = !sender.selected
        if isTracking {
            locationManager.stopUpdatingLocation()
        } else {
            locationManager.startUpdatingLocation()
            walkStore.startWalk()
        }
        
        isTracking = !isTracking
        mapView.showsUserLocation = isTracking
        updateDisplay()
    }
    
    func updateDisplay() {
//        if let walk = walkStore.currentWalk {
//            titleItem.title = String(format: "%.02f km", walk.distance.doubleValue/1000.0)
//        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let walk = walkStore.currentWalk {
            for location in locations {
                if let newLocation = location as? CLLocation {
                    if newLocation.horizontalAccuracy > 0 {
                        // Only set the location on and region on the first try
                        // This may change in the future
                        if walk.locations.count <= 0 {
                            mapView.setCenterCoordinate(newLocation.coordinate, animated: true)
                            
                            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000)
                            mapView.setRegion(region, animated: true)
                        }
                        let locations = walk.locations as Array<CLLocation>
                        if let oldLocation = locations.last as CLLocation? {
                            let delta: Double = newLocation.distanceFromLocation(oldLocation)
                            walk.addDistance(delta)
                        }
                        
                        walk.addNewLocation(newLocation)
                        
                        mapView.removeOverlays(mapView.overlays)
                        mapView.addOverlay(polyLine())
                    }
                }
            }
            updateDisplay()
        }
    }
    
    func polyLine() -> MKPolyline {
        if let walk = walkStore.currentWalk {
            var coordinates = walk.locations.map({ (location: CLLocation) ->
                CLLocationCoordinate2D in
                return location.coordinate
            })
            
            return MKPolyline(coordinates: &coordinates, count: walk.locations.count)
        }
        return MKPolyline()
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

