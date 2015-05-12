//
//  LUResultViewController.m
//  SalaryCalculator
//
//  Created by song lei on 15/2/12.
//  Copyright (c) 2015年 lucky. All rights reserved.
//

#import "LUResultViewController.h"

@interface LUResultViewController ()
@property(nonatomic) NSInteger segId;
@end

@implementation LUResultViewController
@synthesize segId;

NSArray* arrayBoundsCNName;
NSArray* arrayBoundsType;
NSDictionary* dict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//初始化设置
-(void) setup
{
    //基础参数设置
    //保险中文名称
    arrayBoundsCNName = [NSArray arrayWithObjects: @"住房公积金",@"医疗保险",@"养老保险",@"工伤保险",@"失业保险",@"生育保险",nil];
    //保险名称
    arrayBoundsType = [NSArray arrayWithObjects: @"HousingFund",@"MedicalInsurance",@"EndowmentInsurance",@"EmploymentInjuryInsurance",@"UnemploymentInsurance",@"MaternityInsurance",nil];
    
    //查找文件
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view.
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.allowsSelection = NO;
}
//返回薪资计算器对象实例
-(LUSalaryCalculator*) getCalculator
{
    return [[LUSalaryCalculator alloc] initWithSalary:self.salary BoundTypeId:self.boundTypeId CityId: self.cityId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeSegmentValue:(id)sender {
    segId = [sender selectedSegmentIndex];
    
    [self.table reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* indentifier = @"cell1";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier forIndexPath:indexPath];
    
    UILabel* boundName =(UILabel*)[cell viewWithTag:1];
    UITextField* boundValue =(UITextField*)[cell viewWithTag:2];
    boundValue.textAlignment = NSTextAlignmentLeft;
    LUSalaryCalculator* cal=[self getCalculator];
    
    if(segId==0 && indexPath.row>=arrayBoundsCNName.count)
    {
        //个人缴费部分总计项部分
        NSMutableDictionary* result = [cal getPersonalResult];
        if(indexPath.row==arrayBoundsCNName.count){
            boundName.text = @"所得税：";
            boundValue.text = [result valueForKey:@"IncomeTax"];

        }else{
            boundName.text = @"税后工资：";
            boundValue.text = [result valueForKey:@"SalaryAfterTax"];
        }
    }else{
        //个人和单位缴费各保险项目计算结果
        boundName.text = [[arrayBoundsCNName objectAtIndex:indexPath.row] stringByAppendingString:@"："];
        NSMutableDictionary* result;
        if (segId==0) {
            result=[cal getPersonalResult];
        }else{
            result=[cal getCompanyResult];
        }
        boundValue.text = [result valueForKey:[arrayBoundsType objectAtIndex:indexPath.row]];
    }
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segId==0) {
        return arrayBoundsCNName.count+2;
    }else{
        return arrayBoundsCNName.count;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



@end
