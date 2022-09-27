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

import ColorSetKit
import XCTest

class Test: XCTestCase
{
    private var bundle: Bundle?

    override func setUp()
    {
        self.bundle = Bundle( for: type( of: self ) )
    }

    func testInitWithURLBinary()
    {
        guard let url = self.bundle?.url( forResource: "Colors", withExtension: "colorset" )
        else
        {
            XCTFail( "Cannot get URL of colorset file" )
            return
        }

        guard let _ = ColorSet( url: url )
        else
        {
            XCTFail( "Cannot create colorset file" )
            return
        }
    }

    func testInitWithURLXML()
    {
        guard let url = self.bundle?.url( forResource: "Colors-XML", withExtension: "colorset" )
        else
        {
            XCTFail( "Cannot get URL of colorset file" )
            return
        }

        guard let _ = ColorSet( url: url )
        else
        {
            XCTFail( "Cannot create colorset file" )
            return
        }
    }

    func testInitWithPathBinary()
    {
        guard let path = self.bundle?.path( forResource: "Colors", ofType: "colorset" )
        else
        {
            XCTFail( "Cannot get URL of colorset file" )
            return
        }

        guard let _ = ColorSet( path: path )
        else
        {
            XCTFail( "Cannot create colorset file" )
            return
        }
    }

    func testInitWithPathXML()
    {
        guard let path = self.bundle?.path( forResource: "Colors-XML", ofType: "colorset" )
        else
        {
            XCTFail( "Cannot get URL of colorset file" )
            return
        }

        guard let _ = ColorSet( path: path )
        else
        {
            XCTFail( "Cannot create colorset file" )
            return
        }
    }

    func testInitWithDataBinary()
    {
        guard let path = self.bundle?.path( forResource: "Colors", ofType: "colorset" )
        else
        {
            XCTFail( "Cannot get URL of colorset file" )
            return
        }

        guard let data = FileManager.default.contents( atPath: path )
        else
        {
            XCTFail( "Cannot read contents of colorset file" )
            return
        }

        guard let _ = ColorSet( data: data )
        else
        {
            XCTFail( "Cannot create colorset file" )
            return
        }
    }

    func testInitWithDataXML()
    {
        guard let path = self.bundle?.path( forResource: "Colors-XML", ofType: "colorset" )
        else
        {
            XCTFail( "Cannot get URL of colorset file" )
            return
        }

        guard let data = FileManager.default.contents( atPath: path )
        else
        {
            XCTFail( "Cannot read contents of colorset file" )
            return
        }

        guard let _ = ColorSet( data: data )
        else
        {
            XCTFail( "Cannot create colorset file" )
            return
        }
    }

    func testShared()
    {
        XCTAssertEqual( ColorSet.shared.colors.count, 2 )

        guard let p1 = ColorSet.shared[ "NoVariant" ]
        else
        {
            XCTFail( "Cannot retrieve color from shared color set file" )
            return
        }

        guard let p2 = ColorSet.shared[ "Variant" ]
        else
        {
            XCTFail( "Cannot retrieve color from shared color set file" )
            return
        }

        if let c = p1.color
        {
            XCTAssertEqual( c.redComponent   * 255,  50.0 )
            XCTAssertEqual( c.greenComponent * 255, 100.0 )
            XCTAssertEqual( c.blueComponent  * 255, 150.0 )
            XCTAssertEqual( c.alphaComponent,         0.5 )
        }
        else
        {
            XCTFail( "Color is not defined" )
        }

        if let _ = p1.variant
        {
            XCTFail( "No variant should be defined" )
        }

        if let c = p2.color
        {
            XCTAssertEqual( c.redComponent   * 255, 250.0 )
            XCTAssertEqual( c.greenComponent * 255, 200.0 )
            XCTAssertEqual( c.blueComponent  * 255, 150.0 )
            XCTAssertEqual( c.alphaComponent,       0.75 )
        }
        else
        {
            XCTFail( "Color is not defined" )
        }

        if let c = p2.variant
        {
            XCTAssertEqual( c.redComponent   * 255, 200.0 )
            XCTAssertEqual( c.greenComponent * 255, 150.0 )
            XCTAssertEqual( c.blueComponent  * 255, 250.0 )
            XCTAssertEqual( c.alphaComponent,       0.25 )
        }
        else
        {
            XCTFail( "Color is not defined" )
        }
    }

    func testNSColor()
    {
        if let c = NSColor.fromColorSet( name: "NoVariant" )
        {
            XCTAssertEqual( c.redComponent   * 255,  50.0 )
            XCTAssertEqual( c.greenComponent * 255, 100.0 )
            XCTAssertEqual( c.blueComponent  * 255, 150.0 )
            XCTAssertEqual( c.alphaComponent,         0.5 )
        }
        else
        {
            XCTFail( "Cannot retrieve color from NSColor" )
            return
        }
    }

    func testChild()
    {
        let set   = ColorSet()
        let child = ColorSet()
        let clear = NSColor.clear
        let red   = NSColor.red

        XCTAssertNil( set[ "foo" ] )

        set.add( child: child )

        XCTAssertNil( set[ "foo" ] )

        child.add( color: red, forName: "foo" )

        XCTAssertNotNil( set[ "foo" ] )
        XCTAssertTrue( set[ "foo" ]!.color === red )

        set.add( color: clear, forName: "foo" )

        XCTAssertNotNil( set[ "foo" ] )
        XCTAssertTrue( set[ "foo" ]!.color === clear )
    }

    func testCreate()
    {
        var set = ColorSet()

        set.add( color: NSColor( red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4 ), forName: "NoVariant" )
        set.add( color: NSColor( red: 0.5, green: 0.6, blue: 0.7, alpha: 0.8 ), variant: NSColor( red: 0.8, green: 0.7, blue: 0.6, alpha: 0.5 ), forName: "Variant" )

        set = ColorSet( data: set.data ) ?? ColorSet()

        XCTAssertEqual( set.colors.count, 2 )

        guard let p1 = set[ "NoVariant" ]
        else
        {
            XCTFail( "Cannot retrieve color from shared color set file" )
            return
        }

        guard let p2 = set[ "Variant" ]
        else
        {
            XCTFail( "Cannot retrieve color from shared color set file" )
            return
        }

        if let c = p1.color
        {
            XCTAssertEqual( c.redComponent,   0.1 )
            XCTAssertEqual( c.greenComponent, 0.2 )
            XCTAssertEqual( c.blueComponent,  0.3 )
            XCTAssertEqual( c.alphaComponent, 0.4 )
        }
        else
        {
            XCTFail( "Color is not defined" )
        }

        if let _ = p1.variant
        {
            XCTFail( "No variant should be defined" )
        }

        if let c = p2.color
        {
            XCTAssertEqual( c.redComponent,   0.5 )
            XCTAssertEqual( c.greenComponent, 0.6 )
            XCTAssertEqual( c.blueComponent,  0.7 )
            XCTAssertEqual( c.alphaComponent, 0.8 )
        }
        else
        {
            XCTFail( "Color is not defined" )
        }

        if let c = p2.variant
        {
            XCTAssertEqual( c.redComponent,   0.8 )
            XCTAssertEqual( c.greenComponent, 0.7 )
            XCTAssertEqual( c.blueComponent,  0.6 )
            XCTAssertEqual( c.alphaComponent, 0.5 )
        }
        else
        {
            XCTFail( "Color is not defined" )
        }
    }
}
