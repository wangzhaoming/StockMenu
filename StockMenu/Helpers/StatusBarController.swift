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
                statusButton?.image = #imageLiteral(resourceName: "StatusBarIcon")
                print(out.err)
            }
            else {
                let output = render(strs: out.out.split(separator: "\n"))
                
                statusButton?.image = nil
                statusButton?.attributedTitle = output[0]
                
                if menu.items.count > 1 {
                    for item in menu.items[0...menu.items.count - 2] {
                        menu.removeItem(item)
                    }
                }

                for (i, o) in output[1...].enumerated(){
                    let item = NSMenuItem.init()
                    item.attributedTitle = o
                    menu.insertItem(item, at: i)
                }
            }
        }
        else {
            statusButton?.image = #imageLiteral(resourceName: "StatusBarIcon")
        }
    }
    
    func render(strs: [Substring]) -> [NSAttributedString] {
        var out: [NSAttributedString] = []
        for s in strs {
            let segs = String(s).split(separator: "|")
            if segs.count == 1 {
                out.append(NSAttributedString(string: String(segs[0])))
            }
            else if segs.count > 1 {
                var attributes = [NSAttributedString.Key:Any]()
                
                for seg in segs[1...] {
                    let attr = seg.split(separator: "=")
                    if attr.count > 1 {
                        if String(attr[0]) == "color" {
                            if let color = NSColor(hex: String(attr[1])) {
                                attributes[.foregroundColor] = color
                            }
                        }
                    }
                }
                
                out.append(NSAttributedString(string: String(segs[0]), attributes: attributes))
            }
        }
        
        return out
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


extension NSColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
            else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }
        else {
            switch hex.lowercased() {
            case "red":
                self.init(red: 1, green: 0, blue: 0, alpha: 1)
                return
            case "green":
                self.init(red: 0, green: 1, blue: 0, alpha: 1)
                return
            case "blue":
                self.init(red: 0, green: 0, blue: 1, alpha: 1)
                return
            default:
                return nil
            }
        }
        return nil
    }
}
