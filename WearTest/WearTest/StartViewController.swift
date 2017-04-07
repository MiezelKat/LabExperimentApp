//
//  ViewController.swift
//  WearTest
//
//  Created by Katrin Haensel on 04/04/2017.
//  Copyright © 2017 Katrin Haensel. All rights reserved.
//

import UIKit
import MSBandSensorService
import PolarHRService
import SensorEvaluationShared
import WatchConnectivity


class StartViewController: UITableViewController, PeriphalEventHandler, MSBEventHandler, PolarEventHandler, WCSessionDelegate {
    
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        awAvailable = session.isPaired
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        awAvailable = session.isPaired
    }

    
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        awAvailable = session.isPaired
    }


    @IBOutlet weak var awStatusLabel: UILabel!
    
    @IBOutlet weak var msbStatusLabel: UILabel!
    
    @IBOutlet weak var polarStatusLabel: UILabel!
    
    @IBOutlet weak var pIDTextField: UITextField!
    
    @IBOutlet weak var startButton: UIButton!
    
    private var msbAvailable = false
    private var polarAvailable = false
    private var awAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // check sensor sensor status
        MSBService.instance.subscribe(msbEventHandler: self)
        MSBService.instance.subscribe(periphalEventHandler: self)
        
        PolarHRService.instance.subcribeToHREvents(self)
        PolarHRService.instance.subcribeToPeriphalEvents(self)
        
        if WCSession.isSupported() { // check if the device support to handle an Apple Watch
            let session = WCSession.default()
            session.delegate = self
            session.activate() // activate the session
            
            awAvailable = session.isPaired
        }
        
    }

    public func handleEvent(withData data: PeriphalChangedEventData) {
        if(data.source == .microsoftBand){
            msbStatusLabel.text = data.status.rawValue
            if(data.status == .isConnected){
                msbAvailable = true
            }else{
                msbAvailable = false
            }
        }else if(data.source == .polarStrap){
            polarStatusLabel.text = data.status.rawValue
            if(data.status == .isConnected){
                polarAvailable = true
            }else{
                polarAvailable = false
            }
        }
    }
    
    private func checkAndEnableStart(){
        startButton.isEnabled = awAvailable && polarAvailable && msbAvailable

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startSessionButtonPressed(_ sender: Any) {
        
        
        
    }

    /**
     Handle a new MSB Event with the data
     
     - parameter event: event data
     */
    public func handleEvent(withData data: MSBEventData) {
        
    }
    
    /**
     Handle a new HR Event with the data
     
     - parameter event: event data
     */
    public func handleEvent(withData data: PolarEventData) {
        
    }
}

