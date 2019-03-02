#import "FlutterZsdkPlugin.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "MfiBtPrinterConnection.h"

@implementation FlutterZsdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_zsdk"
            binaryMessenger:[registrar messenger]];
  FlutterZsdkPlugin* instance = [[FlutterZsdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}


- (void)discoverBluetoothDevices:(FlutterResult)result {
    NSString *serialNumber = @"";
    NSString *name = @"";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
    NSArray * connectedAccessories = [sam connectedAccessories];
    for (EAAccessory *accessory in connectedAccessories) {
        if([accessory.protocolStrings indexOfObject:@"com.zebra.rawport"] != NSNotFound){
            serialNumber = accessory.serialNumber;
            name = accessory.name;
            
            [dict setObject:name forKey:serialNumber];
        }
    }
    result(dict);
}



- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"Handle method call");
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
   }
   else if ([@"discoverBluetoothDevices" isEqualToString:call.method]) {
       //discoverBluetoothDevices(result);
       [self discoverBluetoothDevices:result];
   } else {
     result(FlutterMethodNotImplemented);
   }
}
       

@end
