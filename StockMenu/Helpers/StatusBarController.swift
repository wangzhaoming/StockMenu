//
//  StatusBarController.swift
//  Ambar
//
//  Created by Anagh Sharma on 12/11/19.
//  Copyright © 2019 Anagh Sharma. All rights reserved.
//

import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem
    private var menu: NSMenu
    private var statusButton: NSStatusBarButton?
    private let bash: CommandExecuting
    private let script: String
    
    func exec() {
        if let lsOutput = try? bash.run(commandName: "/bin/bash", arguments: [script]) {
            statusButton!.title = (lsOutput)
        }
    }
    
    init()
    {
        bash = Bash()
        script = Bundle.main.object(forInfoDictionaryKey: "Script path") as! String
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.autosaveName = "wzm.stockmenu"
        statusButton = statusItem.button
        
        menu = NSMenu.init()
        let item = menu.addItem(withTitle: "Quit", action: #selector(self.quit(_:)), keyEquivalent: "quit")
        item.target = self
        statusItem.menu = menu
        
        statusButton?.target = self

        exec()
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.exec()
        }
    }
    
    @objc func quit(_: AnyObject) {
        NSApplication.shared.terminate(self)
    }
}
