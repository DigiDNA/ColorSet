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
using System.Reflection;
using System.Text;
using System.Windows.Media;

namespace ColorSetKit
{
    public partial class ColorSet
    {
        private static readonly ulong Magic = 0x434F4C4F52534554;
        private static ColorSet _Shared     = null;
        private static object   _SharedLock = new object();

        public static ColorSet Shared
        {
            get
            {
                lock( _SharedLock )
                {
                    if( _Shared == null )
                    {
                        string path = Assembly.GetExecutingAssembly().Location;
                        
                        _Shared = new ColorSet( System.IO.Path.Combine( System.IO.Path.GetDirectoryName( path ), "Colors.colorset" )  );
                    }

                    return _Shared;
                }
            }
        }
        
        public Dictionary< string, ColorPair > Colors
        {
            get
            {
                lock( this._Lock )
                {
                    return new Dictionary< string, ColorPair >( this._Colors );
                }
            }
        }
        
        private Dictionary< string, ColorPair > _Colors
        {
            get;
            set;
        }
        = new Dictionary< string, ColorPair >();

        private object _Lock
        {
            get;
        }
        = new object();

        public ColorSet()
        {}

        public ColorSet( string path ): this( new Data( path ) )
        {}

        public ColorSet( Data data )
        {
            if( data.Count == 0 )
            {
                return;
            }

            ColorSetStream stream = new ColorSetStream( data );

            if( stream.ReadUInt64() != Magic )
            {
                return;
            }

            if( stream.ReadUInt32() == 0 )
            {
                return;
            }

            stream.ReadUInt32();

            ulong n = stream.ReadUInt64();

            for( ulong i = 0; i < n; i++ )
            {
                if( !( stream.ReadString() is string name ) )
                {
                    return;
                }

                bool hasVariant = stream.ReadBool();

                if( !( stream.ReadColor() is SolidColorBrush color ) )
                {
                    return;
                }

                if( !( stream.ReadColor() is SolidColorBrush variant ) )
                {
                    return;
                }

                this.Add( color, ( hasVariant ) ? variant : null, name );
            }
        }

        public SolidColorBrush ColorNamed( string name )
        {
            lock( this._Lock )
            {
                if( this._Colors.ContainsKey( name ) )
                {
                    return this._Colors[ name ].Color;
                }

                return null;
            }
        }

        public void Add( SolidColorBrush color, string name )
        {
            this.Add( color, null, name );
        }

        public void Set( SolidColorBrush color, string name )
        {
            this.Set( color, null, name );
        }

        public void Add( SolidColorBrush color, SolidColorBrush variant, string name )
        {
            lock( this._Lock )
            {
                if( this._Colors.ContainsKey( name ) == false )
                {
                    this.Set( color, variant, name );
                }
            }
        }
        
        public void Set( SolidColorBrush color, SolidColorBrush variant, string name )
        {
            if( name == null )
            {
                return;
            }

            lock( this._Lock )
            {
                this._Colors[ name ] = new ColorPair( color, variant );
            }
        }

        public Data Data
        {
            get
            {
                Dictionary< string, ColorPair > colors = this.Colors;
                ColorSetStream                  stream = new ColorSetStream();
                System.Windows.Media.Color      clear  = new System.Windows.Media.Color();

                clear.R = 0;
                clear.G = 0;
                clear.B = 0;
                clear.A = 0;

                stream += Magic;                     /* COLORSET */
                stream += ( uint )1;                 /* Major */
                stream += ( uint )0;                 /* Minor */
                stream += ( ulong )( colors.Count ); /* Count */

                foreach( KeyValuePair< string, ColorPair > p in colors )
                {
                    stream += p.Key;
                    stream += p.Value.Variant != null;
                    stream += p.Value.Color   ?? new SolidColorBrush( clear );
                    stream += p.Value.Variant ?? new SolidColorBrush( clear );
                }

                return stream.Data;
            }
        }
    }
}
