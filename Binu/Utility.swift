//
//  Utility.swift
//  BinuProxy
//
//  Created by xminds on 25/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
class Utility{
  
   public func getTime()->Int{
       let someNSDate = NSDate()
       let timeInterval = someNSDate.timeIntervalSince1970
       let timeNow = Int(timeInterval)
       return timeNow
   }
 
    func convertUInt64(inputString:String)->UInt64{
        let scanner = Scanner(string: inputString)
        var value: UInt64 = 0
       
        if scanner.scanHexInt64(&value) {
            print("Decimal: \(value)")
        }
        
        return value
    }
    
    func convertToDecimal(settingsFlag:String)-> UInt64{
        let scanner = Scanner(string:settingsFlag)
        var valueInt64: UInt64 = 0
        if scanner.scanHexInt64(&valueInt64) {
            print("Decimal: \(valueInt64)")
            print("Hex: 0x\(String(valueInt64, radix: 16))")
        }
        return valueInt64
    }
    
    func compareToStrings(responseflag:String,settingsFlag:String)->Bool{
        let scanner = Scanner(string: responseflag)
        var valueBinu: UInt64 = 0
        let scannerSettings = Scanner(string:settingsFlag)
        var valueBinuSettings: UInt64 = 0
        if scanner.scanHexInt64(&valueBinu) {
            print("Decimal: \(valueBinu)")
            print("Hex: 0x\(String(valueBinu, radix: 16))")
        }
        if(scannerSettings.scanHexInt64(&valueBinuSettings)){
            
            print("Decimal: \(valueBinuSettings)")
            print("Hex: 0x\(String(valueBinuSettings, radix: 16))")
        }
        if((valueBinu & valueBinuSettings) == valueBinuSettings){
            return true
        }else{
            return false
        }
    }
    
    func stringToJson(jsonString:String)->NSDictionary{
        
        let jsondata = jsonString.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: jsondata, options : .allowFragments) as? NSDictionary
            {
                return jsonArray
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        return [:]
        
    }
}

