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
    
    // MARK: properties
    
    var managedObjectContext: NSManagedObjectContext?
    var presenter: VehicleRunPresenter?
    var run: Run?
    var seconds = 0.0
    var distance = 0.0
    var instantPace = 0.0
    var currentLocation:CLLocation?
    
    var currentTimeInterval = 0.0
    var nextTimeInterval = 0.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var customLocations = [CustomLocation]()
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    var mapOverlay: MKTileOverlay!
    var vehicleCurrentSpeed = 0.0
    var vehiclePastSpeed = 0.0
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView2: MKMapView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    // MARK: View Lifecycle Functions
    convenience required init(_ aDecoder: NSCoder) {
        self.init(aDecoder)
    }

    /**
     * @description: Called when the view is going to appear.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView2.delegate = self;
        // calculate the time interval for the location update
        guard let managedObjectContext = self.managedObjectContext else {
            return
        }
        presenter = VehicleRunPresenter(managedObjectContext)
        
        mapView2.showsUserLocation = true
    }

    /**
     * @description: Function is called when the view is going to appear.
     * @params: animated Bool type
     * - animated: Whether or not the view should animate.
     */
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
   
    /**
     * @description: Function is called when the view is appeared.
     * @params: animated Bool type
     * - animated: Whether or not the view should animate.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView2.userLocation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView2.setRegion(coordinateRegion, animated: true)
    }
    
    /**
     * @description: Function is called to prepare for segue and sender
     * @params: segue: UIStoryboardSegue and sender: Any
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailViewController {
            //let presenter = VehicleRunPresenter()
            detailViewController.run = run
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    
    // MARK: IBActions
    
    /**
     * @description: Function is called on tap the start button to capture the vehicle location,speed etc
     * @params: sender of AnyObject type
     */
    @IBAction func startPressed(_ sender: AnyObject) {
        guard let presenter = presenter else {
            // Error
            print("Error: presenter is not initialised")
            return
        }
        
        startButton.isHidden = true
        promptLabel.isHidden = true
        timeLabel.isHidden = false
        distanceLabel.isHidden = false
        paceLabel.isHidden = false
        locationLabel.isHidden = false
        stopButton.isHidden = false
        mapView2.isHidden = false
        
        seconds = 0.0
        currentTimeInterval = 0.0
        distance = 0.0
        instantPace = 0.0
        vehicleCurrentSpeed = 0.0
        vehiclePastSpeed = 0.0
        locations.removeAll(keepingCapacity: false)
        presenter.customLocations.removeAll(keepingCapacity: false)
        
        
        timeLabel.text = "Time: 0"
        distanceLabel.text = "Distance: 0"
        paceLabel.text = "Current speed: 0 km/h"//"Pace:
        locationLabel.text = "Current lat:   long: "
        
        timer = Timer.scheduledTimer(timeInterval: currentTimeInterval,
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
    
    // MARK: Member Functions
    
    /**
     * @description: Function is called on each time interval which is based on the vehicle current speed
     */
    func eachInterval(_ timer: Timer) {
        
        seconds += currentTimeInterval
        
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
        let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
        let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))
        
        
        timeLabel.text = "Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        
        distanceLabel.text = "Distance: " + distanceQuantity.description
        
        paceLabel.text = "Current speed: "+String((instantPace*3.6*10).rounded()/10)+" km/h"
        
        vehicleCurrentSpeed = (instantPace*3.6*10).rounded()/10
        
        vehiclePastSpeed = vehicleCurrentSpeed
        
        guard let presenter = presenter else {
            // Error
            print("Error: presenter is not initialised")
            return
        }
        nextTimeInterval = presenter.calculateNextTimeInterval(vehicleCurrentSpeed, pastSpeed: vehiclePastSpeed, currentTimeInterval: currentTimeInterval)
        
        
        guard let loc = self.currentLocation else { return }
        
        var currentlocationMessage = "Location: "
        let lat = loc.coordinate.latitude
        let long = loc.coordinate.longitude
        currentlocationMessage = currentlocationMessage + "lat: \(String(describing: lat))   long:\(String(describing: long))"
        
        guard let timeStamp = self.currentLocation?.timestamp else { return }

        let customLocation = CustomLocation(timestamp: timeStamp, latitude:lat, longitude: long, currenttimeinterval: currentTimeInterval, nexttimeinterval: nextTimeInterval)
        
        presenter.customLocations.append(customLocation)
        locationLabel.text = currentlocationMessage
        
        if currentTimeInterval != nextTimeInterval {
            timer.invalidate()
            Timer.scheduledTimer(timeInterval: nextTimeInterval,
                                         target: self,
                                         selector: #selector(eachInterval(_:)),
                                         userInfo: nil,
                                         repeats: true)
        }
        
        currentTimeInterval = nextTimeInterval
        
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func startLocationUpdates() {
        
        locationManager.startUpdatingLocation()
    }
    
    /**
     * @description Function is called to save the Run and Location
     */
    func saveRun() {
        
        guard let presenter = presenter else {
            // Error
            print("Error: presenter is not initialised")
            abort()
        }
        run = presenter.saveRun()
 
        
        /*
        // Save Run
        let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run",
                                                           into: managedObjectContext!) as! Run
        savedRun.distance = NSNumber(value: distance)
        savedRun.duration = (NSNumber(value: seconds))
        savedRun.timestamp = NSDate() as Date
        
        // Save Location
        var savedLocations = [Location]()
        for customLocation in customLocations {
            let savedLocation = NSEntityDescription.insertNewObject(forEntityName: "Location",
                                                                    into: managedObjectContext!) as! Location
            guard let timeStamp = customLocation.timestamp else { return }
            guard let latValue = customLocation.latitude else { return }
            guard let longValue = customLocation.longitude else { return }
            guard let currentTimeInterval = customLocation.currenttimeinterval else { return }
            guard let nextTimeInterval = customLocation.nexttimeinterval else { return }
            savedLocation.timestamp = timeStamp
            savedLocation.latitude = NSNumber(value: latValue)
            savedLocation.longitude = NSNumber(value: longValue)
            savedLocation.currenttimeinterval = NSNumber(value: currentTimeInterval)
            savedLocation.nexttimeinterval = NSNumber(value: nextTimeInterval)
            
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        //Save Location and Run details in Core Data using managedObjectContext
        do{
            try managedObjectContext!.save()
        }catch{
            print("Could not save the run!")
        }
 */
 
    }
    
    // MARK: delegates
    
    /**
     * @description: This location delegate method is called to update the location
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            
            //print("locations.count111:\(locations.count)")
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
                //print("locations.count222:\(locations.count)")
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

