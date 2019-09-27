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

@objc public extension NSColor
{
    @objc class func from( colorSet name: String ) -> NSColor?
    {
        if name.hasPrefix( "NS" )
        {
            var selectorName = String( name[ name.index( name.startIndex, offsetBy: 2 )... ] )
            
            if selectorName.count > 0
            {
                selectorName = ( selectorName as NSString ).replacingCharacters( in: NSMakeRange( 0, 1 ), with: String( selectorName[ selectorName.startIndex ] ).lowercased() )
            }
            
            let sel = NSSelectorFromString( selectorName )
            
            if NSColor.responds( to: sel )
            {
                return NSColor.perform( sel )?.takeUnretainedValue() as? NSColor
            }
            
        }
        
        let pair = ColorSet.shared[ name ]
        
        if #available( macOS 10.14, * )
        {
            if let variant = pair?.variant
            {
                if NSApp.effectiveAppearance.name == NSAppearance.Name.darkAqua
                {
                    return variant
                }
            }
        }
        
        return pair?.color
    }
    
    @objc convenience init( hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat )
    {
        let rgb = hslToRGB( hue, saturation, lightness )
        
        self.init( srgbRed: rgb.0, green: rgb.1, blue: rgb.2, alpha: alpha )
    }
    
    @objc func getHue( _ hue: UnsafeMutablePointer< CGFloat >?, saturation: UnsafeMutablePointer< CGFloat >?, lightness: UnsafeMutablePointer< CGFloat >?, alpha: UnsafeMutablePointer< CGFloat >? )
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let hsl = rgbToHSL( r, g, b )
        
        hue?.pointee        = hsl.0
        saturation?.pointee = hsl.1
        lightness?.pointee  = hsl.2
        alpha?.pointee      = a
    }
    
    @objc func byChangingHue( _ h: CGFloat ) -> NSColor
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let hsl = rgbToHSL( r, g, b )
        
        return NSColor( hue: h, saturation: hsl.1, lightness: hsl.2, alpha: a )
    }
    
    @objc func byChangingSaturation( _ s: CGFloat ) -> NSColor
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let hsl = rgbToHSL( r, g, b )
        
        return NSColor( hue: hsl.0, saturation: s, lightness: hsl.2, alpha: a )
    }
    
    @objc func byChangingLightness( _ l: CGFloat ) -> NSColor
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let hsl = rgbToHSL( r, g, b )
        
        return NSColor( hue: hsl.0, saturation: hsl.1, lightness: l, alpha: a )
    }
}

fileprivate func hslToRGB( _ h: CGFloat, _ s: CGFloat, _ l: CGFloat ) -> ( CGFloat, CGFloat, CGFloat )
{
    var t1:  CGFloat     = 0.0
    var t2:  CGFloat     = 0.0
    var rgb: [ CGFloat ] = []
    
    if s == 0.0
    {
        return ( l, l, l )
    }
    
    if l < 0.5
    {
        t2 = l * ( 1.0 + s )
    }
    else
    {
        t2 = l + s - l * s
    }
    
    t1 = 2.0 * l - t2
    
    rgb.append( h + 1.0 / 3.0 )
    rgb.append( h )
    rgb.append( h - 1.0 / 3.0 )
  
    for i in 0 ..< 3
    {
        if rgb[ i ] < 0.0
        {
            rgb[ i ] += 1.0
        }
        else if rgb[ i ] > 1.0
        {
            rgb[ i ] -= 1.0
        }   
        
        if rgb[ i ] * 6.0 < 1.0
        {
            rgb[ i ] = t1 + ( t2 - t1 ) * 6.0 * rgb[ i ]
        }
        else if rgb[ i ] * 2.0 < 1.0
        {
            rgb[ i ] = t2
        }
        else if rgb[ i ] * 3.0 < 2.0
        {
            rgb[ i ] = t1 + ( t2 - t1 ) * ( ( 2.0 / 3.0 ) - rgb[ i ] ) * 6.0
        }
        else
        {
            rgb[ i ] = t1
        }
    }
    
    return ( rgb[ 0 ], rgb[ 1 ], rgb[ 2 ] )
}

fileprivate func rgbToHSL( _ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> ( CGFloat, CGFloat, CGFloat )
{
    var h:  CGFloat = 0.0
    var s:  CGFloat = 0.0
    var l:  CGFloat = 0.0
    let v:  CGFloat = max( max( r, g ), b )
    let m:  CGFloat = min( min( r, g ), b )
    var vm: CGFloat = 0.0
    var r2: CGFloat = 0.0
    var g2: CGFloat = 0.0
    var b2: CGFloat = 0.0
    
    l = ( m + v ) / 2.0
    
    if l <= 0.0
    {
        return ( h, s, l )
    }
    
    vm = v - m
    s  = vm
    
    if s > 0.0
    {
        s = s / ( ( l <= 0.5 ) ? v + m : 2.0 - v - m )
    }
    else
    {
        return ( h, s, l )
    }
    
    r2 = ( v - r ) / vm
    g2 = ( v - g ) / vm
    b2 = ( v - b ) / vm
  
    if r == v
    {
        h = ( g == m ) ? 5.0 + b2 : 1.0 - g2
    }
    else if g == v
    {
        h = ( b == m ) ? 1.0 + r2 : 3.0 - b2
    }
    else
    {
        h = ( r == m ) ? 3.0 + g2 : 5.0 - r2
    }
    
    h /= 6.0
    
    return ( h, s, l )
}
