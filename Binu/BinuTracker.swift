//
//  BinuTracker.swift
//  BinuProxy
//
//  Created by Arun on 11/14/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
import MatomoTracker
import Alamofire
public enum TrackType: String {
       case View
       case EVENT
       case AB_TESTING
       case UNKNOWN
   }
public class BinuTracker{
    
    private static let BINU_TOKEN:String = "BINUANL"
    public static let PIWIK_TRACKING:Int  = 1
    public  let GOOGLE_TRACKING:Int = 2
    private var mTrackingTypeEnabled = 0
    let mTrackNavigation:Bool = false
   
    var tracker:MatomoTracker? = nil
    var  mGoogleTrackingUrl:URL? = nil
    
    public func enable(settings:ProxySettings,type:Int,id:String,trackNavigation:Bool){
        
        if(type == 1){
            if(tracker == nil){
                let mSiteId = Int(id)
                
                tracker = MatomoTracker(siteId: "\(mSiteId)", baseURL: URL(string: "https://dfi.bi.nu/")!)
                mTrackingTypeEnabled = 1
                debugPrint("binuTracker type \(type)")
            }
        }else if(type == 2){
            debugPrint("binuTracker type \(type)")
            mGoogleTrackingUrl = URL(string: id)
            mTrackingTypeEnabled = 2
        }
    }
     public func track(type:TrackType,siteUrl:String,title:String){
        debugPrint("Step1")
        if(mTrackingTypeEnabled == 0){
            return
        }
        debugPrint("Track Type Step2\(type)")
        if(TrackType.EVENT == type){
           
            
        }else if(TrackType.View == type){
            debugPrint("Track Type \(type)")
            if(!mTrackNavigation){
                return
            }else{
                if(siteUrl == ""){
                    return
                }
            }
            debugPrint("Track Type \(type) Step3")
            if(mTrackingTypeEnabled == 2){
                debugPrint("binuTracker type \(siteUrl)")
                self.executeGoogleTrackeing(docURL: siteUrl)
            }else{
                tracker = MatomoTracker(siteId: "\(siteUrl)", baseURL: URL(string: "https://dfi.bi.nu/")!)
            }
        }else if(TrackType.AB_TESTING == type){
            //Not Implemented
        }
    
    }
    
    func executeGoogleTrackeing(docURL:String){
        var strUrl = "\(mGoogleTrackingUrl)"
        if(strUrl.contains(BinuTracker.BINU_TOKEN)){
            var binuanl = String(format:"cid=%@&uip=%@&dl=%@"
                , ServiceManager.shared.mSession.device.mDeviceId, docURL);
            strUrl = strUrl.replacingOccurrences(of:BinuTracker.BINU_TOKEN, with: binuanl)
        }
        let binuProxy = BinuProxy()
        binuProxy.request(url: strUrl, method: .get, requestBody: nil).response{response in
            
            if(response.error == nil){
            }else{
                if(response.response?.statusCode == 500){
                   
                }else{
                   
                }
            }
        }
    }
}

