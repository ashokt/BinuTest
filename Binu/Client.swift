//
//  Client.swift
//  BinuProxy
//
//  Created by Xminds on 13/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
class Client{
    private var mAppId:String = ""
    private var mGP_versionCode:String = ""
    private var mGP_versionNumber:String = ""
    private var mBinu_clientVersion:String = "undefined";
    private var mAppSize:Int = 0
    private var mInstallTime:Int = 0
    private var mFirstInstallTime:Int = 0
    private var mDownloadSource:String = ""
    private var mSecurityToken:String = ""
    private var mBuildId:String = "0"
    private var mReferrer:String = ""
    private var mProductCode:String = "SW"
    public init(){
        
        self.mAppId = String(format:"%d",Binu.mBinuAppId)
        self.mGP_versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        self.mGP_versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        self.mAppSize = getAppSize()
        self.mInstallTime = getInstallationDate()
        self.mFirstInstallTime = getInstallationDate()
        self.mBuildId = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        self.mReferrer = ""
        self.mDownloadSource = "AppStore"
        self.mProductCode = "SW"
    }
    func ToString()->String{
        
       return String(format:"[%@, %@, %@, %d, %d, %d, %@, %@, %@, %@, %@, %@]",mAppId,mGP_versionCode,mGP_versionNumber,mAppSize,mInstallTime,mFirstInstallTime,mDownloadSource,mSecurityToken,mBinu_clientVersion,mBuildId,mReferrer,mProductCode)
    }
    func getAppSize()->Int{
        let paths : NSArray   = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let path : NSString   = paths.firstObject as! NSString
        let files : NSArray   = try! FileManager.default.subpathsOfDirectory(atPath: path as String) as NSArray
        let dirEnumerator     = files.objectEnumerator()
        var totalSize: UInt64 = 0
        let fileManager       = FileManager.default;
        while let file:String = dirEnumerator.nextObject() as? String
        {
            let attributes:NSDictionary = try! fileManager.attributesOfItem(atPath: path.appendingPathComponent(file)) as NSDictionary
            totalSize += attributes.fileSize();
        }
        
        let fileSystemSizeInMegaBytes : Double = Double(totalSize)/1000000
        return Int(fileSystemSizeInMegaBytes)
        
    }
    func getInstallationDate()->Int{
        let urlToDocumentsFolder: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let installDate = try? FileManager.default.attributesOfItem(atPath: (urlToDocumentsFolder?.path)!)[.creationDate] as? Date
        let timeInterval = installDate!.timeIntervalSince1970
        return(Int(timeInterval))
    }
}
