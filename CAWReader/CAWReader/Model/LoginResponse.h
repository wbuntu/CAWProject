//
//  LoginResponse.h
//  CAWReader
//
//  Created by wbuntu on 16/5/4.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import "BaseResponse.h"
#import "bookModel.h"
@interface LoginData : JSONModel
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *userEmail;
@property (nonatomic,strong) NSString *userPasswd;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSArray<bookModel> *userShelf;
@property (nonatomic,assign) BOOL loginSuccess;
@end

@interface LoginResponse : BaseResponse
@property (nonatomic,strong) LoginData *data;
@end
