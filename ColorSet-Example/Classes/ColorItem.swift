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
import ColorSetKit

@objc public class ColorItem: NSCollectionViewItem
{
    public override var nibName: NSNib.Name?
    {
        return NSNib.Name( "ColorItem" )
    }
    
    public override func viewDidLoad()
    {
        guard let view = self.view as? DrawingView else
        {
            return
        }
        
        view.onDraw = { [ weak self ] rect in self?.drawColors( rect: rect ) }
    }
    
    private func drawColors( rect: NSRect )
    {
        guard let info = self.representedObject as? ColorInfo else
        {
            return
        }
        
        guard let base = NSColor.from( colorSet: info.name ) else
        {
            return
        }
        
        base.setFill()
        rect.fill()
        
        var h = CGFloat( 0 )
        var s = CGFloat( 0 )
        var l = CGFloat( 0 )
        var r = CGFloat( 0 )
        var g = CGFloat( 0 )
        var b = CGFloat( 0 )
        
        base.getHue( &h, saturation: &s, lightness: &l, alpha: nil )
        base.getRed( &r, green: &g, blue: &b, alpha: nil )
        
        let textColor = ( l > 0.65 ) ? NSColor.black : NSColor.white
        var p         = NSMakePoint( rect.origin.x + 10, rect.origin.y + 10 )
        
        ( info.name as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 25, weight: .thin ) ] )
        
        let hex = String( format: "HEX: #%02X%02X%02X", Int( r * 255 ), Int( g * 255 ), Int( b * 255 ) )
        p.y    += 30
        
        ( hex as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 12, weight: .thin ) ] )
        
        let hsl = String( format: "HSL: %.0f, %.0f, %.0f", h * 360, s * 100, l * 100 )
        p.y    += 15
        
        ( hsl as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 12, weight: .thin ) ] )
        
        var variants = info.variants
        
        if variants.count > 0
        {
            if let pair = ColorSet.shared[ info.name ]
            {
                if let color = pair.color
                {
                    variants.append( color.hsl().lightness )
                }
                
                if let variant = pair.variant
                {
                    variants.append( variant.hsl().lightness )
                }
                
                variants.sort()
                variants.reverse()
            }
            
            let width     = rect.size.width / CGFloat( variants.count )
            var r         = rect
            r.size.width  = width
            r.size.height = r.size.height / 4
            r.origin.y    = rect.size.height - r.size.height
            
            for lightness in variants
            {
                guard let color = NSColor.from( colorSet: info.name + "." + String( format: "%.0f", lightness * 100 ) ) else
                {
                    continue
                }
                
                color.setFill()
                r.fill()
                
                var l = CGFloat( 0 )
                
                color.getHue( nil, saturation: nil, lightness: &l, alpha: nil )
                
                let textColor = ( l > 0.5 ) ? NSColor.black : NSColor.white
                let p         = NSMakePoint( r.origin.x - 8 + ( r.size.width / 2 ), r.origin.y - 5 + ( r.size.height / 2 ) )
                
                String( format: "%.0f", lightness * 100 ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 10, weight: .thin ) ] )
                
                r.origin.x += width
            }
        }
    }
}
