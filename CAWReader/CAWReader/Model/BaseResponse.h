//
//  BaseResponse.h
//  CAWReader
//
//  Created by wbuntu on 4/3/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@interface BaseResponse : JSONModel
@property (nonatomic,assign) NSInteger code;
@property (nonatomic,strong) NSString *msg;
@end
