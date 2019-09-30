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
    private static let major: UInt32 = 1
    private static let minor: UInt32 = 2
    
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
    
    public private( set ) var colorPairs  = [ String : ColorPair ]()
    private               var children    = [ ColorSet ]()
    private               var accentNames = [ String ]()
    
    @objc public var colors: [ String : ColorPair ]
    {
        return self.synchronized
        {
            var colors = [ String : ColorPair ]()
            
            for p in self.colorPairs
            {
                if let color = self.colorWith( name: p.key )
                {
                    colors[ p.key ] = color
                }
            }
            
            return colors
        }
    }
    
    @objc public var count: Int
    {
        return self.synchronized
        {
            return self.colorPairs.count
        }
    }
    
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
        
        let major = stream.readUInt32()
        
        if major == 0
        {
            return nil
        }
        
        let minor = stream.readUInt32()
        
        if major > ColorSet.major || minor > ColorSet.minor
        {
            return nil
        }
        
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
            
            var lightnesses = [ LightnessPair ]()
            
            if major > 1 || minor > 1
            {
                let n = stream.readUInt64()
                
                for _ in 0 ..< n
                {
                    let p = LightnessPair()
                    
                    p.lightness1.lightness = CGFloat( stream.readDouble() )
                    p.lightness1.name      = stream.readString() ?? ""
                    p.lightness2.lightness = CGFloat( stream.readDouble() )
                    p.lightness2.name      = stream.readString() ?? ""
                    
                    lightnesses.append( p )
                }
            }
            
            self.add( color: color, variant: hasVariant ? variant : nil, lightnesses: lightnesses, forName: name )
        }
    }
    
    @objc public subscript( key: String ) -> ColorPair?
    {
        return self.colorWith( name: key )
    }
    
    @objc public func useAccentColorForColor( name: String )
    {
        self.synchronized
        {
            self.accentNames.append( name )
        }
    }
    
    @objc public func colorWith( name: String ) -> ColorPair?
    {
        return self.synchronized
        {
            if let color = self.colorPairs[ name ]
            {
                if #available( macOS 10.14, * )
                {
                    if self.accentNames.contains( name )
                    {
                        let accent    = NSColor.controlAccentColor.usingColorSpace( .sRGB )
                        let p         = ColorPair( color: accent, variant: ( color.variant != nil ) ? accent : nil )
                        p.lightnesses = color.lightnesses
                        
                        return p
                    }
                }
                
                return color
            }
            
            for child in self.children
            {
                if let color = child[ name ]
                {
                    return color
                }
            }
            
            return nil
        }
    }
    
    @objc( addChild: )
    public func add( child: ColorSet )
    {
        if child === self
        {
            return
        }
        
        self.synchronized
        {
            self.children.append( child )
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
        self.add( color: color, variant: variant, lightnesses: [], forName: name )
    }
    
    @objc( setColor:variant:forName: )
    public func set( color: NSColor, variant: NSColor?, forName name: String )
    {
        self.set( color: color, variant: variant, lightnesses: [], forName: name )
    }
    
    @objc( addColor:variant:lightnesses:forName: )
    public func add( color: NSColor, variant: NSColor?, lightnesses: [ LightnessPair ], forName name: String )
    {
        self.synchronized
        {
            if self.colorPairs.keys.contains( name ) == false
            {
                self.set( color: color, variant: variant, lightnesses: lightnesses, forName: name )
            }
        }
    }
    
    @objc( setColor:variant:lightnesses:forName: )
    public func set( color: NSColor, variant: NSColor?, lightnesses: [ LightnessPair ], forName name: String )
    {
        self.synchronized
        {
            let p                   = ColorPair( color: color, variant: variant )
            p.lightnesses           = lightnesses
            self.colorPairs[ name ] = p
        }
    }
    
    @objc public var data: Data
    {
        get
        {
            var colors: [ String : ColorPair ]!
            
            self.synchronized
            {
                colors = self.colorPairs
            }
            
            let stream = ColorSetStream()
            
            stream += ColorSet.magic
            stream += UInt32( ColorSet.major )
            stream += UInt32( ColorSet.minor )
            stream += UInt64( colors.count ) /* Count */
            
            for p in colors
            {
                stream += p.key
                stream += p.value.variant != nil
                stream += p.value.color   ?? NSColor.clear
                stream += p.value.variant ?? NSColor.clear
                stream += UInt64( p.value.lightnesses.count )
                
                for lp in p.value.lightnesses
                {
                    stream += Double( lp.lightness1.lightness )
                    stream += lp.lightness1.name
                    stream += Double( lp.lightness2.lightness )
                    stream += lp.lightness2.name
                }
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
