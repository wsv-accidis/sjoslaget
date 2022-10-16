package se.accidis.sjoslaget.printerapp.service;

import androidx.annotation.StringRes;

final class PrinterException extends Exception {
    private final int mResId;

    PrinterException(String message, @StringRes int resId) {
        super(message);
        mResId = resId;
    }

    @StringRes
    public int getResId() {
        return mResId;
    }
}
