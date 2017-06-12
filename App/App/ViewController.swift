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
import Firebase
import FirebaseDatabase

class ViewController: UIViewController ,GMSMapViewDelegate,CLLocationManagerDelegate{

    //Location Variables
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    var curLocation = CLLocationCoordinate2D()
    var otherLocation = CLLocation(latitude: 39.448178953526, longitude: -122.13945301261) //Constant for now
    var initial = true
    var shapeLayer = CAShapeLayer()
    //End
    
    //Map path variables
    var count = 0
    var path_timer = Timer()
    var path = GMSMutablePath()
    var true_path = GMSMutablePath()
    var true_line = GMSPolyline()
    var line = GMSPolyline()
    //end
    
    //Animation Variables
    var meterDistance = 0
    var isTimerRunning = false
    var tracking = false
    //end
    
    //Option Variables
    let alert = UIAlertController(title: "WARNING", message: "Do you really want to be creepy by following me?", preferredStyle: UIAlertControllerStyle.alert)
    //end
    
    //database reference
    var ref: DatabaseReference!

    //Outlets
    @IBOutlet weak var untrackButton: UIButton!
    @IBOutlet weak var distanceLabel: Dialogue_Label!
    @IBOutlet weak var trackButton: UIButton!
    
    @IBOutlet weak var headImageView: Head_Image!
    @IBOutlet weak var dialogue: UIImageView!
    //Outlets End
    
    //Actions
    @IBAction func untrack(_ sender: Any) {
        
        if( (headImageView.isTimerRunning || distanceLabel.isTimerRunning || self.isTimerRunning) || !tracking )
        {
            return
        }
        
        curLocation = (self.locationManager.location?.coordinate)!
        let camera = GMSCameraPosition.camera(withLatitude: curLocation.latitude, longitude: curLocation.longitude, zoom: Constants.MapView.local_zoom)
        mapView.animate(to: camera)
        
        dialogue.isHidden = true
        headImageView.unanimate()
        distanceLabel.isHidden = true
        
        line.map = nil
        true_line.map = nil
        
        count = 0
        path_timer = Timer()
        path = GMSMutablePath()
        true_path = GMSMutablePath()
        true_line = GMSPolyline()
        line = GMSPolyline()
        
        tracking = false
    }
    
    @IBAction func track(_ sender: Any) {
        if( (headImageView.isTimerRunning || distanceLabel.isTimerRunning || self.isTimerRunning) || tracking )
        {
            return
        }
        //alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        let camera = GMSCameraPosition.camera(withLatitude: 40, longitude: 40, zoom: Constants.MapView.local_zoom)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        //view = mapView
        self.view.addSubview(mapView)
        
        //trackButton.removeFromSuperview()
        self.view.insertSubview(trackButton, aboveSubview: self.mapView)
        self.view.insertSubview(untrackButton, aboveSubview: self.mapView)
        
        //test firebase
        ref = Database.database().reference()
        
        //set other user and listen to other user
        let newRef = self.ref.child("kyle")
        newRef.observe(.value, with: { snapshot in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if(!postDict.isEmpty)
            {
                let lat = (postDict["lat"] as! NSNumber).floatValue
                let long = (postDict["long"] as! NSNumber).floatValue
                let location = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
                self.otherLocation = location
            }
        })
        
        alert.addAction(UIAlertAction(title: "Yaas, Track Anyways", style: .default, handler: { (void) in
            self.tracking = true
            self.record_path()
        }))
        alert.addAction(UIAlertAction(title: "Nah, Im not creepy",style: .cancel))
        
    }
    
    
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(initial)
        {
            let l = (self.locationManager.location?.coordinate)!
            curLocation = l
            let camera = GMSCameraPosition.camera(withLatitude: l.latitude, longitude: l.longitude, zoom: Constants.MapView.local_zoom)
            mapView.animate(to: camera)
        }
        mapView.isMyLocationEnabled = true
        locationManager.stopUpdatingLocation()
        
        //update MY info (Default Kyle for now)
        let newRef = self.ref.child("fah")
        newRef.setValue(["lat":curLocation.latitude,"long": curLocation.longitude])

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func parseDistanceText(distance: Int) -> String //Fill in with more words later
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
    
    
    let color_array = [#colorLiteral(red: 0.9784535766, green: 0.6787097454, blue: 0.7884691358, alpha: 1),#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1),#colorLiteral(red: 0.1152106896, green: 0.3501339257, blue: 0.503962636, alpha: 1),#colorLiteral(red: 0.2659465969, green: 0.7377687097, blue: 0.9586290717, alpha: 1),#colorLiteral(red: 0.3718120456, green: 0.7847277522, blue: 1, alpha: 1)]
    
    func animate_path()
    {
        if (UInt(count) < path.count()) {
            isTimerRunning = true
            let c = self.path.coordinate(at: UInt(count))
            true_path.add(c)
            self.true_line.path = self.true_path
            self.true_line.strokeColor = color_array[(count % 100)/20]
            self.true_line.strokeWidth = 7
            self.true_line.map = self.mapView
            self.count += 1
            
            //Camera
            let camera = GMSCameraPosition.camera(withLatitude: c.latitude, longitude: c.longitude, zoom: Constants.MapView.local_zoom, bearing: 90, viewingAngle: 0)
            mapView.animate(to: camera)
            
        }
        else {
            count = 0;
            self.path_timer.invalidate()
            goal_animation()
            isTimerRunning = false
        }
    }
    
    func create_initial_path()
    {
        line = GMSPolyline(path: path)
        //line.map = mapView
        line.strokeColor = .blue
        line.strokeWidth = 15
        
        self.path_timer = Timer.scheduledTimer(timeInterval: Constants.MapView.path_animation_tdelta, target: self, selector: (#selector(ViewController.animate_path)), userInfo: nil, repeats: true)
    }
    
    func goal_animation()
    {
        let position = CLLocationCoordinate2D(latitude: otherLocation.coordinate.latitude, longitude: otherLocation.coordinate.longitude)
        let kyle = GMSMarker(position: position)
        kyle.title = "Kyle"
        kyle.icon = UIImage(named: "goal_face")
        kyle.map = mapView
        
        var text = "Your distance to me is \(meterDistance) meters!\n"
        text.append(parseDistanceText(distance: meterDistance))
        distanceLabel.text = ""
        distanceLabel.numberOfLines = 4
        self.view.insertSubview(distanceLabel, aboveSubview: self.mapView)
        distanceLabel.animate(newText: text, characterDelay: 0.07)
        distanceLabel.isHidden = false
        
        self.view.insertSubview(headImageView, aboveSubview: self.mapView)
        headImageView.animate(repetitions: 1)
        
        self.view.insertSubview(dialogue, aboveSubview: self.mapView)
        dialogue.isHidden = false
    }
    
    func record_path()
    {
        //new path draw
        let userLocation = curLocation
        let kyleLocation = otherLocation.coordinate
        let vector = (kyleLocation.latitude - userLocation.latitude , kyleLocation.longitude - userLocation.longitude)
        self.meterDistance = Int((locationManager.location?.distance(from: otherLocation))!);
        
        let intervals = self.meterDistance/100
        //equations
        path.add(userLocation)
        for index in 1...intervals
        {
            let delta_x = (CLLocationDegrees(index)/CLLocationDegrees(intervals))*vector.0
            let delta_y = (CLLocationDegrees(index)/CLLocationDegrees(intervals))*vector.1
            let x = userLocation.latitude + delta_x
            let y = userLocation.longitude + delta_y
            path.add(CLLocationCoordinate2D(latitude: x, longitude: y))
        }
        path.add(kyleLocation)
        //equations end
        
        create_initial_path()
    }
    



}

