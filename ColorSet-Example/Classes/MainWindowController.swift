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

class MainWindowController: NSWindowController
{
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet var collectionView:  NSCollectionView!
    
    @objc private dynamic var supportsDarkMode = false
    @objc private dynamic var appearanceIndex  = 0
          private         var observations     = [ NSKeyValueObservation ]()
    
    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name( "MainWindowController" )
    }
    
    override func windowDidLoad()
    {
        if #available( macOS 10.14, * )
        {
            self.supportsDarkMode = true
            self.appearanceIndex  = ( NSApp.effectiveAppearance.name == NSAppearance.Name.darkAqua ) ? 1 : 0
            
            let o1 = self.observe( \.appearanceIndex )
            {
                [ weak self ] o, c in guard let self = self else { return }
                
                NSApp.appearance = ( self.appearanceIndex == 0 ) ? NSAppearance( named: .aqua ) : NSAppearance( named: .darkAqua )
            }
            
            self.observations.append( o1 )
        }
        
        self.collectionView.register( ColorItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier( "ColorItem" ) )
        
        self.arrayController.sortDescriptors = [ NSSortDescriptor( key: "name", ascending: true ) ]
        
        self.load()
    }
    
    private func load()
    {
        for p in ColorSet.shared.colors
        {
            guard let color = p.value.color else
            {
                continue
            }
            
            var variants = [ CGFloat ]()
            
            variants.append( color.hsl().lightness )
            
            if let variant = p.value.variant
            {
                variants.append( variant.hsl().lightness )
            }
            
            for l in p.value.lightnesses
            {
                variants.append( l.lightness1.lightness )
                variants.append( l.lightness2.lightness )
            }
            
            variants.sort()
            variants.reverse()
            
            self.arrayController.addObject( ColorInfo( name: p.key, variants: variants ) )
        }
    }
}
