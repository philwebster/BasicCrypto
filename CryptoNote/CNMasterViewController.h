//
//  CNMasterViewController.h
//  CryptoNote
//
//  Created by Phil Webster on 3/31/14.
//  Copyright (c) 2014 philwebster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CNDetailViewController;

#import <CoreData/CoreData.h>

@interface CNMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) CNDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
