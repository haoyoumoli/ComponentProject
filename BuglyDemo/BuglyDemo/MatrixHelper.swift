//
//  MatrixHelper.swift
//  BuglyDemo
//
//  Created by apple on 2022/3/15.
//

import Foundation
import Matrix
class MatrixHelper:NSObject, MatrixPluginListenerDelegate {
    
    
    static let shared = MatrixHelper()
    
    func
    start() {
        let matrix:Matrix = Matrix.sharedInstance() as! Matrix
        let matrixBuilder = MatrixBuilder.init()
        matrixBuilder.pluginListener = self
        
        let crashBlockPlugin = WCCrashBlockMonitorPlugin()
        matrixBuilder.add(crashBlockPlugin)
        
        let memoryStatPlugin = WCMemoryStatPlugin()
        matrixBuilder.add(memoryStatPlugin)
        
        //      let fpsMonitorPlugin = WCFPSMonitorPlugin()
        //      matrixBuilder.add(fpsMonitorPlugin)
        
        matrix.add(matrixBuilder)
        crashBlockPlugin.start()
        memoryStatPlugin.start()
        //fpsMonitorPlugin.start()
        
    }
    
    
    func onReport(_ issue: MatrixIssue!) {
        debugPrint("onReport:\(issue)")
        
        if issue.issueTag == WCCrashBlockMonitorPlugin.getTag() {
            if issue.dataType == .data,
               issue.issueData != nil,
               let issueString = String.init(data: issue.issueData, encoding: .utf8)
            {
                do {
                    try issueString.write(toFile: "/Users/apple/Desktop/\(Date().timeIntervalSince1970).text", atomically: true, encoding: .utf8)
                } catch let err {
                    debugPrint(err)
                }
            } else  {
                debugPrint("filePath:\(issue.filePath ?? "")")
            }
        }
        
        let matrix:Matrix = Matrix.sharedInstance() as! Matrix
        matrix.reportIssueComplete(issue, success: true)
    }
    
}
