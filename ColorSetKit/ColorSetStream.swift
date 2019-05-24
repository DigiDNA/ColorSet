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

@objc public class ColorSetStream: NSObject
{
    @objc public private( set ) dynamic var data: Data
    
    private var pos: size_t = 0
    
    @objc public convenience override init()
    {
        self.init( data: nil )
    }
    
    @objc public init( data: Data? )
    {
        self.data = data ?? Data()
    }
    
    @objc public func append( string: String )
    {
        self.synchronized
        {
            guard let data = string.data( using: .ascii ) else
            {
                return
            }
            
            self.append( uInt64: UInt64( string.count ) + 1 )
            self.data.append( data )
            self.append( uInt8: 0 )
        }
    }
    
    @objc public func append( color: NSColor )
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
            
            self.append( double: Double( r ) )
            self.append( double: Double( g ) )
            self.append( double: Double( b ) )
            self.append( double: Double( a ) )
        }
    }
    
    @objc public func append( uInt8: UInt8 )
    {
        self.synchronized
        {
            var value = uInt8.littleEndian
            
            self.data.append( &value, count: 1 )
        }
    }
    
    @objc public func append( uInt16: UInt16 )
    {
        self.synchronized
        {
            var value = uInt16.littleEndian
            
            self.data.append( UnsafeBufferPointer( start: &value, count: 1 ) )
        }
    }
    
    @objc public func append( uInt32: UInt32 )
    {
        self.synchronized
        {
            var value = uInt32.littleEndian
            
            self.data.append( UnsafeBufferPointer( start: &value, count: 1 ) )
        }
    }
    
    @objc public func append( uInt64: UInt64 )
    {
        self.synchronized
        {
            var value = uInt64.littleEndian
            
            self.data.append( UnsafeBufferPointer( start: &value, count: 1 ) )
        }
    }
    
    @objc public func append( float: Float )
    {
        self.synchronized
        {
            var value = float
            
            self.data.append( UnsafeBufferPointer( start: &value, count: 1 ) )
        }
    }
    
    public func append( double: Double )
    {
        self.synchronized
        {
            var value = double
            
            self.data.append( UnsafeBufferPointer( start: &value, count: 1 ) )
        }
    }
    
    public func append( bool: Bool )
    {
        self.synchronized
        {
            self.append( uInt8: bool ? 1 : 0 )
        }
    }
    
    public func append( value: UInt8 )
    {
        self.synchronized
        {
            self.append( uInt8: value )
        }
    }
    
    public func append( value: UInt16 )
    {
        self.synchronized
        {
            self.append( uInt16: value )
        }
    }
    
    public func append( value: UInt32 )
    {
        self.synchronized
        {
            self.append( uInt32: value )
        }
    }
    
    public func append( value: UInt64 )
    {
        self.synchronized
        {
            self.append( uInt64: value )
        }
    }
    
    public func append( value: Float )
    {
        self.synchronized
        {
            self.append( float: value )
        }
    }
    
    public func append( value: Double )
    {
        self.synchronized
        {
            self.append( double: value )
        }
    }
    
    public func append( value: Bool )
    {
        self.synchronized
        {
            self.append( bool: value )
        }
    }
    
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
    
    @objc public func readUInt8() -> UInt8
    {
        return self.synchronized
        {
            var value: UInt8 = 0
            
            if self.read( size: 1, in: UnsafeMutableBufferPointer( start: &value, count: 1  ) )
            {
                return value.littleEndian
            }
            
            return 0
        }
    }
    
    @objc public func readUInt16() -> UInt16
    {
        return self.synchronized
        {
            var value: UInt16 = 0
            
            if self.read( size: 2, in: UnsafeMutableBufferPointer( start: &value, count: 1  ) )
            {
                return value.littleEndian
            }
            
            return 0
        }
    }
    
    @objc public func readUInt32() -> UInt32
    {
        return self.synchronized
        {
            var value: UInt32 = 0
            
            if self.read( size: 4, in: UnsafeMutableBufferPointer( start: &value, count: 1  ) )
            {
                return value.littleEndian
            }
            
            return 0
        }
    }
    
    @objc public func readUInt64() -> UInt64
    {
        return self.synchronized
        {
            var value: UInt64 = 0
            
            if self.read( size: 8, in: UnsafeMutableBufferPointer( start: &value, count: 1  ) )
            {
                return value.littleEndian
            }
            
            return 0
        }
    }
    
    @objc public func readFloat() -> Float
    {
        return self.synchronized
        {
            var value: Float = 0
            
            if self.read( size: 4, in: UnsafeMutableBufferPointer( start: &value, count: 1  ) )
            {
                return value
            }
            
            return 0
        }
    }
    
    @objc public func readDouble() -> Double
    {
        return self.synchronized
        {
            var value: Double = 0
            
            if self.read( size: 8, in: UnsafeMutableBufferPointer( start: &value, count: 1  ) )
            {
                return value
            }
            
            return 0
        }
    }
    
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

public func +=( lhs: ColorSetStream, rhs: String )
{
    lhs.append( string: rhs )
}

public func +=( lhs: ColorSetStream, rhs: NSColor )
{
    lhs.append( color: rhs )
}

public func +=( lhs: ColorSetStream, rhs: UInt8 )
{
    lhs.append( value: rhs )
}

public func +=( lhs: ColorSetStream, rhs: UInt16 )
{
    lhs.append( value: rhs )
}

public func +=( lhs: ColorSetStream, rhs: UInt32 )
{
    lhs.append( value: rhs )
}

public func +=( lhs: ColorSetStream, rhs: UInt64 )
{
    lhs.append( value: rhs )
}

public func +=( lhs: ColorSetStream, rhs: Float )
{
    lhs.append( value: rhs )
}

public func +=( lhs: ColorSetStream, rhs: Double )
{
    lhs.append( value: rhs )
}

public func +=( lhs: ColorSetStream, rhs: Bool )
{
    lhs.append( value: rhs )
}
