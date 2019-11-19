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
 * Represents a lightness variant for a specific color.
 * 
 * Lightness means the `L` component in the `HSL` color representation.
 * 
 * - Authors:
 *      Jean-David Gadina
 */
@objc public class LightnessVariant: NSObject, DictionaryRepresentable
{
    /**
     * The lightness value - `0` to `1`.
     */
    @objc public dynamic var lightness: CGFloat = 0
    
    /**
     * An optional name for the lightness variant.
     */
    @objc public dynamic var name: String  = ""
    
    @objc public override init()
    {}
    
    @objc public required init?( dictionary: [ String : Any ] )
    {
        if let lightness = dictionary[ "lightness" ] as? CGFloat
        {
            self.lightness = lightness
        }
        
        if let name = dictionary[ "name" ] as? String
        {
            self.name = name
        }
    }
    
    @objc public func toDictionary() -> [ String : Any ]
    {
        var dict = [ String : Any ]()
        
        dict[ "lightness" ] = self.lightness
        dict[ "name" ]      = self.name
        
        return dict
    }
}
