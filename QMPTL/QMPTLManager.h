//
//  QMPTLManager.h
//  QMEnjoyApp
//
//  Created by Massimo on 2016/11/5.
//  Copyright © 2016年 Massimo. All rights reserved.
//

#import <Foundation/Foundation.h>


static int const PTL_GET_DEVICE_ID         = 0x00000010;  //16
static int const PTL_AUTO_LOGIN            = 0x00000011;  //17
static int const PTL_GET_FLOW_AND_SCORE    = 0x00000012;  //18
static int const PTL_DATA_UPDATED          = 0x00000013;  //19
static int const PTL_SET_AUTO_SWITCH       = 0x00000014;  //20

static int const RESULT_OK                 = 0;
static int const RESULT_ERROR              = 1;
static int const ERROR_USER_NOT_FIND       = 2001;

static  NSString* const ERROR_MSG_NET = @"网络状态不稳，通讯错误，请稍后再试！";
static  NSString* const ERROR_MSG_USER_NOT_FIND = @"用户未在该设备认证！";

typedef void(^CompletionSocket)(id value);
typedef void(^FailSocket)(id value);

#pragma mark: - Protocol

@protocol QMPTLProtocol <NSObject>

@required
-(NSData*)sendMsgWithParam:(NSDictionary*)params;
- (void)handleResult:(NSData*)result;
@end



@interface QMPTLManager : NSObject<QMPTLProtocol>
@property (nonatomic, copy) CompletionSocket completCallBack;
@property (nonatomic, copy) FailSocket failCallBack;
@property (nonatomic,readonly,assign ,getter = getTag) int tag;

-(void)socketWithParam:(NSDictionary*)params complet:(CompletionSocket)complet fail:(FailSocket)fail;
- (void)complet:(id)result;
- (void)fail:(id)result;
- (void)finishConnect;
-(void)disConnect;
@end


@interface QMBasePTL : QMPTLManager

@property (nonatomic, strong)NSMutableData *emptyData;

+ (NSData*)writeByte:(Byte*)value;
+ (NSData*)writeUTF:(NSString*)string;
+ (NSData*)writeInt:(int)value;
+ (NSData*)writeLong:(long long)value;


+(NSString*)getString:(NSData*)data loc:(int*)loc;
+(NSNumber*)getInt:(NSData*)data loc:(int*)loc;
+(NSNumber*)getLong:(NSData*)data loc:(int*)loc;
+(NSNumber*)getByte:(NSData*)data loc:(int*)loc;


- (void)handleSuccessWithData:(NSData*)data;
@end 
