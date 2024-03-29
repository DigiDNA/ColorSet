/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2022, DigiDNA
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa
import ColorSetKit

class MainWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSMenuDelegate
{
    @objc private dynamic var               selectedColor: ColorItem?
    @objc private dynamic var               hasVariant          = false
    @objc public private( set ) dynamic var colors:        [ ColorItem ] = []

    public  var url:                           URL?
    private var observations:                  [ NSKeyValueObservation ] = []
    private var tableView:                     NSTableView?
    private var colorNameTextField:            NSTextField?
    private var searchField:                   NSSearchField?
    private var timer:                         Timer?
    private var lightnessPairWindowController: LightnessPairWindowController?
    private var paletteViewController:         PaletteViewController?
    private var format:                        ColorSet.Format = .binary

    @IBOutlet public var colorsArrayController:         NSArrayController!
    @IBOutlet public var lightnessPairsArrayController: NSArrayController!
    @IBOutlet public var collectionView:                NSCollectionView!
    @IBOutlet public var paletteViewContainer:          NSView!

    convenience init( colors: [ ColorItem ], format: ColorSet.Format )
    {
        self.init()

        self.colors = colors
        self.format = format
    }

    deinit
    {
        self.timer?.invalidate()
    }

    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name( NSStringFromClass( type( of: self ) ) )
    }

    override func windowDidLoad()
    {
        self.window?.title = ( self.url == nil ) ? "Untitled.colorset" : ( self.url!.path as NSString ).lastPathComponent

        guard let colorView = self.window?.contentView?.subviewWithIdentifier( "Color" ) as? ColorView
        else
        {
            return
        }

        guard let variantView = self.window?.contentView?.subviewWithIdentifier( "Variant" ) as? ColorView
        else
        {
            return
        }

        guard let tableView = self.window?.contentView?.subviewWithIdentifier( "TableView" ) as? NSTableView
        else
        {
            return
        }

        guard let colorNameTextField = self.window?.contentView?.subviewWithIdentifier( "ColorNameTextField" ) as? NSTextField
        else
        {
            return
        }

        guard let searchField = self.window?.contentView?.subviewWithIdentifier( "SearchField" ) as? NSSearchField
        else
        {
            return
        }

        self.tableView          = tableView
        self.colorNameTextField = colorNameTextField
        self.searchField        = searchField

        self.colorsArrayController.sortDescriptors        = [ NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ) ]
        self.colorsArrayController.selectsInsertedObjects = true

        colorView.bind(   NSBindingName( "color" ), to: self, withKeyPath: "selectedColor.color",   options: nil )
        variantView.bind( NSBindingName( "color" ), to: self, withKeyPath: "selectedColor.variant", options: nil )

        self.collectionView.register( LightnessPairCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier( rawValue: "LightnessPairCollectionViewItem" ) )

        let o1 = self.colorsArrayController.observe( \.selectionIndexes, options: .new )
        {
            [ weak self ] o, c in guard let self = self else { return }

            guard let color = self.colorsArrayController.selectedObjects.first as? ColorItem
            else
            {
                self.selectedColor = nil
                self.hasVariant    = false

                self.paletteViewController?.colorSet = self.generateColorSet()

                return
            }

            self.selectedColor = color
            self.hasVariant    = color.variant != nil

            self.updateLightnesses()
        }

        let o2 = self.observe( \.hasVariant, options: .new )
        {
            [ weak self ] o, c in guard let self = self else { return }

            guard let color = self.colorsArrayController.selectedObjects.first as? ColorItem
            else
            {
                return
            }

            if self.hasVariant == false
            {
                color.variant = nil
            }
            else if self.hasVariant, color.variant == nil
            {
                color.variant = color.color
            }
        }

        let o3 = self.observe( \.selectedColor?.color )
        {
            [ weak self ] o, c in self?.updateLightnesses()
        }

        self.observations.append( contentsOf: [ o1, o2, o3 ] )

        self.paletteViewController           = PaletteViewController()
        self.paletteViewController?.colorSet = self.generateColorSet()

        if let view = self.paletteViewController?.view
        {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.frame                                     = self.paletteViewContainer.bounds

            self.paletteViewContainer.addSubview( view )

            self.paletteViewContainer.addConstraint( NSLayoutConstraint( item: view, attribute: .centerX, relatedBy: .equal, toItem: self.paletteViewContainer, attribute: .centerX, multiplier: 1, constant: 0 ) )
            self.paletteViewContainer.addConstraint( NSLayoutConstraint( item: view, attribute: .centerY, relatedBy: .equal, toItem: self.paletteViewContainer, attribute: .centerY, multiplier: 1, constant: 0 ) )
            self.paletteViewContainer.addConstraint( NSLayoutConstraint( item: view, attribute: .width,   relatedBy: .equal, toItem: self.paletteViewContainer, attribute: .width, multiplier: 1, constant: 0 ) )
            self.paletteViewContainer.addConstraint( NSLayoutConstraint( item: view, attribute: .height,  relatedBy: .equal, toItem: self.paletteViewContainer, attribute: .height,  multiplier: 1, constant: 0 ) )
        }
    }

    private func updateLightnesses()
    {
        for l in self.lightnessPairsArrayController.content as? [ LightnessPairItem ] ?? []
        {
            l.lightness1.base = self.selectedColor
            l.lightness2.base = self.selectedColor

            l.onEdit =
            {
                [ weak self ] item in self?.editLightnessPair( item )
            }

            l.onDelete =
            {
                [ weak self ] item in self?.lightnessPairsArrayController.removeObject( item )
            }
        }
    }

    @IBAction
    public func performFindPanelAction( _ sender: Any? )
    {
        self.window?.makeFirstResponder( self.searchField )
    }

    @IBAction
    public func saveDocument( _ sender: Any? )
    {
        guard let url = self.url
        else
        {
            self.saveDocumentAs( sender )

            return
        }

        self.save( to: url, format: self.format )
    }

    @IBAction
    public func saveDocumentAs( _ sender: Any? )
    {
        guard let window = self.window
        else
        {
            return
        }

        let panel   = NSSavePanel()
        let options = SaveAsOptionsViewController()

        panel.allowedFileTypes     = [ "colorset" ]
        panel.canCreateDirectories = true
        panel.accessoryView        = options.view

        panel.beginSheetModal( for: window )
        {
            r in

            if r != .OK
            {
                return
            }

            guard let url = panel.url
            else
            {
                return
            }

            self.save( to: url, format: options.format )

            self.format        = options.format
            self.url           = url
            self.window?.title = ( self.url == nil ) ? "Untitled.colorset" : ( self.url!.path as NSString ).lastPathComponent
        }
    }

    public func save( to url: URL, format: ColorSet.Format )
    {
        let set = self.generateColorSet()

        do
        {
            try set.writeTo( url: url, format: format )
        }
        catch let error as NSError
        {
            let alert = NSAlert( error: error )

            guard let window = self.window
            else
            {
                alert.runModal()

                return
            }

            alert.beginSheetModal( for: window, completionHandler: nil )
        }
    }

    public func generateColorSet() -> ColorSet
    {
        let set = ColorSet()

        for color in self.colors
        {
            var lightnesses = [ LightnessPair ]()

            for p in color.lightnessPairs
            {
                let lightness = LightnessPair()

                lightness.lightness1.lightness = p.lightness1.lightness
                lightness.lightness1.name      = p.lightness1.name ?? ""
                lightness.lightness2.lightness = p.lightness2.lightness
                lightness.lightness2.name      = p.lightness2.name ?? ""

                lightnesses.append( lightness )
            }

            set.add( color: color.color, variant: color.variant, lightnesses: lightnesses, forName: color.name )
        }

        return set
    }

    @IBAction
    public func newColor( _ sender: Any? )
    {
        var i     = 0
        let color = ColorItem()

        for item in self.colors
        {
            if item.name.hasPrefix( "Untitled" )
            {
                i += 1
            }
        }

        color.name = ( i > 0 ) ? "Untitled-" + String( describing: i ) : "Untitled"

        self.colorsArrayController?.addObject( color )
        self.window?.makeFirstResponder( self.colorNameTextField )
    }

    @IBAction
    public func removeColor( _ sender: Any? )
    {
        guard let tableView = self.tableView
        else
        {
            return
        }

        if tableView.clickedRow >= 0
        {
            self.colorsArrayController?.remove( atArrangedObjectIndex: tableView.clickedRow )
        }
    }

    func tableView( _ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int ) -> NSView?
    {
        guard let view = tableView.makeView( withIdentifier: NSUserInterfaceItemIdentifier( "Row" ), owner: self ) as? NSTableCellView
        else
        {
            return nil
        }

        for sub in view.subviews
        {
            if sub.isKind( of: ColorView.self )
            {
                sub.bind( NSBindingName( "color" ), to: view, withKeyPath: "objectValue.color", options: nil )
                sub.bind( NSBindingName( "variant" ), to: view, withKeyPath: "objectValue.variant", options: nil )
            }
            else if sub.isKind( of: NSTextField.self )
            {
                ( sub as? NSTextField )?.delegate = self
            }
        }

        return view
    }

    func control( _ control: NSControl, textShouldBeginEditing fieldEditor: NSText ) -> Bool
    {
        return true
    }

    func control( _ control: NSControl, textShouldEndEditing fieldEditor: NSText ) -> Bool
    {
        guard let textField = control as? NSTextField
        else
        {
            return false
        }

        guard let cell = control.superview as? NSTableCellView
        else
        {
            return false
        }

        guard let color = cell.objectValue as? ColorItem
        else
        {
            return false
        }

        for item in self.colors
        {
            if item == color
            {
                continue
            }

            if textField.stringValue == item.name
            {
                return false
            }
        }

        return true
    }

    func validateMenuItem( _ item: NSMenuItem ) -> Bool
    {
        guard let tableView = self.tableView
        else
        {
            return false
        }

        if item.action == #selector( self.removeColor( _: ) )
        {
            return tableView.clickedRow >= 0
        }

        return true
    }

    @IBAction
    func addLightnessPair( _ sender: Any? )
    {
        self.editLightnessPair( nil )
        {
            [ weak self ] c, r in

            if r == .OK
            {
                self?.lightnessPairsArrayController.addObject( c.item )
            }
        }
    }

    func editLightnessPair( _ item: LightnessPairItem?, completion: ( ( LightnessPairWindowController, NSApplication.ModalResponse ) -> Void )? = nil )
    {
        guard let selectedColor = self.selectedColor
        else
        {
            NSSound.beep()

            return
        }

        if self.lightnessPairWindowController != nil
        {
            NSSound.beep()

            return
        }

        guard let window = self.window
        else
        {
            NSSound.beep()

            return
        }

        let o = item ?? LightnessPairItem( base: selectedColor )

        let sheetController = LightnessPairWindowController( base: selectedColor, item: o )

        guard let sheet = sheetController.window
        else
        {
            NSSound.beep()

            return
        }

        self.lightnessPairWindowController = sheetController

        window.beginSheet( sheet )
        {
            [ weak self ] r in guard let self = self else { return }

            self.lightnessPairWindowController = nil

            if r != .OK
            {
                completion?( sheetController, r )

                return
            }

            completion?( sheetController, r )
            self.updateLightnesses()
        }
    }
}
