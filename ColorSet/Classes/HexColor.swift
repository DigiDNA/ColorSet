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

@objc
class HexColor: ValueTransformer
{
    @objc
    public override static func allowsReverseTransformation() -> Bool
    {
        return true
    }

    @objc
    public override static func transformedValueClass() -> Swift.AnyClass
    {
        return NSString.self
    }

    @objc
    public override func transformedValue( _ value: Any? ) -> Any?
    {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0

        guard let c = value as? NSColor
        else
        {
            return "#000000"
        }

        c.usingColorSpace( NSColorSpace.sRGB )?.getRed( &r, green: &g, blue: &b, alpha: nil )

        return NSString( format: "#%02X%02X%02X", UInt32( r * 255 ), UInt32( g * 255 ), UInt32( b * 255 ) )
    }

    override func reverseTransformedValue( _ value: Any? ) -> Any?
    {
        guard var s = value as? NSString
        else
        {
            return NSColor.black
        }

        if s.hasPrefix( "#" )
        {
            s = s.substring( from: 1 ) as NSString
        }
        else if s.hasPrefix( "0x" )
        {
            s = s.substring( from: 2 ) as NSString
        }

        if s.length != 6
        {
            return NSColor.black
        }

        var n: UInt32 = 0
        let scanner   = Scanner( string: s as String )

        scanner.scanHexInt32( &n )

        let r = ( n >> 16 ) & 0xFF
        let g = ( n >>  8 ) & 0xFF
        let b = n & 0xFF

        return NSColor( red: CGFloat( r ) / 255, green: CGFloat( g ) / 255, blue: CGFloat( b ) / 255, alpha: 1 )
    }
}
