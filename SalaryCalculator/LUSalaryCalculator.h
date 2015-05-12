//
//  LUSalaryCalculator.h
//  所得税计算类
//
//  Created by song lei on 15/2/18.
//  Copyright (c) 2015年 lucky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LUSalaryCalculator : NSObject

@property int salary;   //税前薪资
@property int boundsTypeId; //保险基数选择类型：0最低，1全部，2自定义
@property int cityId;   //城市选择

-(id)initWithSalary:(int) salary BoundTypeId:(int) boundTypeId CityId:(int) cityId; //初始化构造函数
-(NSMutableDictionary*) getPersonalResult;  //得到个人缴费部分计算结果
-(NSMutableDictionary*) getCompanyResult;   //得到企业缴费部分计算结果

@end
