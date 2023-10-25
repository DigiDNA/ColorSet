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

namespace ColorSetKit
{
    public static class ColorExtensions
    {
        private struct HSL
        {
            public double Hue;
            public double Saturation;
            public double Lightness;
        }

        private struct RGB
        {
            public double Red;
            public double Green;
            public double Blue;
        }

        public struct HSLComponents
        {
            public double Hue;
            public double Saturation;
            public double Lightness;
            public double Alpha;
        }

        public struct RGBComponents
        {
            public double Red;
            public double Green;
            public double Blue;
            public double Alpha;
        }

        public static System.Windows.Media.Color FromHSL( double hue, double saturation, double lightness, double alpha )
        {
            RGB rgb = HSLToRGB( hue, saturation, lightness );

            return new System.Windows.Media.Color
            {
                R = ( byte )( Math.Floor( rgb.Red   * 255 ) ),
                G = ( byte )( Math.Floor( rgb.Green * 255 ) ),
                B = ( byte )( Math.Floor( rgb.Blue  * 255 ) ),
                A = ( byte )( Math.Floor( alpha     * 100 ) )
            };
        }

        public static System.Windows.Media.Color BestTextColorForBackgroundColor( System.Windows.Media.Color background )
        {
            return BestTextColorForBackgroundColor( background, System.Windows.Media.Color.FromRgb( 255, 255, 255 ), System.Windows.Media.Color.FromRgb( 0, 0, 0 ) );
        }

        public static System.Windows.Media.Color BestTextColorForBackgroundColor( System.Windows.Media.Color background, System.Windows.Media.Color lightTextColor, System.Windows.Media.Color darkTextColor )
        {
            double r = background.R;
            double g = background.G;
            double b = background.B;

            double contrast = ( ( r * 299 ) + ( g * 287 ) + ( b * 114 ) ) / 1000;

            return ( contrast > 150 ) ? darkTextColor : lightTextColor;
        }

        public static RGBComponents GetRGB( this System.Windows.Media.Color self )
        {
            return new RGBComponents
            {
                Red   = self.R / 255.0,
                Green = self.G / 255.0,
                Blue  = self.B / 255.0,
                Alpha = self.A / 100.0
            };
        }

        public static HSLComponents GetHSL( this System.Windows.Media.Color self )
        {
            HSL hsl = RGBToHSL( self.R / 255.0, self.G / 255.0, self.B / 255.0 );

            return new HSLComponents
            {
                Hue        = hsl.Hue,
                Saturation = hsl.Saturation,
                Lightness  = hsl.Lightness,
                Alpha      = self.A / 100.0,
            };
        }

        public static System.Windows.Media.Color ByChangingHue( this System.Windows.Media.Color self, double h )
        {
            RGBComponents rgb = self.GetRGB();
            HSL           hsl = RGBToHSL( rgb.Red, rgb.Green, rgb.Blue );

            return FromHSL( h, hsl.Saturation, hsl.Lightness, rgb.Alpha );
        }

        public static System.Windows.Media.Color ByIncreasingHue( this System.Windows.Media.Color self, double h )
        {
            return self.ByChangingHue( self.GetHSL().Hue + h );
        }

        public static System.Windows.Media.Color ByDecreasingHue( this System.Windows.Media.Color self, double h )
        {
            return self.ByChangingHue( self.GetHSL().Hue - h );
        }

        public static System.Windows.Media.Color ByChangingSaturation( this System.Windows.Media.Color self, double s )
        {
            RGBComponents rgb = self.GetRGB();
            HSL           hsl = RGBToHSL( rgb.Red, rgb.Green, rgb.Blue );

            return FromHSL( hsl.Hue, s, hsl.Lightness, rgb.Alpha );
        }

        public static System.Windows.Media.Color ByIncreasingSaturation( this System.Windows.Media.Color self, double s )
        {
            return self.ByChangingSaturation( self.GetHSL().Saturation + s );
        }

        public static System.Windows.Media.Color ByDecreasingSaturation( this System.Windows.Media.Color self, double s )
        {
            return self.ByChangingSaturation( self.GetHSL().Saturation - s );
        }

        public static System.Windows.Media.Color ByChangingLightness( this System.Windows.Media.Color self, double l )
        {
            RGBComponents rgb = self.GetRGB();
            HSL           hsl = RGBToHSL( rgb.Red, rgb.Green, rgb.Blue );

            return FromHSL( hsl.Hue, hsl.Saturation, l, rgb.Alpha );
        }

        public static System.Windows.Media.Color ByIncreasingLightness( this System.Windows.Media.Color self, double l )
        {
            return self.ByChangingLightness( self.GetHSL().Lightness + l );
        }

        public static System.Windows.Media.Color ByDecreasingLightness( this System.Windows.Media.Color self, double l )
        {
            return self.ByChangingLightness( self.GetHSL().Lightness - l );
        }

        private static RGB HSLToRGB( double h, double s, double l )
        {
            double   t1;
            double   t2;
            double[] rgb = { 0, 0, 0 };

            if( s == 0.0 )
            {
                return new RGB { Red = l, Green = l, Blue = l };
            }

            if( l < 0.5 )
            {
                t2 = l * ( 1.0 + s );
            }
            else
            {
                t2 = l + s - ( l * s );
            }

            t1 = ( 2.0 * l ) - t2;

            rgb[ 0 ] = h + ( 1.0 / 3.0 );
            rgb[ 1 ] = h;
            rgb[ 2 ] = h - ( 1.0 / 3.0 );

            for( int i = 0; i < 3; i++ )
            {
                if( rgb[ i ] < 0.0 )
                {
                    rgb[ i ] += 1.0;
                }
                else if( rgb[ i ] > 1.0 )
                {
                    rgb[ i ] -= 1.0;
                }

                if( rgb[ i ] * 6.0 < 1.0 )
                {
                    rgb[ i ] = t1 + ( ( t2 - t1 ) * 6.0 * rgb[ i ] );
                }
                else if( rgb[ i ] * 2.0 < 1.0 )
                {
                    rgb[ i ] = t2;
                }
                else if( rgb[ i ] * 3.0 < 2.0 )
                {
                    rgb[ i ] = t1 + ( ( t2 - t1 ) * ( ( 2.0 / 3.0 ) - rgb[ i ] ) * 6.0 );
                }
                else
                {
                    rgb[ i ] = t1;
                }
            }

            return new RGB { Red = rgb[ 0 ], Green = rgb[ 1 ], Blue = rgb[ 2 ] };
        }

        private static HSL RGBToHSL( double r, double g, double b )
        {
            double v = Math.Max( Math.Max( r, g ), b );
            double m = Math.Min( Math.Min( r, g ), b );
            double h = 0;
            double s = 0;
            double l;
            double vm;
            double r2;
            double g2;
            double b2;

            l = ( m + v ) / 2.0;

            if( l <= 0.0 )
            {
                return new HSL { Hue = h, Saturation = s, Lightness = l };
            }

            vm = v - m;
            s  = vm;

            if( s > 0.0 )
            {
                s /= ( ( l <= 0.5 ) ? v + m : 2.0 - v - m );
            }
            else
            {
                return new HSL { Hue = h, Saturation = s, Lightness = l };
            }

            r2 = ( v - r ) / vm;
            g2 = ( v - g ) / vm;
            b2 = ( v - b ) / vm;

            if( r == v )
            {
                h = ( g == m ) ? 5.0 + b2 : 1.0 - g2;
            }
            else if( g == v )
            {
                h = ( b == m ) ? 1.0 + r2 : 3.0 - b2;
            }
            else
            {
                h = ( r == m ) ? 3.0 + g2 : 5.0 - r2;
            }

            h /= 6.0;

            return new HSL { Hue = h, Saturation = s, Lightness = l };
        }
    }
}
