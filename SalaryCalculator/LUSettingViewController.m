//
//  LUSettingViewController.m
//  SalaryCalculator
//
//  Created by song lei on 15/2/12.
//  Copyright (c) 2015年 lucky. All rights reserved.
//

#import "LUSettingViewController.h"


@interface LUSettingViewController ()
@property(nonatomic) NSInteger segId;
@end

@implementation LUSettingViewController

@synthesize segId;

NSArray* arrayBoundsCNName;
NSArray* arraySettingType;
NSArray* arrayBoundsType;
NSMutableDictionary* dict;
NSString* filePath;
//是否显示行内的开关控件
bool isUseSwitch;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self setup];
    }
    return self;
}

//初始化数据
-(void) setup
{
    //基础参数设置
    //保险中文名称
    arrayBoundsCNName = [NSArray arrayWithObjects: @"住房公积金",@"医疗保险",@"养老保险",@"工伤保险",@"失业保险",@"生育保险",nil];
    //plist大类
    arraySettingType = [NSArray arrayWithObjects: @"PersonalRate",@"CompanyRate",@"InsuranceBase",@"CityBase",nil];
    //保险名称
    arrayBoundsType = [NSArray arrayWithObjects: @"HousingFund",@"MedicalInsurance",@"EndowmentInsurance",@"EmploymentInjuryInsurance",@"UnemploymentInsurance",@"MaternityInsurance",nil];
    
    //查找文件
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    filePath = [rootPath stringByAppendingPathComponent:@"setting.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    }
    
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view.
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.allowsSelection = NO;
    isUseSwitch = true;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.table addGestureRecognizer:gestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

//根据设置选项卡选择，确定读取dict的哪个大类
-(NSMutableDictionary*) getSettingDic
{
    NSDictionary* settingDic = [dict objectForKey:arraySettingType[segId]];
    return [[NSMutableDictionary alloc] initWithDictionary:settingDic];
}

//读取dict指定大类的小类
-(NSMutableArray *) getSettingValue:(NSInteger) index
{
    NSArray* settingArr = [[self getSettingDic] objectForKey:arrayBoundsType[index]];
    return [[NSMutableArray alloc] initWithArray:settingArr] ;
}

//设置选项卡切换，0个人，1单位，2基数
- (IBAction)segmentChanged:(id)sender {
    segId = [sender selectedSegmentIndex];
    switch (segId) {
        case 0:
            isUseSwitch=true;
            break;
        case 1:
            isUseSwitch=true;
            break;
        case 2:
            isUseSwitch = false;
            break;
        default:
            break;
    }
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
    
    //保险名称
    UILabel* boundName =(UILabel*)[cell viewWithTag:1];
    boundName.text = [[arrayBoundsCNName objectAtIndex:indexPath.row] stringByAppendingString:@"："];
    //保险值
    UITextField* boundValue =(UITextField*)[cell viewWithTag:2];
    boundValue.text = [[self getSettingValue:indexPath.row] objectAtIndex:0];
    //是否启用保险
    UISwitch* boundSwitch = (UISwitch*)[cell viewWithTag:3];
    boundSwitch.hidden = !isUseSwitch;
    //保险设置单位，非基数设定选项卡时单位为%
    UILabel* boundPix =(UILabel*)[cell viewWithTag:4];
    boundPix.text=@"元";
    //基数设定时不能设置是否启用该项，且单位为元
    if(segId<2)
    {
        boundPix.text = @"%";
        boundSwitch.on = [(NSNumber *)[[self getSettingValue:indexPath.row] objectAtIndex:1] boolValue];
    }
    
    return cell;
}
//值修改后立即保存
- (IBAction)changeValue:(id)sender {
    [sender resignFirstResponder];
    UITextField* txt =(UITextField*)sender;
    
    //IOS版本差异造成获得对象的方式不一致
    UITableViewCell* cell;
    float Version=[[[UIDevice currentDevice] systemVersion] floatValue];
    if(Version>=7.0)
    {
        cell = (UITableViewCell *)txt.superview.superview.superview;
    }
    else
    {
        cell=(UITableViewCell *)txt.superview.superview;
    }
    //获得该文本框所在tableviewcell的行数
    NSInteger row = [self.table indexPathForCell:cell].row;
    //根据行数获得dict内对应的数组对象
    NSMutableArray* arr = [self getSettingValue:row];
    //替换数组内对应内容
    [arr replaceObjectAtIndex:0 withObject:txt.text];
    //调用保存
    [self savePlist:row andArry:arr];
}
//是否启用保险改变时立即保存
- (IBAction)changeSwitch:(id)sender {
    //获得是否启用标记
    UISwitch* sw =(UISwitch*)sender;
    bool isOn;
    if(sw.isOn)
    {
        isOn = YES;
    }else{
        isOn = NO;
    }
    
    //IOS版本差异造成获得对象的方式不一致
    UITableViewCell* cell;
    float Version=[[[UIDevice currentDevice] systemVersion] floatValue];
    if(Version>=7.0)
    {
        cell = (UITableViewCell *)sw.superview.superview.superview;
    }
    else
    {
        cell=(UITableViewCell *)sw.superview.superview;
    }
     //获得该文本框所在tableviewcell的行数
    NSInteger row = [self.table indexPathForCell:cell].row;
    //根据行数获得dict内对应的数组对象
    NSMutableArray* arr = [self getSettingValue:row];
    //替换数组内对应内容
    [arr replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:isOn]];
    //调用保存
    [self savePlist:row andArry:arr];
}

//保存plist修改
-(void)savePlist:(NSInteger)row andArry:(NSMutableArray*) arr
{
    //得到当前设置选项卡内在dict对应的字典对象
    NSMutableDictionary* newDic = [self getSettingDic];
    //替换给定row设定的字典项的值
    [newDic setValue:arr forKey:arrayBoundsType[row]];
    //替换该设置选项卡的全部内容
    [dict setValue:newDic forKey:arraySettingType[segId]];
    //得到plist文件所在的文件夹路径
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //plist对应的文件路径
    filePath = [rootPath stringByAppendingPathComponent:@"setting.plist"];
    //保存文件
    [dict writeToFile:filePath atomically:YES];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayBoundsCNName.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"参数设置";
}

@end
