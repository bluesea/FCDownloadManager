//
//  FCViewController.m
//  DownloadManager
//
//  Created by pingyandong on 14-2-22.
//  Copyright (c) 2014年 平 艳东. All rights reserved.
//

#import "FCViewController.h"
#import "RadioCell_iPhone.h"
#import "ExpandRadioCell_iPhone.h"
#import "Sql_Utils.h"
#import "DownloadViewController.h"
#import "DownloadManager.h"

@interface FCViewController ()

@end

@implementation FCViewController
- (void)dealloc
{
    [radioTable release];
    [radioListArray release];
    [downloadingArray release];
    [statusDict release];
    [taskArray release];
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [DownloadTask sharedDownload].delegate_down = nil;
    //    [[DownloadTask sharedDownload] cancelAllDownloadRequest];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IsIOS7) {
        self.navigationController.navigationBar.translucent =NO;
        self.navigationController.edgesForExtendedLayout = NO;
    }
    downloadingArray = [[NSMutableArray alloc]init];
    statusDict = [[NSMutableDictionary alloc]init];
    taskArray = [[NSMutableArray alloc]init];
    self.title = @"列表";
    radioTable = [[ExtensibleTableView alloc]initWithFrame:self.view.bounds];
    radioTable.delegate = self;
    radioTable.dataSource = self;
    radioTable.delegate_extend = self;
    [self.view addSubview:radioTable];
    radioListArray = [[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D", nil];
    
    UIButton *chartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    chartBtn.frame = CGRectMake(0, 5, 40, 30);
    [chartBtn setBackgroundImage:[UIImage imageNamed:@"chart.png"] forState:UIControlStateNormal];
    [chartBtn addTarget:self action:@selector(downloadview) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[[UIBarButtonItem alloc]initWithCustomView:chartBtn]autorelease];
    self.navigationItem.rightBarButtonItem = rightItem;

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadview
{
    DownloadViewController *downloadView = [[DownloadViewController alloc]init];
    [self.navigationController pushViewController:downloadView animated:YES];
    [downloadView release];
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [radioListArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hei=0.0f;
    if([radioTable isEqualToSelectedIndexPath:indexPath])
    {
        NSLog(@"%d",indexPath.row);
        return [self tableView:radioTable extendedHeightForRowAtIndexPath:indexPath];//展开后的行高
    }else
    {
        hei= 60.0;  // 未展开下的行高
    }
    return hei;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //若当前行被选中，则返回展开的cell
    if([radioTable isEqualToSelectedIndexPath:indexPath])
    {
        return [self tableView:radioTable extendedCellForRowAtIndexPath:indexPath];
    }
    static NSString *CellIdentifier =@"CCCell";
    RadioCell_iPhone *cell = (RadioCell_iPhone *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [RadioCell_iPhone cell];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    //在此设置Cell的相关数据
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(260,3,45, 45)];
    [btn setBackgroundColor:[UIColor blueColor]];
    //    [btn setImage:[UIImage imageNamed:@"tragile_down@2x.png"]forState:UIControlStateNormal];
    btn.tag=indexPath.row;
    [btn addTarget:self action:@selector(operateCell:)forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn];
    [btn release];
    
    cell.radioNameL.text= [radioListArray objectAtIndex:[indexPath row]];
    
    return cell;
}

//返回展开之后的cell
- (UITableViewCell *)tableView:(UITableView *)tableView extendedCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //每个cell的标识
    NSString *CellTableIdentifier=@"CCopenCell";
    ExpandRadioCell_iPhone *cell = (ExpandRadioCell_iPhone *)[tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    if (cell == nil)
    {
        cell = [ExpandRadioCell_iPhone cell];
        //        if (nil == [statusDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]]) {
        //            cell.status = CSTaskStatus_standby;
        //            [cell.downBtn setTitle:@"下载" forState:UIControlStateNormal];
        //        }else{
        //            cell.status = [[statusDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]]intValue];
        //            DownloadTask *task = (DownloadTask *)[taskArray objectAtIndex:indexPath.row];
        //            task.downCell = cell;
        //        }
        //        [cell setDownloadTask:[DownloadTask sharedDownload]];
        //        cell.frame=CGRectMake(0,0,260,0);
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    //在此设置cell的相关数据
    
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(260,3,45,45)];
    [btn setBackgroundColor:[UIColor blueColor]];
    //    [btn setImage:[UIImageselfimageNamed:@"tragile_down@2x.png"]forState:UIControlStateNormal];
    btn.tag=indexPath.row;
    [btn addTarget:self action:@selector(shrinkCellWithAnimated:)forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn];
    [btn release];
    
    cell.downBtn.tag = indexPath.row;
    [cell.downBtn addTarget:self action:@selector(addDownloadTask:) forControlEvents:UIControlEventTouchUpInside];
    cell.radioNameL.text= [radioListArray objectAtIndex:[indexPath row]];
    return cell;
}

//返回展开之后的cell的高度
- (CGFloat)tableView:(UITableView *)tableView extendedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0;
}

- (void)operateCell:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int index = btn.tag;
    [radioTable extendCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES goToTop:YES];
}

- (void)shrinkCellWithAnimated:(id)sender
{
    [radioTable shrinkCellWithAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"1111");

}

#pragma mark -DownloadMethod
/**
 *  点击下载，添加到下载队列
 *
 *  @param _url 下载地址
 */
- (void)addDownloadTask:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int index = btn.tag;
    DownloadTask *task = [DownloadTask sharedDownload];
    task.delegate_down = self;
    NSURL *url = [NSURL URLWithString:@"http://zhangmenshiting.baidu.com/data2/music/35420495/7333126252000128.mp3?xcode=c0bbc4aca85548dd93b8c1ea86a060c45c1e649d511ced50"];
    NSString *string = @"测试1";
    //测试
    switch (index) {
        case 0:
            url = [NSURL URLWithString:@"http://zhangmenshiting.baidu.com/data2/music/114919473/114909440115200128.mp3?xcode=f217172a5089a0ddc8807ce1a6822092f48ae2a732e86bfd"];
            break;
        case 1:
            url = [NSURL URLWithString:@"http://zhangmenshiting.baidu.com/data2/music/114946264/114944077133200128.mp3?xcode=5c967ee3728e5cd92bb54d662ab462b3a201dc3ec9586f57"];
            string = @"测试2";
            break;
        case 2:
            url = [NSURL URLWithString:@"http://zhangmenshiting.baidu.com/data2/music/114941606/1149220991392804061128.mp3?xcode=fbf11a1824a829984b76c2be7c28a331ceb4d87a3e1875ef"];
            string = @"测试3";
            break;
        case 3:
            url = [NSURL URLWithString:@"http://zhangmenshiting.baidu.com/data2/music/64022204/73383361392822061128.mp3?xcode=fbf11a1824a82998a100c9a4558e1a1cec0497093d29d6f3"];
            string = @"测试4";
            break;
        default:
            break;
    }
    
    ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url]autorelease];
    [downloadingArray addObject:request];
    task.name = string;
    task.cellIndex = index;
    Sql_Utils *sql = [Sql_Utils sharedInstance];
    [sql createDB];
    [sql createDownloadTable];
    if ([sql canAddDownload:string]) {
        //首次下载
//        [APPUtils showMessage:@"加入下载列表" addView:self.view];
        [task setDownloadDirectory:fileDestination];
        [task addDownloadRequest:request];
    }else{
        //继续断点下载
        //提示已在下载列表中
        NSLog(@"已在下载列表中");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已在下载列表中" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
    }
    [sql closeDB];
    
    DownloadManager *manager = [DownloadManager sharedDownloadManager];
    [manager.downloadManagerArray addObject:task.taskRequest];
}

- (void)removeRequest:(ASIHTTPRequest *)request index:(int)_index task:(id)_task
{
    DownloadManager *manager = [DownloadManager sharedDownloadManager];
    [manager.downloadManagerArray removeObject:request];
}



@end
