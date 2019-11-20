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
using System.Xml;

namespace ColorSetKit
{
    static class PropertyListSerialization
    {
        public static object PropertyListFromData( Data data )
        {
            if( data == null || data.Count == 0 )
            {
                return null;
            }

            try
            {
                byte[] bytes = new byte[ data.Count ];

                data.CopyBytes( bytes, 0, data.Count );

                if( !( Encoding.UTF8.GetString( bytes ) is string plist ) )
                {
                    return null;
                }
                
                XmlDocument xml            = new XmlDocument();
                XmlReaderSettings settings = new XmlReaderSettings
                {
                    DtdProcessing = DtdProcessing.Ignore
                };

                using( XmlReader reader = XmlReader.Create( new StringReader( plist ), settings ) )
                {
                    xml.Load( reader );

                    if( xml.ChildNodes.Count != 1 )
                    {
                        return null;
                    }

                    if( xml.FirstChild.Name != "plist" )
                    {
                        return null;
                    }

                    if( xml.FirstChild.ChildNodes.Count != 1 )
                    {
                        return null;
                    }

                    return PropertyListFromXmlNode( xml.FirstChild.FirstChild );
                }
            }
            catch
            {}

            return null;
        }

        private static object PropertyListFromXmlNode( XmlNode node )
        {
            try
            {
                switch( node.Name )
                {
                    case "integer": return LongFromXmlNode( node );
                    case "real":    return DoubleFromXmlNode( node );
                    case "string":  return StringFromXmlNode( node );
                    case "true":    return true;
                    case "false":   return false;
                    case "array":   return ListFromXmlNode( node );
                    case "dict":    return DictionaryFromXmlNode( node );
                }
            }
            catch
            {}

            return null;
        }

        private static long LongFromXmlNode( XmlNode node )
        {
            try
            {
                return Convert.ToInt64( node.Value );
            }
            catch
            {}

            return 0;
        }

        private static double DoubleFromXmlNode( XmlNode node )
        {
            try
            {
                return Convert.ToDouble( node.Value );
            }
            catch
            {}

            return 0.0;
        }

        private static string StringFromXmlNode( XmlNode node )
        {
            return node.Value;
        }

        private static List< object > ListFromXmlNode( XmlNode node )
        {
            List< object > list = new List< object >();

            foreach( XmlNode child in node.ChildNodes )
            {
                try
                {
                    if( PropertyListFromXmlNode( child ) is object o )
                    {
                        list.Add( o );
                    }
                }
                catch
                {}
            }

            return list;
        }

        private static Dictionary< string, object > DictionaryFromXmlNode( XmlNode node )
        {
            Dictionary< string, object > dict = new Dictionary< string, object >();
            string                       key  = null;

            foreach( XmlNode child in node.ChildNodes )
            {
                try
                {
                    if( child.Name == "key" )
                    {
                        key = child.Value;

                        continue;
                    }

                    if( key == null || key.Length == 0 )
                    {
                        continue;
                    }

                    if( PropertyListFromXmlNode( child ) is object o )
                    {
                        dict[ key ] = o;
                        key         = null;
                    }
                }
                catch
                {}
            }

            return dict;
        }
    }
}
