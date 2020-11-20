//
//  Bash.swift
//  StockMenu
//
//  Created by 王赵明 on 2020/11/19.
//  Copyright © 2020 Golden Chopper. All rights reserved.
//

import Foundation

protocol CommandExecuting {
    func run(commandName: String, arguments: [String]) throws -> (out: String, err: String)
}

enum BashError: Error {
    case commandNotFound(name: String)
}

struct Bash: CommandExecuting {
    func run(commandName: String, arguments: [String] = []) throws -> (out: String, err: String) {
        return try run(commandName, with: arguments)
    }

//    private func resolve(_ command: String) throws -> String {
//        guard var bashCommand = try? run("/bin/bash" , with: ["-l", "-c", "which \(command)"]) else {
//            throw BashError.commandNotFound(name: command)
//        }
//        bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
//        return bashCommand
//    }

    private func run(_ command: String, with arguments: [String] = []) throws -> (out: String, err: String) {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        let outputPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errPipe
        process.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let err = String(decoding: errData, as: UTF8.self)
        return (output, err)
    }
}
