//
//  BinuHeaders.swift
//  BinuProxy
//
//  Created by Xminds on 13/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
public class BinuHeaders{
    private let HDR_PROTO_VALUE:Int = 3;
    public  let HDR_DEFAULT_USER_AGENT:String = "";
    
    static let HDR_BINU:String          = "X-Binu";
    static let HDR_BINU_CONTEXT:String  = "X-Binu-Context";
    static let HDR_CACHE_CONTROL:String = "Cache-Control";
    static let HDR_ACCEPT:String        = "Accept";
    static let HDR_REFERER:String       = "Referer";
    
    static var APP_FIRST_REQUEST:Bool    = true;
    
    // flags used in app and optimizer interactions
    static let APP_OPT_NONE:String        = "0x00000000"
    
    static let APP_OPT_GZIP:String        = "0x00000001" // is compressed
    static let APP_OPT_BASE64:String      = "0x00000002" // is base64 encoded
    static let APP_OPT_JSON:String        = "0x00000004" // json format
    static let APP_OPT_TRACE:String       = "0x00000008" // send trace data
    
    static let APP_OPT_FIRST:String       = "0x00000100" // first request
    static let APP_OPT_NO_CONTEXT:String  = "0x00000200" // don't send context to source
    static let APP_OPT_IMAGE:String       = "0x00000400" // image request
    static let APP_OPT_ECHO:String        = "0x00000800"
    static let APP_OPT_NET_CHANGE:String  = "0x00001000" // net status has changed
    
    static let APP_OPT_RESEND:String      = "0x00010000"
    static let APP_OPT_NO_CACHE:String    = "0x00020000" // cache server is un-contactable
    static let APP_OPT_APK_INVALID:String = "0x00040000"
    static let APP_OPT_APK_UPGRADE:String = "0x00080000"
    static let APP_OPT_FREEDATA:String    = "0x00100000"
    static let APP_OPT_IP_ADDR:String     = "0x00200000"
    
    private static let CONTEXT_NONZIP_THRESHOLD:Int = 1024;
    
    func getHeaders(usage:Bool)->NSDictionary{
        return getHeaders(binuFlags: 0,usage: usage)
    }
    
    func getHeaders(binuFlags:UInt64,usage:Bool)->NSDictionary{
        var flagBinu:UInt64 = 0
        if (BinuHeaders.APP_FIRST_REQUEST) {
            
            flagBinu = binuFlags | ServiceManager.shared.mUtility.convertUInt64(inputString: BinuHeaders.APP_OPT_FIRST)
        }
        
        if (!ServiceManager.shared.APP_NET_CHANGE_SENT) {
            flagBinu = binuFlags | ServiceManager.shared.mUtility.convertUInt64(inputString: BinuHeaders.APP_OPT_NET_CHANGE)
        }
        let settings = ServiceManager.shared.getSettings()
        if (settings.mUseOptTrace){
            flagBinu = binuFlags | ServiceManager.shared.mUtility.convertUInt64(inputString: BinuHeaders.APP_OPT_TRACE)
        }

        if (ServiceManager.shared.BinuFreeStaus == "FREE"){
            flagBinu = flagBinu | ServiceManager.shared.mUtility.convertUInt64(inputString: BinuHeaders.APP_OPT_FREEDATA)
        }
        
        
        
        if (ServiceManager.shared.getSession() != nil) {
            let session = ServiceManager.shared.getSession()
            var sessionData:Data? = nil
            do{
                sessionData = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
            }catch{
                debugPrint("Archiving Data Failed")
            }
            let sessionBytes = sessionData!.withUnsafeBytes {
                [UInt8](UnsafeBufferPointer(start: $0, count: sessionData!.count))
            }
            flagBinu = flagBinu | ServiceManager.shared.mUtility.convertUInt64(inputString: BinuHeaders.APP_OPT_BASE64) | ServiceManager.shared.mUtility.convertUInt64(inputString: BinuHeaders.APP_OPT_JSON)
            if (sessionBytes.count > BinuHeaders.CONTEXT_NONZIP_THRESHOLD) {
                do{
                    flagBinu = flagBinu | ServiceManager.shared.mUtility.convertUInt64(inputString: BinuHeaders.APP_OPT_GZIP)
                }catch let error{
                    print(error);
                }
            }
        }
        
        let xbinuString = String(format:"proto=%d, did=%@, appId=%d, flags=%d, echo=%d, auth=%@, t=%d",HDR_PROTO_VALUE,UIDevice.current.identifierForVendor!.uuidString ,ServiceManager.shared.mBinuAppId,flagBinu,Date().millisecondsSince1970,getToken(),Date().millisecondsSince1970)
        
        var base64String:String = ""
        if (ServiceManager.shared.getSession() != nil){
            let session = ServiceManager.shared.getSession()
            print(session)
            let data = (session).data(using: String.Encoding.utf8)
            base64String = data!.base64EncodedString()

        }
        if(!BinuHeaders.APP_FIRST_REQUEST){
            let jsonHeader = ["accept": "application/json",
             "X-Binu":xbinuString,
             "User-Agent":"okhttp/ios",
            ]
            return jsonHeader as NSDictionary
        }else{
            BinuHeaders.APP_FIRST_REQUEST = false
            let jsonHeader = ["accept": "application/json",
             "X-Binu-Context":base64String,
             "X-Binu":xbinuString,
             "User-Agent":"okhttp/ios",
            ]
            return jsonHeader as NSDictionary
        }
    }
    
    private func getToken()->String{
        return "null"
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
