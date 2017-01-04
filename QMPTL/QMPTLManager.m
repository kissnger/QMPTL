//
//  QMPTLManager.m
//  QMEnjoyApp
//
//  Created by Massimo on 2016/11/5.
//  Copyright © 2016年 Massimo. All rights reserved.
//

#import "QMPTLManager.h"
#import "CAsyncSocket.h"

NSString * const QPTLConnectIp = @"192.168.18.1";
int const QPTLConnetPort = 8868;
int const QPTLTimeOut = 10;
@interface  QMPTLManager()
{
  BOOL _isOpen;
  dispatch_queue_t  _sleepQueue ;
}
@property (nonatomic,strong)NSMutableData *resultData;
@property (nonatomic,strong)AsyncSocket *sendSocket;


@end
@implementation QMPTLManager



- (void)handleResult:(NSData *)result{
  NSAssert(0, @"  子类必须实现 --（handleResult:(NSData *)result）-- 这个方法 ");
}

- (NSData *)sendMsgWithParam:(NSDictionary *)params{
  NSAssert(0, @"  子类必须实现 -- (sendMsgWithParam:(NSDictionary *)params ）-- 这个方法 ");
  return nil;
}
- (int)getTag{
  NSAssert(0, @"  子类必须实现 -- (getTag）-- 这个方法 ");
  return 0;
}

- (void)socketWithParam:(NSDictionary*)params complet:(CompletionSocket)complet fail:(FailSocket)fail{
  _sleepQueue = dispatch_queue_create("sleepQueue", DISPATCH_QUEUE_CONCURRENT);
  
    _completCallBack = complet;
    _failCallBack = fail;
    _resultData = [NSMutableData data];
    static BOOL connectOK = NO;
    
    if (_sendSocket) { 
      _sendSocket = nil;
    }
    
    if (!_sendSocket)
    {
      self.sendSocket = [[AsyncSocket alloc] initWithDelegate: self];
      
      NSError *error;
      connectOK = [_sendSocket connectToHost: QPTLConnectIp onPort: QPTLConnetPort error: &error];
      
      if (!connectOK)
      {
 
        _failCallBack(@"设备连接失败");
        NSLog(@"\n 连接失败");
      }else{
        NSLog(@"\n connect success!");
      }
      
      [_sendSocket setRunLoopModes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }
    
    if (connectOK)
    {
      NSLog(@"\n--PTL----connectOK------ tag = %@  ip： = %@",[self getTagStr],QPTLConnectIp);
      Byte verifyCode[] = {(Byte)'q',(Byte)'m',(Byte)'a',(Byte)'p',(Byte)'p',(Byte)'p',(Byte)'t',(Byte)'l'};
      NSMutableData *data = [NSMutableData data];
      //verifyCode
      NSLog(@"\n -PTL--- verifyCode = %s",verifyCode);
      [data appendData:[NSData dataWithBytes:verifyCode length:sizeof(verifyCode)]];
      //ptlId
      NSLog(@"\n -PTL--- ptlId = %@   %@",[self getTagStr],[NSThread currentThread]);
      [data appendData:[QMBasePTL writeInt:self.tag]];
      //params
      if (params.count >0) {
        NSLog(@"\n --PTL----  params  ------ ");
        
        [data appendData:[self sendMsgWithParam:params]];
        
        NSLog(@"\n ------  ");
      }
      [_sendSocket writeData:data withTimeout: QPTLTimeOut tag: self.tag];
    }
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
  
  [_sendSocket readDataWithTimeout: QPTLTimeOut tag: self.tag];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
  NSLog(@"\n开始写入, ------- tag = %@",  [self getTagStr]);
  
  [_sendSocket readDataWithTimeout: QPTLTimeOut tag: tag];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
  if (!err) {  return; }
  NSString *tag = ERROR_MSG_NET;
  
  if ([err.localizedDescription containsString:@"timed out"]) {
    tag = [NSString stringWithFormat:@"与Wifi设备通讯超时 --- %@ ",[self getTagStr]];
  }else if ([err.localizedDescription containsString:@"Connection refused"]) {
    tag = [NSString stringWithFormat:@"与Wifi设备连接失败 --- %@ ",[self getTagStr]];
    
  }
  if (_failCallBack) {
    _failCallBack(tag);
  }
  [self disConnect];
  if (err) { 
    NSLog(@"\n------\n tag = %@ \n----\n err = %@ -----",[self getTagStr], err);
  }

}
- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(CFIndex)partialLength tag:(long)tag{
  
  NSLog(@"\n --- \n partialLength =  %ld", partialLength);
  [_sendSocket readDataWithTimeout:QPTLTimeOut tag:tag];
}


// 这里必须要使用流式数据
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
  [self handleResult:data];
  
  NSLog(@"\n  -- tag: %@   读取到从服务端返回的内容 --  \n  %@   \n ------------- \n ",[self getTagStr],data);
  [_sendSocket readDataWithTimeout:QPTLTimeOut tag:tag];
}


- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
  NSLog(@" --%@--  DidDisconnect  ---- ", [self getTagStr]);
  if (_failCallBack) {
    _failCallBack(nil);
  }
  [sock disconnect];
  
}


- (void)complet:(id)result{
  if (_completCallBack) {
    _completCallBack(result);
  } 
  [self finishConnect];
}

- (void)fail:(id)result{
  if (_failCallBack) {
    _failCallBack(result);
  }
  
  [self finishConnect];
}

- (void)finishConnect{

 
  Byte b[] = {0};
  NSData *data = [NSData dataWithBytes:b length:1];
  [self.sendSocket writeData:data withTimeout:QPTLTimeOut tag:self.tag];
  typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
     NSLog(@"\n ---- finishConnect -- \n tag = %@   %@",[weakSelf getTagStr],[NSThread currentThread]);
    sleep(1);
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf disConnect];
    });
    
    
    
  });
  
}

-(void)disConnect{
  
 
  [_sendSocket disconnectAfterReadingAndWriting];
  [_sendSocket disconnect];
}




- (NSString*)getTagStr{
  return [NSString stringWithFormat:@"%d",self.tag];
}



- (NSMutableData *)resultData{
  if (_resultData) {
    _resultData = [NSMutableData data];
  }
  return _resultData;
}
@end

@interface QMBasePTL()

@end

@implementation QMBasePTL

//接受数据
- (void)handleResult:(NSData *)result{
  ////  协议返回成功/失败
  
  [self.emptyData appendData:result];
  int loc = 0;
  int code = [[QMBasePTL getInt:self.emptyData loc:&loc] intValue];
  
  switch (code) {
    case RESULT_OK:
    case RESULT_ERROR: {
      
      if (self.emptyData.length >= 4 ) {
        NSData *subData = [self.emptyData subdataWithRange:NSMakeRange(loc, self.emptyData.length - loc)];
        if (code == RESULT_OK) {
          [self handleSuccessWithData:subData];
          break;
        }
        
        [self handleFailWithData:subData];
      }
      
    }
      break;
    case ERROR_USER_NOT_FIND:
      if (self.failCallBack) {
        self.failCallBack([NSString stringWithFormat:@"%@: %@",[self getTagStr],ERROR_MSG_USER_NOT_FIND]);
      }
      [self finishConnect];
      break;
    default:
      if (self.failCallBack) {
        self.failCallBack([NSString stringWithFormat:@"wifi设备连接错误：代码 -- %d",code]);
      }
      
      [self finishConnect];
      break;
  }
}




- (void)handleFailWithData:(NSData*)data{
  int loc = 0;
  NSString *msg = [QMBasePTL getString:data loc:&loc];
  if (self.failCallBack && msg.length>0) {
    self.failCallBack(msg);
  }
  [self finishConnect];
}
- (void)handleSuccessWithData:(NSData*)data{
  
  NSAssert(0, @"子类必须实现此方法 \n---- \n- (void)handleSuccess:(BOOL)success data:(NSData*)data  \n ------- \n");
}
- (NSMutableData *)emptyData{
  if (!_emptyData) {
    _emptyData = [NSMutableData data];
    
  }
  return _emptyData;
}



#pragma mark - SocketTools


+ (NSData*)writeByte:(Byte*)value{
  NSLog(@"Byte----%d",value[0]);
  NSData *data = [NSMutableData dataWithBytes:value length:1];
  return data;
}

+ (NSData*)writeUTF:(NSString*)string{
  
  Byte *count = malloc(2);
  
  NSInteger strlen = string.length;
  NSInteger a = (strlen >> 8 & 0xff);
  NSData *adata = [NSData dataWithBytes:&a length:1];
  NSInteger b = (strlen >> 0 & 0xff);
  NSData *bdata = [NSData dataWithBytes:&b length:1];
  
  count[0] = ((Byte*)adata.bytes)[0];
  count[1] = ((Byte*)bdata.bytes)[0];
  NSMutableData *mutilData = [NSMutableData dataWithBytes:count length:2];
  NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
  [mutilData appendData:data];
  
  NSLog(@"count: %u-- %u---- string----%@",count[0],count[1],string);
  return  mutilData.copy;
}

+ (NSData*)writeInt:(int)value{
  NSMutableData *result = [NSMutableData data];
  for (int i = 3 ; i>=0; i--) {
    NSInteger integer = (value >>(i*8)& 0xff);
    [result appendData:[NSData dataWithBytes:&integer length:1]];
  }
  
  NSLog(@"count: Int----%d",value);
  return  result.copy;
}
+ (NSData*)writeLong:(long long)value{
  NSMutableData *result = [NSMutableData data];
  for (int i = 7 ; i>=0; i--) {
    NSInteger integer = (value >>(i*8)& 0xff);
    [result appendData:[NSData dataWithBytes:&integer length:1]];
  }
  
  NSLog(@"count: long----%lld",value);
  
  return  result.copy;
}






+(NSString*)getString:(NSData*)data loc:(int*)loc{
  Byte bytes[2];
  int len = 0;
  if (*loc+2>data.length) {
    return nil;
  }
  [data getBytes:bytes range:NSMakeRange(*loc, 2)];
  uint32_t n = (int)bytes[0] << 8;
  n |= (int)bytes[1] ;
  len = n;
  if (*loc+2+len > data.length) {
    NSLog(@"err:字符串长度：%d 位置：%d ",len,*loc);
    return nil;
  }
  NSData *subData = [data subdataWithRange:NSMakeRange(*loc+2, len)];
  NSString *str = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
  
  
  *loc = *loc + len+2;
  
  return str;
}

+(NSNumber*)getInt:(NSData*)data loc:(int*)loc{
  
  if (*loc + 4 > data.length) {
    NSLog(@"err:字符串长度：%d 位置：%d ",4,*loc);
    return nil;
  }
  NSData *subData = [data subdataWithRange:NSMakeRange(*loc, 4)];
  unsigned char bytes[4];
  [subData getBytes:bytes length:4];
  int n = (int)bytes[0] << 24;
  n |= (int)bytes[1] << 16;
  n |= (int)bytes[2] << 8;
  n |= (int)bytes[3];
  *loc = *loc + 4;
  return @(n);
}
+(NSNumber*)getLong:(NSData*)data loc:(int*)loc{
  if (*loc + 8 > data.length) {
    NSLog(@"err:字符串长度：%d 位置：%d ",8,*loc);
    return nil;
  }
  NSData *subData = [data subdataWithRange:NSMakeRange(*loc, 8)];
  unsigned char bytes[8];
  [subData getBytes:bytes length:8];
  long long n = (long long)bytes[0] << 56;
  n |= (long long)bytes[1] << 48;
  n |= (long long)bytes[2] << 40;
  n |= (long long)bytes[3] << 32;
  n |= (long long)bytes[4] << 24;
  n |= (long long)bytes[5] << 16;
  n |= (long long)bytes[6] << 8;
  n |= (long long)bytes[7] ;
  *loc = *loc + 8;
  return @(n);
}
+(NSNumber*)getByte:(NSData*)data loc:(int*)loc{
  if (*loc + 1 > data.length) {
    NSLog(@"err:字符串长度：%d 位置：%d ",1,*loc);
    return nil;
  }
  int len = 0;
  Byte bytes[1];
  [data getBytes:bytes range:NSMakeRange(*loc, 1)];
  uint32_t n = (int)bytes[0] << 8;
  n |= (int)bytes[1] ;
  len = n;
  *loc = *loc + 1;
  return @(n);
}





@end
