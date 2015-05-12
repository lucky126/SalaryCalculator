//
//  LUResultViewController.h
//  SalaryCalculator
//
//  Created by song lei on 15/2/12.
//  Copyright (c) 2015年 lucky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUSalaryCalculator.h"

@interface LUResultViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic) int salary;
@property (nonatomic) int boundTypeId;
@property (nonatomic) int cityId;
@end
