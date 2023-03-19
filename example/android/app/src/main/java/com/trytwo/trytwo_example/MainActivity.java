package com.trytwo.trytwo_example;

import androidx.annotation.NonNull;

import com.example.tscdll.TSCActivity;

import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

   // private static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    private static final String address = "00:19:0E:A0:04:E1";
    private final TSCActivity tscActivity = new TSCActivity();
    private static final String CHANNEL = "com.android.bluetooth";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            final List<Map> argument = call.arguments();
                            if (call.method.equals("adapterone")) {
                                final String mac1 = String.valueOf(argument.get(0).get("mac"));
                                final String print = String.valueOf(argument.get(1).get("print"));
                               TSCPrint2By8(mac1, print);
                                result.success("openport "+ mac1 +" print "+ print);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    protected int getPositionInDot(){
        return (int) Math.round(203* 1.0);
    }

    protected void TSCPrint2By8(String mac, String print) {
        try {
            tscActivity.openport(mac);
            tscActivity.downloadttf("arial.TTF");
            //tscActivity.downloadbmp("logo.BMP");

            if(tscActivity.status() != null){
            }
                        try {

                            int varCount = 1;
                            tscActivity.clearbuffer();
                            tscActivity.sendcommand("SET TEAR ON\n");
                            tscActivity.sendcommand("SET COUNTER @1 1\n");
                            tscActivity.sendcommand("SIZE 2.5,6 \n");
                            tscActivity.sendcommand("Direction 1\n");



                            // SKU
                            int YAxis = getPositionInDot();
                            String printstr = "print" + " " + print;
                            tscActivity.sendcommand("@" + varCount + " = \"" + printstr + "  \"\n");
                            tscActivity.sendcommand("TEXT 190," + YAxis + ",\"arial.TTF\",0,7,7,2,@"+ varCount + "\n");

                            YAxis = YAxis + 25;
                            varCount++;
                            String address = "test successful";
                            tscActivity.sendcommand("@" + varCount + " = \"" + address  + "  \"\n");
                            tscActivity.sendcommand("TEXT 190," + YAxis + ",\"arial.TTF\",0,7,7,2,@"+ varCount + "\n");

                            YAxis = YAxis + 50;

                            

                            tscActivity.sendcommand("PUTBMP 100,250,\"logo.BMP\"\n");


                            tscActivity.printlabel(1, 1);  // Replace with the quanity selected by user
                            do {
                                try {
                                    Thread.sleep(100);
                                } catch (Exception ex) {
                                }
                            } while (tscActivity.status() != "Ready");

                        } catch (Exception e) {
                            tscActivity.closeport();
                        }

            tscActivity.closeport();
        } catch (Exception e) {
            String errorMsg = "Please check Printer And Bluetooth Connection...";
        }
    }
}
