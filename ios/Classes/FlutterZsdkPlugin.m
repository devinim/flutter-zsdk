#import "FlutterZsdkPlugin.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "MfiBtPrinterConnection.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterFactory.h"

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
    
    id<ZebraPrinterConnection, NSObject> connection = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serial];
    
    NSError *error = nil;
    
    BOOL success = [connection open];
    
    id<ZebraPrinter,NSObject> printer = [ZebraPrinterFactory getInstance:connection error:&error];
    
    NSData *dataBytes = [NSData dataWithBytes:[data UTF8String] length:[data length]];
    
    [connection write:dataBytes error:&error];

   /* success = success && [thePrinterConn write:[data dataUsingEncoding:NSUTF8StringEncoding] error:&error];*/
    if (success != YES || error != nil) {
        result([FlutterError errorWithCode:@"Error"
                             message: error.description
                             details:nil]);
    }
    
    [connection close];
    result(@"Wrote. Are you happy?");
    //[thePrinterConn release];
}

/*
-(void)test:(FlutterResult) result {
    NSString *serialNumber = @"";
    //Find the Zebra Bluetooth Accessory
    EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
    NSArray * connectedAccessories = [sam connectedAccessories];
    for (EAAccessory *accessory in connectedAccessories) {
        if([accessory.protocolStrings indexOfObject:@"com.zebra.rawport"] != NSNotFound){
            serialNumber = accessory.serialNumber;
            break;
            //Note: This will find the first printer connected! If you have multiple Zebra printers connected, you should display a list to the user and have him select the one they wish to use
        }
    }
    // Instantiate connection to Zebra Bluetooth accessory
    id<ZebraPrinterConnection, NSObject> thePrinterConn = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serialNumber];
    // Open the connection - physical connection is established here.
    BOOL success = [thePrinterConn open];
    // This example prints "This is a ZPL test." near the top of the label.
    NSString *zplData = @"^XA^FO20,20^A0N,25,25^FDThis is a ZPL test.^FS^XZ";
    NSError *error = nil;
    // Send the data to printer as a byte array.
    success = success && [thePrinterConn write:[zplData dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    if (success != YES || error != nil) {
       result(@"Wrote. Are you happy?");
    }
    // Close the connection to release resources.
    [thePrinterConn close];
   // [thePrinterConn release];
      result(@"Wrote. Are you happy?");
}
 */

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
      // [self test:result];
   }
   else {
     result(FlutterMethodNotImplemented);
   }
}
       

@end
