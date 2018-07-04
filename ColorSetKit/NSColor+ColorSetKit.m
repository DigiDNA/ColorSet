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
#import <objc/runtime.h>

static ColorSet * MainColorSet = nil;
static NSLock   * Lock         = nil;

@implementation NSColor( ColorSetKit )

+ ( nullable NSColor * )colorFromColorSet: ( NSString * )name
{
    static dispatch_once_t once;
    
    dispatch_once
    (
        &once,
        ^( void )
        {
            Lock = [ NSLock new ];
        }
    );
    
    [ Lock lock ];
    
    if( MainColorSet == nil )
    {
        {
            NSString * path;
            
            path = [ [ NSBundle mainBundle ] pathForResource: @"Colors" ofType: @"colorset" ];
            
            if( path != nil && [ [ NSFileManager defaultManager ] fileExistsAtPath: path ] )
            {
                MainColorSet = [ [ ColorSet alloc ] initWithPath: path ];
            }
        }
    }
    
    [ Lock unlock ];
    
    if( [ name hasPrefix: @"NS" ] )
    {
        {
            NSMutableString * selectorName;
            SEL               sel;
            
            selectorName = [ name substringFromIndex: 2 ].mutableCopy;
            
            if( selectorName.length > 0 )
            {
                [ selectorName replaceCharactersInRange: NSMakeRange( 0, 1 ) withString: [ selectorName substringToIndex: 1 ].lowercaseString ];
                
                sel = NSSelectorFromString( selectorName );
                
                if( sel && [ NSColor respondsToSelector: sel ] )
                {
                    return [ NSColor performSelector: sel ];
                }
            }
        }
    }
    
    {
        ColorPair * pair;
        
        pair = [ MainColorSet.colors objectForKey: name ];
        
        if( @available( macOS 10.14, * ) )
        {
            if( pair.variant != nil && [ [ NSAppearance currentAppearance ].name isEqualToString: NSAppearanceNameDarkAqua ] )
            {
                return pair.variant;
            }
        }
            
        return pair.color;
    }
}

@end
