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

#import "ColorSetStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColorSetStream()

@property( atomic, readwrite, strong ) NSMutableData * mutableData;
@property( atomic, readwrite, assign ) size_t          pos;

- ( BOOL )read: ( size_t )n in: ( void * )buf;

@end

NS_ASSUME_NONNULL_END

@implementation ColorSetStream

- ( instancetype )init
{
    return [ self initWithData: nil ];
}

- ( instancetype )initWithData: ( nullable NSData * )data
{
    if( ( self = [ super init ] ) )
    {
        self.mutableData = ( data == nil ) ? [ NSMutableData new ] : [ data mutableCopy ];
    }
    
    return self;
}

- ( NSData * )data
{
    @synchronized( self )
    {
        return [ self.mutableData copy ];
    }
}

- ( void )appendString: ( nullable  NSString * )value
{
    @synchronized( self )
    {
        [ self appendUInt64: value.length + 1 ];
        [ self.mutableData appendData: [ value dataUsingEncoding: NSASCIIStringEncoding ] ];
        [ self appendUInt8: 0 ];
    }
}

- ( void )appendColor: ( nullable NSColor * )value
{
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
    
    @synchronized( self )
    {
        r = 0.0;
        g = 0.0;
        b = 0.0;
        a = 0.0;
        
        [ [ value colorUsingColorSpace: [ NSColorSpace sRGBColorSpace ] ] getRed: &r green: &g blue: &b alpha: &a ];
        
        [ self appendDouble: ( double )r ];
        [ self appendDouble: ( double )g ];
        [ self appendDouble: ( double )b ];
        [ self appendDouble: ( double )a ];
    }
}

- ( void )appendUInt8: ( uint8_t )value
{
    @synchronized( self )
    {
        [ self.mutableData appendBytes: &value length: 1 ];
    }
}

- ( void )appendUInt16: ( uint16_t )value
{
    @synchronized( self )
    {
        [ self.mutableData appendBytes: &value length: 2 ];
    }
}

- ( void )appendUInt32: ( uint32_t )value
{
    @synchronized( self )
    {
        [ self.mutableData appendBytes: &value length: 4 ];
    }
}

- ( void )appendUInt64: ( uint64_t )value
{
    @synchronized( self )
    {
        [ self.mutableData appendBytes: &value length: 8 ];
    }
}

- ( void )appendFloat: ( float )value
{
    @synchronized( self )
    {
        [ self.mutableData appendBytes: &value length: 4 ];
    }
}

- ( void )appendDouble: ( double )value
{
    @synchronized( self )
    {
        [ self.mutableData appendBytes: &value length: 8 ];
    }
}

- ( nullable NSString * )readString
{
    uint64_t n;
    NSData * data;
    
    @synchronized( self )
    {
        if( [ self read: 8 in: &n ] && n > 0 )
        {
            if( ( data = [ self readDataOfLength: n ] ) )
            {
                return [ [ NSString alloc ] initWithData: data encoding: NSASCIIStringEncoding ];
            }
        }
        
        return nil;
    }
}

- ( nullable NSColor * )readColor
{
    double r;
    double g;
    double b;
    double a;
    
    @synchronized( self )
    {
        if
        (
               [ self read: 8 in: &r ]
            && [ self read: 8 in: &g ]
            && [ self read: 8 in: &b ]
            && [ self read: 8 in: &a ]
        )
        {
            return [ NSColor colorWithRed: r green: g blue: b alpha: a ];
        }
        
        return nil;
    }
}

- ( nullable NSData * )readDataOfLength: ( size_t )n
{
    NSData * data;
    
    @synchronized( self )
    {
        if( self.pos < self.mutableData.length + n )
        {
            data      = [ self.mutableData subdataWithRange: NSMakeRange( self.pos, n ) ];
            self.pos += n;
            
            return data;
        }
        
        return nil;
    }
}

- ( uint8_t )readUInt8
{
    uint8_t v;
    
    if( [ self read: 1 in: &v ] )
    {
        return v;
    }
    
    return 0;
}

- ( uint16_t )readUInt16
{
    uint16_t v;
    
    if( [ self read: 2 in: &v ] )
    {
        return v;
    }
    
    return 0;
}

- ( uint32_t )readUInt32
{
    uint32_t v;
    
    if( [ self read: 4 in: &v ] )
    {
        return v;
    }
    
    return 0;
}

- ( uint64_t )readUInt64
{
    uint64_t v;
    
    if( [ self read: 8 in: &v ] )
    {
        return v;
    }
    
    return 0;
}

- ( float )readFloat
{
    float v;
    
    if( [ self read: 4 in: &v ] )
    {
        return v;
    }
    
    return 0;
}

- ( double )readDouble
{
    double v;
    
    if( [ self read: 8 in: &v ] )
    {
        return v;
    }
    
    return 0;
}

- ( BOOL )read: ( size_t )n in: ( void * )buf
{
    @synchronized( self )
    {
        if( self.pos < self.mutableData.length + n )
        {
            memcpy( buf, ( ( char * )( self.mutableData.bytes ) ) + self.pos, n );
            
            self.pos = self.pos + n;
            
            return YES;
        }
        
        return NO;
    }
}

@end
