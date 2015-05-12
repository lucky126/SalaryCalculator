//
//  LUMainViewController.m
//  SalaryCalculator
//
//  Created by song lei on 15/2/12.
//  Copyright (c) 2015年 lucky. All rights reserved.
//

#import "LUMainViewController.h"

@interface LUMainViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic) NSInteger boundTypeId;
@property(nonatomic) NSInteger cityId;
@property (strong, nonatomic) UIPickerView *picker;
@end

@implementation LUMainViewController
NSArray* arrayCity;
NSArray* arraySettingType;
NSMutableDictionary* dict;
NSString* filePath;
@synthesize boundTypeId;
@synthesize cityId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

//初始化数据
-(void) setup
{
    //基础参数设置
    arraySettingType = [NSArray arrayWithObjects: @"PersonalRate",@"CompanyRate",@"InsuranceBase",@"CityBase",nil];
    arrayCity = [NSArray arrayWithObjects:@"BeiJing",@"ShangHai" ,nil];
    
    //查找文件
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    //设置城市默认选择
    cityId = 0;
    self.cityField.text =[[self getSettingValue:cityId] objectAtIndex:0];
    
    //绑定城市选择的UIPickerView控件
    _picker=[[UIPickerView alloc]init];
    _picker.delegate = self;
    _picker.dataSource = self;
    self.cityField.inputView = _picker;
    
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.table addGestureRecognizer:gestureRecognizer];
}

//隐藏文本框键盘
- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//缴费类型选择
- (IBAction)segmentChange:(id)sender {
    boundTypeId=[sender selectedSegmentIndex];
}

//从字典中获取子项字典，只取得城市部分
-(NSMutableDictionary*) getSettingDic
{
    NSDictionary* settingDic = [dict objectForKey:arraySettingType[3]];
    return [[NSMutableDictionary alloc] initWithDictionary:settingDic];
}

//从字典中获取数组
-(NSMutableArray *) getSettingValue:(NSInteger) index
{
    NSArray* settingArr = [[self getSettingDic] objectForKey:arrayCity[index]];
    return [[NSMutableArray alloc] initWithArray:settingArr] ;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 获取segue将要跳转到的目标视图控制器
    id destController = segue.destinationViewController;
    // 使用KVC方式将label内的文本设为destController的editContent属性值
    [destController setValue:self.salarField.text forKey:@"salary"];
    [destController setValue:[NSString stringWithFormat:@"%ld",(long)boundTypeId] forKey:@"boundTypeId"];
    [destController setValue:[NSString stringWithFormat:@"%ld",(long)cityId] forKey:@"cityId"];    
}


#pragma mark - PickerView
//pickerview
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self getSettingDic] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self getSettingValue:row] objectAtIndex:0];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.cityField.text =[[self getSettingValue:row] objectAtIndex:0];
    cityId = row;
}
//pickerview end

//通过薪资文本框控制计算按钮是否可以使用
- (IBAction)ChangeSalaryInput:(id)sender {
    if(self.salarField.text.length>0){
        self.btnCalculator.enabled = TRUE;
    }else{
        self.btnCalculator.enabled = FALSE;
    }
}


- (IBAction)finishEdit:(id)sender {
   
    [sender resignFirstResponder];
}



@end
