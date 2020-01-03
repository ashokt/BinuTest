//
//  DBHelper.swift
//  BinuProxy
//
//  Created by xminds on 22/11/19.
//  Copyright © 2019 Xminds. All rights reserved.
//

import Foundation
import SQLite3
class DBHelper{
    private static let DATABASE_NAME:String = "binu.db";
    private static let USAGE_TABLE_NAME:String = "usage";
    private static let USAGE_COLUMN_ID:String = "id";
    private static let USAGE_COLUMN_DATA:String = "data";
    var db: OpaquePointer?
    public init(){
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(DBHelper.DATABASE_NAME)
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS usage (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    public func insertData(data:String){
        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO usage (data) VALUES (?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, data, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
    
    }
    public func getAllUsage(isDelete:Bool)->NSMutableArray{
        
        var arrayUsageActivities:NSMutableArray = []
        let queryString = "SELECT * FROM usage"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return arrayUsageActivities
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let data = String(cString: sqlite3_column_text(stmt, 1))
            
            let dataDict = data 
            arrayUsageActivities.add(dataDict)
            if(isDelete){
                let deletequeryString = "DELETE FROM usage where id = \(id)"
                
                var stmtdelete:OpaquePointer?
                
                if sqlite3_prepare(db, deletequeryString, -1, &stmtdelete, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return arrayUsageActivities
                }
                let r = sqlite3_step(stmtdelete)
                if r != SQLITE_DONE {
                    print("sqlite3_step(deleteEntryStmt) \(r)")
                    return arrayUsageActivities
                }
            }
        }
        return arrayUsageActivities
    }
}
