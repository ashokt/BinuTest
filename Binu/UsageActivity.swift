//
//  UsageActivity.swift
//  BinuProxy
//
//  Created by Xminds on 13/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
class UsageActivity{
    var mStartTime:Int = 0
    var mEndTime:Int = 0
    var mOnline:Bool = false
    var mDeferred:Bool = false
    var mUrls:NSMutableArray = []
    
    func setUsageActivity(startTime:Int,endTime:Int,online:Bool,deferred:Bool){
        mStartTime = startTime
        mEndTime = endTime
        mOnline = online
        mDeferred = deferred
    }
    
    func toString()->String{
        return String(format:"%d,%d,%d,%d",self.mStartTime,self.mEndTime-self.mStartTime,self.mOnline ? 1 : 0,mDeferred ? 1 : 0)
    }
}

