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
 * Represents a pair of lightness variants for a specific color.
 * 
 * Lightness means the `L` component in the `HSL` color representation.
 * 
 * Lightness variants are used in pairs, making it easy to handle dark
 * mode for user interfaces.  
 * Requestting a specific lightness variant for a color will automatically
 * return the corresponding value in the pair if dark mode is on.
 * 
 * - Authors:
 *      Jean-David Gadina
 * 
 * - Seealso: `LightnessVariant`
 */
@objc public class LightnessPair: NSObject, DictionaryRepresentable
{
    /**
     * The first lightness variant.
     */
    @objc public dynamic var lightness1 = LightnessVariant()
    
    /**
     * The second lightness variant.
     */
    @objc public dynamic var lightness2 = LightnessVariant()
    
    @objc public override init()
    {}
    
    @objc public required init?( dictionary: [ String : Any ] )
    {
        guard let dict1 = dictionary[ "lightness1" ] as? [ String : Any ],
              let dict2 = dictionary[ "lightness2" ] as? [ String : Any ]
        else
        {
            return nil
        }
        
        guard let lightness1 = LightnessVariant( dictionary: dict1 ),
              let lightness2 = LightnessVariant( dictionary: dict2 )
        else
        {
            return nil
        }
        
        self.lightness1 = lightness1
        self.lightness2 = lightness2
    }
    
    @objc public func toDictionary() -> [ String : Any ]
    {
        var dict = [ String : Any ]()
        
        dict[ "lightness1" ] = self.lightness1.toDictionary()
        dict[ "lightness2" ] = self.lightness2.toDictionary()
        
        return dict
    }
}
