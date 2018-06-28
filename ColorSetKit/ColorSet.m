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

#import "ColorSet.h"
#import "ColorSetStream.h"
#import "ColorPair.h"

#define MAGIC 0x434F4C4F52534554

NS_ASSUME_NONNULL_BEGIN

@interface ColorSet()

@property( atomic, readwrite, strong ) NSDictionary<        NSString *, ColorPair * > * colors;
@property( atomic, readwrite, strong ) NSMutableDictionary< NSString *, ColorPair * > * mutableColors;

@end

NS_ASSUME_NONNULL_END

@implementation ColorSet

- ( nullable instancetype )initWithPath: ( NSString * )path
{
    return [ self initWithURL: [ NSURL fileURLWithPath: path ] ];
}

- ( nullable instancetype )initWithURL: ( NSURL * )url
{
    NSData * data;
    
    data = [ NSData dataWithContentsOfURL: url ];
    
    if( data == nil )
    {
        return nil;
    }
    
    return [ self initWithData: data ];
}

- ( nullable instancetype )initWithData: ( NSData * )data
{
    ColorSetStream * stream;
    uint64_t         n;
    uint64_t         i;
    
    if( data.length == 0 )
    {
        return nil;
    }
    
    if( ( self = [ self init ] ) )
    {
        stream = [ [ ColorSetStream alloc ] initWithData: data ];
        
        if( [ stream readUInt64 ] != MAGIC )
        {
            return nil;
        }
        
        if( [ stream readUInt32 ] == 0 )
        {
            return nil;
        }
        
        [ stream readUInt32 ];
        
        n = [ stream readUInt64 ];
        
        for( i = 0; i < n; i++ )
        {
            {
                NSString * name;
                uint8_t    hasVariant;
                NSColor  * color;
                NSColor  * variant;
                
                if( ( name = [ stream readString ] ) == nil )
                {
                    return nil;
                }
                
                hasVariant = [ stream readUInt8 ];
                
                if( ( color = [ stream readColor ] ) == nil )
                {
                    return nil;
                }
                
                if( ( variant = [ stream readColor ] ) == nil )
                {
                    return nil;
                }
                
                [ self addColor: color variant: ( hasVariant ) ? variant : nil forName: name ];
            }
        }
    }
    
    return self;
}

- ( instancetype )init
{
    if( ( self = [ super init ] ) )
    {
        [ self addObserver: self forKeyPath: NSStringFromSelector( @selector( mutableColors ) ) options: 0 context: nil ];
        
        self.mutableColors = [ NSMutableDictionary new ];
    }
    
    return self;
}

- ( void )observeValueForKeyPath: ( NSString * )keyPath ofObject: ( id )object change: ( NSDictionary< NSKeyValueChangeKey, id > * )change context: ( void * )context
{
    if( object == self && [ keyPath isEqualToString: NSStringFromSelector( @selector( mutableColors ) ) ] )
    {
        self.colors = [ self.mutableColors copy ];
    }
    else
    {
        [ super observeValueForKeyPath: keyPath ofObject: object change: change context: context ];
    }
}

- ( void )addColor: ( NSColor * )color forName: ( NSString * )name
{
    [ self addColor: color variant: nil forName: name ];
}

- ( void )setColor: ( NSColor * )color forName: ( NSString * )name
{
    [ self setColor: color variant: nil forName: name ];
}

- ( void )addColor: ( NSColor * )color variant: ( nullable NSColor * )variant forName: ( NSString * )name
{
    @synchronized( self )
    {
        if( [ self.mutableColors objectForKey: name ] != nil )
        {
            return;
        }
        
        [ self willChangeValueForKey: NSStringFromSelector( @selector( mutableColors ) ) ];
        [ self.mutableColors setObject: [ [ ColorPair alloc ] initWithColor: color variant: variant ] forKey: name ];
        [ self didChangeValueForKey: NSStringFromSelector( @selector( mutableColors ) ) ];
    }
}

- ( void )setColor: ( NSColor * )color variant: ( nullable NSColor * )variant forName: ( NSString * )name
{
    @synchronized( self )
    {
        [ self willChangeValueForKey: NSStringFromSelector( @selector( mutableColors ) ) ];
        [ self.mutableColors setObject: [ [ ColorPair alloc ] initWithColor: color variant: variant ] forKey: name ];
        [ self didChangeValueForKey: NSStringFromSelector( @selector( mutableColors ) ) ];
    }
}

- ( NSData * )data
{
    ColorSetStream                          * stream;
    NSDictionary< NSString *, ColorPair * > * colors;
    
    @synchronized ( self )
    {
        colors = [ self.colors copy ];
    }
    
    stream = [ ColorSetStream new ];
    
    [ stream appendUInt64: MAGIC ];         /* COLORSET */
    [ stream appendUInt32: 0x01 ];          /* Major */
    [ stream appendUInt32: 0x00 ];          /* Minor */
    [ stream appendUInt64: colors.count ];  /* Count */
    
    for( NSString * name in colors )
    {
        {
            ColorPair * pair;
            
            pair = [ colors objectForKey: name ];
            
            [ stream appendString: name ];
            [ stream appendUInt8: pair.variant != nil ];
            [ stream appendColor: pair.color ];
            [ stream appendColor: pair.variant ];
        }
    }
    
    return stream.data;
}

- ( BOOL )writeToPath: ( NSString * )path error: ( NSError * _Nullable __autoreleasing * _Nullable )error
{
    return [ self writeToURL: [ NSURL fileURLWithPath: path ] error: error ];
}

- ( BOOL )writeToURL: ( NSURL * )url error: ( NSError * _Nullable __autoreleasing * _Nullable )error
{
    return [ self.data writeToURL: url options: NSDataWritingAtomic error: error ];
}

@end
