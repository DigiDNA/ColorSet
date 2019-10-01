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

/**
 * Extension for `NSColor` to support colorset files.
 * 
 * - Authors:
 *      Jean-David Gadina
 */
@objc public extension NSColor
{
    /**
     * Gets a color from the shared `ColorSet` instance.
     * 
     * This methods will return the correct color, depending on the current
     * user interface mode.  
     * If the requested color is found and has a dark mode variant, and if
     * dark mode is on, the variant will be returned instead of the main color.
     * 
     * For this reason, you should never store color objects returned by this
     * method, but instead ask for the color each time you need it (eg. in
     * drawing code).  
     * This is because the user interface mode may change while the application
     * is running. As all views will be redrawned, this is to ensure the correct
     * color is used.
     * 
     * Lightness variants may be requested by adding a `.` (dot) and a lightness
     * value from `0` to `100` in the name, such as `SomeColor.75`.  
     * This will return the base color, with the lightness changed to 75%.  
     * Note that the lightness will be automatically reversed in dark mode
     * (if the lightness value coresponds to a predefined lightness pair, the
     * corresponding lightness will be used.
     * 
     * It's also possible to refer to lightness variants using names, if custom
     * names were added, such as `SomeColor.SomeVariant`.
     * 
     * Standard Cocoa colors can also be retrieved using the `NS` prefix,
     * such as `NSSecondaryLabelColor` for `NSColor.secondaryLabelColor`.
     * 
     * - parameter name:    The name of the color to retrieve.
     * 
     * - returns:   The color object, if found.
     */
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
        
        let components = NSColor.componentsForColorName( name )
        
        guard let pair = ColorSet.shared[ components.name ] else
        {
            return nil
        }
        
        let hsl       = pair.color?.hsl() ?? ( hue: 0, saturation: 0, lightness: 0, alpha: 0 )
        var lightness = components.lightness
        
        if let v = components.variant
        {
            for lp in pair.lightnesses
            {
                if lp.lightness1.name == v
                {
                    lightness = lp.lightness1.lightness
                    
                    break
                }
                
                if lp.lightness2.name == v
                {
                    lightness = lp.lightness2.lightness
                    
                    break
                }
            }
        }
        
        if var l = lightness, abs( hsl.lightness - l ) > 0.001
        {
            if isDarkModeOn()
            {
                var found = false
                
                for lp in pair.lightnesses
                {
                    if abs( lp.lightness1.lightness - l ) < 0.001
                    {
                        l     = lp.lightness2.lightness
                        found = true
                        
                        break
                    }
                    else if abs( lp.lightness2.lightness - l ) < 0.001
                    {
                        l     = lp.lightness1.lightness
                        found = true
                        
                        break
                    }
                }
                
                if found == false
                {
                    l = 1.0 - l
                }
            }
            
            return pair.color?.byChangingLightness( l )
        }
        
        if isDarkModeOn(), let variant = pair.variant
        {
            return variant
        }
        
        return pair.color
    }
    
    /**
     * Creates a color from `HSL` components.
     * 
     * Note that the `HSL` values will be converted to `RGB`.  
     * The color object will be created using `sRGB` values.
     * 
     * - parameter hue:         The hue component - `0` to `1`.
     * - parameter saturation:  The saturation component - `0` to `1`.
     * - parameter lightness:   The lightness component - `0` to `1`.
     * - parameter alpha:       The alpha component - `0` to `1`.
     */
    @objc convenience init( hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat )
    {
        let rgb = NSColor.hslToRGB( hue, saturation, lightness )
        
        self.init( srgbRed: rgb.0, green: rgb.1, blue: rgb.2, alpha: alpha )
    }
    
    /**
     * Finds the best text color for a specific background color, to
     * ensure a good contrast ration between the text and the background
     * color.
     * 
     * Note that the returned text color will either be black or white,
     * depending on the background color.
     * 
     * - parameter background:  The background color
     * 
     * - returns:   A suitable text color for the background color.
     * 
     * - Seealso: `bestTextColorForBackgroundColor(_:lightTextColor:darkTextColor:)`
     */
    @objc class func bestTextColorForBackgroundColor( _ background: NSColor ) -> NSColor
    {
        return NSColor.bestTextColorForBackgroundColor( background, lightTextColor: NSColor.white, darkTextColor: NSColor.black )
    }
    
    /**
     * Finds the best text color for a specific background color, to
     * ensure a good contrast ration between the text and the background
     * color.
     * 
     * The caller is responsible for passing two alternative text colors.  
     * The light one will be choosen on dark backgrounds, while the dark one
     * will be chosen on light backgrounds.
     * 
     * In order to ensure a good contrast ratio, these two colors should be
     * close to black and white.
     * 
     * - parameter background:      The background color
     * - parameter lightTextColor:  The light text color (for use on dark backgrounds).
     * - parameter darkTextColor:   The dark text color (for use on light backgrounds).
     * 
     * - returns:   Depending on the background color, either the `lightTextColor` or the `darkTextColor` parameter.
     * 
     * - Seealso: `bestTextColorForBackgroundColor(_:)`
     */
    @objc class func bestTextColorForBackgroundColor( _ background: NSColor, lightTextColor: NSColor, darkTextColor: NSColor ) -> NSColor
    {
        guard var rgb = background.usingColorSpace( .sRGB )?.rgb() else
        {
            return NSColor.textColor
        }
        
        rgb.red   *= 255
        rgb.green *= 255
        rgb.blue  *= 255
        
        let contrast = ( ( rgb.red * 299 ) + ( rgb.green * 587 ) + ( rgb.blue * 114 ) ) / 1000
        
        return ( contrast > 150 ) ? darkTextColor : lightTextColor
    }
    
    /**
     * Gets the color as an RGB hexadecimal string, prefixed with `#`.
     */
    @objc var hexString: String
    {
        let rgb = self.rgb()
        
        return String( format: "#%02X%02X%02X", Int( rgb.red * 255 ), Int( rgb.green * 255 ), Int( rgb.blue * 255 ) )
    }
    
    /**
     * Gets the `HSL` components of the color.
     * 
     * - parameter hue:         Upon return, contains the hue component of the color object - `0` to `1`.
     * - parameter saturation:  Upon return, contains the saturation component of the color object - `0` to `1`.
     * - parameter lightness:   Upon return, contains the lightness component of the color object - `0` to `1`.
     * - parameter alpha:       Upon return, contains the alphas component of the color object - `0` to `1`.
     */
    @objc func getHue( _ hue: UnsafeMutablePointer< CGFloat >?, saturation: UnsafeMutablePointer< CGFloat >?, lightness: UnsafeMutablePointer< CGFloat >?, alpha: UnsafeMutablePointer< CGFloat >? )
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let hsl = NSColor.rgbToHSL( r, g, b )
        
        hue?.pointee        = hsl.0
        saturation?.pointee = hsl.1
        lightness?.pointee  = hsl.2
        alpha?.pointee      = a
    }
    
    /**
     * Gets the `RGB` components of the color as a tuple.
     * 
     * - returns:   A tuple with the `RGB` components.
     */
    @nonobjc func rgb() -> ( red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat )
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        return ( red: r, green: g, blue: b, alpha: a )
    }
    
    /**
     * Gets the `HSB` components of the color as a tuple.
     * 
     * - returns:   A tuple with the `HSB` components.
     */
    @nonobjc func hsb() -> ( hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat )
    {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getHue( &h, saturation: &s, brightness: &b, alpha: &a )
        
        return ( hue: h, saturation: s, brightness: b, alpha: a )
    }
    
    /**
     * Gets the `HSL` components of the color as a tuple.
     * 
     * - returns:   A tuple with the `HSL` components.
     */
    @nonobjc func hsl() -> ( hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat )
    {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var l: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getHue( &h, saturation: &s, lightness: &l, alpha: &a )
        
        return ( hue: h, saturation: s, lightness: l, alpha: a )
    }
    
    /**
     * Creates a new color by modifying the hue components of the `HSL`
     * representation.
     * 
     * - returns:   The new color
     */
    @objc func byChangingHue( _ h: CGFloat ) -> NSColor
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let hsl = NSColor.rgbToHSL( r, g, b )
        
        return NSColor( hue: h, saturation: hsl.1, lightness: hsl.2, alpha: a )
    }
    
    /**
     * Creates a new color by modifying the saturation components of the `HSL`
     * representation.
     * 
     * - returns:   The new color
     */
    @objc func byChangingSaturation( _ s: CGFloat ) -> NSColor
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let hsl = NSColor.rgbToHSL( r, g, b )
        
        return NSColor( hue: hsl.0, saturation: s, lightness: hsl.2, alpha: a )
    }
    
    /**
     * Creates a new color by modifying the lightness components of the `HSL`
     * representation.
     * 
     * - returns:   The new color
     */
    @objc func byChangingLightness( _ l: CGFloat ) -> NSColor
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let hsl = NSColor.rgbToHSL( r, g, b )
        
        return NSColor( hue: hsl.0, saturation: hsl.1, lightness: l, alpha: a )
    }
    
    @nonobjc private class func componentsForColorName( _ name: String ) -> ( name: String, lightness: CGFloat?, variant: String? )
    {
        guard let r = name.range( of: ".", options: .backwards ) else
        {
            return ( name: name, lightness: nil, variant: nil )
        }
        
        let s1 = String( name[ name.index( name.startIndex, offsetBy: 0 ) ..< name.index( r.lowerBound, offsetBy: 0 ) ] )
        let s2 = String( name[ name.index( r.lowerBound, offsetBy: 1 )... ] )
        
        if let i = Int( s2 )
        {
            return ( name: s1, lightness: CGFloat( i ) / 100.0, variant: s2 )
        }
        
        return ( name: s1, lightness: nil, variant: s2 )
    }
    
    @nonobjc private class func hslToRGB( _ h: CGFloat, _ s: CGFloat, _ l: CGFloat ) -> ( CGFloat, CGFloat, CGFloat )
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
    
    @nonobjc private class func rgbToHSL( _ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> ( CGFloat, CGFloat, CGFloat )
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
    
    @nonobjc private class func isDarkModeOn() -> Bool
    {
        if #available( macOS 10.14, * )
        {
            if NSApp != nil && NSApp.effectiveAppearance.name == NSAppearance.Name.darkAqua
            {
                return true
            }
        }
        
        return false
    }
}
