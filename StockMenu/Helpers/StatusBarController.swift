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
        if let out = try? bash.run(commandName: "/bin/bash", arguments: [script]) {
            if out.err.count > 0 {
                statusButton?.image = NSImage(named: NSImage.Name("StatusBarIcon"))
            }
            else {
                let output = out.out.split(separator: "\n")
                statusButton?.image = nil
                statusButton?.title = (String(output[0]))
                
                if menu.items.count > 1 {
                    for item in menu.items[0...menu.items.count - 2] {
                        menu.removeItem(item)
                    }
                }

                for (i, o) in output[1...].enumerated(){
                    menu.insertItem(withTitle: String(o), action: nil, keyEquivalent: "", at: i)
                }
            }
        }
        else {
            statusButton?.image = NSImage(named: NSImage.Name("StatusBarIcon"))
        }
    }
    
    init()
    {
        bash = Bash()
        script = Bundle.main.object(forInfoDictionaryKey: "Script path") as! String
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.autosaveName = "wzm.stockmenu" + script
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
