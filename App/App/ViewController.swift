//
//  ViewController.swift
//  App
//
//  Created by Kyle Tan on 5/17/17.
//  Copyright © 2017 Kyle Tan. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController ,GMSMapViewDelegate,CLLocationManagerDelegate{

    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    var curLocation = CLLocationCoordinate2D()
    
    //start
    var count = 0
    var path_timer = Timer()
    var path = GMSMutablePath()
    var true_path = GMSMutablePath()
    var true_line = GMSPolyline()
    var line = GMSPolyline()
    //end
    
    
    let otherLocation = CLLocation(latitude: 39.448178953526, longitude: -122.13945301261) //Constant for now
    //let curLocation = CLLocation(latitude: 40.0, longitude: 2.34)
    let initial = true
    
    
    let maxDistance = 9000000.0
    var shapeLayer = CAShapeLayer()

    @IBOutlet weak var untrackButton: UIButton!
    @IBOutlet weak var distanceLabel: Dialogue_Label!
    @IBOutlet weak var trackButton: UIButton!
    
    @IBOutlet weak var headImageView: Head_Image!
    @IBOutlet weak var dialogue: UIImageView!
    
    //Actions
    @IBAction func untrack(_ sender: Any) {
        
        if(headImageView.isTimerRunning || distanceLabel.isTimerRunning)
        {
            return
        }
        
        curLocation = (self.locationManager.location?.coordinate)!
        let camera = GMSCameraPosition.camera(withLatitude: curLocation.latitude, longitude: curLocation.longitude, zoom: 8.0)
        mapView.animate(to: camera)
        
        dialogue.isHidden = true
        headImageView.unanimate()
        //headImageView.isHidden = true
        distanceLabel.isHidden = true
        line.map = nil
        true_line.map = nil
        true_path = GMSMutablePath()
        true_line = GMSPolyline()
        
    }
    
    @IBAction func track(_ sender: Any) {
        if(headImageView.isTimerRunning || distanceLabel.isTimerRunning)
        {
            return
        }
        
        //new path draw
        let userLocation = curLocation
        let kyleLocation = otherLocation.coordinate
        //let latitude_difference = abs(userLocation.latitude - kyleLocation.latitude)
        //let magnitude = sqrt( pow(userLocation.longitude - kyleLocation.longitude, 2.0) + pow(userLocation.latitude - kyleLocation.latitude, 2.0) )
        let vector = (kyleLocation.latitude - userLocation.latitude , kyleLocation.longitude - userLocation.longitude)
        
        //equations
        //let m = (userLocation.longitude - kyleLocation.longitude)/(userLocation.latitude - kyleLocation.latitude)
        path.add(userLocation)
        print(userLocation.longitude)
        print(userLocation.latitude)
        for index in 1...1000
        {
            let delta_x = (CLLocationDegrees(index)/CLLocationDegrees(1000))*vector.0
            let delta_y = (CLLocationDegrees(index)/CLLocationDegrees(1000))*vector.1
            let x = userLocation.latitude + delta_x
            let y = userLocation.longitude + delta_y
            path.add(CLLocationCoordinate2D(latitude: x, longitude: y))
        }
        path.add(kyleLocation)
        //equations end

        create_initial_path()

        
        let position = CLLocationCoordinate2D(latitude: otherLocation.coordinate.latitude, longitude: otherLocation.coordinate.longitude)
        let kyle = GMSMarker(position: position)
        kyle.title = "Kyle"
        kyle.icon = UIImage(named: "goal_face")
        kyle.map = mapView
        
        let meterDistance = locationManager.location?.distance(from: otherLocation);
        
        let latAverage = (userLocation.latitude + otherLocation.coordinate.latitude)/2
        let longAverage = (userLocation.longitude + otherLocation.coordinate.longitude)/2
        //let newPos = CLLocationCoordinate2DMake(latAverage,longAverage);

        /*var zoomRatio = 1.0
        if maxDistance > meterDistance!
        {
            zoomRatio = maxDistance/meterDistance!
            if(zoomRatio > 20.0)
            {
                zoomRatio = 20.0
            }
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: latAverage, longitude: longAverage, zoom: Float(zoomRatio), bearing: 90, viewingAngle: 0)
        mapView.animate(to: camera)*/
        
        var text = "Your distance to me is \(Int(meterDistance!)) meters!\n"
        text.append(parseDistanceText(distance: Int(meterDistance!)))
        distanceLabel.text = ""
        distanceLabel.numberOfLines = 4
        self.view.insertSubview(distanceLabel, aboveSubview: self.mapView)
        distanceLabel.animate(newText: text, characterDelay: 0.07)
        distanceLabel.isHidden = false
        
        self.view.insertSubview(headImageView, aboveSubview: self.mapView)
        headImageView.animate(repetitions: 1)
        //headImageView.isHidden = false
        //animate(repetitions: count/4)
        
        self.view.insertSubview(dialogue, aboveSubview: self.mapView)
        dialogue.isHidden = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter=kCLDistanceFilterNone;
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        //create initial screen
        //curLocation = (self.locationManager.location?.coordinate)!
        let camera = GMSCameraPosition.camera(withLatitude: 40, longitude: 40, zoom: 8.0)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        //view = mapView
        self.view.addSubview(mapView)
        
        //trackButton.removeFromSuperview()
        self.view.insertSubview(trackButton, aboveSubview: self.mapView)
        self.view.insertSubview(untrackButton, aboveSubview: self.mapView)
    }
    
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(initial)
        {
            let l = (self.locationManager.location?.coordinate)!
            curLocation = l
            let camera = GMSCameraPosition.camera(withLatitude: l.latitude, longitude: l.longitude, zoom: 8.0)
            mapView.animate(to: camera)
        }
        mapView.isMyLocationEnabled = true
        locationManager.stopUpdatingLocation()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func parseDistanceText(distance: Int) -> String
    {
        var s = ""
        
        if(distance > 200000)
        {
            s.append("Thats very far!")
        }
        else if(distance > 25000)
        {
            s.append("Wow  ")
        }
        else if(distance > 1000)
        {
            s.append("Wow  ")
        }
        else{
            s.append("Wow  ")
        }
        
        return s
    }
    
    
    func animate_path()
    {
        if (UInt(count) < path.count()) {
            true_path.add(self.path.coordinate(at: UInt(count)))
            self.true_line.path = self.true_path
            self.true_line.strokeColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
            self.true_line.strokeWidth = 3
            self.true_line.map = self.mapView
            self.count += 1
        }
        else {
            count = 0;
            self.path_timer.invalidate()
        }
    }
    
    func create_initial_path()
    {
        line = GMSPolyline(path: path)
        //line.map = mapView
        line.strokeColor = .blue
        line.strokeWidth = 7
        
        self.path_timer = Timer.scheduledTimer(timeInterval: 0.0003, target: self, selector: (#selector(ViewController.animate_path)), userInfo: nil, repeats: true)
    }
    



}

