//
//  AliLiveViewController.m
//  Runner
//
//  Created by 张智慧 on 2020/2/18.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "AliLiveViewController.h"
#import <AlivcLivePusher/AlivcLivePusher.h>
#import <AlivcLibFace/AlivcLibFaceManager.h>
#import <AlivcLibBeauty/AlivcLibBeautyManager.h>

#import "UIView+Extension.h"
#import "BoardMacro.h"

#import "AliLiveConfigView.h"
#import "BeautySettingView.h"

@interface AliLiveViewController ()
<AlivcLivePusherInfoDelegate,
AlivcLivePusherErrorDelegate,
AlivcLivePusherNetworkDelegate,
AlivcLivePusherBGMDelegate,
AlivcLivePusherCustomFilterDelegate,
AlivcLivePusherCustomDetectorDelegate,
AlivcLivePusherSnapshotDelegate,
AliLiveConfigViewDelegate,
BeautySettingViewDelegate>
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) NSTimer *noticeTimer;
@property (nonatomic, strong) AlivcLivePusher *livePusher;
@property (nonatomic, assign) BOOL isUseAsyncInterface;

@property (nonatomic, strong) AliLiveConfigView *configView;
@property (nonatomic, strong) BeautySettingView *beautySettingView;

@end

@implementation AliLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self initLive];
    [self setBaseConfig];
    // Do any additional setup after loading the view.
}

- (void)initialize {
    self.view.backgroundColor = [UIColor whiteColor];
    self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, NSTATUS_H, 45, 40)];
    [self.backBtn setImage:[UIImage imageNamed:@"whitenav_back"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
}

- (void)back:(id)sender {
    [self cancelTimer];
    [self destoryPusher];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)initLive {
    self.pushConfig = [[AlivcLivePushConfig alloc]init];
    self.pushConfig.resolution = AlivcLivePushResolution540P;
    self.pushConfig.cameraType = AlivcLivePushCameraTypeBack;
}

- (void)setBaseConfig {
    // 如果不需要退后台继续推流，可以参考这套退后台通知的实现。
    [self addBackgroundNotifications];
    
    [self initLive];

    [self setupSubviews];
    
    [self setupDebugTimer];


    int ret = [self setupPusher];
    
    if (ret != 0) {
        return;
    }
    
    ret = [self startPreview];
    
    if (ret != 0) {
        return;
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    ret = [self startPush];
    if(ret != 0) {
        return;
    }
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeLeft) {
        return UIInterfaceOrientationMaskLandscapeLeft;
    } else if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (int)setupPusher {
    self.pushConfig.externMainStream = false; /// 自定义流
    self.livePusher = [[AlivcLivePusher alloc] initWithConfig:self.pushConfig];
    [self.livePusher setLogLevel:(AlivcLivePushLogLevelDebug)];
    if (!self.livePusher) {
        return -1;
    }
    [self.livePusher setInfoDelegate:self];
    [self.livePusher setErrorDelegate:self];
    [self.livePusher setNetworkDelegate:self];
    [self.livePusher setBGMDelegate:self];
    [self.livePusher setSnapshotDelegate:self];
    [self.livePusher setCustomFilterDelegate:self];
    [self.livePusher setCustomDetectorDelegate:self];
    
    return 0;
}


/**
 销毁推流
 */
- (void)destoryPusher {
    if (self.livePusher) {
        [self.livePusher destory];
    }
    
    self.livePusher = nil;
}


/**
 开始预览
 */
- (int)startPreview {
    
    if (!self.livePusher) {
        return -1;
    }
    int ret = 0;
     if (self.isUseAsyncInterface) {
           // 使用异步接口
           ret = [self.livePusher startPreviewAsync:self.previewView];
           
       } else {
           // 使用同步接口
           ret = [self.livePusher startPreview:self.previewView];
       }
    return ret;
}


/**
 停止预览
 */
- (int)stopPreview {
    
    if (!self.livePusher) {
        return -1;
    }
    int ret = [self.livePusher stopPreview];
    return ret;
}


/**
 开始推流
 */
- (int)startPush {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher startPushWithURLAsync:self.pushURL];
    
    } else {
        // 使用同步接口
        ret = [self.livePusher startPushWithURL:self.pushURL];
    }
    return ret;
}


/**
 停止推流
 */
- (int)stopPush {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = [self.livePusher stopPush];
    return ret;
}


/**
 暂停推流
 */
- (int)pausePush {
    
    if (!self.livePusher) {
        return -1;
    }

    int ret = [self.livePusher pause];
    return ret;
}


/**
 恢复推流
 */
- (int)resumePush {
   
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;

   if (self.isUseAsyncInterface) {
        // 使用异步接口
       ret = [self.livePusher resumeAsync];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher resume];
    }
    return ret;
}



/**
 重新推流
 */
- (int)restartPush {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher restartPushAsync];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher restartPush];
    }
    return ret;
}


- (void)reconnectPush {
    
    if (!self.livePusher) {
        return;
    }
    
    [self.livePusher reconnectPushAsync];
}

#pragma mark -- AlivcLivePusherErrorDelegate

- (void)onSystemError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {

   
}


- (void)onSDKError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    
    
}



#pragma mark -- AlivcLivePusherNetworkDelegate

- (void)onConnectFail:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    
  

}


- (void)onSendDataTimeout:(AlivcLivePusher *)pusher {
    
   
}

- (void)onSendSeiMessage:(AlivcLivePusher *)pusher {
    
   
}


- (void)onConnectRecovery:(AlivcLivePusher *)pusher {
    

}


- (void)onNetworkPoor:(AlivcLivePusher *)pusher {
    

}


- (void)onReconnectStart:(AlivcLivePusher *)pusher {
    
    
}


- (void)onReconnectSuccess:(AlivcLivePusher *)pusher {
    
  
}

- (void)onConnectionLost:(AlivcLivePusher *)pusher {
    
}


- (void)onReconnectError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    

}

- (NSString *)onPushURLAuthenticationOverdue:(AlivcLivePusher *)pusher {
    
    if(!self.livePusher.isPushing) {
         NSLog(@"推流url鉴权即将过期。更新url");
    }
    return self.pushURL;
}

- (void)onPacketsLost:(AlivcLivePusher *)pusher {
    
}


#pragma mark -- AlivcLivePusherInfoDelegate

- (void)onPreviewStarted:(AlivcLivePusher *)pusher {

}


- (void)onPreviewStoped:(AlivcLivePusher *)pusher {
    
 
}

- (void)onPushStarted:(AlivcLivePusher *)pusher {
    
    
}


- (void)onPushPaused:(AlivcLivePusher *)pusher {
    
    
}


- (void)onPushResumed:(AlivcLivePusher *)pusher {
    
   
}


- (void)onPushStoped:(AlivcLivePusher *)pusher {
    
   
}


- (void)onFirstFramePreviewed:(AlivcLivePusher *)pusher {
    
 
}


- (void)onPushRestart:(AlivcLivePusher *)pusher {
    
   
}


#pragma mark -- AlivcLivePusherBGMDelegate

- (void)onStarted:(AlivcLivePusher *)pusher {
    
 
}


- (void)onStoped:(AlivcLivePusher *)pusher {
    
  
}


- (void)onPaused:(AlivcLivePusher *)pusher {
    
   
}


- (void)onResumed:(AlivcLivePusher *)pusher {
    
   
}


- (void)onProgress:(AlivcLivePusher *)pusher progress:(long)progress duration:(long)duration {
    
   
}


- (void)onCompleted:(AlivcLivePusher *)pusher {
    
   
}


- (void)onOpenFailed:(AlivcLivePusher *)pusher {
    
    

}


- (void)onDownloadTimeout:(AlivcLivePusher *)pusher {
    
    
}

#pragma mark -- AlivcLivePusherCustomFilterDelegate
/**
 通知外置滤镜创建回调
 */
- (void)onCreate:(AlivcLivePusher *)pusher context:(void*)context
{
    [[AlivcLibBeautyManager shareManager] create:context];
}

- (void)updateParam:(AlivcLivePusher *)pusher buffing:(float)buffing whiten:(float)whiten pink:(float)pink cheekpink:(float)cheekpink thinface:(float)thinface shortenface:(float)shortenface bigeye:(float)bigeye
{
    [[AlivcLibBeautyManager shareManager] setParam:buffing whiten:whiten pink:pink cheekpink:cheekpink thinface:thinface shortenface:shortenface bigeye:bigeye];
}

- (void)switchOn:(AlivcLivePusher *)pusher on:(bool)on
{
    [[AlivcLibBeautyManager shareManager] switchOn:on];
}
/**
 通知外置滤镜处理回调
 */
- (int)onProcess:(AlivcLivePusher *)pusher texture:(int)texture textureWidth:(int)width textureHeight:(int)height extra:(long)extra
{
    return [[AlivcLibBeautyManager shareManager] process:texture width:width height:height extra:extra];
}
/**
 通知外置滤镜销毁回调
 */
- (void)onDestory:(AlivcLivePusher *)pusher
{
    [[AlivcLibBeautyManager shareManager] destroy];
}

#pragma mark -- AlivcLivePusherCustomDetectorDelegate
/**
 通知外置视频检测创建回调
 */
- (void)onCreateDetector:(AlivcLivePusher *)pusher
{
    [[AlivcLibFaceManager shareManager] create];
}
/**
 通知外置视频检测处理回调
 */
- (long)onDetectorProcess:(AlivcLivePusher *)pusher data:(long)data w:(int)w h:(int)h rotation:(int)rotation format:(int)format extra:(long)extra
{
     return [[AlivcLibFaceManager shareManager] process:data width:w height:h rotation:rotation format:format extra:extra];
}
/**
 通知外置视频检测销毁回调
 */
- (void)onDestoryDetector:(AlivcLivePusher *)pusher
{
    [[AlivcLibFaceManager shareManager] destroy];
}

#pragma mark -- AlivcLivesNAPSHOTDelegate
- (void)onSnapshot:(AlivcLivePusher *)pusher image:(UIImage *)image
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-ss-SS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString* fileName = [NSString stringWithFormat:@"snapshot-%@.png", dateString];
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:
                          [NSString stringWithFormat:fileName]];
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:filePath   atomically:YES]; // 保存成功会返回YES
    if (result == YES) {
        NSLog(@"保存成功");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"截图已保存" message:filePath delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    });
}

#pragma mark -- 退后台停止推流的实现方案
- (void)addBackgroundNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}


- (void)applicationWillResignActive:(NSNotification *)notification {

    if (!self.livePusher) {
        return;
    }
    // 如果退后台不需要继续推流，则停止推流
    if ([self.livePusher isPushing]) {
        [self.livePusher stopPush];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (!self.livePusher) {
        return;
    }
   [self.livePusher startPushWithURLAsync:self.pushURL];
}

- (void)didPush {
    int ret = [self startPush];
    if (ret != 0) {
        return;
    }
}


#pragma mark -- UI
- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.previewView];
    [self.view bringSubviewToFront:self.backBtn];
    [self.view addSubview:self.configView];
}



#pragma mark --  Timer
- (void)setupDebugTimer {
    self.noticeTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(noticeTimerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.noticeTimer forMode:NSDefaultRunLoopMode];
}

- (void)cancelTimer{
    if (self.noticeTimer) {
        [self.noticeTimer invalidate];
        self.noticeTimer = nil;
    }
}


- (void)noticeTimerAction:(NSTimer *)sender {
    
    if (!self.livePusher) {
        return;
    }
    BOOL isPushing = [self.livePusher isPushing];
    NSString *text = @"";
    if (isPushing) {
        text = [NSString stringWithFormat:@"是否推流:%@|推流地址:%@", isPushing?@"YES":@"NO", [self.livePusher getPushURL]];
    } else {
        text = [NSString stringWithFormat:@"是否推流:%@", isPushing?@"YES":@"NO"];
    }
    NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&  %@",text);

}

#pragma mark -- AliLiveConfigViewDelegate
- (void)didClickView:(AliLiveConfigView *)configView typeWith:(ConfigType)currentType {
    if (!self.livePusher) {
        return;
    }
    if(currentType == ConfigType_camera) { /// 旋转摄像头
        [self.livePusher switchCamera];
    }else if(currentType == ConfigType_flash) {
        self.pushConfig.flash = !self.pushConfig.flash;
        [self.livePusher setFlash:self.pushConfig.flash];
    }else if(currentType == ConfigType_skin) {
        self.beautySettingView.hidden = NO;
        self.pushConfig.beautyOn = !self.pushConfig.beautyOn;
        [self.livePusher setBeautyOn:self.pushConfig.beautyOn];
    }
    self.configView.pushConfig = self.pushConfig;
}

#pragma mark -- BeautySettingViewDelegate
- (void)didClickBeautyView:(BeautySettingView *)settingView typeWith:(BeautyType)type valueWith:(int)value {
/*
 @"磨皮",@"美白",@"红润",@"腮红",@"瘦脸",@"收下巴",@"大眼"
 */
    if (!self.livePusher) {
        return;
    }
    if(type == BeautyType_beautyBuffing) {
         [self.livePusher setBeautyBuffing:value];
    }else if(type == BeautyType_beautyWhite) {
        [self.livePusher setBeautyWhite:value];
    }else if(type == BeautyType_beautyRuddy) {
        [self.livePusher setBeautyRuddy:value];
    }else if(type == BeautyType_beautyCheekPink){
        [self.livePusher setBeautyRuddy:value];
    }else if(type == BeautyType_beautyThinFace) {
        [self.livePusher setBeautyThinFace:value];
    }else if(type == BeautyType_beautyShortenFace) {
        [self.livePusher setBeautyShortenFace:value];
    }else { /// 大眼
        [self.livePusher setBeautyBigEye:value];
    }
}



#pragma mark - LazyMethod
- (UIView *)previewView {
    if (!_previewView) {
        _previewView = [[UIView alloc] init];
        _previewView.backgroundColor = [UIColor clearColor];
        _previewView.frame = CGRectMake(0, 0, WIDE, HIGHT - Indicator_H);
    }
    return _previewView;
}

- (AliLiveConfigView *)configView {
    if(!_configView) {
        _configView = [[AliLiveConfigView alloc]initWithFrame:CGRectMake(WIDE - 280, NSTATUS_H, 280, 44)];
        _configView.delegate = self;
        [_configView initConfigWith:self.pushConfig];
    }
    return _configView;
}

- (BeautySettingView *)beautySettingView {
    if(!_beautySettingView) {
        _beautySettingView = [[BeautySettingView alloc]initWithFrame:CGRectMake(15, HIGHT - 300 - Indicator_H, WIDE - 30, 300) configWith:self.pushConfig];
        _beautySettingView.delegate = self;
        [self.view addSubview:_beautySettingView];
    }
    return _beautySettingView;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
