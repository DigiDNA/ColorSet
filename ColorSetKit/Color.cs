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
using System.Windows.Markup;
using System.Windows.Media;

namespace ColorSetKit
{
    [MarkupExtensionReturnType( typeof( SolidColorBrush ) )]
    public partial class Color: MarkupExtension
    {
        private struct NameComponents
        {
            public string  Name;
            public double? Lightness;
            public string  Variant;
        }

        public Color( string name ): this( name, false, null )
        {}

        public Color( string name, SolidColorBrush fallback ): this( name, false, fallback )
        {}

        public Color( string name, bool variant ): this( name, variant, null )
        {}

        public Color( string name, bool variant, SolidColorBrush fallback )
        {
            this.Name     = name;
            this.Variant  = variant;
            this.Fallback = fallback;
        }

        private NameComponents ComponentsForColorName( string name )
        {
            int index = name.LastIndexOf( '.' );

            if( index < 0 )
            {
                return new NameComponents { Name = name, Lightness = null, Variant = null };
            }

            string s1 = name.Substring( 0, index );
            string s2 = name.Substring( index + 1 );

            if( int.TryParse( s2, out int i ) )
            {
                return new NameComponents { Name = s1, Lightness = i / 100.0, Variant = null };
            }

            return new NameComponents { Name = s1, Lightness = null, Variant = s2 };
        }

        public override object ProvideValue( IServiceProvider provider )
        {
            NameComponents components = this.ComponentsForColorName( this.Name );

            if( !( ColorSet.Shared.ColorNamed( this.Name ) is ColorPair pair ) )
            {
                return this.Fallback;
            }

            ColorExtension.HSLComponents hsl       = pair.Color?.Color.GetHSL() ?? new ColorExtension.HSLComponents { Hue = 0, Saturation = 0, Lightness = 0, Alpha = 0 };
            double?                      lightness = components.Lightness;

            if( components.Variant is string v )
            {
                foreach( LightnessPair lp in pair.Lightnesses )
                {
                    if( v == lp.Lightness1.Name )
                    {
                        lightness = lp.Lightness1.Lightness;

                        break;
                    }

                    if( v == lp.Lightness2.Name )
                    {
                        lightness = lp.Lightness2.Lightness;

                        break;
                    }
                }
            }

            if( lightness.HasValue && lightness.Value is double l && Math.Abs( hsl.Lightness - l ) > 0.001 )
            {
                if( this.Variant )
                {
                    bool found = false;

                    foreach( LightnessPair lp in pair.Lightnesses )
                    {
                        if( Math.Abs( lp.Lightness1.Lightness - l ) < 0.001 )
                        {
                            l     = lp.Lightness2.Lightness;
                            found = true;

                            break;
                        }
                        else if( Math.Abs( lp.Lightness1.Lightness - l ) < 0.001 )
                        {
                            l     = lp.Lightness1.Lightness;
                            found = true;

                            break;
                        }
                    }

                    if( found == false )
                    {
                        l = 1.0 - l;
                    }
                }
                
                return ( pair.Color == null ) ? null : new SolidColorBrush( pair.Color.Color.ByChangingLightness( l ) );
            }

            if( this.Variant && pair.Variant is SolidColorBrush variant )
            {
                return variant;
            }

            return pair.Color;
        }

        [ConstructorArgument( "name" )]
        public string Name
        {
            get;
            set;
        }

        [ConstructorArgument( "variant" )]
        public bool Variant
        {
            get;
            set;
        }

        [ConstructorArgument( "fallback" )]
        public SolidColorBrush Fallback
        {
            get;
            set;
        }
    }
}
