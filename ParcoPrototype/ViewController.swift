//
//  ViewController.swift
//  ParcoPrototype
//
//  Created by Felix Milea-Ciobanu on 1/2/16.
//  Copyright © 2016 Felix Milea-Ciobanu. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var locErrLabel: UILabel!
    @IBOutlet weak var pingBtn: UIButton!
    @IBOutlet weak var dataView: UITextView!
    @IBOutlet weak var outputView: UITextView!
    
    
    let SERVER_URL = "http://parco.felixmilea.com/location"
//    let SERVER_URL = "http://127.0.0.1:1225/location"
    
    let uuid = NSUUID().UUIDString
    let locationManager = CLLocationManager()
    var lastLocation: CLLocationCoordinate2D? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("INIT APP WITH SESSION ID:", uuid)
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        print("IS LOCATION ENABLED: ", CLLocationManager.locationServicesEnabled())
        
        if CLLocationManager.locationServicesEnabled() {
            hideLocErr()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            showLocErr()
        }
        
    }
    
    
    func showLocErr() {
        locErrLabel.hidden = false
        pingBtn.hidden = true
    }

    func hideLocErr() {
        locErrLabel.hidden = true
        pingBtn.hidden = false
    }
    
    func getData() throws -> NSData {
        let json = [ "uuid": uuid, "lat": lastLocation!.latitude, "long": lastLocation!.longitude ]
        return try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = manager.location!.coordinate
        print("LOCATION -> \(lastLocation!.latitude) \(lastLocation!.longitude)")
        
        do {
            let json = try getData()
            dataView.text = String(data: json, encoding: NSUTF8StringEncoding)
        } catch {
            print("JSON ERROR -> ", error)
        }
    }
    
    
    func sendServerData() {
        if lastLocation == nil {
            showLocErr()
            return
        } else {
            hideLocErr()
        }
        
        do {
            let jsonData = try getData()
            
            // create post request
            let url = NSURL(string: SERVER_URL)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil {
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.outputView.text = String(data: data!, encoding: NSUTF8StringEncoding)
                    }

                    

                    print("Result -> \(data)")
                    
                } catch {
                    print("Error -> \(error)")
                }
            }
            
            task.resume()
//            return task
            
            
            
        } catch {
            print("HTTP ERROR -> ", error)
        }
    }
    
    
    @IBAction func buttonPressed(sender: AnyObject) {
        print("BUTTON CLICKED")
        sendServerData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

