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

@interface ColorSetStream: NSObject

@property( atomic, readonly ) NSData * data;

- ( instancetype )initWithData: ( nullable NSData * )data NS_DESIGNATED_INITIALIZER;

- ( void )appendString: ( nullable NSString * )value;
- ( void )appendColor: ( nullable NSColor  * )value;
- ( void )appendUInt8: ( uint8_t )value;
- ( void )appendUInt16: ( uint16_t )value;
- ( void )appendUInt32: ( uint32_t )value;
- ( void )appendUInt64: ( uint64_t )value;
- ( void )appendFloat: ( float )value;
- ( void )appendDouble: ( double )value;

- ( nullable NSString * )readString;
- ( nullable NSColor * )readColor;
- ( nullable NSData * )readDataOfLength: ( size_t )n;
- ( uint8_t )readUInt8;
- ( uint16_t )readUInt16;
- ( uint32_t )readUInt32;
- ( uint64_t )readUInt64;
- ( float )readFloat;
- ( double )readDouble;

@end

NS_ASSUME_NONNULL_END
