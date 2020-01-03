//
//  ProxySettings.swift
//  BinuProxy
//
//  Created by Arun on 11/14/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
open class ProxySettings{
    private let PREF_NAME = "Settings"
    private let PREF_KEY_CACHE_SIZE = "cacheSize"
    
    public static let CACHE_SIZE_BYTE_MIN = 1024
    public static let CONNECT_TIMEOUT_SECS_MIN = 3
    public static let CACHE_MAX_AGE_SECONDS_MIN = 10
    public static let CACHE_MAX_STALE_HOURS_MIN = 2
    public static let LOG_PERIOD_MIN = 60000
    
    public var mCacheSize:Int = 10485760
    public var mConnectTimeout:Int = 10
    public var mReadTimeout:Int = 10
    public var mUseHttpInterceptor:Bool = false
    public var mCacheMaxAgeSeconds:Int = 120
    public var mCacheMaxStaleHours:Int = 48
    public static var mLogInterval:Int = 10
    public var mPiwikDispatchInterval:Int = 10000
    
    public var mImageCacheIndicator:Bool = false
    public var mUseOptTrace:Bool = false
    public var mShowImage:Bool = true
    
    public var mBinuTracker = BinuTracker()
    public var mAlwaysFree:Bool = false
    public var mRetryOnConnectionFailure:Bool = true
    public var mExtras:NSDictionary = [:]
    
    public init(){
        print("ProxySettings")
    }
}
public enum DeploymentURLS:String{
    case PRODUCTION
    case SANDBOX
    case SYSTEST
    case HTTP2
    case PRODUCTION_H2
    case SANDBOX_H2
    case SYSTEST_H2
    case DEVELOPMENT
    case FAILOVER
    case LOCAL
}

public class Deployment{
    public var production:NSDictionary = ["deploymentId":"1",
                                          "proxyUrl":"http://h2opt.bi.nu",
                                          "imageServerUrl":"h2image.bi.nu",
                                          "encodedUrl":"http://rp.bi.nu/",
                                          "adServerUrl":"http://ads.bi.nu",
                                          "piwikUrl":"https://dfi.bi.nu/"]
    public var sandbox:NSDictionary = ["deploymentId":"2",
                                       "proxyUrl":"http://h2optsandbox.bi.nu",
                                       "imageServerUrl":"h2imagesandbox.bi.nu",
                                       "encodedUrl":"http://rp.sandbox.bi.nu/",
                                       "adServerUrl":"http://ads.bi.nu",
                                       "piwikUrl":"https://dfi.bi.nu/"]
    public var systest:NSDictionary = ["deploymentId":"3",
                                       "proxyUrl":"http://h2optsystest.bi.nu",
                                       "imageServerUrl":"h2imagesystest.bi.nu",
                                       "encodedUrl":"http://rp.systest.bi.nu/",
                                       "adServerUrl":"http://ads.systest.bi.nu",
                                       "piwikUrl":"https://piwik.systest.bi.nu/"]
    public var http2:NSDictionary = ["deploymentId":"4",
                                     "proxyUrl":"http://h2optsystest.bi.nu:443/",
                                     "imageServerUrl":"h2imagesystest.bi.nu",
                                     "encodedUrl":"http://rp.bi.nu/",
                                     "adServerUrl":"http://ads.systest.bi.nu",
                                     "piwikUrl":"https://dfi.bi.nu/"]
    public var production_h2:NSDictionary = ["deploymentId":"5",
                                             "proxyUrl":"http://h2opt.bi.nu",
                                             "imageServerUrl":"h2image.bi.nu",
                                             "encodedUrl":"http://rp.systest.bi.nu/",
                                             "adServerUrl":"http://ads.systest.bi.nu",
                                             "piwikUrl":"https://piwik.systest.bi.nu/"]
    public var sandbox_h2:NSDictionary = ["deploymentId":"6",
                                          "proxyUrl":"http://h2opt.bi.nu",
                                          "imageServerUrl":"h2image.bi.nu",
                                          "encodedUrl":"http://rp.bi.nu/",
                                          "adServerUrl":"http://ads.bi.nu",
                                          "piwikUrl":"https://dfi.bi.nu/"]
    public var systest_h2:NSDictionary = ["deploymentId":"7",
                                          "proxyUrl":"http://h2optsystest.bi.nu",
                                          "imageServerUrl":"h2imagesystest.bi.nu",
                                          "encodedUrl":"http://rp.systest.bi.nu/",
                                          "adServerUrl":"http://ads.systest.bi.nu",
                                          "piwikUrl":"https://piwik.systest.bi.nu/"]
    public var development:NSDictionary = ["deploymentId":"8",
                                           "proxyUrl":"https://h2optsandbox.bi.nu:443",
                                           "imageServerUrl":"h2imagesandbox.bi.nu",
                                           "encodedUrl":"http://rp.sandbox.bi.nu/",
                                           "adServerUrl":"http://ads.bi.nu",
                                           "piwikUrl":"https://piwik.systest.bi.nu/"]
    public var failover:NSDictionary = ["deploymentId":"9",
                                        "proxyUrl":"http://192.168.56.101",
                                        "imageServerUrl":"h2imagesandbox.bi.nu",
                                        "encodedUrl":"http://rp.systest.bi.nu/",
                                        "adServerUrl":"http://ads.systest.bi.nu",
                                        "piwikUrl":"https://piwik.systest.bi.nu/"]
    public var local:NSDictionary = ["deploymentId":"10",
                                     "proxyUrl":"http://192.168.56.101",
                                     "imageServerUrl":"h2imagesandbox.bi.nu",
                                     "encodedUrl":"http://rp.systest.bi.nu/",
                                     "adServerUrl":"http://ads.systest.bi.nu",
                                     "piwikUrl":"https://piwik.systest.bi.nu/"]
    public var mId:Int = 0
    public var mImageServer:String = ""
    public var mUrlEncoder:String = ""
    public var mAdServerUrl:String = ""
    public var mPiwikServer:String = ""
    public var mSecondaryProxies:[String] = []
    
    init(){
        
    }
    public func setDeployment(deploymentType:DeploymentURLS){
        if(DeploymentURLS.PRODUCTION == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = production
        }else if(DeploymentURLS.SANDBOX == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = sandbox
        }else if(DeploymentURLS.SYSTEST == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = systest
        }else if(DeploymentURLS.HTTP2 == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = http2
        }else if(DeploymentURLS.PRODUCTION_H2 == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = production_h2
        }else if(DeploymentURLS.SANDBOX_H2 == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = sandbox_h2
        }else if(DeploymentURLS.SYSTEST_H2 == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = systest_h2
        }else if(DeploymentURLS.DEVELOPMENT == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = development
        }else if(DeploymentURLS.FAILOVER == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = failover
        }else if(DeploymentURLS.LOCAL == deploymentType){
            ServiceManager.shared.currentDeploymentURLS = local
        }
    }
    
}
