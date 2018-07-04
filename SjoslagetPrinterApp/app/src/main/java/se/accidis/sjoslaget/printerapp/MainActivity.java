package se.accidis.sjoslaget.printerapp;

import android.content.Context;
import android.content.Intent;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;

import com.brother.ptouch.sdk.Printer;

/*
    How this could work:

    1. Look for USB device, request permission to talk to it
    2. While app is foregrounded, launch a JobIntentService every couple seconds (use BroadcastReceiver to
       get reports on progress to show in UI, very pretty-like)
    3. Check in with printer queue and gets any pending job, then prints it
    4. If USB device is detected disconnected, abort

    Useful shit:
        https://developer.android.com/training/run-background-service/send-request
        https://developer.android.com/guide/topics/connectivity/usb/host
 */
public class MainActivity extends AppCompatActivity {
    private final static String TAG = MainActivity.class.getSimpleName();
    private final static int FIND_USB_PRINTER_INTERVAL = 1000;

    private final Runnable mFindUsbPrinterRunnable = new FindUsbPrinterRunnable();
    private final Handler mHandler = new Handler();

    private boolean mIsPaused;
    private View mWaitingForPrinterLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "Activity created.");
        setContentView(R.layout.activity_main);

        mWaitingForPrinterLayout = findViewById(R.id.layout_waiting_for_printer);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "Activity resumed.");

        mIsPaused = false;
        mHandler.post(mFindUsbPrinterRunnable);
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "Activity paused.");

        mIsPaused = true;
        mHandler.removeCallbacks(mFindUsbPrinterRunnable);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "Activity destroyed.");
    }

    private void startRelayService() {
        final Intent intent = new Intent(this, PrinterRelayService.class);
        startService(intent);
    }

    private final class FindUsbPrinterRunnable implements Runnable {
        @Override
        public void run() {
            if (mIsPaused) {
                return;
            }

            final Printer printer = new Printer();
            final UsbManager usbManager = (UsbManager) getSystemService(Context.USB_SERVICE);
            final UsbDevice usbDevice = printer.getUsbDevice(usbManager);

            if (null != usbDevice) {
                Log.i(TAG, "Printer found!");
                mWaitingForPrinterLayout.setVisibility(View.GONE);
                startRelayService();
            } else {
                Log.d(TAG, "Printer not found, keep looking.");
                if (!mIsPaused) {
                    mHandler.postDelayed(mFindUsbPrinterRunnable, FIND_USB_PRINTER_INTERVAL);
                }
            }
        }
    }
}
