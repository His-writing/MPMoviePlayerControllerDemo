//
//  LiveVideoController.m
//  knowZhengzhou
//
//  Created by hongkunpeng on 15/7/30.
//  Copyright (c) 2015年 hongkunpeng. All rights reserved.
//历年获奖节目回顾
/*
1.获取网络url 后不传到avplay,让其他的字符串来接，等到点击播放的时候，进行视频加载
2.在avplay内部进行 进行处理播放
3.播放开始加载数据，暂停将加载停止
4.第一次播放 单独处理出来
 */
#import "LiveVideoController.h"
//#import "JZVideoPlayerView.h"
#import "AppDelegate.h"
#import "LiveVideoTableViewCell.h"
#import "KrVideoPlayerController.h"
#define grayRGBO   [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0]

// 4.屏幕大小尺寸
#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

#define liveVideoY  64
#define liveVideoHeifht 250


@interface LiveVideoController ()<UITableViewDelegate,UITableViewDataSource>
{
//    JZVideoPlayerView *_jzPlayer;
    
    NSIndexPath *selectedIndexPath;
}


@property (nonatomic, strong) KrVideoPlayerController  *videoController;


//@property (strong, nonatomic)  JZVideoPlayerView *jzPlayer;
@property(strong,nonatomic) UITableView *livevideoTableView;

@property(strong,nonatomic)NSMutableArray *liveNameArray;

@property(strong,nonatomic)NSMutableArray *liveUrlArray;

@property(strong,nonatomic)NSMutableArray *liveUrlArrayb;

@end

@implementation LiveVideoController


-(void)backPressed:(id)sender{

    
    [self.videoController dismiss];

    [self.navigationController popViewControllerAnimated:YES];
    

}

- (void)addVideoPlayerWithURL:(NSURL *)url{
    
    if (!self.videoController) {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;

        self.videoController = [[KrVideoPlayerController alloc] initWithFrame:CGRectMake(0, 64, width, 230)];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
            
        }];
        ///** 进入最小化状态 */
        [self.videoController setWillBackOrientationPortrait:^{
            [weakSelf toolbarHidden:NO];
            [weakSelf tableViewHidden:NO];

        }];
        
        
        ///** 进入全屏状态 */
        [self.videoController setWillChangeToFullscreenMode:^{
            
            [weakSelf toolbarHidden:YES];
            
            
        }];
        
        
//        [self.videoController setWillBackOrientationPortraitAn:^{
//            [weakSelf tableViewHidden:NO];
//        }];
        
        [self.videoController setWillChangeToFullscreenModeAn:^{
            [weakSelf tableViewHidden:YES];

        }];
//        /** 进入最小化状态 */
//        @property(nonatomic,copy)void(^willBackOrientationPortraitAn)(void);
//        
//        /** 进入全屏状态 */
//        @property (nonatomic, copy)void(^willChangeToFullscreenModeAn)(void);

        [self.view addSubview:self.videoController.view];
        
//              self.livevideoTableView.tableFooterView=self.videoController.view;


    }
    self.videoController.contentURL = url;
    
}

-(void)tableViewHidden:(BOOL)Bool{
    self.livevideoTableView.hidden=Bool;
    self.navigationController.navigationBar.hidden = Bool;
    self.tabBarController.tabBar.hidden = Bool;
    [[UIApplication sharedApplication] setStatusBarHidden:Bool withAnimation:UIStatusBarAnimationFade];


}
//隐藏navigation tabbar 电池栏
- (void)toolbarHidden:(BOOL)Bool{
    
    self.navigationController.navigationBar.hidden = Bool;
    self.tabBarController.tabBar.hidden = Bool;
    [[UIApplication sharedApplication] setStatusBarHidden:Bool withAnimation:UIStatusBarAnimationFade];
}



-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.titleView=[ Titlelable lableTitile:@""];
//    lastIndexPath=nil;
//    indexPathByAddingIndex

//  lastIndexPath=  [lastIndexPath indexPathByAddingIndex:0];
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    appDelegate.isFullScreen = YES;
    
    
    self.liveNameArray=[[NSMutableArray alloc]initWithObjects:@"点击进入",@"点击进入间",@"点击进入",@"点击进入",@"点击进入", nil];
//    @"点击进入深圳财经",
    self.liveUrlArrayb=[[NSMutableArray alloc]initWithObjects:@"正在播放：",@"正在播放：",@"正在播放：",@"正在播放：",@"正在播放：", nil];
//    @"正在播放：深圳财经",
    self.liveUrlArray=[[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"",nil];
    [self liveVideoUrlmethods];
    
//    http://219.232.160.141:5080/hls/77e19c3214ef876a1e71b4f92bd49040.m3u8

    NSLog(@"%f",self.videoController.frame.size.height);
    self.livevideoTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 230+64, screen_width, screen_height-230-64) style:UITableViewStylePlain];
    self.livevideoTableView.dataSource=self;
    self.livevideoTableView.delegate=self;
    self.livevideoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

//    self.livevideoTableView.backgroundColor = [UIColor purpleColor];

    [self.view addSubview:self.livevideoTableView];
    //    dispatch_async(dispatch_get_main_queue(), ^{
//        [self initJZPlayer];
//    });
    

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.liveNameArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strategyIdentifier = @"LiveVideoTableViewCell";
    LiveVideoTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:strategyIdentifier];
        if (cell == nil) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"LiveVideoTableViewCell" owner:self options:nil]lastObject];
        }
    if (selectedIndexPath.row == indexPath.row) {
        
        cell.backgroundColor=grayRGBO;

        cell.liveLable.text=[self.liveUrlArrayb objectAtIndex:indexPath.row];
    }else {
        cell.liveLable.text=[self.liveNameArray objectAtIndex:indexPath.row];
        cell.backgroundColor=[UIColor clearColor];

    }
    
    
//    
//    if (indexPath.row==0) {
//
//    }else{
//
//    
//    }
//    cell.liveLable.backgroundColor=[UIColor clearColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    [self stop];

    
//    if (self.videoController. ) {
//        <#statements#>
//    }
//    [self.videoController stop];
//    [self.videoControl animateShow];

//    [self.videoController.videoControl  animateShow];
    
    
    self.liveVideoUrl=[NSString stringWithFormat:@"%@",[self.liveUrlArray objectAtIndex:indexPath.row]];
    
    [self addVideoPlayerWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.liveVideoUrl]]];

    
    selectedIndexPath = indexPath;
    
    LiveVideoTableViewCell *newCell = (LiveVideoTableViewCell*)[tableView cellForRowAtIndexPath:
                                                                indexPath];
    newCell.liveLable.text = [self.liveUrlArrayb objectAtIndex:indexPath.row];
    
    [tableView reloadData];
    

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    appDelegate.isFullScreen = NO;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if ([[MacroCommon  getCurrntNet]isEqualToString:@"当前网络不可用，请检查您的网络连接。"]) {
//        [SVProgressHUD showErrorWithStatus:@"亲，网速不给力，稍好重试哦!"];
//    }else if( [[MacroCommon getCurrntNet]isEqualToString:@"您当前使用的是蜂窝数据"]){
//        [self showHUD:@"您当前使用的是蜂窝数据" withHiddenDelay:1.0];
//    }
    
    
    [self liveVideoUrlmethods];
    

}

-(void)liveVideoUrlmethods{
    
    
    self.liveVideoUrl=[NSString stringWithFormat:@"%@",@"  "];
    
    [self addVideoPlayerWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.liveVideoUrl]]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
