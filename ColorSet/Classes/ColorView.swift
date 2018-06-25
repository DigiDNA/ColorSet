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

class ColorView: NSView
{
    @objc public dynamic var color = NSColor.black
    @objc public dynamic var variant: NSColor?
    private var observations: [ NSKeyValueObservation ] = []
    
    override init( frame: NSRect )
    {
        super.init( frame: frame )
        
        let o1 = ( self as ColorView ).observe( \.color   ) { ( o, c ) in self.display() }
        let o2 = ( self as ColorView ).observe( \.variant ) { ( o, c ) in self.display() }
        
        self.observations.append( contentsOf: [ o1, o2 ] )
    }

    required init?( coder: NSCoder )
    {
        super.init( coder: coder )
        
        let o1 = ( self as ColorView ).observe( \.color   ) { ( o, c ) in self.display() }
        let o2 = ( self as ColorView ).observe( \.variant ) { ( o, c ) in self.display() }
        
        self.observations.append( contentsOf: [ o1, o2 ] )
    }
    
    override func draw( _ rect: NSRect )
    {
        self.color.setFill()
        rect.fill()
        
        guard let variant = self.variant else
        {
            return
        }
        
        var r = rect
        
        r.size.height = r.size.height / 2
        
        variant.setFill()
        r.fill()
    }
}
