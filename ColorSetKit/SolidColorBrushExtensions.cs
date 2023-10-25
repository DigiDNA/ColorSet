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
    public static class SolidColorBrushExtensions
    {
        public static System.Windows.Media.SolidColorBrush ByChangingHue( this System.Windows.Media.SolidColorBrush self, double h )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByChangingHue( h ) );
        }
        public static System.Windows.Media.SolidColorBrush ByIncreasingHue( this System.Windows.Media.SolidColorBrush self, double h )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByIncreasingHue( h ) );
        }
        public static System.Windows.Media.SolidColorBrush ByDecreasingHue( this System.Windows.Media.SolidColorBrush self, double h )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByDecreasingHue( h ) );
        }

        public static System.Windows.Media.SolidColorBrush ByChangingSaturation( this System.Windows.Media.SolidColorBrush self, double s )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByChangingSaturation( s ) );
        }

        public static System.Windows.Media.SolidColorBrush ByIncreasingSaturation( this System.Windows.Media.SolidColorBrush self, double s )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByIncreasingSaturation( s ) );
        }

        public static System.Windows.Media.SolidColorBrush ByDecreasingSaturation( this System.Windows.Media.SolidColorBrush self, double s )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByDecreasingSaturation( s ) );
        }

        public static System.Windows.Media.SolidColorBrush ByChangingLightness( this System.Windows.Media.SolidColorBrush self, double l )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByChangingLightness( l ) );
        }

        public static System.Windows.Media.SolidColorBrush ByIncreasingLightness( this System.Windows.Media.SolidColorBrush self, double l )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByIncreasingLightness( l ) );
        }

        public static System.Windows.Media.SolidColorBrush ByDecreasingLightness( this System.Windows.Media.SolidColorBrush self, double l )
        {
            return new System.Windows.Media.SolidColorBrush( self.Color.ByDecreasingLightness( l ) );
        }

        public static System.Windows.Media.SolidColorBrush ByChangingOpacity( this System.Windows.Media.SolidColorBrush self, double o )
        {
            System.Windows.Media.SolidColorBrush copy = self.Clone();
            copy.Opacity                              = o;

            return copy;
        }

        public static System.Windows.Media.SolidColorBrush ByIncreasingOpacity( this System.Windows.Media.SolidColorBrush self, double o )
        {
            return self.ByChangingOpacity( self.Opacity + o );
        }

        public static System.Windows.Media.SolidColorBrush ByDecreasingOpacity( this System.Windows.Media.SolidColorBrush self, double o )
        {
            return self.ByChangingOpacity( self.Opacity - o );
        }
    }
}
