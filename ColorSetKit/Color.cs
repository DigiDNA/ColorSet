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

        public override object ProvideValue( IServiceProvider provider )
        {
            if( ColorSet.Shared.ColorNamed( this.Name ) is ColorPair pair )
            {
                if( this.Variant && pair.Variant != null )
                {
                    return pair.Variant;
                }

                return pair.Color ?? this.Fallback;
            }

            return this.Fallback;
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
