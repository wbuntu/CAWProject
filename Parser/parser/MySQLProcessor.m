//
//  MySQLProcessor.m
//  parser
//
//  Created by wbuntu on 16/3/15.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import "MySQLProcessor.h"
#import "mysql.h"
#import "bookModel.h"
@implementation MySQLProcessor
+ (void)insertInitialBookData
{
    NSMutableArray *tA = [NSMutableArray array];
    for (int i=0; i<4092; i++) {
        NSString *file = [NSString stringWithFormat:@"/Users/wbuntu/latest/%d.txt",i];
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:file];
        if (exist) {
            NSLog(@"%d",i);
            [tA addObject:file];
        }
    }
    NSLog(@"count %lu",(unsigned long)tA.count);
    MYSQL *connection, mysql;
    mysql_init(&mysql);
    connection = mysql_real_connect(&mysql,"127.0.0.1","test","sdfghjkl","test",3306,"/tmp/mysql.sock",0);
    for (NSString *file in tA) {
        NSString *str = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
        
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *queryStr = @"insert into latest(title,sfid,author,sort,rating,tags,cover) values('%@','%d','%@','%@','%f','%@','%@')";

        for (NSDictionary *dic in arr) {
            bookModel *model = [[bookModel alloc] initWithDictionary:dic error:nil];
            NSString *tempStr = [NSString stringWithFormat:queryStr,model.NovelName,model.NovelID,model.AuthorName,model.TypeName,model.Point,[model.Tags componentsJoinedByString:@","],model.NovelCover];
            NSInteger re =  mysql_query(connection,[tempStr cStringUsingEncoding:NSUTF8StringEncoding]);
            if (re) {
                NSLog(@"%@",model);
                NSLog(@"%@",@(re));
            }
        }
    }
}
+(void)updateBookInfoData
{
    NSString *preQueryStr = @"select cover from book where bookid = %@";
    NSString *preUpdateStr = @"update book set cover='%@' where bookid=%@";
    MYSQL *connection, mysql;
    MYSQL_RES *res;
    mysql_init(&mysql);
    connection = mysql_real_connect(&mysql,"127.0.0.1","test","sdfghjkl","test",3306,"/tmp/mysql.sock",0);
    for (int i=1; i<26392; i++) {
        NSString *queryStr = [NSString stringWithFormat:preQueryStr,@(i)];
        NSInteger t =  mysql_query(connection, [queryStr cStringUsingEncoding:NSUTF8StringEncoding]);
        if (t) {
            NSLog(@"mysql_query filed %@",@(i));
            continue;
        }
        res = mysql_store_result(connection);
        MYSQL_ROW row = mysql_fetch_row(res);
        if (!row) {
            NSLog(@"mysql_fetch_row filed %@",@(i));
            continue;
        }
        NSString *str = [NSString stringWithCString:row[0] encoding:NSUTF8StringEncoding];
        str = [[str componentsSeparatedByString:@"/"] lastObject];
        NSString *updateStr = [NSString stringWithFormat:preUpdateStr,str,@(i)];
        t =  mysql_query(connection, [updateStr cStringUsingEncoding:NSUTF8StringEncoding]);
        if (t) {
            NSLog(@"mysql_update filed %@",@(i));
            continue;
        }
    }
    mysql_close(connection);
    NSLog(@"***********************************");
}

+ (void)insertBookInfo
{
    static NSString *bPostfix = @"/Users/wbuntu/CAWReader/bookJSON/%d.json";
    static NSString *iPostfix = @"/Users/wbuntu/CAWReader/indexJSON/%d.json";
    NSFileManager *manager = [NSFileManager defaultManager];
    MYSQL *connection, mysql;
    mysql_init(&mysql);
    connection = mysql_real_connect(&mysql,"127.0.0.1","test","sdfghjkl","test",3306,"/tmp/mysql.sock",0);
    NSString *queryStr = @"insert into book(bookid,sfid,title,rating,sort,status,author,wordcount,clickcount,updatetime,intro,tags,cover) values('%d','%d','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')";
    NSMutableArray *arr = [NSMutableArray new];
    for (int i=1; i<47731; i++) {
        NSString *bPostTemp = [NSString stringWithFormat:bPostfix,i];
        NSString *iPostTemp = [NSString stringWithFormat:iPostfix,i];
        if ([manager fileExistsAtPath:bPostTemp]&&[manager fileExistsAtPath:iPostTemp]) {
            bookModel *book = [[bookModel alloc] initWithData:[NSData dataWithContentsOfFile:bPostTemp] error:nil];
            if([book.author containsString:@"'"])
            {
                book.author = [book.author stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            }
            book.title = [book.title stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            book.intro = [book.intro stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            NSString *insert = [NSString stringWithFormat:queryStr,book.bookid,book.sfid,book.title,book.rating,book.sort,book.status,book.author,book.wordcount,book.clickcount,book.updatetime,book.intro,book.tags,book.cover];
            NSInteger result =  mysql_query(connection,[insert cStringUsingEncoding:NSUTF8StringEncoding]);
            if (result) {
                NSLog(@"********** %@",@(i));
                [arr addObject:insert];
            }else
            {
                NSLog(@"sucess %@",@(i));
            }
        }
    }
    mysql_close(connection);
    [arr writeToFile:@"/Users/wbuntu/CAWReader/insert.plist" atomically:YES];
}
@end
