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

import Cocoa

/**
 * Represents a binary data stream for `colorset` files.  
 * Note that stream objects are thread-safe.
 * 
 * - Authors:
 *      Jean-David Gadina
 */
@objc public class ColorSetStream: NSObject
{
    /**
     * The binary data contained in the stream.
     */
    @objc public private( set ) dynamic var data: Data
    
    private var pos: size_t = 0
    
    /**
     * Default convenience initializer.
     */
    @objc public convenience override init()
    {
        self.init( data: nil )
    }
    
    /**
     * Designated initializer.
     * 
     * - parameter data: The data to use as stream. 
     */
    @objc public init( data: Data? )
    {
        self.data = data ?? Data()
    }
    
    /**
     * Appends a string object to the stream.
     * 
     * - parameter string:  The string object to append. 
     */
    @objc( appendString: )
    public func append( string: String )
    {
        self.synchronized
        {
            guard let data = string.data( using: .ascii ) else
            {
                return
            }
            
            self.append( value: UInt64( string.count ) + 1 )
            self.data.append( data )
            self.append( value: UInt8( 0 ) )
        }
    }
    
    /**
     * Appends a color object to the stream.
     * 
     * - parameter color:   The color object to append. 
     */
    @objc( appendColor: )
    public func append( color: NSColor )
    {
        self.synchronized
        {
            guard let rgb = color.usingColorSpace( .sRGB ) else
            {
                return
            }
            
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            
            rgb.getRed( &r, green: &g, blue: &b, alpha: &a )
            
            self.append( value: Double( r ) )
            self.append( value: Double( g ) )
            self.append( value: Double( b ) )
            self.append( value: Double( a ) )
        }
    }
    
    /**
     * Appends a `UInt8` value to the stream.
     * 
     * - parameter value:   The `UInt8` value to append. 
     */
    @objc( appendUInt8: )
    public func append( value: UInt8 )
    {
        self.synchronized
        {
            var v = value.littleEndian
            
            self.data.append( &v, count: 1 )
        }
    }
    
    /**
     * Appends a `UInt16` value to the stream.
     * 
     * - parameter value:  The `UInt16` value to append. 
     */
    @objc( appendUInt16: )
    public func append( value: UInt16 )
    {
        self.synchronized
        {
            [ value.littleEndian ].withUnsafeBufferPointer
            {
                p in self.data.append( p )
            }
        }
    }
    
    /**
     * Appends a `UInt32` value to the stream.
     * 
     * - parameter value:   The `UInt32` value to append. 
     */
    @objc( appendUInt32: )
    public func append( value: UInt32 )
    {
        self.synchronized
        {
            [ value.littleEndian ].withUnsafeBufferPointer
            {
                p in self.data.append( p )
            }
        }
    }
    
    /**
     * Appends a `UInt64` value to the stream.
     * 
     * - parameter value:   The `UInt64` value to append. 
     */
    @objc( appendUInt64: )
    public func append( value: UInt64 )
    {
        self.synchronized
        {
            [ value.littleEndian ].withUnsafeBufferPointer
            {
                p in self.data.append( p )
            }
        }
    }
    
    /**
     * Appends a float value to the stream.
     * 
     * - parameter value:   The float value to append. 
     */
    @objc( appendFloat: )
    public func append( value:  Float )
    {
        self.synchronized
        {
            [ value ].withUnsafeBufferPointer
            {
                p in self.data.append( p )
            }
        }
    }
    
    /**
     * Appends a double value to the stream.
     * 
     * - parameter value:   The double value to append. 
     */
    @objc( appendDouble: )
    public func append( value: Double )
    {
        self.synchronized
        {
            [ value ].withUnsafeBufferPointer
            {
                p in self.data.append( p )
            }
        }
    }
    
    /**
     * Appends a boolean value to the stream.
     * 
     * - parameter value:   The boolean value to append. 
     */
    @objc( appendBool: )
    public func append( value: Bool )
    {
        self.synchronized
        {
            self.append( value: value ? UInt8( 1 ) : UInt8( 0 ) )
        }
    }
    
    /**
     * Reads a string object from the stream at the current position.  
     * If the stream has not enough data available or if there is no valid
     * string, `nil` will be returned.
     * 
     * - returns:   An optional string object.
     */
    @objc public func readString() -> String?
    {
        return self.synchronized
        {
            let nb = UnsafeMutableBufferPointer< UInt64 >.allocate( capacity: 1 )
            
            if self.read( size: 8, in: nb )
            {
                guard let n = nb.first?.littleEndian else
                {
                    return nil
                }
                
                if n == 0
                {
                    return nil
                }
                
                guard let data = self.readData( ofLength: size_t( n ) ) else
                {
                    return nil
                }
                
                if data.count == 0
                {
                    return ""
                }
                
                return String( data: data.subdata( in: 0 ..< data.count - 1 ), encoding: .ascii ) ?? ""
            }
            
            return nil
        }
    }
    
    /**
     * Reads a color object from the stream at the current position.  
     * If the stream has not enough data available or if there is no valid
     * color, `nil` will be returned.
     * 
     * - returns:   An optional color object.
     */
    @objc public func readColor() -> NSColor?
    {
        return self.synchronized
        {
            let rb = UnsafeMutableBufferPointer< Double >.allocate( capacity: 1 )
            let gb = UnsafeMutableBufferPointer< Double >.allocate( capacity: 1 )
            let bb = UnsafeMutableBufferPointer< Double >.allocate( capacity: 1 )
            let ab = UnsafeMutableBufferPointer< Double >.allocate( capacity: 1 )
            
            if self.read( size: 8, in: rb )
            && self.read( size: 8, in: gb )
            && self.read( size: 8, in: bb )
            && self.read( size: 8, in: ab )
            {
                guard let r = rb.first,
                      let g = gb.first,
                      let b = bb.first,
                      let a = ab.first
                else
                {
                    return nil
                }
                
                return NSColor( srgbRed: CGFloat( r ), green: CGFloat( g ), blue: CGFloat( b ), alpha: CGFloat( a ) )
            }
            
            return nil
        }
    }
    
    /**
     * Reads data from the stream at the current position.
     * 
     * - parameter length:  THe number of bytes to read.
     * 
     * - returns:   A data object or nil if the stream has not enough data available.
     */
    @objc public func readData( ofLength length: size_t ) -> Data?
    {
        return self.synchronized
        {
            let buffer = UnsafeMutableBufferPointer< UInt8 >.allocate( capacity: Int( length ) )
            
            if self.read( size: length, in: buffer )
            {
                return Data( buffer: buffer )
            }
            
            return nil
        }
    }
    
    /**
     * Reads a `UInt8` value from the stream at the current position.  
     * If the stream has not enough data available, `0` will be returned.
     * 
     * - returns:   A `UInt8` value.
     */
    @objc public func readUInt8() -> UInt8
    {
        return self.synchronized
        {
            var value   = [ UInt8( 0 ) ]
            var success = false
            
            value.withUnsafeMutableBufferPointer
            {
                p in success = self.read( size: 1, in: p )
            }
            
            return success ? value[ 0 ].littleEndian : 0
        }
    }
    
    /**
     * Reads a `UInt16` value from the stream at the current position.  
     * If the stream has not enough data available, `0` will be returned.
     * 
     * - returns:   A `UInt16` value.
     */
    @objc public func readUInt16() -> UInt16
    {
        return self.synchronized
        {
            var value   = [ UInt16( 0 ) ]
            var success = false
            
            value.withUnsafeMutableBufferPointer
            {
                p in success = self.read( size: 2, in: p )
            }
            
            return success ? value[ 0 ].littleEndian : 0
        }
    }
    
    /**
     * Reads a `UInt32` value from the stream at the current position.  
     * If the stream has not enough data available, `0` will be returned.
     * 
     * - returns:   A `UInt32` value.
     */
    @objc public func readUInt32() -> UInt32
    {
        return self.synchronized
        {
            var value   = [ UInt32( 0 ) ]
            var success = false
            
            value.withUnsafeMutableBufferPointer
            {
                p in success = self.read( size: 4, in: p )
            }
            
            return success ? value[ 0 ].littleEndian : 0
        }
    }
    
    /**
     * Reads a `UInt64` value from the stream at the current position.  
     * If the stream has not enough data available, `0` will be returned.
     * 
     * - returns:   A `UInt64` value.
     */
    @objc public func readUInt64() -> UInt64
    {
        return self.synchronized
        {
            var value   = [ UInt64( 0 ) ]
            var success = false
            
            value.withUnsafeMutableBufferPointer
            {
                p in success = self.read( size: 8, in: p )
            }
            
            return success ? value[ 0 ].littleEndian : 0
        }
    }
    
    /**
     * Reads a float value from the stream at the current position.  
     * If the stream has not enough data available, `0` will be returned.
     * 
     * - returns:   A float value.
     */
    @objc public func readFloat() -> Float
    {
        return self.synchronized
        {
            var value   = [ Float( 0 ) ]
            var success = false
            
            value.withUnsafeMutableBufferPointer
            {
                p in success = self.read( size: 4, in: p )
            }
            
            return success ? value[ 0 ] : 0
        }
    }
    
    /**
     * Reads a double value from the stream at the current position.  
     * If the stream has not enough data available, `0` will be returned.
     * 
     * - returns:   A double value.
     */
    @objc public func readDouble() -> Double
    {
        return self.synchronized
        {
            var value   = [ Double( 0 ) ]
            var success = false
            
            value.withUnsafeMutableBufferPointer
            {
                p in success = self.read( size: 8, in: p )
            }
            
            return success ? value[ 0 ] : 0
        }
    }
    
    /**
     * Reads a boolean value from the stream at the current position.  
     * If the stream has not enough data available, `false` will be returned.
     * 
     * - returns:   A boolean value.
     */
    @objc public func readBool() -> Bool
    {
        return self.synchronized
        {
            return self.readUInt8() != 0
        }
    }
    
    private func read< T >( size: size_t, in buffer: UnsafeMutableBufferPointer< T > ) -> Bool
    {
        return self.synchronized
        {
            if self.pos < size_t( data.count ) + size
            {
                self.data.copyBytes( to: buffer, from: self.pos ..< self.pos + size )
                
                self.pos += size
                
                return true
            }
            
            return false
        }
    }
    
    private func synchronized< T >( _ closure: () -> T ) -> T
    {
        objc_sync_enter( self )
        
        let r = closure()
        
        objc_sync_exit( self )
        
        return r
    }
}

/**
 * Appends a string object to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The string object to append. 
 */
public func +=( lhs: ColorSetStream, rhs: String )
{
    lhs.append( string: rhs )
}

/**
 * Appends a color object to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The color object to append. 
 */
public func +=( lhs: ColorSetStream, rhs: NSColor )
{
    lhs.append( color: rhs )
}

/**
 * Appends a `UInt8` value to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The `UInt8` value to append. 
 */
public func +=( lhs: ColorSetStream, rhs: UInt8 )
{
    lhs.append( value: rhs )
}

/**
 * Appends a `UInt16` value to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The `UInt16` value to append. 
 */
public func +=( lhs: ColorSetStream, rhs: UInt16 )
{
    lhs.append( value: rhs )
}

/**
 * Appends a `UInt32` value to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The `UInt32` value to append. 
 */
public func +=( lhs: ColorSetStream, rhs: UInt32 )
{
    lhs.append( value: rhs )
}

/**
 * Appends a `UInt64` value to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The `UInt64` value to append. 
 */
public func +=( lhs: ColorSetStream, rhs: UInt64 )
{
    lhs.append( value: rhs )
}

/**
 * Appends a float value to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The float value to append. 
 */
public func +=( lhs: ColorSetStream, rhs: Float )
{
    lhs.append( value: rhs )
}

/**
 * Appends a double value to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The double value to append. 
 */
public func +=( lhs: ColorSetStream, rhs: Double )
{
    lhs.append( value: rhs )
}

/**
 * Appends a boolean value to a stream.
 * 
 * - parameter lhs: The stream object.
 * - parameter rhs: The boolean value to append. 
 */
public func +=( lhs: ColorSetStream, rhs: Bool )
{
    lhs.append( value: rhs )
}
