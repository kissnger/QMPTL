//
//  QMPTLSocketList.h
//  QMEnjoyApp
//
//  Created by Massimo on 2016/11/5.
//  Copyright © 2016年 Massimo. All rights reserved.
//

#import "QMPTLManager.h" 

@interface QMPTL_GET_DEVICE_ID : QMBasePTL

@end
@interface QMPTL_AUTO_LOGIN : QMBasePTL

@end
@interface QMPTL_GET_FLOW_AND_SCORE : QMBasePTL

@end
@interface QMPTL_DATA_UPDATED : QMBasePTL

@end
@interface QMPTL_SET_AUTO_SWITCH : QMBasePTL<QMPTLProtocol>

@end

#pragma mark - Model

@interface PTLFlowModel : NSObject
@property (nonatomic, copy)NSString *cid,*uid,*flow_size,*score,*autoSwitch;
@end
