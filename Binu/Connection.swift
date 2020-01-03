//
//  Connection.swift
//  BinuProxy
//
//  Created by Xminds on 13/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
import CoreTelephony
import Network
class Connection{
    public static let simId:Int = -1
    var mNetwork = String()
    var mSim = String()
    var mType = String()
    var mNetInfo = CTTelephonyNetworkInfo()
    var mHni = String()
    var mSimHni = String()
    var mIsoCountry = String()
    var mIsRoaming = Int()
    var mSimCount = Int()
    var mBinuAppId = Int()
    init(){
        
    }
    func toString()->String{
        #if targetEnvironment(simulator)
         return "[\"\",\"\" ,\"WIFI\",\"\" ,\"\" , 0, 1]"
        #else
        return String(format: "[%@, %@, %@, %@, %@, %d, %d]",mNetwork,mSim,mHni,mSimHni,mIsRoaming,mSimCount)
        #endif
    }
    func pollNetWork(){
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        print(carrier?.carrierName ?? "")
        self.mNetwork = (carrier?.carrierName) ?? ""
        self.mSim = (carrier?.carrierName)  ?? ""
        self.mHni = (carrier?.carrierName) ?? ""
        self.mIsoCountry = (carrier?.isoCountryCode) ?? ""
        self.mIsRoaming = self.isRoaming() ? 1:0
        if(NetStatus.shared.interfaceType == NWInterface.InterfaceType.wifi){
            self.mType = "WIFI"
            ServiceManager.shared.BinuNetStatus = "WIFI"
        }else{
            self.mType = "CELLULAR"
            ServiceManager.shared.BinuNetStatus = "CELLULAR"
        }
    }
    
    func isRoaming()->Bool{
        let carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
        let operatorPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.operator.plist"

        let fm = FileManager.default
        let carrierPlistPath = try? fm.destinationOfSymbolicLink(atPath:carrierPListSymLinkPath)
        let operatorPListPath = try? fm.destinationOfSymbolicLink(atPath:operatorPListSymLinkPath)
        if(operatorPListPath == carrierPListSymLinkPath){
            return true
        }else{
            return false
        }
    }
}
