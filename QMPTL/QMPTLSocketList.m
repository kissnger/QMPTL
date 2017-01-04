//
//  QMPTLSocketList.m
//  QMEnjoyApp
//
//  Created by Massimo on 2016/11/5.
//  Copyright © 2016年 Massimo. All rights reserved.
//

#import "QMPTLSocketList.h"

@implementation QMPTL_GET_DEVICE_ID
- (int)getTag{
  return PTL_GET_DEVICE_ID;
}
- (NSData *)sendMsgWithParam:(NSDictionary *)params{
  self.emptyData = [NSMutableData data];
  return nil;
}
- (void)handleSuccessWithData:(NSData*)data{
  int loc = 0;
  NSString *dev_num = [QMBasePTL getString:data loc:&loc];
  if (self.completCallBack && dev_num.length) {
    self.completCallBack(dev_num);
     [self finishConnect];
  }
 
  
}
@end



@implementation QMPTL_AUTO_LOGIN
- (int)getTag{
  return PTL_AUTO_LOGIN;
}
-(NSData*)sendMsgWithParam:(NSDictionary*)params{
  
  self.emptyData = [NSMutableData data];
  NSMutableData *data = [NSMutableData data];
  NSString *mac = params[@"mac"];
  NSString *cidStr = params[@"cid"];
  long long cid = (long long)[cidStr longLongValue];
  [data appendData:[QMBasePTL writeLong:cid]];
  [data appendData:[QMBasePTL writeUTF:mac]];
  return data;
}

//                             [cid,用户私用编号,long]
//                             [uid,用户公开编号,long]
//                             [flow_size,剩余流量,long]
//                             [score,积分数量,int]
//                             [autoSwitch,自动开关状态,byte]    0:关闭，1:打开
- (void)handleSuccessWithData:(NSData *)data{
  int loc = 0;
  NSNumber *cid = [QMBasePTL getLong:data loc:&loc] ;
  NSNumber *uid = [QMBasePTL getLong:data loc:&loc];
  NSNumber *flow_size = [QMBasePTL getLong:data loc:&loc];
  NSNumber *score = [QMBasePTL getInt:data loc:&loc];
  NSNumber *autoSwitch = [QMBasePTL getByte:data loc:&loc];
  if (cid&&uid&&flow_size&&score&&autoSwitch) {
    NSDictionary *result = @{@"cid":[cid stringValue],
                             @"uid":[uid stringValue],
                             @"flow_size":[flow_size stringValue],
                             @"score":[score stringValue],
                             @"autoSwitch":[autoSwitch stringValue]};
    if (self.completCallBack) {
      self.completCallBack(result);
    }
    [self finishConnect];
  }
  
}
@end
@implementation QMPTL_GET_FLOW_AND_SCORE
- (int)getTag{
  return PTL_GET_FLOW_AND_SCORE;
}
-(NSData*)sendMsgWithParam:(NSDictionary*)params{
  
  self.emptyData = [NSMutableData data];
  
  
  NSMutableData *data = [NSMutableData data];
  NSString *cidStr = params[@"cid"];
  long long cid = (long long)[cidStr longLongValue];
  [data appendData:[QMBasePTL writeLong:cid]];
  return data;
}

//                             [cid,用户私用编号,long]
//                             [uid,用户公开编号,long]
//                             [flow_size,剩余流量,long]
//                             [score,积分数量,int]
//                             [autoSwitch,自动开关状态,byte]    0:关闭，1:打开
- (void)handleSuccessWithData:(NSData *)data{
  int loc = 0;
  NSNumber *cid = [QMBasePTL getLong:data loc:&loc] ;
  NSNumber *uid = [QMBasePTL getLong:data loc:&loc];
  NSNumber *flow_size = [QMBasePTL getLong:data loc:&loc];
  NSNumber *score = [QMBasePTL getInt:data loc:&loc];
  NSNumber *autoSwitch = [QMBasePTL getByte:data loc:&loc];
  if (cid&&uid&&flow_size&&score&&autoSwitch) {
    NSDictionary *result = @{@"cid":[cid stringValue],
                             @"uid":[uid stringValue],
                             @"flow_size":[flow_size stringValue],
                             @"score":[score stringValue],
                             @"autoSwitch":[autoSwitch stringValue]};
    if (self.completCallBack) {
      self.completCallBack(result);
    }
    [self finishConnect];
  }
  
}
@end
@implementation QMPTL_DATA_UPDATED
- (int)getTag{
  return PTL_DATA_UPDATED;
}
-(NSData*)sendMsgWithParam:(NSDictionary*)params{
  
  self.emptyData = [NSMutableData data];
  NSMutableData *data = [NSMutableData data];
  NSString *cidStr = params[@"cid"];
  long long cid = (long long)[cidStr longLongValue];
  [data appendData:[QMBasePTL writeLong:cid]];
  return data;
}

//                             [cid,用户私用编号,long]
//                             [uid,用户公开编号,long]
//                             [flow_size,剩余流量,long]
//                             [score,积分数量,int]
//                             [autoSwitch,自动开关状态,byte]    0:关闭，1:打开
- (void)handleSuccessWithData:(NSData *)data{
  int loc = 0;
  NSNumber *cid = [QMBasePTL getLong:data loc:&loc] ;
  NSNumber *uid = [QMBasePTL getLong:data loc:&loc];
  NSNumber *flow_size = [QMBasePTL getLong:data loc:&loc];
  NSNumber *score = [QMBasePTL getInt:data loc:&loc];
  NSNumber *autoSwitch = [QMBasePTL getByte:data loc:&loc];
  if (cid&&uid&&flow_size&&score&&autoSwitch) {
    NSDictionary *result = @{@"cid":[cid stringValue],
                             @"uid":[uid stringValue],
                             @"flow_size":[flow_size stringValue],
                             @"score":[score stringValue],
                             @"autoSwitch":[autoSwitch stringValue]};
    if (self.completCallBack) {
      self.completCallBack(result);
    }
    [self finishConnect];
  }
  
}
@end




@implementation QMPTL_SET_AUTO_SWITCH
- (int)getTag{
  return PTL_SET_AUTO_SWITCH;
}
-(NSData*)sendMsgWithParam:(NSDictionary*)params{
  
  self.emptyData = [NSMutableData data];
  NSMutableData *data = [NSMutableData data];
  NSString *cidStr = params[@"cid"];
  long long cid = (long long)[cidStr longLongValue];
  Byte autoSwitch[] = {[params[@"autoSwitch"] boolValue]};
  
  [data appendData:[QMBasePTL writeLong:cid]];
  [data appendData:[QMBasePTL writeByte:autoSwitch]];
  
  return data;
}


- (void)handleSuccessWithData:(NSData*)data{
  int loc = 0;
  BOOL autoSwitch = [[QMBasePTL getByte:data loc:&loc] boolValue];
  if (self.completCallBack) {
    self.completCallBack(@(autoSwitch));
  }
  [self finishConnect];
  
}



@end


@implementation PTLFlowModel 
@end
