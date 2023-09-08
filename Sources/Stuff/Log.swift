//
//  Log.swift
//  video2mvb
//
//  Created by Onee Chan on 08.09.2023.
//

import Foundation

public enum LogLevel {
    case info, error
}

public final class Log {
    
    public static func log(_ message: String,
                           _ level: LogLevel = .info,
                           terminator: String = "\n") {
        switch level {
        case .info:
            fputs("\(message)\(terminator)", stdout)
            fflush(stdout)
        case .error:
            fputs("[e] \(message)\(terminator)", stderr)
            fflush(stderr)
        }
    }
}
