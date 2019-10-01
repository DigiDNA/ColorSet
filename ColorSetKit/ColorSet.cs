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
        private static readonly ulong  Magic          = 0x434F4C4F52534554;
        private static readonly uint   Major          = 1;
        private static readonly uint   Minor          = 2;
        private static ColorSet        SharedInstance = null;
        private static readonly object SharedLock     = new object();

        public static ColorSet Shared
        {
            get
            {
                lock( SharedLock )
                {
                    if( SharedInstance == null )
                    {
                        Assembly assembly = Assembly.GetEntryAssembly() ?? Assembly.GetExecutingAssembly();

                        if( assembly == null )
                        {
                            throw new ApplicationException( "Cannot get entry assembly" );
                        }

                        if( !( assembly.GetName() is AssemblyName name ) )
                        {
                            throw new ApplicationException( "Cannot get entry assembly name" );
                        }

                        string path = System.IO.Path.Combine( System.IO.Path.GetDirectoryName( assembly.Location ), "Colors.colorset" );

                        if( System.IO.File.Exists( path ) )
                        {
                            SharedInstance = new ColorSet( path );
                        }
                        else
                        {
                            System.Resources.ResourceManager manager = new System.Resources.ResourceManager( name.Name + ".Properties.Resources", assembly );

                            SharedInstance = !( manager.GetObject( "Colors" ) is byte[] data ) || data.Length == 0 ? new ColorSet() : new ColorSet( new Data( data ) );
                        }
                    }

                    return SharedInstance;
                }
            }
        }
        
        private Dictionary< string, ColorPair > ColorPairs
        {
            get;
            set;
        }
        = new Dictionary< string, ColorPair >();
        
        private List< ColorSet > Children
        {
            get;
            set;
        }
        = new List< ColorSet >();

        private object Lock
        {
            get;
        }
        = new object();

        public Dictionary< string, ColorPair > Colors
        {
            get
            {
                lock( this.Lock )
                {
                    Dictionary< string, ColorPair > colors = new Dictionary< string, ColorPair >();

                    foreach( KeyValuePair< string, ColorPair > p in this.ColorPairs )
                    {
                        if( this.ColorNamed( p.Key ) is ColorPair color )
                        {
                            colors[ p.Key ] = color;
                        }
                    }

                    return colors;
                }
            }
        }

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

            uint major = stream.ReadUInt32();

            if( major == 0 )
            {
                return;
            }

            uint minor = stream.ReadUInt32();

            if( major > Major || minor > Minor )
            {
                return;
            }
            
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

                List< LightnessPair > lightnesses = new List< LightnessPair >();

                if( major > 1 || minor > 1 )
                {
                    ulong nn = stream.ReadUInt64();

                    for( ulong j = 0; j < nn; j++ )
                    {
                        LightnessPair p = new LightnessPair();

                        p.Lightness1.Lightness = stream.ReadDouble();
                        p.Lightness1.Name      = stream.ReadString() ?? "";
                        p.Lightness2.Lightness = stream.ReadDouble();
                        p.Lightness2.Name      = stream.ReadString() ?? "";

                        lightnesses.Add( p );
                    }
                }

                this.Add( color, ( hasVariant ) ? variant : null, lightnesses, name );
            }
        }

        public ColorPair this[ string key ]
        {
            get => this.ColorNamed( key );
        }

        public ColorPair ColorNamed( string name )
        {
            lock( this.Lock )
            {
                if( this.ColorPairs.ContainsKey( name ) )
                {
                    return this.ColorPairs[ name ];
                }

                foreach( ColorSet child in this.Children )
                {
                    if( child[ name ] is ColorPair color )
                    {
                        return color;
                    }
                }

                return null;
            }
        }

        public void Add( ColorSet child )
        {
            if( ReferenceEquals( this, child ) )
            {
                return;
            }

            lock( this.Lock )
            {

                this.Children.Add( child );
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
            this.Add( color, variant, null, name );
        }
        
        public void Set( SolidColorBrush color, SolidColorBrush variant, string name )
        {
            this.Set( color, variant, null, name );
        }

        public void Add( SolidColorBrush color, SolidColorBrush variant, List< LightnessPair > lightnesses, string name )
        {
            lock( this.Lock )
            {
                if( this.ColorPairs.ContainsKey( name ) == false )
                {
                    this.Set( color, variant, lightnesses, name );
                }
            }
        }
        
        public void Set( SolidColorBrush color, SolidColorBrush variant, List< LightnessPair > lightnesses, string name )
        {
            if( name == null )
            {
                return;
            }

            lock( this.Lock )
            {
                ColorPair p = new ColorPair( color, variant )
                {
                    Lightnesses = lightnesses ?? new List< LightnessPair >()
                };
                this.ColorPairs[ name ] = p;
            }
        }

        public Data Data
        {
            get
            {
                Dictionary< string, ColorPair > colors = this.ColorPairs;
                ColorSetStream                  stream = new ColorSetStream();
                System.Windows.Media.Color clear       = new System.Windows.Media.Color
                {
                    R = 0,
                    G = 0,
                    B = 0,
                    A = 0
                };

                stream += Magic;
                stream += Major;
                stream += Minor;
                stream += ( ulong )( colors.Count );

                foreach( KeyValuePair< string, ColorPair > p in colors )
                {
                    stream += p.Key;
                    stream += p.Value.Variant != null;
                    stream += p.Value.Color   ?? new SolidColorBrush( clear );
                    stream += p.Value.Variant ?? new SolidColorBrush( clear );
                    stream += ( ulong )( p.Value.Lightnesses?.Count ?? 0 );

                    foreach( LightnessPair lp in p.Value.Lightnesses )
                    {
                        LightnessVariant l1 = lp.Lightness1 ?? new LightnessVariant();
                        LightnessVariant l2 = lp.Lightness2 ?? new LightnessVariant();

                        stream += l1.Lightness;
                        stream += l1.Name ?? "";
                        stream += l2.Lightness;
                        stream += l2.Name ?? "";
                    }
                }

                return stream.Data;
            }
        }
    }
}
