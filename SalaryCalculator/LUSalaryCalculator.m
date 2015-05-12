//
//  LUSalaryCalculator.m
//  SalaryCalculator
//
//  Created by song lei on 15/2/18.
//  Copyright (c) 2015年 lucky. All rights reserved.
//

#import "LUSalaryCalculator.h"

@implementation LUSalaryCalculator

NSArray* arraySettingType;
NSArray* arrayBoundsType;
NSArray* arrayCity;
NSMutableDictionary* dict;
NSString* filePath;

//初始化构造函数
-(id)initWithSalary:(int) salary BoundTypeId:(int) boundTypeId CityId:(int) cityId
{
    if(self == [super init])
    {
        self.salary = salary;
        self.boundsTypeId = boundTypeId;
        self.cityId = cityId;
    }
    return self;
}

//基础设置方法，用于初始化数组和获取配置文件信息
-(void)setup
{
    //基础参数设置
    //plist大分类列表
    arraySettingType = [NSArray arrayWithObjects: @"PersonalRate",@"CompanyRate",@"InsuranceBase",@"CityBase",nil];
    //保险列表
    arrayBoundsType = [NSArray arrayWithObjects: @"HousingFund",@"MedicalInsurance",@"EndowmentInsurance",@"EmploymentInjuryInsurance",@"UnemploymentInsurance",@"MaternityInsurance",nil];
    //城市列表
    arrayCity = [NSArray arrayWithObjects:@"BeiJing",@"ShangHai" ,nil];

    
    //查找文件
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    filePath = [rootPath stringByAppendingPathComponent:@"setting.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    }
    
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
}

//查找指定可变字典
-(NSMutableDictionary*) getSettingDic:(NSInteger) segId
{
    NSDictionary* settingDic = [dict objectForKey:arraySettingType[segId]];
    return [[NSMutableDictionary alloc] initWithDictionary:settingDic];
}

//查找指定可变数组，用于查询具体配置信息
-(NSMutableArray *) getSettingValue:(int) index andSeg:(NSInteger) segId
{
    NSArray* settingArr;
    if (segId<3) {
        //查询个人，单位和自定义基数
        settingArr = [[self getSettingDic:segId] objectForKey:arrayBoundsType[index]];
    }else{
        //查询城市
        settingArr = [[self getSettingDic:segId] objectForKey:arrayCity[self.cityId]];
    }
    return [[NSMutableArray alloc] initWithArray:settingArr] ;
}

//得到个人缴费部分计算结果
-(NSMutableDictionary*) getPersonalResult
{
    [self setup];
    //初始化返回结果
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    //遍历所有五险一金类型，计算相应数值
    for (int i=0; i<arrayBoundsType.count; i++) {
        float boundValue = 0.0;
        float boundPercent = [[[self getSettingValue:i andSeg:0] objectAtIndex:0] floatValue];
        bool isUse =[[[self getSettingValue:i andSeg:0] objectAtIndex:1] boolValue];
        if (isUse) {
            if (i==0) {
                boundValue = [self getBoundValue:boundPercent andIsEndo:NO andIsHouse:YES andIndex:i];
            }else if (i==2 || i==4){
                boundValue = [self getBoundValue:boundPercent andIsEndo:YES andIsHouse:NO andIndex:i];
            }else{
                boundValue = [self getBoundValue:boundPercent andIsEndo:NO andIsHouse:NO andIndex:i];
            }
        }
        [result setValue:[NSString stringWithFormat:@"%9.2f",boundValue] forKey:arrayBoundsType[i]];
    }
    //计算所得税
    float tax =[self getIncomeTax:result];
    [result setValue:[NSString stringWithFormat:@"%9.2f",tax] forKey:@"IncomeTax"];
    //计算税后工资
    [result setValue:[NSString stringWithFormat:@"%9.2f",[self getSalaryAfterTax:result andTax:tax]] forKey:@"SalaryAfterTax"];
    
    return result;
}

//得到企业缴费部分计算结果
-(NSMutableDictionary*) getCompanyResult
{
    [self setup];
    //初始化返回结果
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    //遍历所有五险一金类型，计算相应数值
    for (int i=0; i<arrayBoundsType.count; i++) {
        float boundValue = 0.0;
        float boundPercent = [[[self getSettingValue:i andSeg:1] objectAtIndex:0] floatValue];
        bool isUse =[[[self getSettingValue:i andSeg:1] objectAtIndex:1] boolValue];
        if (isUse) {
            if (i==0) {
                boundValue = [self getBoundValue:boundPercent andIsEndo:NO andIsHouse:YES andIndex:i];
            }else if (i==2 || i==4){
                boundValue = [self getBoundValue:boundPercent andIsEndo:YES andIsHouse:NO andIndex:i];
            }else{
                boundValue = [self getBoundValue:boundPercent andIsEndo:NO andIsHouse:NO andIndex:i];
            }
        }
        [result setValue:[NSString stringWithFormat:@"%9.2f",boundValue] forKey:arrayBoundsType[i]];
    }
    
    return result;
}

//计算社保缴纳额度
-(float) getBoundValue:(float) boundPercent andIsEndo:(bool) isEndoAndUnd andIsHouse:(bool) isHouse andIndex:(int)index
{
    //计算五险一金，如果BoundTypeId为0，则按照最低额度计算，如果为1，按照实际计算，如果为2，按照自定义的数值计算
    //根据boundTypeId确定是按照哪种方式计算，再根据税前工资计算相关费用
    int boundMax = [[[self getSettingValue:0 andSeg:3] objectAtIndex:1] intValue];
    //养老，失业按照1项，其余按照2项计算最低额度，最高不超过0项
    int endoAndUndMin =[[[self getSettingValue:0 andSeg:3] objectAtIndex:2] intValue];
    int otherMin =[[[self getSettingValue:0 andSeg:3] objectAtIndex:3] intValue];

    //判断保险类型
    NSInteger boundMin = isEndoAndUnd?endoAndUndMin:otherMin;
    //公积金缴费上限是2倍的0项
    boundMax = isHouse ? boundMax * 2 : boundMax;
    
    NSInteger boundSalary = _salary > boundMax ? boundMax : _salary;
    boundSalary = boundSalary < boundMin ? boundMin : boundSalary;
    
    if (self.boundsTypeId == 0) {
        boundSalary = boundMin;
    }else if (_boundsTypeId == 2){
        boundSalary = [[[self getSettingValue:index andSeg:2] objectAtIndex:0] floatValue];
    }
    
    return boundSalary * boundPercent / 100;
}

//计算所得税
-(float) getIncomeTax:(NSMutableDictionary*) arrayBound
{
    //初始化税前工资
    float incomeTaxSalary = _salary;
    float incomeTax = 0.0;
    //遍历所有五险一金，扣除相关费用，得到应纳税所得额
    for (int i = 0; i < arrayBoundsType.count; i++) {
        incomeTaxSalary -= [[arrayBound valueForKey:arrayBoundsType[i]] floatValue];
    }
    //扣除缴费基数3500
    incomeTaxSalary -= 3500;
    
    /*
     全月应纳税所得额	全月应纳税所得额（不含税级距）	税率(%)	速算扣除数
     不超过1,500元	不超过1455元的	3	0
     超过1,500元至4,500元的部分	超过1455元至4155元的部分	10	105
     超过4,500元至9,000元的部分	超过4155元至7755元的部分	20	555
     超过9,000元至35,000元的部分	超过7755元至27255元的部分	25	1,005
     超过35,000元至55,000元的部分	超过27255元至41255元的部分	30	2,755
     超过55,000元至80,000元的部分	超过41255元至57505元的部分	35	5,505
     超过80,000元的部分	超过57505元的部分	45	13,505
     */
    if(incomeTaxSalary<1500)
    {
        incomeTax = incomeTaxSalary * 0.03;
    }else if (incomeTaxSalary<4500){
        incomeTax = incomeTaxSalary * 0.1-105;
    }else if (incomeTaxSalary<9000){
        incomeTax = incomeTaxSalary * 0.2-555;
    }else if (incomeTaxSalary<35000){
        incomeTax = incomeTaxSalary * 0.25-1005;
    }else if (incomeTaxSalary<55000){
        incomeTax = incomeTaxSalary * 0.3-2755;
    }else if (incomeTaxSalary<80000){
        incomeTax = incomeTaxSalary * 0.35-5505;
    }else{
        incomeTax = incomeTaxSalary * 0.45-13505;
    }
    
    return incomeTax;
}

//获得税后工资
-(float) getSalaryAfterTax:(NSMutableDictionary*) arrayBound andTax:(float) tax
{
    float result = _salary;
    
    for (int i=0; i<arrayBoundsType.count; i++) {
        result -= [[arrayBound valueForKey:arrayBoundsType[i]] floatValue];
    }
    return result-tax;
}

@end
