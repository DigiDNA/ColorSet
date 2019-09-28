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
    @objc public dynamic var name           = "Untitled"
    @objc public dynamic var hasVariant     = false
    @objc public dynamic var lightnessPairs = [ LightnessPairItem ]()
    
    @objc public dynamic var color:   NSColor = NSColor.black
    @objc public dynamic var variant: NSColor?
    
    @objc public dynamic var red:        CGFloat = 0.0
    @objc public dynamic var green:      CGFloat = 0.0
    @objc public dynamic var blue:       CGFloat = 0.0
    @objc public dynamic var hue:        CGFloat = 0.0
    @objc public dynamic var saturation: CGFloat = 0.0
    @objc public dynamic var lightness:  CGFloat = 0.0
    @objc public dynamic var alpha:      CGFloat = 1.0
    
    @objc public dynamic var red2:        CGFloat = 0.0
    @objc public dynamic var green2:      CGFloat = 0.0
    @objc public dynamic var blue2:       CGFloat = 0.0
    @objc public dynamic var hue2:        CGFloat = 0.0
    @objc public dynamic var saturation2: CGFloat = 0.0
    @objc public dynamic var lightness2:  CGFloat = 0.0
    @objc public dynamic var alpha2:      CGFloat = 1.0
    
    @objc public private( set ) dynamic var primaryTitle = "Color"
    
    private var observations: [ NSKeyValueObservation ] = []
    private var updating                                = false
    
    override init()
    {
        super.init()
        self.observe()
    }
    
    private func observe()
    {
        let o1 = self.observe( \.red         ) { [ weak self ] ( o, c ) in self?.updateColorFromRGB() }
        let o2 = self.observe( \.green       ) { [ weak self ] ( o, c ) in self?.updateColorFromRGB() }
        let o3 = self.observe( \.blue        ) { [ weak self ] ( o, c ) in self?.updateColorFromRGB() }
        let o4 = self.observe( \.hue         ) { [ weak self ] ( o, c ) in self?.updateColorFromHSL() }
        let o5 = self.observe( \.saturation  ) { [ weak self ] ( o, c ) in self?.updateColorFromHSL() }
        let o6 = self.observe( \.lightness   ) { [ weak self ] ( o, c ) in self?.updateColorFromHSL() }
        let o7 = self.observe( \.alpha       ) { [ weak self ] ( o, c ) in self?.updateColorFromRGB() }
        let o8 = self.observe( \.color       ) { [ weak self ] ( o, c ) in self?.updateColorFromColor( updateHSL: true ) }
        
        let o9  = self.observe( \.red2        ) { [ weak self ] ( o, c ) in self?.updateVariantFromRGB() }
        let o10 = self.observe( \.green2      ) { [ weak self ] ( o, c ) in self?.updateVariantFromRGB() }
        let o11 = self.observe( \.blue2       ) { [ weak self ] ( o, c ) in self?.updateVariantFromRGB() }
        let o12 = self.observe( \.hue2        ) { [ weak self ] ( o, c ) in self?.updateVariantFromHSL() }
        let o13 = self.observe( \.saturation2 ) { [ weak self ] ( o, c ) in self?.updateVariantFromHSL() }
        let o14 = self.observe( \.lightness2  ) { [ weak self ] ( o, c ) in self?.updateVariantFromHSL() }
        let o15 = self.observe( \.alpha2      ) { [ weak self ] ( o, c ) in self?.updateVariantFromRGB() }
        let o16 = self.observe( \.variant     ) { [ weak self ] ( o, c ) in self?.updateVariantFromColor( updateHSL: true ) }
        
        let o17 = self.observe( \.hasVariant )
        {
            [ weak self ] o, c in self?.primaryTitle = ( self?.hasVariant ?? false ) ? "Light Mode Color" : "Color"
        }
        
        self.observations.append( contentsOf: [ o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, o17 ] )
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
        
        self.updateColorFromColor( updateHSL: true )
    }
    
    private func updateColorFromHSL()
    {
        if( self.updating )
        {
            return
        }
        
        self.updating = true
        self.color    = NSColor( hue: self.hue, saturation: self.saturation, lightness: self.lightness, alpha: self.alpha )
        self.updating = false
        
        self.updateColorFromColor( updateHSL: false )
    }
    
    private func updateColorFromColor( updateHSL: Bool )
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
                var h: CGFloat = 0.0
                var s: CGFloat = 0.0
                var l: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                self.color.getRed( &r, green: &g, blue: &b, alpha: &a )
                self.color.getHue( &h, saturation: &s, lightness: &l, alpha: nil )
                
                self.red        = r
                self.green      = g
                self.blue       = b
                self.alpha      = a
                
                if updateHSL
                {
                    self.hue        = h
                    self.saturation = s
                    self.lightness  = l
                }
            },
            {
                ( e ) in
                
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
                var h: CGFloat = 0.0
                var s: CGFloat = 0.0
                var l: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                self.color.usingColorSpace( NSColorSpace.sRGB )?.getRed( &r, green: &g, blue: &b, alpha: &a )
                self.color.usingColorSpace( NSColorSpace.sRGB )?.getHue( &h, saturation: &s, lightness: &l, alpha: nil )
                
                self.red        = r
                self.green      = g
                self.blue       = b
                self.alpha      = a
                
                if updateHSL
                {
                    self.hue        = h
                    self.saturation = s
                    self.lightness  = l
                }
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
        
        self.updateVariantFromColor( updateHSL: true )
    }
    
    private func updateVariantFromHSL()
    {
        if( self.updating )
        {
            return
        }
        
        self.updating = true
        self.variant  = NSColor( hue: self.hue2, saturation: self.saturation2, lightness: self.lightness2, alpha: self.alpha2 )
        self.updating = false
        
        self.updateVariantFromColor( updateHSL: false )
    }
    
    private func updateVariantFromColor( updateHSL: Bool )
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
                var h: CGFloat = 0.0
                var s: CGFloat = 0.0
                var l: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                self.variant?.getRed( &r, green: &g, blue: &b, alpha: &a )
                self.variant?.getHue( &h, saturation: &s, lightness: &l, alpha: nil )
                
                self.red2        = r
                self.green2      = g
                self.blue2       = b
                self.alpha2      = a
                
                if updateHSL
                {
                    self.hue2        = h
                    self.saturation2 = s
                    self.lightness2  = l
                }
            },
            {
                ( e ) in
                
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
                var h: CGFloat = 0.0
                var s: CGFloat = 0.0
                var l: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                self.variant?.usingColorSpace( NSColorSpace.sRGB )?.getRed( &r, green: &g, blue: &b, alpha: &a )
                self.variant?.usingColorSpace( NSColorSpace.sRGB )?.getHue( &h, saturation: &s, lightness: &l, alpha: nil )
                
                self.red2        = r
                self.green2      = g
                self.blue2       = b
                self.alpha2      = a
                
                if updateHSL
                {
                    self.hue2        = h
                    self.saturation2 = s
                    self.lightness2  = l
                }
            }
        )
        
        self.updating = false
    }
}
