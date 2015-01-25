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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateDisplay()
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
        if let walk = walkStore.currentWalk {
            if let region = self.mapRegion(walk) {
                mapView.setRegion(region, animated: true)
            }
        }
        
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyLine())
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
    
    // This feels like it could definitely live somewhere else
    // I am not sure yet where this function lives
    func mapRegion(walk: Walk) -> MKCoordinateRegion? {
        if let startLocation = walk.locations.first? {
            var minLatitude = startLocation.coordinate.latitude
            var maxLatitude = startLocation.coordinate.latitude
            
            var minLongitude = startLocation.coordinate.longitude
            var maxLongitude = startLocation.coordinate.longitude
            
            for location in walk.locations {
                if location.coordinate.latitude < minLatitude {
                    minLatitude = location.coordinate.latitude
                }
                if location.coordinate.latitude > maxLatitude {
                    maxLatitude = location.coordinate.latitude
                }
                
                if location.coordinate.longitude < minLongitude {
                    minLongitude = location.coordinate.longitude
                }
                if location.coordinate.latitude > maxLongitude {
                    maxLongitude = location.coordinate.longitude
                }
            }
            
            let center = CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude)/2.0,
                                                longitude: (minLongitude + maxLongitude)/2.0)
            
            // 10% padding need more padding vertically because of the toolbar
            let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude)*1.3,
                longitudeDelta: (maxLongitude - minLongitude)*1.1)
        
            return MKCoordinateRegion(center: center, span: span)
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polyLine = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyLine)
            renderer.strokeColor = UIColor(hue:0.88, saturation:0.46, brightness:0.73, alpha:0.75)
            renderer.lineWidth = 6
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
    
    @IBAction func unwindToMapsView(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

