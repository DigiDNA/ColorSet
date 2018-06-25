/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2018 Jean-David Gadina - www.imazing.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa

@NSApplicationMain

class ApplicationDelegate: NSResponder, NSApplicationDelegate
{
    private var controllers = [ NSWindowController ]()
    private var aboutWindowController: NSWindowController?
    
    func applicationDidFinishLaunching( _ notification: Notification )
    {}

    func applicationWillTerminate( _ notification: Notification )
    {}
    
    @IBAction public func newDocument( _ sender: Any? )
    {
        let controller = MainWindowController()
        
        controller.window?.center()
        controller.window?.makeKeyAndOrderFront( sender )
        
        self.controllers.append( controller )
    }
    
    @IBAction public func showAboutWindow( _ sender: Any? )
    {
        if( self.aboutWindowController == nil )
        {
            self.aboutWindowController = AboutWindowController()
            
            self.aboutWindowController?.window?.center()
        }
        
        self.aboutWindowController?.window?.makeKeyAndOrderFront( sender )
    }
    
    @IBAction public func openDocument( _ sender: Any? )
    {
        let panel = NSOpenPanel()
        
        panel.canChooseDirectories    = false
        panel.canChooseFiles          = true
        panel.canCreateDirectories    = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes        = [ "colorset" ]
        
        let r = panel.runModal()
        
        if( r != .OK )
        {
            return
        }
        
        guard let url = panel.url else
        {
            return
        }
        
        do
        {
            let data = try Data( contentsOf: url )
            
            guard let colors = NSKeyedUnarchiver.unarchiveObject( with: data ) as? [ ColorItem ] else
            {
                let alert             = NSAlert()
                alert.messageText     = "Load error"
                alert.informativeText = "Invalid data format"
                
                alert.runModal()
                
                return
            }
            
            let controller = MainWindowController( colors: colors )
            controller.url = url
            
            controller.window?.center()
            controller.window?.makeKeyAndOrderFront( sender )
            
            self.controllers.append( controller )
        }
        catch let error as NSError
        {
            NSAlert( error: error ).runModal()
        }
    }
}
