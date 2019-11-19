/*******************************************************************************
 * Copyright (c) 2019, DigiDNA
 * All rights reserved
 * 
 * Unauthorised copying of this copyrighted work, via any medium is strictly
 * prohibited.
 * Proprietary and confidential.
 ******************************************************************************/

import Foundation

@objc public protocol DictionaryRepresentable
{
    @objc init?( dictionary: [ String : Any ] )
    @objc func toDictionary() -> [ String : Any ]
}
