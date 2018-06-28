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

#import "NSColor+ColorSetKit.h"
#import "ColorSet.h"
#import "ColorPair.h"

static ColorSet * MainColorSet = nil;
static NSLock   * Lock         = nil;

@implementation NSColor( ColorSetKit )

+ ( nullable NSColor * )colorFromColorSet: ( NSString * )name
{
    static dispatch_once_t once;
    static BOOL ( ^ isDark )( void );
    
    dispatch_once
    (
        &once,
        ^( void )
        {
            Lock   = [ NSLock new ];
            isDark = ^
            {
                return NO;
            };
        }
    );
    
    [ Lock lock ];
    
    if( MainColorSet == nil )
    {
        MainColorSet = [ [ ColorSet alloc ] initWithPath: [ [ NSBundle mainBundle ] pathForResource: @"Colors" ofType: @"colorset" ] ];
    }
    
    [ Lock unlock ];
    
    {
        ColorPair * pair;
        
        pair = [ MainColorSet.colors objectForKey: name ];
        
        if( pair != nil )
        {
            return ( pair.variant != nil && isDark() ) ? pair.variant : pair.color;
        }
    }
    
    return nil;
}

@end
