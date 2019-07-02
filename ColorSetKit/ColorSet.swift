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

@objc public class ColorSet: NSObject
{
    private static let magic: UInt64 = 0x434F4C4F52534554
    
    public static var shared: ColorSet =
    {
        var set: ColorSet?
        
        if let path = Bundle.main.path( forResource: "Colors", ofType: "colorset" )
        {
            if FileManager.default.fileExists( atPath: path )
            {
                set = ColorSet( path: path )
            }
        }
        
        #if DEBUG
        
        if set == nil, let path = Bundle( identifier: "com.xs-labs.ColorSetKit-Test" )?.path( forResource: "Colors", ofType: "colorset" )
        {
            if FileManager.default.fileExists( atPath: path )
            {
                set = ColorSet( path: path )
            }
        }
        
        #endif
        
        return set ?? ColorSet()
    }()
    
    @objc public private( set ) dynamic var colors = [ String : ColorPair ]()
    
    @objc public override init()
    {}
    
    @objc public convenience init?( path: String )
    {
        self.init( url: URL.init( fileURLWithPath: path ) )
    }
    
    @objc public convenience init?( url: URL )
    {
        guard let data = try? Data( contentsOf: url ) else
        {
            return nil
        }
        
        self.init( data: data )
    }
    
    @objc public init?( data: Data )
    {
        if data.count == 0
        {
            return nil
        }
        
        super.init()
        
        let stream = ColorSetStream( data: data )
        
        if stream.readUInt64() != ColorSet.magic
        {
            return nil
        }
        
        if stream.readUInt32() == 0
        {
            return nil
        }
        
        let _ = stream.readUInt32()
        let n = stream.readUInt64()
        
        for _ in 0 ..< n
        {
            guard let name = stream.readString() else
            {
                return nil
            }
            
            let hasVariant = stream.readBool()
            
            guard let color = stream.readColor() else
            {
                return nil
            }
            
            guard let variant = stream.readColor() else
            {
                return nil
            }
            
            self.add( color: color, variant: hasVariant ? variant : nil, forName: name )
        }
    }
    
    @objc( addColor:forName: )
    public func add( color: NSColor, forName name: String )
    {
        self.add( color: color, variant: nil, forName: name )
    }
    
    @objc( setColor:forName: )
    public func set( color: NSColor, forName name: String )
    {
        self.set( color: color, variant: nil, forName: name )
    }
    
    @objc( addColor:variant:forName: )
    public func add( color: NSColor, variant: NSColor?, forName name: String )
    {
        self.synchronized
        {
            if self.colors.keys.contains( name ) == false
            {
                self.set( color: color, variant: variant, forName: name )
            }
        }
    }
    
    @objc( setColor:variant:forName: )
    public func set( color: NSColor, variant: NSColor?, forName name: String )
    {
        self.synchronized
        {
            self.colors[ name ] = ColorPair( color: color, variant: variant )
        }
    }
    
    @objc public var data: Data
    {
        get
        {
            var colors: [ String : ColorPair ]!
            
            self.synchronized
            {
                colors = self.colors
            }
            
            let stream = ColorSetStream()
            
            stream += ColorSet.magic         /* COLORSET */
            stream += UInt32( 1 )            /* Major */
            stream += UInt32( 0 )            /* Minor */
            stream += UInt64( colors.count ) /* Count */
            
            for p in colors
            {
                stream += p.key
                stream += p.value.variant != nil
                stream += p.value.color   ?? NSColor.clear
                stream += p.value.variant ?? NSColor.clear
            }
            
            return stream.data
        }
    }
    
    @objc public func writeTo( url: URL ) throws
    {
        do
        {
            try self.data.write( to: url )
        }
        catch let e
        {
            throw e
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
