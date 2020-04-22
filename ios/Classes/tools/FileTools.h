#import <Foundation/Foundation.h>

@interface FileTools : NSObject
// 删除沙盒指定文件夹和文件（删除文件夹）
+ (void)deleteFile:(NSString *)props;

// 删除沙盒指定文件夹内容（不删除文件夹）
+ (void)deleteDirectory:(NSString *)props;

// 沙盒是否有指定文件夹
+ (BOOL)isDirectoryExist:(NSString *)props;

// 获取文件或文件夹大小
+ (NSString *)getFilePathSize:(NSString *)props;

// 路径是否是文件夹
+ (BOOL)isDirectory:(NSString *)props;

//获取目录下所有文件夹和文件名字
+(NSMutableArray *)getDirectoryAllName:(NSDictionary *)props;

// 解压文件
+ (NSString *)unZipFile:(NSString *)props;

@end


