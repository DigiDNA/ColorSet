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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Media;

namespace ColorSetKit
{
    public partial class ColorPair
    {
        public SolidColorBrush? Color
        {
            get;
            set;
        }

        public SolidColorBrush? Variant
        {
            get;
            set;
        }

        public List< LightnessPair > Lightnesses
        {
            get;
            set;
        }
        = new List< LightnessPair >();

        public ColorPair(): this( null, null )
        {}

        public ColorPair( SolidColorBrush? color ): this( color, null )
        {}

        public ColorPair( SolidColorBrush? color, SolidColorBrush? variant )
        {
            this.Color   = color;
            this.Variant = variant;
        }

        public ColorPair( Dictionary< string, object > dictionary ): this()
        {
            {
                if( dictionary.TryGetValue( "color", out object? o ) && ColorFromDictionary( o as Dictionary< string, object > ) is SolidColorBrush color )
                {
                    this.Color = color;
                }
            }

            {
                if( dictionary.TryGetValue( "variant", out object? o ) && ColorFromDictionary( o as Dictionary< string, object > ) is SolidColorBrush variant )
                {
                    this.Variant = variant;
                }
            }

            {
                if( dictionary.TryGetValue( "lightnesses", out object? o ) && o is List< object > list )
                {
                    foreach( object value in list )
                    {
                        if( !( value is Dictionary< string, object > l ) )
                        {
                            continue;
                        }

                        try
                        {
                            this.Lightnesses.Add( new LightnessPair( l ) );
                        }
                        catch
                        {}
                    }
                }
            }
        }

        public Dictionary< string, object > ToDictionary()
        {
            Dictionary< string, object > dict = new Dictionary< string, object >();

            {
                if( ColorToDictionary( this.Color ) is Dictionary< string, object > d )
                {
                    dict[ "color" ] = d;
                }
            }

            {
                if( ColorToDictionary( this.Variant ) is Dictionary< string, object > d )
                {
                    dict[ "variant" ] = d;
                }
            }

            List< Dictionary< string, object > > lightnesses = new List< Dictionary< string, object > >();

            foreach( LightnessPair l in this.Lightnesses )
            {
                lightnesses.Add( l.ToDictionary() );
            }

            dict[ "lightnesses" ] = lightnesses;

            return dict;
        }

        private static Dictionary< string, object >? ColorToDictionary( SolidColorBrush? color )
        {
            if( color == null )
            {
                return null;
            }

            ColorExtensions.RGBComponents rgb = color.Color.GetRGB();

            return new Dictionary< string, object >
            {
                { "r", rgb.Red },
                { "g", rgb.Green },
                { "b", rgb.Blue },
                { "a", rgb.Alpha }
            };
        }

        private static SolidColorBrush? ColorFromDictionary( Dictionary< string, object >? dictionary )
        {
            if( dictionary == null )
            {
                return null;
            }

            double r;
            double g;
            double b;
            double a;

            {
                if( dictionary.TryGetValue( "r", out object? o ) == false || !( o is double d ) )
                {
                    return null;
                }

                r = d;
            }

            {
                if( dictionary.TryGetValue( "g", out object? o ) == false || !( o is double d ) )
                {
                    return null;
                }

                g = d;
            }

            {
                if( dictionary.TryGetValue( "b", out object? o ) == false || !( o is double d ) )
                {
                    return null;
                }

                b = d;
            }

            {
                if( dictionary.TryGetValue( "a", out object? o ) == false || !( o is double d ) )
                {
                    return null;
                }

                a = d;
            }

            return new SolidColorBrush
            (
                System.Windows.Media.Color.FromArgb
                (
                    ( byte )Math.Round( a * 255 ),
                    ( byte )Math.Round( r * 255 ),
                    ( byte )Math.Round( g * 255 ),
                    ( byte )Math.Round( b * 255 )
                )
            );
        }
    }
}