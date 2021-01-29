//
//  CocoaSpells.swift
//  CocoaSpells
//
//  Created by Steve Sheets on 1/10/21.
//  Copyright © 2021 Steve Sheets. All rights reserved.

import Foundation
import Cocoa
import SwiftSpellBook

/// Abstract extension for name space of typealias & static functions.
public struct CocoaSpellBook {
    
}

// MARK: Closure Typealiases

public extension CocoaSpellBook {

    /// Closure that has no results, but it passed a NSImage.
    typealias ImageClosure = (NSImage) -> Void
    
    /// Closure that has no parameters, but returns a NSImage.
    typealias imageSourceClosure = () -> NSImage
    
}

// MARK: - Info.plist Constants

public extension CocoaSpellBook {
    
    /// App Name (lazy)
    static var appName: String = {
        if let text = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return text
        }

        if let text = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return text
        }
        
        return ""
    }()
    
    /// App Version (lazy)
    static var appVersion: String = {
        guard let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }

        return text
    }()
    
    /// App Copyright (lazy)
    static var appCopyright: String = {
        guard let text = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String else {
            return ""
        }
        
        return text
    }()

}

// MARK: Open/Save Panel Extensions

public extension CocoaSpellBook {

    /// Invokes SavePanel for given file type.  If user enters path, closure is invoked with specified URL.
    static func saveFileURL(type: String, block: @escaping SwiftSpellBook.URLClosure) {
        let savePanel = NSSavePanel()
        
        savePanel.allowedFileTypes = [type]
        
        savePanel.begin { result in
            guard result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                  let url = savePanel.url else { return }
            
            block(url)
        }
    }

    /// Invokes SavePanel for given file type.  If user enters path, given data is saved to specified URL.
    static func saveFile(data: Data, type: String) {
        CocoaSpellBook.saveFileURL(type: type) { url in
            let nsdata = data as NSData
            
            nsdata.write(to: url, atomically: false)
        }
    }
    
    /// Invokes SavePanel for given file type (default 'txt').  If user enters path, given string is saved to specified URL.
    static func saveFile(string: String, type: String = "txt") {
        let data = Data(string.utf8)
        
        CocoaSpellBook.saveFile(data: data, type: type)
    }
    
    /// Invokes SavePanel for JPEG images.  If user enters path, given image is saved to specified URL.
    static func saveFile(image: NSImage) {
        CocoaSpellBook.saveFileURL(type: "jpg") { url in
            guard let bits = image.representations.first as? NSBitmapImageRep,
                  let data = bits.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:]) else { return }
            
            let nsdata = data as NSData
            
            nsdata.write(to: url, atomically: false)
        }
    }

    /// Invokes SavePanel for given file type.  If user selecta a file, closure is invoked with specified URL.
    static func openFileURL(type: String, block: @escaping SwiftSpellBook.URLClosure ) {
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = [type]
        
        openPanel.begin { result in
            guard result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                  let url = openPanel.url else { return }
            
            block(url)
        }
    }

    /// Invokes SavePanel for given file type.  If user selecta a file, closure is invoked with data from specified URL.
    static func openFileData(type: String, block: @escaping SwiftSpellBook.DataClosure ) {
        CocoaSpellBook.openFileURL(type: type) { url in
            guard let data = try? Data(contentsOf: url) else { return }
            
            block(data)
       }
    }

    /// Invokes SavePanel for given file type (default 'txt').  If user selecta a file, closure is invoked with string from specified URL.
    static func openFileString(type: String, block: @escaping SwiftSpellBook.StringClosure ) {
        CocoaSpellBook.openFileData(type: type) { data in
            let string = String(decoding: data, as: UTF8.self)
            
            block(string)
       }
    }

    /// Invokes SavePanel for "jpg" file type.  If user selecta a file, closure is invoked with image from specified URL.
    static func openFileImage(block: @escaping ImageClosure ) {
        CocoaSpellBook.openFileURL(type: "jpg") { url in
            guard let image = NSImage(contentsOf: url) else { return }
            
            block(image)
       }
    }

}

// MARK: NSApp Extensions

public extension CocoaSpellBook {
    
    /// Given string, open Safari with that Link
    /// - Parameter link: String text to open.
    static func openURL(_ link: String) {
        guard !link.isEmpty, let aURL = URL(string: link) else { return }
        
        NSWorkspace.shared.open(aURL)
    }

    /// Given string, open bundled file with that name
    /// - Parameter link: String File to open.
    static func openBundledFile(_ name: String) {
       guard !name.isEmpty, let aPath = Bundle.main.path(forResource: name, ofType: nil) else { return }
        
       NSWorkspace.shared.openFile(aPath, withApplication: nil)
    }
    
    /// Given string, open Help wtih that section
    /// - Parameter link: String Help to open.
    static func openHelp(_ name: String? = nil) {
        NSApplication.shared.showHelp(nil)
    }
    
}

// MARK: NSDocumentController Extensions

public extension CocoaSpellBook {
    
    /// Is the app designed for document editors
    static func isDocumentEditor() -> Bool {
        let dc = NSDocumentController.shared
        
        guard let _ = dc.defaultType else { return false }
    
        return true
    }
    
    /// New Document displayed
    static func newDoc() {
        let dc = NSDocumentController.shared

        dc.newDocument(nil)
    }

    /// Open Document displayed
    static func openDoc() {
        let dc = NSDocumentController.shared

        dc.openDocument(nil)
    }
}

// MARK: UI Extensions

public extension CocoaSpellBook {
    
    static func modal(window: NSWindow, okAction: SwiftSpellBook.SimpleClosure? = nil, cancelAction: SwiftSpellBook.SimpleClosure? = nil) {
        window.center()

        let m = NSApplication.shared.runModal(for: window)
        
        window.orderOut(nil)

        if m == .OK {
            if let block = okAction {
                block()
            }
        }
        else if m == .cancel {
            if let block = cancelAction {
                block()
            }
        }
    }
}
