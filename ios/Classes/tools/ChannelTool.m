//
//  ChannelTool.m
//  Runner
//
//  Created by 张智慧 on 2019/11/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "ChannelTool.h"
#import "AliLiveViewController.h"
#import "AliLivePlayerViewController.h"

#import <Flutter/Flutter.h>
#import "FluAliliveMethods.h"
#import "UIViewController+BaseAction.h"


#define ChannelName @"com.czh.tvmerchantapp/plugin"

typedef void(^MethodChannelBlock)(FlutterMethodCall *methodCall, FlutterResult methodResult);

@interface ChannelTool ()
<FlutterStreamHandler>

@end

@implementation ChannelTool

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static ChannelTool *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)flutterBridgeOC {
    [self initMethodChannelWithName:ChannelName blockWith:^(FlutterMethodCall *methodCall, FlutterResult methodResult) {
        if([methodCall.method isEqualToString:jumpToBoast]) { /// 直播
            AliLiveViewController *vc = [[AliLiveViewController alloc]init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.pushURL = methodCall.arguments;
            [[UIViewController currentViewController]presentViewController:vc animated:YES completion:nil];
        }
        if([methodCall.method isEqualToString:jumpToLivePlay]) { /// 观看直播
            AliLivePlayerViewController *vc = [[AliLivePlayerViewController alloc]init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.playerURL = methodCall.arguments;
            [[UIViewController currentViewController]presentViewController:vc animated:YES completion:nil];
        }
    }];
}


#pragma mark -- flutter 调用原生
- (void)initMethodChannelWithName:(NSString *)channelName blockWith:(MethodChannelBlock)channelBlock {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:(FlutterViewController *)[UIViewController currentViewController]];
    [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if(channelBlock) {
            channelBlock(call,result);
        }
    }];

}

#pragma mark -- 需要再扩展。原生主动向flutter发送消息
- (void)initEventChannelWithName:(NSString *)channelName {
    FlutterEventChannel *evenChannal = [FlutterEventChannel eventChannelWithName:channelName binaryMessenger:(FlutterViewController *)[UIViewController currentViewController]];
    [evenChannal setStreamHandler:self];
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  
    return nil;
}

@end
