//
//  BCRDetailViewController.h
//  BasicCrypto
//
//  Created by Phil Webster on 3/7/14.
//  Copyright (c) 2014 Phil Webster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCRDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
