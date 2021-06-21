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
    public partial class LightnessVariant: IDictionaryRepresentable
    {
        public double Lightness
        {
            get;
            set;
        }
        = 0.0;

        public string Name
        {
            get;
            set;
        }
        = "";

        public LightnessVariant()
        {}

        public LightnessVariant( Dictionary< string, object > dictionary ): this()
        {
            {
                if( dictionary.TryGetValue( "lightness", out object? o ) && o is double lightness )
                {
                    this.Lightness = lightness;
                }
            }

            {
                if( dictionary.TryGetValue( "name", out object? o ) && o is string name )
                {
                    this.Name = name;
                }
            }
        }

        public Dictionary< string, object > ToDictionary()
        {
            return new Dictionary< string, object >
            {
                { "lightness", this.Lightness },
                { "name",      this.Name }
            };
        }
    }
}