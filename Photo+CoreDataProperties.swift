
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {
  
  @NSManaged var imageData: Data?
  @NSManaged var url: String
  @NSManaged var pin: Pin
  
}
