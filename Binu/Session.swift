//
//  Session.swift
//  BinuProxy
//
//  Created by Xminds on 12/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
class Session{
    var GCMId:String = ""
    var GADId: String = ""
    var Ux:String = ""
    var mlocation = BinuLocation()
    var client =  Client()
    var mConnection = Connection()
    var device = Device()
    var startTime:Int = 0
    var mUtility = Utility()
    
    public init(){
        startTime = mUtility.getTime()
        print(startTime)
    }
   
    func getSessionToString()->String{
        self.mConnection.pollNetWork()
        var sessionStr:String = ""
        let dictionary = ["v": "2",
            "did": UIDevice.current.identifierForVendor?.uuidString as! String,
                          "aid":GADId,
                          "ux":Ux,
                          "c":mConnection.toString(),
                          "a":client.ToString(),
                          "d":device.toString(),
                          "l":mlocation.ToString(),
                          "mid":""
                         ]
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: []) {
               sessionStr = String(data: theJSONData,
                                   encoding: .ascii)!
        }
        return sessionStr
    }
}
