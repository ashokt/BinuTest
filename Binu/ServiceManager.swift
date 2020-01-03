//
//  ServiceManager.swift
//  Binu
//
//  Created by Xminds on 11/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
import Alamofire
import Network
class ServiceManager:NSObject{
    
    static let shared = ServiceManager()
    var mSession = Session()
    private var isInitialised:Bool = false
    var Client_Net_Status:String?
    var mDataFreeHni:[Set<String>] = []
    var mUsage = Usage()
    var binuTracker:BinuTracker? = nil
    fileprivate let carrier = Carrier()
    var mToken:String = ""
    var BinuNetStatus = "UNKNOWN"
    var BinuFreeStaus = "UNKNOWN"
    var isBinuNetworkChanged:Bool = false
    var isBinuStatusChanged:Bool = false
    var APP_NET_CHANGE_SENT:Bool = false
    var mSettings = ProxySettings()
    var mBinuAppId = Int()
    var currentDeploymentURLS = NSDictionary()
    var mUtility = Utility()
    
    public override init(){
        super.init()
        carrier.delegate = self
        Client_Net_Status = "UNKNOWN"
        NetStatus.shared.netStatusChangeHandler = {
            
            if(NetStatus.shared.interfaceType == NWInterface.InterfaceType.wifi){
                self.mSession.mConnection.mType = "WIFI"
            }else if(NetStatus.shared.interfaceType == NWInterface.InterfaceType.cellular){
                self.mSession.mConnection.mType = "CELLULAR"
            }else {
                self.mSession.mConnection.mType = "UNKNOWN"
            }
            if(self.mSession.mConnection.mType != self.BinuNetStatus){
                self.isBinuNetworkChanged = true
                self.BinuNetStatus = self.mSession.mConnection.mType
                print("ON Binu network changed first")
            }
            DispatchQueue.main.async { [unowned self] in
                if(self.isBinuStatusChanged){
                    self.isBinuStatusChanged = false
                    Binu.onFreeStatusChanged?(self.BinuFreeStaus)
                    print("On Binu free status changed")
                }
                if(self.isBinuNetworkChanged){
                    self.isBinuNetworkChanged = false
                    if(self.isInitialised){
                        print("On Binu Network changed")
                        if(self.mDataFreeHni.count>0){
                            self.setClientStatus()
                        }
                        Binu.onConnectivityChange?(self.BinuNetStatus)
                        
                    }else{
                        self.lifeCycle(event: "ON_START")
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishLaunching), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminateNotication), name: UIApplication.willTerminateNotification, object: nil)
        
    }
    
    public func getSession()->String{
        return mSession.getSessionToString()
    }
    
    public func getSettings()->ProxySettings{
        return mSettings
    }
    @objc func didFinishLaunching(){
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum);
    }
    @objc func didEnterBackGround(){
        debugPrint("didEnterBackGround")
        self.lifeCycle(event: "PAUSE")
    }
    
    @objc func willTerminateNotication(){
        debugPrint("willTerminateNotification")
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum);
        self.lifeCycle(event: "DESTROY")
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // fetch data from internet now
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("endBackgroundTask called by iOS"), object: nil)
        print("Background fetching")
        self.lifeCycle(event: "DESTROY")
    }
    
    func lifeCycle(event:String){
        if(event == "ON_START"){
             sendBinuInitalizeData()
            var usageActivity = self.mUsage.mUsageActivity.object(at: (self.mUsage.mUsageActivity.count)-1) as! UsageActivity
            if (usageActivity != nil) {
                usageActivity.mStartTime = self.mUtility.getTime();
                if (!usageActivity.mOnline){
                    usageActivity.mOnline = (Client_Net_Status != "OFFLINE");
                }
                
            }
        }else if(event == "PAUSE"){
             onNavigate(url: "", title: "")
            
        }else if(event == "DESTROY"){
            let binuProxy = BinuProxy()
            print("destroy")
            let url = self.currentDeploymentURLS.object(forKey: "proxyUrl") as! String
            binuProxy.request(url:url+"/client",method:.post,requestBody:self.mUtility.stringToJson(jsonString: mUsage.ToString())).response{ response in
                print(response)
                if(response.error == nil){
                    print("Destroy succefull")
                }else{
                    print("Destroy not succefull")
                }
            }
        }
    }

    func sendBinuInitalizeData(){
        if(NetStatus.shared.isConnected){
            var setArry :[Set<String>] = []
            let binuProxy = BinuProxy()
            let url = self.currentDeploymentURLS.object(forKey: "proxyUrl") as! String
            binuProxy.request(url:url+"/config", method:.get, requestBody:nil).response{
                response in
                if(response.error == nil){
                    if(response.response!.statusCode == 500){
                        Binu.onBinuInitializeResponse!("Binu Initialize Failed")
                    }else{
                        self.isInitialised = true
                        print("data body = ", String(data: response.data!, encoding: String.Encoding.utf8.self) as Any)
                        
                        let responseResult = String(data: response.data!, encoding: String.Encoding.utf8.self)
                        
                        let responseDictionary = self.mUtility.stringToJson(jsonString: responseResult!)
                        let responseDataHni = responseDictionary.object(forKey: "datafree")
                        for anItem in responseDataHni as! NSArray{
                            var setData:Set<String> = []
                            for item in anItem as! NSArray{
                                setData.insert(item as! String)
                            }
                            setArry.append(setData)
                        }
                        if(self.mDataFreeHni.count > 0){
                            self.mDataFreeHni.removeAll()
                        }
                        self.mDataFreeHni = setArry
                        if(self.mDataFreeHni.count>0){
                            self.setClientStatus()
                        }
                        Binu.onBinuInitializeResponse!("Binu Initialize Successfully")
                    }
                }else{
                    Binu.onBinuInitializeResponse!("Binu Initialize Failed")
                    
                }
            }
        }
    }
   
    func setClientStatus(){
        var netStatus = String()
        
        if(NetStatus.shared.isConnected){
            print("Checking netstatus : \(mSession.mConnection.mType)")
            if(mSession.mConnection.mType == "WIFI"){
                netStatus = "WIFI"
            }else{
                netStatus = "ONLINE"
            }
            if (netStatus == "WIFI"){
                self.BinuFreeStaus = "WIFI"
            }else if(mSession.mConnection.mHni == "" || self.mDataFreeHni.count < 1){
                self.BinuFreeStaus = "UNKNOWN"
            }else if (checkMDataFreeHni()){
                self.BinuFreeStaus = "FREE"
            }else{
                self.BinuFreeStaus = "PAID"
            }
        }else{
            self.BinuNetStatus = "OFFLINE"
            self.BinuFreeStaus = "UNKNOWN"
        }
        debugPrint("netstatus :\(self.BinuNetStatus), freestatus:\(self.BinuFreeStaus) ")
    }
    func checkMDataFreeHni()->Bool{
        for setDataFreeHni in self.mDataFreeHni{
            if setDataFreeHni.contains(mSession.mConnection.mHni){
                return true
            }
        }
        return false
    }
    
    func setNetStatus(status:String){
        if(status != self.BinuNetStatus){
            self.BinuNetStatus = status
            self.isBinuStatusChanged = true
            NetStatus.shared.netStatusChangeHandler?()
        }
    }
    
    func setFreeStatus(freeStatus:String){
        if(freeStatus != self.BinuFreeStaus){
            self.BinuFreeStaus = freeStatus
            self.isBinuStatusChanged = true
            NetStatus.shared.netStatusChangeHandler?()
        }
    }

    public func onNavigate(url:String,title:String){
        print("onNavigate")
        let timeNow = self.mUtility.getTime()
        var usageActivity = mUsage.mUsageActivity.object(at: mUsage.mUsageActivity.count-1) as! UsageActivity
        mUsage.mNavigations = mUsage.mNavigations+1
        if(url == ""){
            usageActivity.mUrls.add(url)
        }
        binuTracker = BinuTracker()
        binuTracker!.enable(settings: self.mSettings, type: 2, id: url, trackNavigation: true)
        binuTracker?.track(type:TrackType.View , siteUrl: url, title: title)
        print(timeNow - usageActivity.mStartTime)
        if(mSession != nil && (timeNow - usageActivity.mStartTime >= ProxySettings.mLogInterval)){
            usageActivity.mEndTime = timeNow
            if(mSession.mConnection != nil && NetStatus.shared.isConnected){
                let mUsageData = mUsage.dbHelper.getAllUsage(isDelete: true)
                for usage in mUsageData as! [String]{
                    let dict = self.mUtility.stringToJson(jsonString: usage)
                    let mutableDict = NSMutableDictionary(dictionary: dict)
                    mutableDict.removeObject(forKey: "time")
                    mutableDict.setValue(self.mUtility.getTime(), forKey: "time")
                    postUsageData(data: mutableDict)
                }
                 postUsageData(data: self.mUtility.stringToJson(jsonString: mUsage.ToString()))
            }else{
                usageActivity.mDeferred = true
                mUsage.dbHelper.insertData(data: mUsage.ToString())
                mUsage.reset(startTime: timeNow, endTime: timeNow, online: false, deferred: false)
            }
        }
    }
    
    
    func postUsageData(data:NSDictionary) {
        print("post data started")
        print(data as! Parameters)
        let binuProxy = BinuProxy()
        let url = self.currentDeploymentURLS.object(forKey: "proxyUrl") as! String
        binuProxy.request(url:url+"/usage",method:.post,requestBody:(data as! Parameters as NSDictionary)).response{ response in
            if(response.error == nil){
                print("post data succefull")
            }else{
                if(response.response?.statusCode == 500){
                    print("post status code 500")
                    var usageActivity = self.mUsage.mUsageActivity.object(at: self.mUsage.mUsageActivity.count-1) as! UsageActivity
                    usageActivity.mDeferred = true
                    self.mUsage.mUsageActivity.removeObject(at: self.mUsage.mUsageActivity.count-1)
                    self.mUsage.mUsageActivity.add(usageActivity)
                    let jsonString = self.mUsage.json(from: data)
                    self.mUsage.dbHelper.insertData(data: jsonString!)
                }else{
                    print("post status code not 500")
                    var usageActivity = self.mUsage.mUsageActivity.object(at: self.mUsage.mUsageActivity.count-1) as! UsageActivity
                    usageActivity.mDeferred = true
                    self.mUsage.mUsageActivity.removeObject(at: (self.mUsage.mUsageActivity.count)-1)
                    self.mUsage.mUsageActivity.add(usageActivity)
                    let jsonString = self.mUsage.json(from: data)
                    self.mUsage.dbHelper.insertData(data: jsonString!)
                }
            }
        }
    }
}
extension ServiceManager:CarrierDelegate{
    public func carrierRadioAccessTechnologyDidChange() {
        
    }
}

