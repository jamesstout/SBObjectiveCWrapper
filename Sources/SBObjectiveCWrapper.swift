//
//  SBObjectiveCWrapper.swift
//  SBObjectiveCWrapper
//
//  Created by Reese McLean on 12/21/15.
//  Copyright © 2015 Reese McLean. All rights reserved.
//

import Foundation
import SwiftyBeaver

protocol Loggable: class {

    static func verbose(_ msg: @autoclosure () -> Any, _ path: String, _ function: String, line: Int, context: Any?)
    static func debug(_ msg: @autoclosure () -> Any, _ path: String, _ function: String, line: Int, context: Any?)
    static func info(_ msg: @autoclosure () -> Any, _ path: String, _ function: String, line: Int, context: Any?)
    static func warning(_ msg: @autoclosure () -> Any, _ path: String, _ function: String, line: Int, context: Any?)
    static func error(_ msg: @autoclosure () -> Any, _ path: String, _ function: String, line: Int, context: Any?)

}

extension SwiftyBeaver: Loggable {}

@objc open class SBObjectiveCWrapper: NSObject {

    @objc class func _setLogClassForTesting(_ logClass: AnyObject) {
        if let logC = logClass as? Loggable.Type {
            self.logClass = logC
        }
    }

    static var logClass: Loggable.Type = SwiftyBeaver.self

    @objc open class func logVerbose(_ message: String, filePath: String, function: String, line: Int) {

        logClass.verbose(message, filePath, self.convertFunction(function), line: line, context: nil)

    }

    @objc open class func logDebug(_ message: String, filePath: String, function: String, line: Int) {

        logClass.debug(message, filePath, self.convertFunction(function), line: line, context: nil)

    }

    @objc open class func logInfo(_ message: String, filePath: String, function: String, line: Int) {

        logClass.info(message, filePath, self.convertFunction(function), line: line, context: nil)

    }

    @objc open class func logWarning(_ message: String, filePath: String, function: String, line: Int) {

        logClass.warning(message, filePath, self.convertFunction(function), line: line, context: nil)

    }

    @objc open class func logError(_ message: String, filePath: String, function: String, line: Int) {

        logClass.error(message, filePath, self.convertFunction(function), line: line, context: nil)

    }

    @objc open class func convertFunction(_ function: String) -> String {
        var strippedFunction = function

        if let match = function.range(of: "\\w+:*[\\w*:*]*]", options: .regularExpression) {
            let endIndex = function.index(before: match.upperBound)
            let functionParts = function[match.lowerBound..<endIndex].components(separatedBy: ":")

            guard functionParts.isEmpty == false else { return function }

            for (index, part) in functionParts.enumerated() {
                switch index {
                case 0:
                    strippedFunction = part
                    if functionParts.count > 1 { strippedFunction += "(_:" }
                default:
                    if !part.isEmpty {
                        strippedFunction += "\(part):"
                    }
                }
            }
            if functionParts.count > 1 { strippedFunction += ")" } else if functionParts.count == 1 { strippedFunction += "()" }

        }
        return strippedFunction
    }
}
