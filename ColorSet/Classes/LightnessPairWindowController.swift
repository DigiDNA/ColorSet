/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Jean-David Gadina - www.xs-labs.com
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

class LightnessPairWindowController: NSWindowController
{
    @objc public private( set ) dynamic var item = LightnessPairItem( base: nil )
    
    convenience init( base: ColorItem )
    {
        self.init()
        
        self.item = LightnessPairItem( base: base )
    }
    
    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name( NSStringFromClass( type( of: self ) ) )
    }
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        
        if let colorView1 = self.window?.contentView?.subviewWithIdentifier( "Color1" ) as? ColorView
        {
            colorView1.bind( NSBindingName( "color" ), to: self, withKeyPath: "self.item.lightness1.color",   options: nil )
        }
        
        if let colorView2 = self.window?.contentView?.subviewWithIdentifier( "Color2" ) as? ColorView
        {
            colorView2.bind( NSBindingName( "color" ), to: self, withKeyPath: "self.item.lightness2.color", options: nil )
        }
    }
    
    @IBAction func ok( _ sender: Any? )
    {
        guard let window = self.window, let parent = self.window?.sheetParent else
        {
            NSSound.beep()
            
            return
        }
        
        parent.endSheet( window, returnCode: .OK )
        
    }
    
    @IBAction func cancel( _ sender: Any? )
    {
        guard let window = self.window, let parent = self.window?.sheetParent else
        {
            NSSound.beep()
            
            return
        }
        
        parent.endSheet( window, returnCode: .cancel )
    }
}
