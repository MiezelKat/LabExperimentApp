//
//  ViewController.swift
//  AWSenseConnectTest
//
//  Created by Katrin Haensel on 22/02/2017.
//  Copyright © 2017 Katrin Haensel. All rights reserved.
//

import UIKit
import HealthKit
import CoreMotion

import AWSenseConnectPhone

import MSBandSensorService
import PolarHRService
import SensorEvaluationShared

class SessionViewController: UITableViewController   {

    @IBOutlet weak var pIDLabel: UILabel!

    @IBOutlet weak var sIDLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!

    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var awHRLabel: UILabel!
    
    @IBOutlet weak var msbHRLabel: UILabel!
    
    @IBOutlet weak var polarHRLabel: UILabel!
    
    private var startTime : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pIDLabel.text = StudySessionManager.sharedInstance.currentPID
        sIDLabel.text = StudySessionManager.sharedInstance.currentSessionID
        
        StudySessionManager.sharedInstance.setHrHandler(handler: handleHR)
        
        startTime = StudySessionManager.sharedInstance.startDate!
        startLabel.text = DateFormatter.localizedString(from: StudySessionManager.sharedInstance.startDate!, dateStyle: .none, timeStyle: .medium)
        
        // TODO: timer label
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {(t: Timer) -> () in
            let time = self.startTime!.timeIntervalSinceNow
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            formatter.maximumUnitCount = 1
            
            DispatchQueue.main.async {
                self.timerLabel.text = formatter.string(from: time)!
            }
        })
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopSessionPressed(_ sender: Any) {
        StudySessionManager.sharedInstance.stop()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func placeMarker(_ sender: Any) {
        StudySessionManager.sharedInstance.placeMarker()
    }
    
    public func handleEvent(withData data: PeriphalChangedEventData) {
        if(data.status != .isConnected){
            print("is not connected: \(data.source)")
        }
    }


    func handleHR( hr: String, sensor:  SensingDevice) -> (){
        if(sensor == .aw){
            DispatchQueue.main.async {
                self.awHRLabel.text = hr
            }
        }else if(sensor == .msb){
            DispatchQueue.main.async {
                self.msbHRLabel.text = hr
            }
        }else if(sensor == .polar){
            DispatchQueue.main.async {
                self.polarHRLabel.text = hr
            }
        }
    }
    
}

