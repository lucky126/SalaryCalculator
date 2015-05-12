//
//  LUMainViewController.h
//  SalaryCalculator
//
//  Created by song lei on 15/2/12.
//  Copyright (c) 2015年 lucky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUResultViewController.h"

@interface LUMainViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *salarField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *btnCalculator;

@end
