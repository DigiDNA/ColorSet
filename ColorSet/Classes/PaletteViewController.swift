/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2022, DigiDNA
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa
import ColorSetKit

class PaletteViewController: NSViewController
{
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet var collectionView:  NSCollectionView!

    @objc private dynamic var supportsDarkMode = false
    @objc private dynamic var appearanceIndex  = 0
    private         var observations     = [ NSKeyValueObservation ]()

    @objc public dynamic var colorSet: ColorSet?

    override var nibName: NSNib.Name?
    {
        return NSNib.Name( NSStringFromClass( type( of: self ) ) )
    }

    override func viewDidLoad()
    {
        if #available( macOS 10.14, * )
        {
            self.supportsDarkMode = true
            self.appearanceIndex  = ( NSApp.effectiveAppearance.name == NSAppearance.Name.darkAqua ) ? 1 : 0

            let o = self.observe( \.appearanceIndex )
            {
                [ weak self ] o, c in guard let self = self else { return }

                NSApp.appearance = ( self.appearanceIndex == 0 ) ? NSAppearance( named: .aqua ) : NSAppearance( named: .darkAqua )
            }

            self.observations.append( o )
        }

        let o = self.observe( \.colorSet )
        {
            [ weak self ] o, c in self?.reload()
        }

        self.observations.append( o )

        self.collectionView.register( PaletteColorItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier( "PaletteColorItem" ) )

        self.arrayController.sortDescriptors = [ NSSortDescriptor( key: "name", ascending: true ) ]

        self.reload()
    }

    public func reload()
    {
        if let items = self.arrayController.content as? [ Any ]
        {
            self.arrayController.remove( contentsOf: items )
        }

        guard let set = self.colorSet
        else
        {
            return
        }

        for p in set.colors
        {
            var variants = [ CGFloat ]()

            for l in p.value.lightnesses
            {
                variants.append( l.lightness1.lightness )
                variants.append( l.lightness2.lightness )
            }

            variants.sort()
            variants.reverse()

            if let info = PaletteColorInfo( colorSet: set, name: p.key, variants: variants )
            {
                self.arrayController.addObject( info )
            }
        }
    }
}
