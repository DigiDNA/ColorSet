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

public class LightnessPairCollectionViewItem: NSCollectionViewItem
{
    @IBOutlet private var color1: ColorView!
    @IBOutlet private var color2: ColorView!
    
    public override func viewDidLoad()
    {
        self.color1.bind( NSBindingName( "color" ), to: self, withKeyPath: "representedObject.lightness1.color", options: nil )
        self.color2.bind( NSBindingName( "color" ), to: self, withKeyPath: "representedObject.lightness2.color", options: nil )
    }
    
    @IBAction func edit( _ sender: Any? )
    {
        if let item = self.representedObject as? LightnessPairItem
        {
            item.onEdit?( item )
        }
    }
    
    @IBAction func delete( _ sender: Any? )
    {
        if let item = self.representedObject as? LightnessPairItem
        {
            item.onDelete?( item )
        }
    }
}
