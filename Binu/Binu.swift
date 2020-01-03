//
//  Binu.swift
//  Binu
//
//  Created by Xminds on 07/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
import Alamofire
import Network
import os.log

public var mBinuAppId = Int()
public var onFreeStatusChanged: ((_ freestatus:String) -> Void)?
public var onConnectivityChange: ((_ netStatus:String) -> Void)?
public var onBinuInitializeResponse: ((_ responseData:String) -> Void)?
public var mToken = String()

public func initialize(settings:ProxySettings, deploymentType:DeploymentURLS) {
    print("Started \(deploymentType)")
    mBinuAppId = Int(settings.mExtras[BINU_KEY_APP_ID] as! String)!
    ServiceManager.shared.mBinuAppId = Int(settings.mExtras[BINU_KEY_APP_ID] as! String)!
    let deployment = Deployment()
    deployment.setDeployment(deploymentType:deploymentType)
    if(ServiceManager.shared.mBinuAppId != -1){
        mToken = settings.mExtras[BINU_KEY_TOKEN] as! String
        ServiceManager.shared.mToken = settings.mExtras[BINU_KEY_TOKEN] as! String
        ServiceManager.shared.mSettings = settings
        ServiceManager.shared.lifeCycle(event: "ON_START")
        
    }else{
        Binu.onBinuInitializeResponse!("Binu Initialize Failed")
    }
}

public func request(url:String, method:HTTPMethod, requestBody:NSDictionary?)->DataRequest{
    let binuProxy = BinuProxy()
    return binuProxy.request(url: url, method: method, requestBody: requestBody)
}

public func download(url:String)->DownloadRequest{
    let binuProxy = BinuProxy()
    return binuProxy.download(url: url)
}

public func onNavigate(url:String,title:String){
    _ = ServiceManager.shared.onNavigate(url: url, title: title)
}
enum RegistrationError: Error {
    case inValidAppId
}
extension RegistrationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .inValidAppId:
            return NSLocalizedString("Both BINU_APP_ID and BINU_TOKEN must be specified in extras.", comment: "Invalid App Id")
        }
    }
}
