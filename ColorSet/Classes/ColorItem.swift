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

class ColorItem: NSObject
{
    @objc public dynamic var name       = "Untitled"
    @objc public dynamic var hasVariant = false
    
    @objc public dynamic var color:   NSColor = NSColor.black
    @objc public dynamic var variant: NSColor?
    
    @objc public dynamic var red:   CGFloat = 0.0
    @objc public dynamic var green: CGFloat = 0.0
    @objc public dynamic var blue:  CGFloat = 0.0
    @objc public dynamic var alpha: CGFloat = 1.0
    
    @objc public dynamic var red2:   CGFloat = 0.0
    @objc public dynamic var green2: CGFloat = 0.0
    @objc public dynamic var blue2:  CGFloat = 0.0
    @objc public dynamic var alpha2: CGFloat = 1.0
    
    private var observations: [ NSKeyValueObservation ] = []
    private var updating                                = false
    
    override init()
    {
        super.init()
        self.observe()
    }
    
    private func observe()
    {
        let o1 = self.observe( \.red   ) { ( o, c ) in self.updateColorFromRGB() }
        let o2 = self.observe( \.green ) { ( o, c ) in self.updateColorFromRGB() }
        let o3 = self.observe( \.blue  ) { ( o, c ) in self.updateColorFromRGB() }
        let o4 = self.observe( \.alpha ) { ( o, c ) in self.updateColorFromRGB() }
        let o5 = self.observe( \.color ) { ( o, c ) in self.updateColorFromColor() }
        
        let o6  = self.observe( \.red2    ) { ( o, c ) in self.updateVariantFromRGB() }
        let o7  = self.observe( \.green2  ) { ( o, c ) in self.updateVariantFromRGB() }
        let o8  = self.observe( \.blue2   ) { ( o, c ) in self.updateVariantFromRGB() }
        let o9  = self.observe( \.alpha2  ) { ( o, c ) in self.updateVariantFromRGB() }
        let o10 = self.observe( \.variant ) { ( o, c ) in self.updateVariantFromColor() }
        
        self.observations.append( contentsOf: [ o1, o2, o3, o4, o5, o6, o7, o8, o9, o10 ] )
    }
    
    private func updateColorFromRGB()
    {
        if( self.updating )
        {
            return
        }
        
        self.updating = true
        self.color    = NSColor( srgbRed: self.red, green: self.green, blue: self.blue, alpha: self.alpha )
        self.updating = false
    }
    
    private func updateColorFromColor()
    {
        if( self.updating )
        {
            return
        }
        
        self.updating = true
        
        ObjCTryCatch(
            {
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                self.color.getRed( &r, green: &g, blue: &b, alpha: &a )
                
                self.red   = r
                self.green = g
                self.blue  = b
                self.alpha = a
            },
            {
                ( e ) in
                
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                self.color.usingColorSpace( NSColorSpace.sRGB )?.getRed( &r, green: &g, blue: &b, alpha: &a )
                
                self.red   = r
                self.green = g
                self.blue  = b
                self.alpha = a
            }
        )
        
        self.updating = false
    }
    
    private func updateVariantFromRGB()
    {
        if( self.updating )
        {
            return
        }
        
        self.updating = true
        self.variant  = NSColor( srgbRed: self.red2, green: self.green2, blue: self.blue2, alpha: self.alpha2 )
        self.updating = false
    }
    
    private func updateVariantFromColor()
    {
        if( self.updating )
        {
            return
        }
        
        self.updating = true
        
        ObjCTryCatch(
            {
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                self.variant?.getRed( &r, green: &g, blue: &b, alpha: &a )
                
                self.red2   = r
                self.green2 = g
                self.blue2  = b
                self.alpha2 = a
            },
            {
                ( e ) in
                
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                self.variant?.usingColorSpace( NSColorSpace.sRGB )?.getRed( &r, green: &g, blue: &b, alpha: &a )
                
                self.red2   = r
                self.green2 = g
                self.blue2  = b
                self.alpha2 = a
            }
        )
        
        self.updating = false
    }
}
