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

@objc class LightnessPairItem: NSObject
{
    @objc class LightnessVariant: NSObject
    {
        @objc public dynamic      var lightness: CGFloat = 0
        @objc public dynamic weak var base:      ColorItem?
        @objc public dynamic      var name:      String?
        
        @objc public private( set ) dynamic var labelColor: NSColor?
        @objc public private( set ) dynamic var color:      NSColor?
        
        private var observations = [ NSKeyValueObservation ]()
        
        override init()
        {
            super.init()
            
            let o1 = self.observe( \.lightness   ) { [ weak self ] o, c in self?.update() }
            let o2 = self.observe( \.base?.color ) { [ weak self ] o, c in self?.update() }
            
            self.observations.append( contentsOf: [ o1, o2 ] )
        }
        
        convenience init( base: ColorItem )
        {
            self.init()
            
            self.base = base
        }
        
        private func update()
        {
            self.labelColor = ( self.lightness < 0.5 ) ? NSColor.white : NSColor.black
            
            if let color = self.base?.color
            {
                self.color = color.usingColorSpace( .sRGB )?.byChangingLightness( self.lightness )
            }
        }
    }
    
    @objc public private( set ) dynamic var lightness1 = LightnessVariant()
    @objc public private( set ) dynamic var lightness2 = LightnessVariant()
}
