//
//  Http.swift
//  BinuProxy
//
//  Created by xminds on 27/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
import Alamofire

class BinuProxy{
    
    var proxyConfiguration = [AnyHashable: Any]()
    var configuration = URLSessionConfiguration.default
    var sessionManager = Alamofire.SessionManager.default
    var clientIPAddress = String()
    init(){
        
        let configuration = URLSessionConfiguration.default

        proxyConfiguration[kCFNetworkProxiesHTTPProxy] = ServiceManager.shared.currentDeploymentURLS.object(forKey: "proxyUrl") as! String

        proxyConfiguration[kCFNetworkProxiesHTTPPort] = "80"

        proxyConfiguration[kCFNetworkProxiesHTTPEnable] = true

        configuration.timeoutIntervalForRequest = 60

        configuration.timeoutIntervalForResource = 60

        configuration.connectionProxyDictionary = proxyConfiguration

        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
    }
    
    public func request(url:String, method:HTTPMethod, requestBody:NSDictionary!)->DataRequest{

       let binuHeader = BinuHeaders()
       let headersDic = binuHeader.getHeaders(usage: false)
       configuration.httpAdditionalHeaders = headersDic as? [AnyHashable : Any]
        var params:NSDictionary! = nil
        if(requestBody != nil){
            params = requestBody
        }
        
        let dataRequest = self.sessionManager.request(url, method: method, parameters: params as? Parameters ?? nil, headers:headersDic as? HTTPHeaders).response{ response in
            self.checkingHeaders(requestHeaders: response.request?.allHTTPHeaderFields! ?? nil,responseHeaders:  response.response?.allHeaderFields)
        }
        return dataRequest
    }
    
    func checkingHeaders(requestHeaders:[String:String]?,responseHeaders:[AnyHashable:Any]?){
        let requestBinuHeader = requestHeaders!["X-Binu"] as! String
        let stringRequestHeader = requestBinuHeader.split(separator: ",")
        let stringRequestBinuFlag = stringRequestHeader[3].split(separator: "=")
        let requestBinuFlag = UInt64(String(stringRequestBinuFlag[1]) as String)
        let headers = responseHeaders
        var binuHeader = String()
        var binuFlag = String()
        if (responseHeaders?["X-Binu"]) != nil{
            binuHeader = headers!["X-Binu"] as! String
            let stringHeaderArray = binuHeader.split(separator: ",")
            let stringBinuFlag = stringHeaderArray[stringHeaderArray.count-1].split(separator: "=")
            binuFlag = String(stringBinuFlag[1]) as String
        }else{
            binuFlag = "0x00000000"
        }
        let appOptNetChange = ServiceManager.shared.mUtility.convertToDecimal(settingsFlag: BinuHeaders.APP_OPT_NET_CHANGE)
        if((requestBinuFlag! & appOptNetChange) == appOptNetChange){
            ServiceManager.shared.APP_NET_CHANGE_SENT = true
            ServiceManager.shared.BinuFreeStaus = ServiceManager.shared.mUtility.compareToStrings(responseflag: binuFlag, settingsFlag: BinuHeaders.APP_OPT_FREEDATA) ? "Free":"PAID"
            ServiceManager.shared.setFreeStatus(freeStatus: ServiceManager.shared.BinuFreeStaus)
            if(ServiceManager.shared.mUtility.compareToStrings(responseflag: binuFlag, settingsFlag: BinuHeaders.APP_OPT_IP_ADDR)){
                binuHeader = headers!["X-Binu"] as! String
                let stringHeaderArray = binuHeader.split(separator: ",")
                let stringBinuFlag = stringHeaderArray[0].split(separator: "=")
                self.clientIPAddress = String(stringBinuFlag[1]) as String
            }
        }
    }
    public func download(url:String)->DownloadRequest{
        let binuHeader = BinuHeaders()
        let headersDic = binuHeader.getHeaders(usage: false)
        configuration.httpAdditionalHeaders = headersDic as? [AnyHashable : Any]
        self.sessionManager = Alamofire.SessionManager(configuration:self.configuration)
        let urlArray = url.split(separator: ".")
        let fileFormat = urlArray[urlArray.count-1]
        print(fileFormat)
        let destinationPath: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
            let fileURL = documentsURL.appendingPathComponent("test.\(fileFormat)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let downloadRequest = self.sessionManager.download(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headersDic as! HTTPHeaders, to: destinationPath).downloadProgress{ progress in
            
        }
        .response{ response in
             debugPrint(response)
            self.checkingHeaders(requestHeaders: self.configuration.httpAdditionalHeaders as! [String : String],responseHeaders:  response.response?.allHeaderFields)
        }

        return downloadRequest
    }
}
