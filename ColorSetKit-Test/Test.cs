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

            {
                if( p1.Color is SolidColorBrush c )
                {
                    Assert.AreEqual( c.Color.R, 50 );
                    Assert.AreEqual( c.Color.G, 100 );
                    Assert.AreEqual( c.Color.B, 150 );
                    Assert.AreEqual( c.Color.A, 128 );
                }
                else
                {
                    Assert.Fail( "Color is not defined" );
                }
            }

            if( p1.Variant != null )
            {
                Assert.Fail( "No variant should be defined" );
            }

            {
                if( p2.Color is SolidColorBrush c )
                {
                    Assert.AreEqual( c.Color.R, 250 );
                    Assert.AreEqual( c.Color.G, 200 );
                    Assert.AreEqual( c.Color.B, 150 );
                    Assert.AreEqual( c.Color.A, 191 );
                }
                else
                {
                    Assert.Fail( "Color is not defined" );
                }
            }

            {
                if( p2.Variant is SolidColorBrush c )
                {
                    Assert.AreEqual( c.Color.R, 200 );
                    Assert.AreEqual( c.Color.G, 150 );
                    Assert.AreEqual( c.Color.B, 250 );
                    Assert.AreEqual( c.Color.A, 64 );
                }
                else
                {
                    Assert.Fail( "Color is not defined" );
                }
            }
        }

        [TestMethod]
        public void TestColor()
        {
            if( new ColorSetKit.Color( "NoVariant" ).ProvideValue( null ) is SolidColorBrush c )
            {
                Assert.AreEqual( c.Color.R, 50 );
                Assert.AreEqual( c.Color.G, 100 );
                Assert.AreEqual( c.Color.B, 150 );
                Assert.AreEqual( c.Color.A, 128 );
            }
            else
            {
                Assert.Fail( "Cannot retrieve color from NSColor" );
            }
        }

        [TestMethod]
        public void TestCreate()
        {
            ColorSet                   set = new ColorSet();
            System.Windows.Media.Color c1  = new System.Windows.Media.Color();
            System.Windows.Media.Color c2  = new System.Windows.Media.Color();
            System.Windows.Media.Color c3  = new System.Windows.Media.Color();
            
            c1.R =  50; c1.G = 100; c1.B = 150; c1.A = 128;
            c2.R = 250; c2.G = 200; c2.B = 150; c2.A = 191;
            c3.R = 200; c3.G = 150; c3.B = 250; c3.A =  64;

            set.Add( new SolidColorBrush( c1 ), "NoVariant" );
            set.Add( new SolidColorBrush( c2 ), new SolidColorBrush( c3 ), "Variant" );

            set = new ColorSet( set.Data );
            
            Assert.AreEqual( set.Colors.Count, 2 );

            Assert.IsTrue( set.Colors.ContainsKey( "NoVariant" ) );
            Assert.IsTrue( set.Colors.ContainsKey( "Variant" ) );

            ColorPair p1 = set.Colors[ "NoVariant" ];
            ColorPair p2 = set.Colors[ "Variant" ];

            {
                if( p1.Color is SolidColorBrush c )
                {
                    Assert.AreEqual( c.Color.R, 50 );
                    Assert.AreEqual( c.Color.G, 100 );
                    Assert.AreEqual( c.Color.B, 150 );
                    Assert.AreEqual( c.Color.A, 128 );
                }
                else
                {
                    Assert.Fail( "Color is not defined" );
                }
            }

            if( p1.Variant != null )
            {
                Assert.Fail( "No variant should be defined" );
            }

            {
                if( p2.Color is SolidColorBrush c )
                {
                    Assert.AreEqual( c.Color.R, 250 );
                    Assert.AreEqual( c.Color.G, 200 );
                    Assert.AreEqual( c.Color.B, 150 );
                    Assert.AreEqual( c.Color.A, 191 );
                }
                else
                {
                    Assert.Fail( "Color is not defined" );
                }
            }

            {
                if( p2.Variant is SolidColorBrush c )
                {
                    Assert.AreEqual( c.Color.R, 200 );
                    Assert.AreEqual( c.Color.G, 150 );
                    Assert.AreEqual( c.Color.B, 250 );
                    Assert.AreEqual( c.Color.A, 64 );
                }
                else
                {
                    Assert.Fail( "Color is not defined" );
                }
            }
        }
    }
}
