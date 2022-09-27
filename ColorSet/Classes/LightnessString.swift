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
class LightnessString: ValueTransformer
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
        let n = ( ( value as? NSNumber )?.doubleValue ?? 0 ) * 100

        return String( describing: Int( n ) )
    }

    @objc
    public override func reverseTransformedValue( _ value: Any? ) -> Any?
    {
        let s = value as? String ?? "0"
        var i = Int( s ) ?? 0

        if i > 100
        {
            i = 100
        }
        else if i < 0
        {
            i = 0
        }

        return NSNumber( floatLiteral: Double( i ) / 100.0 )
    }
}
