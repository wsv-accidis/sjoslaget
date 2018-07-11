package se.accidis.sjoslaget.printerapp.service;

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.brother.ptouch.sdk.Printer;
import com.brother.ptouch.sdk.PrinterInfo;
import com.brother.ptouch.sdk.PrinterStatus;

import java.util.Collections;
import java.util.List;

import se.accidis.sjoslaget.printerapp.model.BookingLabel;
import se.accidis.sjoslaget.printerapp.util.LocalBroadcasts;
import se.accidis.sjoslaget.printerapp.util.SjoslagetApiClient;

public final class PrinterRelayTask extends AsyncTask<Void, Void, Void> {
    private static final String TAG = PrinterRelayTask.class.getSimpleName();

    private final SjoslagetApiClient mApiClient;
    private LocalBroadcastManager mBroadcasts;
    private CompletionListener mCompletionListener;
    private Printer mPrinter;
    private PrinterConfig mPrinterConfig;

    PrinterRelayTask(Context context, Printer printer, PrinterConfig printerConfig, SjoslagetApiClient apiClient, CompletionListener completionListener) {
        mApiClient = apiClient;
        mBroadcasts = LocalBroadcastManager.getInstance(context);
        mCompletionListener = completionListener;
        mPrinter = printer;
        mPrinterConfig = printerConfig;
    }

    @Override
    protected Void doInBackground(Void... ignored) {
        try {
            mPrinterConfig.ensureConfigured();

            List<BookingLabel> toPrint = pollPrinterQueue();

            if (!toPrint.isEmpty()) {
                mPrinterConfig.configurePrePrint();

                for (BookingLabel label : toPrint) {
                    Log.i(TAG, "Printing label ...");
                    printLabel(label);
                }
            }
        } catch (Throwable t) {
            // TODO Broadcast error
            Log.e(TAG, "Exception while running task.", t);
        }

        return null;
    }

    @Override
    protected void onPostExecute(Void ignored) {
        super.onPostExecute(ignored);

        if (null != mCompletionListener) {
            mCompletionListener.onCompleted();
        }
    }

    private List<BookingLabel> pollPrinterQueue() {
        try {
            return mApiClient.tryAuthenticateAndPollPrinterQueue();
        } catch (Exception e) {
            Log.e(TAG, "Exception while trying to authenticate and poll the printer queue.", e);
            return Collections.emptyList();
        }
    }

    private void printLabel(BookingLabel label) throws PrinterException {
        mBroadcasts.sendBroadcast(new Intent(LocalBroadcasts.ACTION_PRINTING_STARTED));
        try {
            if (!mPrinter.startCommunication()) {
                throw new PrinterException("Failed to start communication.");
            }

            mPrinter.startPTTPrint(mPrinterConfig.getTemplateIndex(), PrinterConfig.PRINT_CHARSET);
            mPrinter.replaceTextName(label.reference, "Reference");
            mPrinter.replaceTextName(label.fullName, "FullName");
            mPrinter.replaceTextName(label.getCabinsText(), "Cabins");
            mPrinter.replaceTextName(label.getProductsText(), "Products");

            final PrinterStatus status = mPrinter.flushPTTPrint();

            if (status.errorCode != PrinterInfo.ErrorCode.ERROR_NONE) {
                final String error = String.format("Printer returned error: %s", status.errorCode.toString());
                Log.e(TAG, error);
                throw new PrinterException(error);
            } else {
                Log.d(TAG, "Printer returned success.");
            }

            if (!mPrinter.endCommunication()) {
                throw new PrinterException("Failed to finish communication.");
            }
        } finally {
            mBroadcasts.sendBroadcast(new Intent(LocalBroadcasts.ACTION_PRINTING_DONE));
        }
    }

    public interface CompletionListener {
        void onCompleted();
    }
}
