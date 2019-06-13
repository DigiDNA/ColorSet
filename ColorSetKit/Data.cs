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
using System.IO;
using System.Linq;
using System.Text;

namespace ColorSetKit
{
    public partial class Data
    {
        public ulong Count
        {
            get
            {
                return ( ulong )( this.Bytes.Count );
            }
        }

        private List< byte > Bytes
        {
            get;
            set;
        }

        public Data()
        {
            this.Bytes = new List< byte >();
        }

        public Data( string path )
        {
            try
            {
                this.Bytes = File.ReadAllBytes( path ).ToList();
            }
            catch
            {

                this.Bytes = new List< byte >();
            }
        }

        public void CopyBytes( byte[] buffer, ulong offset, ulong size )
        {
            for( ulong i = offset; i < offset + size; i++ )
            {
                buffer[ i - offset ] = this.Bytes[ ( int )i ];
            }
        }

        public void Append( byte[] data )
        {
            foreach( byte b in data )
            {
                this.Bytes.Add( b );
            }
        }
    }
}
