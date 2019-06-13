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
using System.Net;
using System.Text;
using System.Windows.Media;

namespace ColorSetKit
{
    public partial class ColorSetStream
    {
        public Data Data
        {
            get;
            private set;
        }

        private ulong Pos
        {
            get;
            set;
        }
        = 0;

        private object Lock
        {
            get;
        }
        = new object();

        public ColorSetStream()
        {
            this.Data = new Data();
        }

        public ColorSetStream( Data data )
        {
            this.Data = data;
        }

        public string ReadString()
        {
            lock( this.Lock )
            {
                if( this.Read( 8, out byte[] nb ) )
                {
                    ulong n = BitConverter.ToUInt64( nb, 0 );

                    if( n == 0 )
                    {
                        return null;
                    }

                    if( this.Read( n, out byte[] data ) == false )
                    {
                        return null;
                    }

                    if( data.Length == 0 )
                    {
                        return "";
                    }

                    if( data.Last() == 0 )
                    {
                        data = data.Take( data.Length - 1 ).ToArray();
                    }

                    return Encoding.UTF8.GetString( data ) ?? "";
                }

                return null;
            }
        }

        public SolidColorBrush ReadColor()
        {
            lock( this.Lock )
            {
                if
                (
                       this.Read( 8, out byte[] rb ) == false
                    || this.Read( 8, out byte[] gb ) == false
                    || this.Read( 8, out byte[] bb ) == false
                    || this.Read( 8, out byte[] ab ) == false
                )
                {
                    return null;
                }

                double r = BitConverter.ToDouble( rb, 0 );
                double g = BitConverter.ToDouble( gb, 0 );
                double b = BitConverter.ToDouble( bb, 0 );
                double a = BitConverter.ToDouble( ab, 0 );

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

        public byte ReadUInt8()
        {
            lock( this.Lock )
            {
                if( this.Read( 1, out byte[] buffer ) )
                {
                    return buffer[ 0 ];
                }

                return 0;
            }
        }

        public ushort ReadUInt16()
        {
            lock( this.Lock )
            {
                if( this.Read( 2, out byte[] buffer ) )
                {
                    return BitConverter.ToUInt16( buffer, 0 );
                }

                return 0;
            }
        }

        public uint ReadUInt32()
        {
            lock( this.Lock )
            {
                if( this.Read( 4, out byte[] buffer ) )
                {
                    return BitConverter.ToUInt32( buffer, 0 );
                }

                return 0;
            }
        }

        public ulong ReadUInt64()
        {
            lock( this.Lock )
            {
                if( this.Read( 8, out byte[] buffer ) )
                {
                    return BitConverter.ToUInt64( buffer, 0 );
                }

                return 0;
            }
        }

        public float ReadFloat()
        {
            lock( this.Lock )
            {
                if( this.Read( 4, out byte[] buffer ) )
                {
                    return BitConverter.ToSingle( buffer, 0 );
                }

                return 0;
            }
        }

        public double ReadDouble()
        {
            lock( this.Lock )
            {
                if( this.Read( 8, out byte[] buffer ) )
                {
                    return BitConverter.ToDouble( buffer, 0 );
                }

                return 0;
            }
        }

        public bool ReadBool()
        {
            lock( this.Lock )
            {
                return this.ReadUInt8() != 0;
            }
        }

        public bool Read( ulong size, out byte[] buffer )
        {
            lock( this.Lock )
            {
                if( this.Pos < this.Data.Count + size )
                {
                    buffer = new byte[ size ];

                    this.Data.CopyBytes( buffer, this.Pos, size );

                    this.Pos += size;

                    return true;
                }
                else
                {
                    buffer = null;

                    return false;
                }
            }
        }

        public void Append( string value )
        {
            lock( this.Lock )
            {
                byte[] data = Encoding.ASCII.GetBytes( value );

                this.Append( ( ulong )( value.Length + 1 ) );
                this.Data.Append( data );
                this.Append( 0 );
            }
        }

        public void Append( SolidColorBrush value )
        {
            lock( this.Lock )
            {
                double r = value.Color.R;
                double g = value.Color.G;
                double b = value.Color.B;
                double a = value.Color.A;

                r /= 255;
                g /= 255;
                b /= 255;
                a /= 255;

                this.Append( r );
                this.Append( g );
                this.Append( b );
                this.Append( a );
            }
        }

        public void Append( byte value )
        {
            lock( this.Lock )
            {
                this.Data.Append( new byte[] { value } );
            }
        }

        public void Append( ushort value )
        {
            lock( this.Lock )
            {
                if( BitConverter.IsLittleEndian == false )
                {
                    value = ( ushort )IPAddress.HostToNetworkOrder( ( short )value );
                }

                this.Data.Append( BitConverter.GetBytes( value ) );
            }
        }

        public void Append( uint value )
        {
            lock( this.Lock )
            {
                if( BitConverter.IsLittleEndian == false )
                {
                    value = ( uint )IPAddress.HostToNetworkOrder( ( int )value );
                }

                this.Data.Append( BitConverter.GetBytes( value ) );
            }
        }

        public void Append( ulong value )
        {
            lock( this.Lock )
            {
                if( BitConverter.IsLittleEndian == false )
                {
                    value = ( ulong )IPAddress.HostToNetworkOrder( ( long )value );
                }

                this.Data.Append( BitConverter.GetBytes( value ) );
            }
        }

        public void Append( float value )
        {
            lock( this.Lock )
            {
                this.Data.Append( BitConverter.GetBytes( value ) );
            }
        }

        public void Append( double value )
        {
            lock( this.Lock )
            {
                this.Data.Append( BitConverter.GetBytes( value ) );
            }
        }

        public void Append( bool value )
        {
            lock( this.Lock )
            {
                this.Append( ( value ) ? ( byte )1 : ( byte )0 );
            }
        }

        public static ColorSetStream operator +( ColorSetStream s, string value )
        {
            s.Append( value );

            return s;
        }

        public static ColorSetStream operator +( ColorSetStream s, SolidColorBrush value )
        {
            s.Append( value );

            return s;
        }

        public static ColorSetStream operator +( ColorSetStream s, byte value )
        {
            s.Append( value );

            return s;
        }

        public static ColorSetStream operator +( ColorSetStream s, ushort value )
        {
            s.Append( value );

            return s;
        }

        public static ColorSetStream operator +( ColorSetStream s, uint value )
        {
            s.Append( value );

            return s;
        }

        public static ColorSetStream operator +( ColorSetStream s, ulong value )
        {
            s.Append( value );

            return s;
        }

        public static ColorSetStream operator +( ColorSetStream s, float value )
        {
            s.Append( value );

            return s;
        }

        public static ColorSetStream operator +( ColorSetStream s, double value )
        {
            s.Append( value );

            return s;
        }

        public static ColorSetStream operator +( ColorSetStream s, bool value )
        {
            s.Append( value );

            return s;
        }
    }
}
