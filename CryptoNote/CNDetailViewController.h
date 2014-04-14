//
//  CNDetailViewController.h
//  CryptoNote
//
//  Created by Phil Webster on 3/31/14.
//  Copyright (c) 2014 philwebster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNMasterViewController.h"

@interface CNDetailViewController : UIViewController <UISplitViewControllerDelegate, UITextViewDelegate>
- (void)setContext:(NSManagedObjectContext *)context;
@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailText;
@end
