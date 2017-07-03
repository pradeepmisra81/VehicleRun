//
//  DetailViewController.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 15/06/17.
//  Copyright © 2017 All rights reserved.
//

import UIKit
import MapKit
import HealthKit

class DetailViewController: UIViewController,MKMapViewDelegate {
    var run: Run?
    var mapOverlay: MKTileOverlay!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        
        //guard let run = presenter.run else { return }
        guard let run = run else { return }
        guard let runTimeStamp = run.timestamp else { return }
        guard let runDuration = run.duration else { return }
        guard let runDistance = run.distance else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = AppConstants.DateFormat
        dateLabel.text = dateFormatter.string(from: runTimeStamp)
        
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(runDuration.doubleValue))
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
        let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
        let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))
        timeLabel.text = "Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: runDistance.doubleValue)
        distanceLabel.text = "Distance: " + distanceQuantity.description
        
        paceLabel.text = "Mean speed: "+String((runDistance.doubleValue/runDistance.doubleValue*3.6*10).rounded()/10)+" km/h"
                
        loadMap()
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    func mapRegion() -> MKCoordinateRegion {
        
        guard let run = run else { return MKCoordinateRegion (
            center: CLLocationCoordinate2D(latitude: 0,
                                           longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0,
                                   longitudeDelta: 0)) }
        
        guard let runLocations = run.locations else { return MKCoordinateRegion (
            center: CLLocationCoordinate2D(latitude: 0,
                                           longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0,
                                   longitudeDelta: 0)) }
        
        let initialLoc = runLocations.firstObject as! Location
        
        var minLat = initialLoc.latitude.doubleValue
        var minLng = initialLoc.longitude.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = runLocations.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude.doubleValue)
            minLng = min(minLng, location.longitude.doubleValue)
            maxLat = max(maxLat, location.latitude.doubleValue)
            maxLng = max(maxLng, location.longitude.doubleValue)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                                           longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                                   longitudeDelta: (maxLng - minLng)*1.1))
    }


    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //print("hello")
        if overlay is MKTileOverlay{
            guard let tileOverlay = overlay as? MKTileOverlay else {
                return MKOverlayRenderer()
            }
            
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        }
        if overlay is MulticolorPolylineSegment {
            let polyline = overlay as! MulticolorPolylineSegment
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = polyline.color
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func polyline() -> MKPolyline {
        
        var coords = [CLLocationCoordinate2D]()
        
        guard let run = run else { return MKPolyline(coordinates: &coords, count: 0) }
        
        guard let runLocations = run.locations else {
            return MKPolyline(coordinates: &coords, count: 0)
        }
        
        let customLocations = runLocations.array as! [Location]
    
        for customLocation in customLocations {
            coords.append(CLLocationCoordinate2D(latitude: customLocation.latitude.doubleValue,
                                                 longitude: customLocation.longitude.doubleValue))
            
            print("Captured location saved in sqlite:")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = AppConstants.DateFormat
            print("Time:\(dateFormatter.string(from: customLocation.timestamp)), Latitude: \(customLocation.latitude.doubleValue), Longitude: \(customLocation.longitude.doubleValue), Current time interval(in seconds):\(customLocation.currenttimeinterval.doubleValue), Next time interval(in seconds) :\(customLocation.nexttimeinterval.doubleValue)")
        }
        
        return MKPolyline(coordinates: &coords, count: runLocations.count)
    }
    
    func loadMap() {
        
        guard let run = run else { return }
        
        guard let runLocations =  run.locations else { return }
        
        if runLocations.count > 0 {
            mapView.isHidden = false
            
            // Set the map bounds
            mapView.region = mapRegion()
            
            // Make the line(s!) on the map
            mapView.add(polyline())
        }else {
            // No locations were found!
            mapView.isHidden = true;
            let alertController = UIAlertController(title: "Error", message: "Sorry this run has no locations saved",preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
