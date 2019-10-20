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

@objc public class PaletteColorItem: NSCollectionViewItem
{
    public override var nibName: NSNib.Name?
    {
        return NSNib.Name( NSStringFromClass( type( of: self ) ) )
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
        guard let info = self.representedObject as? PaletteColorInfo else
        {
            return
        }
        
        guard var base = info.colorPair.color?.usingColorSpace( .sRGB ) else
        {
            return
        }
        
        if #available( macOS 10.14, * )
        {
            if NSApp.effectiveAppearance.name == .darkAqua, let variant = info.colorPair.variant?.usingColorSpace( .sRGB )
            {
                base = variant
            }
        }
        
        base.setFill()
        rect.fill()
        
        let hsl       = base.hsl()
        let textColor = NSColor.bestTextColorForBackgroundColor( base )
        var p         = NSMakePoint( rect.origin.x + 10, rect.origin.y + 10 )
        
        ( info.name as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 25, weight: .thin ) ] )
        
        p.y += 30
        
        ( ( "HEX: " + base.hexString ) as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 12, weight: .thin ) ] )
        
        let hslString = String( format: "HSL: %.0f, %.0f, %.0f", hsl.hue * 360, hsl.saturation * 100, hsl.lightness * 100 )
        p.y          += 15
        
        ( hslString as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 12, weight: .thin ) ] )
        
        var lightnesses = [ ( CGFloat, NSColor ) ]()
        
        for lp in info.colorPair.lightnesses
        {
            let l1 = lp.lightness1.lightness
            let l2 = lp.lightness2.lightness
            var c1 = base.byChangingLightness( l1 )
            var c2 = base.byChangingLightness( l2 )
            
            if #available( macOS 10.14, * )
            {
                if NSApp.effectiveAppearance.name == .darkAqua
                {
                    swap( &c1, &c2 )
                }
            }
            
            lightnesses.append( ( l1, c1 ) )
            lightnesses.append( ( l2, c2 ) )
        }
        
        if let color = info.colorPair.color?.usingColorSpace( .sRGB )
        {
            lightnesses.append( ( color.hsl().lightness, color ) )
        }
        
        if let variant = info.colorPair.variant?.usingColorSpace( .sRGB )
        {
            lightnesses.append( ( variant.hsl().lightness, variant ) )
        }
        
        lightnesses.sort
        {
            l1, l2 in l1.0 > l2.0
        }
        
        if lightnesses.count > 0
        {
            let width     = rect.size.width / CGFloat( lightnesses.count )
            var r         = rect
            r.size.width  = width
            r.size.height = r.size.height / 4
            r.origin.y    = rect.size.height - r.size.height
            
            for lightness in lightnesses
            {
                let color = lightness.1
                
                color.setFill()
                r.fill()
                
                let textColor = NSColor.bestTextColorForBackgroundColor( color )
                let p         = NSMakePoint( r.origin.x - 8 + ( r.size.width / 2 ), r.origin.y - 5 + ( r.size.height / 2 ) )
                
                String( format: "%.0f", lightness.0 * 100 ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 10, weight: .thin ) ] )
                
                r.origin.x += width
            }
        }
    }
}
