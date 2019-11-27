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
 * Represents a `colorset` file.
 * 
 * - Authors:
 *      Jean-David Gadina
 */
@objc public class ColorSet: NSObject, DictionaryRepresentable
{
    @objc public enum Format: UInt
    {
        case binary
        case xml
    }
    
    private static let magic: UInt64 = 0x434F4C4F52534554
    private static let major: UInt32 = 1
    private static let minor: UInt32 = 2
    
    /**
     * Returns the shared (main) instance for the running application.
     * 
     * If the application's bundle contains a file named `Colors.colorset`,
     * this file will be automatically loaded into the shared instance.
     */
    @objc public static var shared: ColorSet =
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
        
        /* For unit tests... */
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
    
    @objc public var format = Format.binary
    
    /**
     * The dictionary of color pairs contained in the colorset.
     * 
     * This property contains only the color pairs defined in this instance,
     * not including colors defined in child colorsets.  
     * To get all colors, please use the `colors` property instead.
     * 
     * - Seealso: `colors`
     */
    public private( set ) var colorPairs  = [ String : ColorPair ]()
    private               var children    = [ ColorSet ]()
    private               var accentNames = [ String ]()
    
    /**
     * The dictionary of color pairs contained in the colorset, including
     * colors in child colorsets, if any.
     */
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
    
    /**
     * Initializes an empty colorset object.
     */
    @objc public override init()
    {}
    
    /**
     * Initializes a colorset object from a file.
     * 
     * - parameter path:    The file's path.
     * 
     * - Seealso: `init(url:)`
     * - Seealso: `init(data:)` 
     */
    @objc public convenience init?( path: String )
    {
        self.init( url: URL.init( fileURLWithPath: path ) )
    }
    
    /**
     * Initializes a colorset object from a file.
     * 
     * - parameter url: The file's URL.
     * 
     * - Seealso: `init(data:)`  
     */
    @objc public convenience init?( url: URL )
    {
        guard let data = try? Data( contentsOf: url ) else
        {
            return nil
        }
        
        self.init( data: data )
    }
    
    /**
     * Initializes a colorset object from data.
     * 
     * - parameter data: The colorset data.
     * 
     * - Seealso: `init(data:)`  
     */
    @objc public convenience init?( data: Data )
    {
        if let dict = try? PropertyListSerialization.propertyList( from: data, options: [], format: nil ) as? [ String : Any ]
        {
            self.init( dictionary: dict )
            
            return
        }
        
        if data.count == 0
        {
            return nil
        }
        
        self.init()
        
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
    
    /**
     * Gets a named color from the colorset.
     * If the color name is not found in the colorset, it will be searched in
     * child colorsets, if any.
     * 
     * - parameter key:    The color's name
     * 
     * - returns: The `ColorPair` object corresponding to the name, or `nil` if it's not found.
     *
     * - Seealso: `colorWith(name:)`
     */
    @objc public subscript( key: String ) -> ColorPair?
    {
        return self.colorWith( name: key )
    }
    
    /**
     * Substitutes a specific color with the system's accent color.
     * 
     * On macOS 10.14 and later, this method allows you to use the system's
     * accent color instead of a specific color contained in the colorset.
     * 
     * - parameter name:    The name of the color for which the system's accent color will be substituded.
     */
    @objc public func useAccentColorForColor( name: String )
    {
        self.synchronized
        {
            self.accentNames.append( name )
        }
    }
    
    /**
     * Gets a named color from the colorset.
     * If the color name is not found in the colorset, it will be searched in
     * child colorsets, if any.
     * 
     * - parameter name:    The color's name
     * 
     * - returns: The `ColorPair` object corresponding to the name, or `nil` if it's not found.
     */
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
    
    /**
     * Adds a child colorset.
     * 
     * If a specific color is not found in the parnet colorset, it will be
     * searched in the children.  
     * This allows you to combine multiple colorsets into a single one
     * (usually the main/shared instance).
     * 
     * - parameter child:   The colorset to add as a child.
     */
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
    
    /**
     * Adds a color to the colorset.  
     * The color will be only added if no color exists with the same name.
     * 
     * - parameter color:   The main/primary color.
     * - parameter name:    The color's name.
     * 
     * - Seealso: `set(color:forName:)`
     * - Seealso: `add(color:variant:forName:)` 
     */
    @objc( addColor:forName: )
    public func add( color: NSColor, forName name: String )
    {
        self.add( color: color, variant: nil, forName: name )
    }
    
    /**
     * Sets a color to the colorset.  
     * If a color already exists with the same name, it will be replaced by
     * the new one.
     * 
     * - parameter color:   The main/primary color.
     * - parameter name:    The color's name.
     * 
     * - Seealso: `add(color:forName:)`
     * - Seealso: `set(color:variant:forName:)` 
     */
    @objc( setColor:forName: )
    public func set( color: NSColor, forName name: String )
    {
        self.set( color: color, variant: nil, forName: name )
    }
    
    /**
     * Adds a color to the colorset.  
     * The color will be only added if no color exists with the same name.
     * 
     * - parameter color:   The main/primary color.
     * - parameter variant: An optional variant for the dark mode.
     * - parameter name:    The color's name. 
     * 
     * - Seealso: `set(color:variant:forName:)`
     * - Seealso: `add(color:variant:lightnesses:forName:)` 
     */
    @objc( addColor:variant:forName: )
    public func add( color: NSColor, variant: NSColor?, forName name: String )
    {
        self.add( color: color, variant: variant, lightnesses: [], forName: name )
    }
    
    /**
     * Sets a color to the colorset.  
     * If a color already exists with the same name, it will be replaced by
     * the new one.
     * 
     * - parameter color:   The main/primary color.
     * - parameter variant: An optional variant for the dark mode. 
     * - parameter name:    The color's name.
     * 
     * - Seealso: `add(color:variant:forName:)`
     * - Seealso: `set(color:variant:lightnesses:forName:)`  
     */
    @objc( setColor:variant:forName: )
    public func set( color: NSColor, variant: NSColor?, forName name: String )
    {
        self.set( color: color, variant: variant, lightnesses: [], forName: name )
    }
    
    /**
     * Adds a color to the colorset.  
     * The color will be only added if no color exists with the same name.
     * 
     * - parameter color:       The main/primary color.
     * - parameter variant:     An optional variant for the dark mode. 
     * - parameter lightnesses: An array of `LightnessPair`. Can be empty.
     * - parameter name:        The color's name. 
     * 
     * - Seealso: `set(color:variant:lightnesses:forName:)`
     * - Seealso: `LightnessPair` 
     */
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
    
    /**
    * Sets a color to the colorset.  
    * If a color already exists with the same name, it will be replaced by
    * the new one.    
     * 
     * - parameter color:       The main/primary color.
     * - parameter variant:     An optional variant for the dark mode. 
     * - parameter lightnesses: An array of `LightnessPair`. Can be empty.
     * - parameter name:        The color's name. 
     * 
     * - Seealso: `LightnessPair` 
     */
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
    
    /**
     * Generates binary data representing the colorset.
     */
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
            stream += UInt64( colors.count )
            
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
    
    /**
     * Writes the colorset to a file.
     * 
     * - parameter url: The URL at which to write the colorset file.
     */
    @objc public func writeTo( url: URL ) throws
    {
        do
        {
            try self.writeTo( url: url, format: self.format )
        }
        catch let e
        {
            throw e
        }
    }
    
    @objc public func writeTo( url: URL, format: Format ) throws
    {
        var data: Data?
        
        do
        {
            switch format
            {
                case .binary: data = self.data
                case .xml:    data = try PropertyListSerialization.data( fromPropertyList: self.toDictionary(), format: .xml, options: 0 )
            }
            
            try data?.write( to: url )
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
    
    @objc public required init?( dictionary: [ String : Any ] )
    {
        guard let magic = dictionary[ "magic" ] as? UInt64,
              let major = dictionary[ "major" ] as? UInt64,
              let minor = dictionary[ "minor" ] as? UInt64
        else
        {
            return nil
        }
        
        if magic != ColorSet.magic
        {
            return nil
        }
        
        if major < 1 || minor < 2
        {
            return nil
        }
        
        if let colors = dictionary[ "colors" ] as? [ String : [ String : Any ] ]
        {
            for p in colors
            {
                guard let color = ColorPair( dictionary: p.value ) else
                {
                    continue
                }
                
                self.colorPairs[ p.key ] = color
            }
        }
        
        self.format = .xml
    }
    
    @objc public func toDictionary() -> [ String : Any ]
    {
        var colors: [ String : ColorPair ]!
        
        self.synchronized
        {
            colors = self.colorPairs
        }
        
        var dict = [ String : Any ]()
        
        dict[ "magic" ] = ColorSet.magic
        dict[ "major" ] = UInt32( ColorSet.major )
        dict[ "minor" ] = UInt32( ColorSet.minor )
        
        var pairs = [ String : [ String : Any ] ]()
        
        for p in colors
        {
            pairs[ p.key ] = p.value.toDictionary()
        }
        
        dict[ "colors" ] = pairs
        
        return dict
    }
}
