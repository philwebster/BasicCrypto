//
//  BCRMasterViewController.h
//  BasicCrypto
//
//  Created by Phil Webster on 3/7/14.
//  Copyright (c) 2014 Phil Webster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BCRMasterViewController : UITableViewController

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *noteDB;
@end
