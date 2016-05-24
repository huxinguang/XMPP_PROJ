//
//  XMPPConfig.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/4.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#ifndef XMPPConfig_h
#define XMPPConfig_h

//这里没有将服务器和域名设置为192.168.1.37(真实的服务器ip)是为了避免真机无法调试（真机调试必须使用wifi,（且WiFi必须跟服务器是同一个，猜测，待验证），如要移动网络下访问服务器(局域网通外网)，服务器需要装双网卡，设置NAT）
#define kHostName           @"192.168.1.37" //openfire服务器IP地址
#define kHostPort           5222         //openfire服务器端口，默认5222
#define kDomain             @"192.168.1.37" //openfire域名
#define kResourse           @"iOS"  

#endif /* XMPPConfig_h */
