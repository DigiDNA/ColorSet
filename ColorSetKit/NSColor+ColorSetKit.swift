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

@objc public extension NSColor
{
    private static var mainColorSet: ColorSet?
    private static var lock        = NSLock()
    
    @objc class func colorFrom( colorSet name: String ) -> NSColor?
    {
        lock.lock()
        
        if mainColorSet == nil
        {
            if let path = Bundle.main.path( forResource: "Colors", ofType: "colorset" )
            {
                if FileManager.default.fileExists( atPath: path )
                {
                    mainColorSet = ColorSet( path:  path )
                }
            }
        }
        
        lock.unlock()
        
        if name.hasPrefix( "NS" )
        {
            var selectorName = String( name[ name.index( name.startIndex, offsetBy: 2 )... ] )
            
            if selectorName.count > 0
            {
                selectorName = ( selectorName as NSString ).replacingCharacters( in: NSMakeRange( 0, 1 ), with: String( selectorName[ selectorName.startIndex ] ).lowercased() )
            }
            
            let sel = NSSelectorFromString( selectorName )
            
            if NSColor.responds( to: sel )
            {
                return NSColor.perform( sel )?.takeUnretainedValue() as? NSColor
            }
            
        }
        
        let pair = mainColorSet?.colors[ name ]
        
        if #available( macOS 10.14, * )
        {
            if let variant = pair?.variant
            {
                if NSApp.effectiveAppearance.name == NSAppearance.Name.darkAqua
                {
                    return variant
                }
            }
        }
        
        return pair?.color
    }
}
