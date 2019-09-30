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
        let textColor = ( hsl.lightness >= 0.5 ) ? NSColor.black : NSColor.white
        var p         = NSMakePoint( rect.origin.x + 10, rect.origin.y + 10 )
        
        ( info.name as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 25, weight: .thin ) ] )
        
        p.y += 30
        
        ( ( "HEX: " + base.hexString ) as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 12, weight: .thin ) ] )
        
        let hslString = String( format: "HSL: %.0f, %.0f, %.0f", hsl.hue * 360, hsl.saturation * 100, hsl.lightness * 100 )
        p.y          += 15
        
        ( hslString as NSString ).draw( at: p, withAttributes: [ .foregroundColor : textColor, .font : NSFont.systemFont( ofSize: 12, weight: .thin ) ] )
    }
}
