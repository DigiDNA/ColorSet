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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class ColorPair;

@interface ColorSet: NSObject

@property( atomic, readonly ) NSDictionary< NSString *, ColorPair * > * colors;

- ( nullable instancetype )initWithPath: ( NSString * )path;
- ( nullable instancetype )initWithURL: ( NSURL * )url;
- ( nullable instancetype )initWithData: ( NSData * )data;

- ( void )addColor: ( NSColor * )color forName: ( NSString * )name;
- ( void )setColor: ( NSColor * )color forName: ( NSString * )name;
- ( void )addColor: ( NSColor * )color variant: ( nullable NSColor * )variant forName: ( NSString * )name;
- ( void )setColor: ( NSColor * )color variant: ( nullable NSColor * )variant forName: ( NSString * )name;

- ( NSData * )data;

- ( BOOL )writeToPath: ( NSString * )path error: ( NSError * _Nullable __autoreleasing * _Nullable )error;
- ( BOOL )writeToURL: ( NSURL * )url error: ( NSError * _Nullable __autoreleasing * _Nullable )error;

@end

NS_ASSUME_NONNULL_END
