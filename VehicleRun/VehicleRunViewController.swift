//
//  VehicleRunViewController.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 15/06/17.
//  Copyright © 2017 All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit
import AudioToolbox

let DetailSegueName = "RunDetails"

class VehicleRunViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    var managedObjectContext: NSManagedObjectContext?
    
    var run: Run!
    var seconds = 0.0
    var distance = 0.0
    var instantPace = 0.0
    var currentLocation:CLLocation?
    
    var timeInterval = 0.0
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    var mapOverlay: MKTileOverlay!
    var vehicleCurrentSpeed = 0.0
    var vehiclePastSpeed = 0.0
    
    @IBOutlet weak var mapView2: MKMapView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startButton.isHidden = false
        promptLabel.isHidden = false
        
        timeLabel.isHidden = true
        distanceLabel.isHidden = true
        paceLabel.isHidden = true
        locationLabel.isHidden = true
        stopButton.isHidden = true
        mapView2.isHidden = false
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10.0
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView2.delegate = self;
        
        mapView2.showsUserLocation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView2.userLocation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView2.setRegion(coordinateRegion, animated: true)
    }
    
    /**
     * @description: Function is called on tap the start button to capture the vehicle location,speed etc
     */
    @IBAction func startPressed(_ sender: AnyObject) {
        startButton.isHidden = true
        promptLabel.isHidden = true
        
        timeLabel.isHidden = false
        distanceLabel.isHidden = false
        paceLabel.isHidden = false
        locationLabel.isHidden = false
        stopButton.isHidden = false
        mapView2.isHidden = false
        
        seconds = 0.0
        timeInterval = 30.0
        distance = 0.0
        instantPace = 0.0
        vehicleCurrentSpeed = 0.0
        vehiclePastSpeed = 0.0
        locations.removeAll(keepingCapacity: false)
        
        
        timeLabel.text = "Time: 0"
        
        distanceLabel.text = "Distance: 0"
        
        paceLabel.text = "Current speed: 0 km/h"//"Pace:
        
        locationLabel.text = "Current lat:   long: "
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: self,
                                     selector: #selector(eachInterval(_:)),
                                     userInfo: nil,
                                     repeats: true)
        
        startLocationUpdates()
    }
    
    /**
     * @description: Function is called on tap the stop button to stop capturing the vehicle location, speed etc
     */
    @IBAction func stopPressed(_ sender: AnyObject) {
        self.locationManager.stopUpdatingLocation();
        let actionSheet = UIAlertController.init(title: "Run Stopped", message: nil, preferredStyle: .actionSheet)
                        actionSheet.addAction(UIAlertAction.init(title: "Save Run", style: UIAlertActionStyle.default, handler: { (action) in
                            self.saveRun();
                            self.performSegue(withIdentifier: DetailSegueName, sender: nil);
        }))
        actionSheet.addAction(UIAlertAction.init(title: "Discard Run", style: UIAlertActionStyle.destructive, handler: { (action) in
            self.navigationController?.popToRootViewController(animated: true)

        }))

        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                self.startLocationUpdates()
        }))

        //Present the controller
        self.present(actionSheet, animated: true, completion: nil)

        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailViewController {
            detailViewController.run = run
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    /**
     * @description: Function is called on each time interval which is based on the vehicle current speed
     */
    func eachInterval(_ timer1: Timer) {
        
        seconds += timeInterval
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
        let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
        let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))
        
        
        timeLabel.text = "Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        
        distanceLabel.text = "Distance: " + distanceQuantity.description
        
        paceLabel.text = "Current speed: "+String((instantPace*3.6*10).rounded()/10)+" km/h"
        
        vehicleCurrentSpeed = (instantPace*3.6*10).rounded()/10
        
        var currentlocationMessage = "Current "
        if let loc = self.currentLocation {
            let lat = loc.coordinate.latitude
            let long = loc.coordinate.longitude
            currentlocationMessage = currentlocationMessage + "lat: \(String(describing: lat))   long:\(String(describing: long))"
        }
        
        locationLabel.text = currentlocationMessage
        
        let speedDiff = abs(vehicleCurrentSpeed - vehiclePastSpeed)
        
        vehiclePastSpeed = vehicleCurrentSpeed
        
        let oldTimeInterval = timeInterval
        
        // Implemented logic for location update based on the vehicle speed
        if vehicleCurrentSpeed >= 80 {
            timeInterval = 30
        }
        else if (vehicleCurrentSpeed >= 60) && (vehicleCurrentSpeed < 80) && speedDiff <= 20 {
            timeInterval = 60
        }
        else if (vehicleCurrentSpeed >= 30) && (vehicleCurrentSpeed < 60) && speedDiff <= 20 {
            timeInterval = 120
        }
        else if (vehicleCurrentSpeed < 30) && (vehicleCurrentSpeed > 0) {
            timeInterval = 5
        }
        else if speedDiff > 20  && oldTimeInterval == 30{
            timeInterval = 60
        }
        else if speedDiff > 20  && oldTimeInterval == 60{
            timeInterval = 120
        }
        else if speedDiff > 20  && oldTimeInterval == 120{
            timeInterval = 300
        }
        
        
        if oldTimeInterval != timeInterval {
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                         target: self,
                                         selector: #selector(eachInterval(_:)),
                                         userInfo: nil,
                                         repeats: true)
        }
        
    }

    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func startLocationUpdates() {
        
        
        locationManager.startUpdatingLocation()
    }
    
    /**
     * @description: This location delegate method is called to update the location
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            
            let howRecent = location.timestamp.timeIntervalSinceNow
            //print("howRecent:\(howRecent)")
            
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {

                //update distance
                if self.locations.count > 0 {
                    distance += location.distance(from: self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    instantPace = location.distance(from: self.locations.last!)/(location.timestamp.timeIntervalSince(self.locations.last!.timestamp))

                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView2.setRegion(region, animated: true)
                    
                    mapView2.add(MKPolyline(coordinates: &coords, count: coords.count))
                    
                }
                
                //save location
                self.currentLocation = location
                self.locations.append(location)
                
                
                
            }
        }
        
    }
    
    func centerMapOnLocation(location: CLLocation, distance: CLLocationDistance) {
        let regionRadius = distance
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView2.setRegion(coordinateRegion, animated: true)
    }
    
    /**
     * @description Function is called to save the Run and Location
     */
    func saveRun() {
        // 1
        let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run",
                                                           into: managedObjectContext!) as! Run
        savedRun.distance = NSNumber(value: distance)
        savedRun.duration = (NSNumber(value: seconds))
        savedRun.timestamp = NSDate() as Date
        
        // 2
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObject(forEntityName: "Location",
                                                                    into: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = NSNumber(value: location.coordinate.latitude)
            savedLocation.longitude = NSNumber(value: location.coordinate.longitude)
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun

        do{
            try managedObjectContext!.save()
        }catch{
            print("Could not save the run!")
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }

}

