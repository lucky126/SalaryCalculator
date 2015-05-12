//
//  LUSettingViewController.h
//  SalaryCalculator
//
//  Created by song lei on 15/2/12.
//  Copyright (c) 2015年 lucky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LUSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;

-(void)savePlist:(NSInteger)row andArry:(NSMutableArray*) arr;
@end
