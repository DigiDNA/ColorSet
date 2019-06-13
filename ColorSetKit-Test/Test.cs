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

using System;
using System.Reflection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ColorSetKit;
using System.Windows.Media;

namespace ColorSetKit_Test
{
    [TestClass]
    public class Test
    {
        [TestMethod]
        public void TestInitWithPath()
        {
            string path  = System.IO.Path.Combine( System.IO.Path.GetDirectoryName( Assembly.GetExecutingAssembly().Location ), "Colors.colorset" );
            ColorSet set = new ColorSet( path );

            Assert.IsTrue( set.Colors.Count > 0 );
        }

        [TestMethod]
        public void TestInitWithData()
        {
            string path  = System.IO.Path.Combine( System.IO.Path.GetDirectoryName( Assembly.GetExecutingAssembly().Location ), "Colors.colorset" );
            Data data    = new Data( path );
            ColorSet set = new ColorSet( data );

            Assert.IsTrue( set.Colors.Count > 0 );
        }

        [TestMethod]
        public void TestShared()
        {
            Assert.AreEqual( ColorSet.Shared.Colors.Count, 2 );

            Assert.IsTrue( ColorSet.Shared.Colors.ContainsKey( "NoVariant" ) );
            Assert.IsTrue( ColorSet.Shared.Colors.ContainsKey( "Variant" ) );

            ColorPair p1 = ColorSet.Shared.Colors[ "NoVariant" ];
            ColorPair p2 = ColorSet.Shared.Colors[ "Variant" ];

            if( p1.Color is SolidColorBrush c )
            {
                Assert.AreEqual( c.Color.R,  50 );
                Assert.AreEqual( c.Color.G, 100 );
                Assert.AreEqual( c.Color.B, 150 );
                Assert.AreEqual( ( double )( c.Color.A ) / 256, 0.5 );
            }
            else
            {
                Assert.Fail( "Color is not defined" );
            }

            if( p1.Variant != null )
            {
                Assert.Fail( "No variant should be defined" );
            }
        }

        /*
        func testShared()
        {
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
            if let c = NSColor.colorFrom( colorSet: "NoVariant" )
            {
                XCTAssertEqual( c.redComponent   * 255,  50.0 )
                XCTAssertEqual( c.greenComponent * 255, 100.0 )
                XCTAssertEqual( c.blueComponent  * 255, 150.0 )
                XCTAssertEqual( c.alphaComponent,         0.5 )
            }
            else
            {
                XCTFail( "Cannot retrieve color from NSColor" ); return
            }
        }
    
        func testCreate()
        {
            var set = ColorSet()
        
            set.add( color: NSColor( red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4 ), forName: "NoVariant" )
            set.add( color: NSColor( red: 0.5, green: 0.6, blue: 0.7, alpha: 0.8 ), variant: NSColor( red: 0.8, green: 0.7, blue: 0.6, alpha: 0.5 ), forName: "Variant" )
        
            set = ColorSet( data: set.data ) ?? ColorSet()
        
            XCTAssertEqual( set.colors.count, 2 )
        
            guard let p1 = set.colors[ "NoVariant" ] else
            {
                XCTFail( "Cannot retrieve color from shared color set file" ); return
            }
        
            guard let p2 = set.colors[ "Variant" ] else
            {
                XCTFail( "Cannot retrieve color from shared color set file" ); return
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
         */
    }
}
