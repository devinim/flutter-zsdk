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

- (void)getDeviceProperties:(NSString*) serial result:(FlutterResult)result {
     NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
     [dict setObject:@"not" forKey:@"avaiable"];
     result(dict);
}

- (void)sendZplOverBluetooth:(NSString *)serial data:(NSString*)data result:(FlutterResult)result {
    
    // Instantiate connection to Zebra Bluetooth accessory
    //EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
    
    id<ZebraPrinterConnection, NSObject> thePrinterConn = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serial];
   
    
    BOOL success = [thePrinterConn open];
   
    NSError *error = nil;

    success = success && [thePrinterConn write:[data dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    if (success != YES || error != nil) {
        result([FlutterError errorWithCode:@"Error"
                             message: error.description
                             details:nil]);
    }
    
    [thePrinterConn close];
    result(@"Wrote. Are you happy?");
   // [thePrinterConn release];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"Handle method call");
   if ([@"discoverBluetoothDevices" isEqualToString:call.method]) {
       [self discoverBluetoothDevices:result];
   }
   else if ([@"getDeviceProperties" isEqualToString:call.method]) {
       NSDictionary *arguments = [call arguments];
       
       NSString* serial = arguments[@"mac"];
       
       [self getDeviceProperties:serial result:result];
   }
   else if ([@"sendZplOverBluetooth" isEqualToString:call.method]) {
       NSDictionary *arguments = [call arguments];
       
       NSString *serial = arguments[@"mac"];
       NSString *data = arguments[@"data"];
       
       [self sendZplOverBluetooth:serial data:data result:result];
   }
   else {
     result(FlutterMethodNotImplemented);
   }
}
       

@end
