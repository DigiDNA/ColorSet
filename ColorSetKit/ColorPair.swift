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
@objc public class ColorPair: NSObject
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
}
