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
 * Represents a color pair.
 * 
 * Color pairs contains a primary color, as well as an optional variant
 * for the dark mode and optional lightness variants..
 * 
 * - Authors:
 *      Jean-David Gadina
 * 
 * - Seealso: `LightnessPair`
 */
@objc public class ColorPair: NSObject, DictionaryRepresentable
{
    /**
     * The main/primary color.
     */
    @objc public dynamic var color: NSColor?
    
    /**
     * An optional color variant to use on dark mode interfaces.
     */
    @objc public dynamic var variant: NSColor?
    
    /**
     * Predefined lightness variants for the main/primary color.
     */
    @objc public dynamic var lightnesses: [ LightnessPair ] = []
    
    /**
     * Default convenience initializer.  
     * Returns a color pair with no color, variant or lightness variant.
     * 
     * - Seealso: `init(color:)`
     * - Seealso: `init(color:variant:)`
     */
    @objc public convenience override init()
    {
        self.init( color: nil, variant: nil )
    }
    
    /**
     * Initializes a color pair with a color.  
     * No variant or lightness variant will be set.
     * 
     * - parameter color:   The main/primary color
     * 
     * - Seealso: `init()`
     * - Seealso: `init(color:variant:)` 
     */
    @objc public convenience init( color: NSColor? )
    {
        self.init( color: color, variant: nil )
    }
    
    /**
     * Initializes a color pair with a color and a dark mode variant.
     * 
     * - parameter color:   The main/primary color
     * - parameter variant: The variant color for the dark mode 
     * 
     * - Seealso: `init()`
     * - Seealso: `init(color:)` 
     */
    @objc public init( color: NSColor?, variant: NSColor? )
    {
        self.color   = color
        self.variant = variant
    }
    
    @objc public required init?( dictionary: [ String : Any ] )
    {
        super.init()
        
        if let color = self.colorFromDictionary( dictionary[ "color" ] as? [ String : Any ] )
        {
            self.color = color
        }
        
        if let variant = self.colorFromDictionary( dictionary[ "variant" ] as? [ String : Any ] )
        {
            self.variant = variant
        }
        
        if let lightnesses = dictionary[ "lightnesses" ] as? [ [ String : Any ] ]
        {
            for l in lightnesses
            {
                if let lightness = LightnessPair( dictionary: l )
                {
                    self.lightnesses.append( lightness )
                }
            }
        }
    }
    
    @objc public func toDictionary() -> [ String : Any ]
    {
        var dict        = [ String : Any ]()
        var lightnesses = [ [ String : Any ] ]()
        
        dict[ "color" ]   = self.colorToDictionary( self.color )
        dict[ "variant" ] = self.colorToDictionary( self.variant )
        
        for l in self.lightnesses
        {
            lightnesses.append( l.toDictionary() )
        }
        
        dict[ "lightnesses" ] = lightnesses
        
        return dict
    }
    
    private func colorToDictionary( _ color: NSColor? ) -> [ String : Any ]?
    {
        guard let color = color else
        {
            return nil
        }
        
        guard let hsl = color.usingColorSpace( .sRGB )?.hsl() else
        {
            return nil
        }
        
        return [ "h" : hsl.hue, "s" : hsl.saturation, "l" : hsl.lightness, "a" : hsl.alpha ]
    }
    
    private func colorFromDictionary( _ dictionary: [ String : Any ]? ) -> NSColor?
    {
        guard let dictionary = dictionary else
        {
            return nil
        }
        
        guard let h = dictionary[ "h" ] as? CGFloat,
              let s = dictionary[ "s" ] as? CGFloat,
              let l = dictionary[ "l" ] as? CGFloat,
              let a = dictionary[ "a" ] as? CGFloat
        else
        {
            return nil
        }
        
        return NSColor( hue: h, saturation: s, lightness: l, alpha: a )
    }
}
