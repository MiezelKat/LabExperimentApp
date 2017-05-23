//
//  StudySessionManager.swift
//  WearTest
//
//  Created by Katrin Haensel on 20/04/2017.
//  Copyright © 2017 Katrin Haensel. All rights reserved.
//

import Foundation
import AWSenseConnectPhone
import MSBandSensorService
import PolarHRService
import SensorEvaluationShared
import WatchConnectivity

internal class StudySessionManager : MSBEventHandler, PolarEventHandler, RemoteSensingEventHandler {

    
    static let sharedInstance = StudySessionManager()
    
    private init(){
        awSessionManager.subscribe(handler: self)
    }
    
    private(set) var currentPID : String? = nil
    private(set) var currentSessionID : String? = nil
    
    private var directoryString : String {
        return "\(currentPID!)_\(currentSessionID!)"
    }
    
    private(set) var startDate : Date? = nil
    
    private(set) var running = false
    
    private let polarMsbDataStorage = DataStorage.sharedInstance
    private let awSessionManager = SessionManager.instance
    
    
    private var hrHandler : ((String, SensingDevice) -> ())?
    
    func setHrHandler(handler : @escaping (String, SensingDevice) -> ()){
        hrHandler = handler
    }
    
    
    internal func start(withPID pid : String){
        if(!running){
            running = true
            currentPID = pid
            
            let random = UUID().uuidString
            
            let index = random.index(random.startIndex, offsetBy: 5)
            
            currentSessionID = "\(random.substring(to: index))"
            print("Session ID: " + currentSessionID!)
            
            startDate = Date()
            
            // polar and msb
            
            MSBService.instance.subscribe(msbEventHandler: self)
            PolarHRService.instance.subcribeToHREvents(self)
            
            polarMsbDataStorage.startRecording(inDirectory: directoryString)
            
            // apple watch
            
            var enabledSensors : [AWSSensorType] = [.heart_rate, .accelerometer, .device_motion]
            
            let transmissionIntervall = DataTransmissionInterval(4)
            
            do {
                
                try awSessionManager.startSensingSession(withName: currentSessionID, configuration: enabledSensors,
                                                         sensorSettings: [RawAccelerometerSensorSettings(withIntervall_Hz: 50.0), DeviceMotionSensorSettings(withIntervall_Hz: 50.0), HeartRateSensorSettings()],
                                                         transmissionIntervall: transmissionIntervall,
                                                         writeToDir: directoryString)
            }catch let error as Error{
                print(error)
            }
        }
    }
    
    internal func stop(){
        if(running){
            // polar and msb
            
            polarMsbDataStorage.stopRecording()
            
            // apple watch
            
            do {
                try awSessionManager.stopSensing()
            }catch let error as Error{
                print(error)
            }
            
            currentPID = nil
            currentSessionID = nil
            startDate = nil
            
            running = false
        }
    }
    
    internal func placeMarker(){
        polarMsbDataStorage.appendMarkerTimestamp()
    }
    
    /**
     Handle a new MSB Event with the data
     
     - parameter event: event data
     */
    public func handleEvent(withData data: MSBEventData) {
        if(running){
            polarMsbDataStorage.append(data: data)
            if(data.sensorDataType == .hrChanged){
                hrHandler!(data.getOnePointPrint(),.msb)
            }
        }
    }
    
    /**
     Handle a new HR Event with the data
     
     - parameter event: event data
     */
    public func handleEvent(withData data: PolarEventData) {
        if(running){
            polarMsbDataStorage.append(data: data)
            if(data.sensorDataType == .hrChanged){
                hrHandler!("\(data.newValue!)",.polar)
            }
        }
    }
    
    public func handle(withType type: RemoteSensingEventType, forSession session: RemoteSensingSession?, withData data: [AWSSensorData]?) {
        if(type == .remoteSessionDataReceived){
            if(data!.count < 1){
                return
            }
            
            if(data![0].sensorType == .heart_rate){
                // todo
                print(data!.last!.prettyPrint)
                hrHandler!(data!.last!.prettyPrint, .aw)
            }
        }
    }
}

internal enum SensingDevice {
    case msb
    case polar
    case aw
}

