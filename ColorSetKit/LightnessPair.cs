﻿/*******************************************************************************
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
    public partial class LightnessPair: IDictionaryRepresentable
    {
        public LightnessVariant Lightness1
        {
            get;
            set;
        }
        = new LightnessVariant();

        public LightnessVariant Lightness2
        {
            get;
            set;
        }
        = new LightnessVariant();

        public LightnessPair()
        {}

        public LightnessPair( Dictionary< string, object > dictionary ): this()
        {
            {
                if( dictionary.TryGetValue( "lightness1", out object? o ) == false || !( o is Dictionary< string, object > dict ) )
                {
                    throw new ArgumentException( "Key lightness1 is missing in input dictionary" );
                }

                this.Lightness1 = new LightnessVariant( dict );
            }

            {
                if( dictionary.TryGetValue( "lightness2", out object? o ) == false || !( o is Dictionary< string, object > dict ) )
                {
                    throw new ArgumentException( "Key lightness2 is missing in input dictionary" );
                }

                this.Lightness2 = new LightnessVariant( dict );
            }
        }

        public Dictionary< string, object > ToDictionary()
        {
            return new Dictionary< string, object >
            {
                { "lightness1", this.Lightness1.ToDictionary() },
                { "lightness2", this.Lightness2.ToDictionary() }
            };
        }
    }
}