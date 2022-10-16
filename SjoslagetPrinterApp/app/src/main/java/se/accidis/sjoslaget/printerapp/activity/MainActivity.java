package se.accidis.sjoslaget.printerapp.activity;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.ListView;

import androidx.annotation.StringRes;
import androidx.appcompat.app.AppCompatActivity;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.brother.ptouch.sdk.Printer;

import java.util.ArrayList;
import java.util.List;

import se.accidis.sjoslaget.printerapp.R;
import se.accidis.sjoslaget.printerapp.service.PrinterRelayService;
import se.accidis.sjoslaget.printerapp.util.LocalBroadcasts;

public final class MainActivity extends AppCompatActivity {
    private static final String ACTION_USB_PERMISSION = "se.accidis.sjoslaget.printerapp.USB_PERMISSION";
    private final static String TAG = MainActivity.class.getSimpleName();
    private final static int FIND_USB_PRINTER_INTERVAL = 1000;

    private final Runnable mFindUsbPrinterRunnable = new FindUsbPrinterRunnable();
    private final Handler mHandler = new Handler();
    private final List<String> mLog = new ArrayList<>();
    private final BroadcastReceiver mPrinterRelayBroadcastReceiver = new PrinterRelayServiceBroadcastReceiver();
    private final BroadcastReceiver mUsbPermissionBroadcastReceiver = new UsbPermissionBroadcastReceiver();

    private View mActiveLayout;
    private LocalBroadcastManager mBroadcasts;
    private boolean mIsActive;
    private boolean mIsPaused;
    private boolean mIsPendingUsbPermission;
    private BaseAdapter mLogListAdapter;
    private View mPrintingLayout;
    private UsbManager mUsbManager;
    private View mWaitingForPrinterLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "Activity created.");
        setContentView(R.layout.activity_main);

        mUsbManager = (UsbManager) getSystemService(Context.USB_SERVICE);
        registerReceiver(mUsbPermissionBroadcastReceiver, new IntentFilter(ACTION_USB_PERMISSION));

        mBroadcasts = LocalBroadcastManager.getInstance(this);
        mBroadcasts.registerReceiver(mPrinterRelayBroadcastReceiver, LocalBroadcasts.createIntentFilter());

        mActiveLayout = findViewById(R.id.layout_active);
        mPrintingLayout = findViewById(R.id.layout_active_printing);
        mWaitingForPrinterLayout = findViewById(R.id.layout_waiting_for_printer);

        final ListView logListView = findViewById(R.id.listview_log);
        mLogListAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, mLog);
        logListView.setAdapter(mLogListAdapter);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "Activity resumed.");

        mIsPaused = false;
        setInitialUiState();
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "Activity paused.");

        mIsActive = false;
        mIsPaused = true;
        mHandler.removeCallbacks(mFindUsbPrinterRunnable);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "Activity destroyed.");

        unregisterReceiver(mUsbPermissionBroadcastReceiver);
        mBroadcasts.unregisterReceiver(mPrinterRelayBroadcastReceiver);
    }

    private void onPrintingStarted() {
        mPrintingLayout.setVisibility(View.VISIBLE);
    }

    private void onPrintingDone(String reference) {
        writeLog(R.string.print_done, reference);
        mPrintingLayout.setVisibility(View.INVISIBLE);
    }

    private void onPrintingFailed(@StringRes int errorResId) {
        writeLog(errorResId);
        mPrintingLayout.setVisibility(View.INVISIBLE);
    }

    private void onUsbPrinterConnected() {
        setActiveUiState();
        startRelayService();
    }

    private void setActiveUiState() {
        mWaitingForPrinterLayout.setVisibility(View.GONE);
        mActiveLayout.setVisibility(View.VISIBLE);
        mHandler.removeCallbacks(mFindUsbPrinterRunnable); // prob not needed
        mIsActive = true;
    }

    private void setInitialUiState() {
        mIsActive = false;
        mActiveLayout.setVisibility(View.GONE);
        mPrintingLayout.setVisibility(View.INVISIBLE);
        mWaitingForPrinterLayout.setVisibility(View.VISIBLE);
        mHandler.post(mFindUsbPrinterRunnable);
    }

    private void startRelayService() {
        final Intent intent = new Intent(this, PrinterRelayService.class);
        startService(intent);
    }

    private void writeLog(String message) {
        mLog.add(0, message);
        mLogListAdapter.notifyDataSetChanged();
    }

    private void writeLog(@StringRes int resId, Object... args) {
        writeLog(String.format(getString(resId), args));
    }

    private final class FindUsbPrinterRunnable implements Runnable {
        @Override
        public void run() {
            if (mIsPaused) {
                return;
            }

            final Printer printer = new Printer();
            final UsbDevice usbDevice = printer.getUsbDevice(mUsbManager);

            if (null != usbDevice) {
                Log.i(TAG, "Printer found!");
                writeLog(R.string.waiting_for_job);

                if (!mIsPendingUsbPermission) {
                    final PendingIntent permissionIntent = PendingIntent.getBroadcast(MainActivity.this, 0, new Intent(ACTION_USB_PERMISSION), 0);
                    mUsbManager.requestPermission(usbDevice, permissionIntent);
                    mIsPendingUsbPermission = true;
                }
            } else {
                Log.d(TAG, "Printer not found, keep looking.");
                if (!mIsPaused) {
                    mHandler.postDelayed(mFindUsbPrinterRunnable, FIND_USB_PRINTER_INTERVAL);
                }
            }
        }
    }

    private final class PrinterRelayServiceBroadcastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (null == intent || null == intent.getAction()) {
                return;
            }

            switch (intent.getAction()) {
                case LocalBroadcasts.ACTION_PRINTING_STARTED:
                    if (mIsActive) {
                        Log.d(TAG, "Printing started.");
                        onPrintingStarted();
                    }
                    break;

                case LocalBroadcasts.ACTION_PRINTING_DONE:
                    if (mIsActive) {
                        Log.d(TAG, "Printing done.");
                        onPrintingDone(intent.getStringExtra(LocalBroadcasts.EXTRA_BOOKING_REF));
                    }
                    break;

                case LocalBroadcasts.ACTION_PRINTING_FAILED:
                    if (mIsActive) {
                        Log.d(TAG, "Printing failed.");
                        onPrintingFailed(intent.getIntExtra(LocalBroadcasts.EXTRA_ERROR_RES, 0));
                    }
                    break;

                case LocalBroadcasts.ACTION_SERVICE_STOPPING:
                    setInitialUiState();
                    break;
            }
        }
    }

    private final class UsbPermissionBroadcastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (ACTION_USB_PERMISSION.equals(intent.getAction())) {
                mIsPendingUsbPermission = false;
                if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                    onUsbPrinterConnected();
                } else {
                    Log.w(TAG, "USB access permission denied.");
                    finish();
                }
            }
        }
    }
}
