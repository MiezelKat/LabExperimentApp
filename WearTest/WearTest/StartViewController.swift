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


class StartViewController: UITableViewController, PeriphalEventHandler, WCSessionDelegate {
    
    
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
    // todo
    private var awAvailable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // check sensor sensor status
        
        PolarHRService.instance.subcribeToPeriphalEvents(self)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {(t: Timer) -> () in
            PolarHRService.instance.connect()
        })
    
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
            MSBService.instance.subscribe(periphalEventHandler: self)
            MSBService.instance.connect()
            
            polarStatusLabel.text = data.status.rawValue
            if(data.status == .isConnected){
                polarAvailable = true
            }else{
                polarAvailable = false
            }
        }
        checkAndEnableStart()
    }
    
    private func checkAndEnableStart(){
        DispatchQueue.main.async {
            let available = self.awAvailable && self.polarAvailable && self.msbAvailable
            print("all sensors available: \(available)")
            self.startButton.isEnabled = available
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startSessionButtonPressed(_ sender: Any) {
        let pID = pIDTextField.text!
        
        
        StudySessionManager.sharedInstance.start(withPID: pID)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "sessionVC")
        self.present(controller, animated: true, completion: nil)
        
    }


}

