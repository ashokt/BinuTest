//
//  Usage.swift
//  BinuProxy
//
//  Created by Xminds on 13/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
class Usage{
    private static let PREF_KEY_NAV_COUNT:String  = "nav_count";
    
    var mStartTime:Int = 0
    var mDataTestResult:Bool = false
    var mNavigations:Int = 0
    var mUsageActivity:NSMutableArray = []
    var dbHelper = DBHelper()
    var mUtility = Utility()
    private var mDeviceId:String?
    
    init(){
      
        mStartTime = mUtility.getTime()
        mDeviceId = UIDevice.current.identifierForVendor?.uuidString as!  String
        var usageActivity = UsageActivity()
        usageActivity.mStartTime = mStartTime
        usageActivity.mEndTime = mStartTime
        usageActivity.mOnline = true
        usageActivity.mDeferred = false
        mUsageActivity.add(usageActivity)
        let kUserDefaults = UserDefaults.standard
        mNavigations = kUserDefaults.integer(forKey: Usage.PREF_KEY_NAV_COUNT)
    }
    
    func reset(startTime:Int, endTime:Int, online:Bool, deferred:Bool){
        for usageActivity in mUsageActivity as! [UsageActivity]{
            usageActivity.mUrls.removeAllObjects()
        }
        mUsageActivity.removeAllObjects()
        
        var usageActivity = UsageActivity()
        usageActivity.setUsageActivity(startTime: startTime, endTime: endTime, online: online, deferred: deferred)
        mUsageActivity.add(usageActivity)
        let kUserDefault = UserDefaults.standard
        kUserDefault.set(mNavigations, forKey: "nav_count")
        kUserDefault.synchronize()
    }
    
    func ToString()->String{
        var arrayUA = NSMutableArray()
        
        for n in 1...mUsageActivity.count {
            let obj = mUsageActivity.object(at:n-1) as! UsageActivity
            arrayUA.add(obj.toString())
        }
        
        let jsonDict:[String:Any] = ["v":"2",
                        "did":mDeviceId,
                        "appId":"\(ServiceManager.shared.mBinuAppId)",
                        "time": ServiceManager.shared.mUtility.getTime(),
            "focusStart":mStartTime,
            "a":json(from: arrayUA)! as Any,
            "mDataResult":"false"
                        ]
        
                return json(from: jsonDict)!
    }
    public func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}
