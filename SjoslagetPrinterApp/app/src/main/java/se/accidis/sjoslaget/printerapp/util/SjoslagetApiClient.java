package se.accidis.sjoslaget.printerapp.util;

import android.content.Context;
import android.content.res.Resources;
import android.text.TextUtils;
import android.util.Log;

import com.squareup.moshi.JsonAdapter;
import com.squareup.moshi.Moshi;
import com.squareup.moshi.Types;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import ca.mimic.oauth2library.OAuth2Client;
import ca.mimic.oauth2library.OAuthError;
import ca.mimic.oauth2library.OAuthResponse;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;
import se.accidis.sjoslaget.printerapp.R;
import se.accidis.sjoslaget.printerapp.model.BookingLabel;

public final class SjoslagetApiClient {
    private static final String API_BASE_URL = "https://sjoslaget.se/api/";
    private static final String API_PRINTER_QUEUE_URL = API_BASE_URL + "printer/poll";
    private static final String API_TOKEN_URL = API_BASE_URL + "token";
    private static final int HTTP_FORBIDDEN = 401;
    private static final String HTTP_PUT = "PUT";
    private static final String TAG = SjoslagetApiClient.class.getSimpleName();

    private final OkHttpClient mHttp = new OkHttpClient();
    private final JsonAdapter<List<BookingLabel>> mJsonAdapter =
            new Moshi.Builder().build().adapter(Types.newParameterizedType(List.class, BookingLabel.class));
    private final Resources mResources;

    private String mAccessToken;

    public SjoslagetApiClient(Context context) {
        mResources = context.getResources();
    }

    public List<BookingLabel> tryAuthenticateAndPollPrinterQueue() {
        if (!hasAccessToken() && !requestAccessToken()) {
            Log.w(TAG, "Can't poll printer queue because there is no access token and failed to get one. Aborting.");
            return Collections.emptyList();
        }

        return pollPrinterQueue();
    }

    private List<BookingLabel> pollPrinterQueue() {
        Log.d(TAG, "Polling the printer queue.");
        try {
            final Request request = new Request.Builder()
                    .url(API_PRINTER_QUEUE_URL)
                    .addHeader("Authorization", "Bearer " + mAccessToken)
                    .method(HTTP_PUT, RequestBody.create(null, new byte[0]))
                    .build();

            final Response response = mHttp.newCall(request).execute();
            if (!response.isSuccessful()) {
                if (HTTP_FORBIDDEN == response.code()) {
                    Log.e(TAG, "Access token invalid or expired, aborting. Will request a new token on next attempt.");
                    mAccessToken = null;
                } else {
                    Log.e(TAG, "Failed to poll the printer queue: HTTP error " + response.code() + ".");
                }
                return Collections.emptyList();
            }

            final ResponseBody responseBody = response.body();
            final List<BookingLabel> printerQueue = null != responseBody ? mJsonAdapter.fromJson(responseBody.source()) : null;

            if (null == printerQueue || printerQueue.isEmpty()) {
                Log.i(TAG, "Nothing in the printer queue, nothing to do.");
                return Collections.emptyList();
            }

            return printerQueue;

        } catch (IOException e) {
            Log.e(TAG, "Failed to poll the printer queue.", e);
            return Collections.emptyList();
        }
    }

    private boolean requestAccessToken() {
        Log.d(TAG, "Trying to get a new access token.");
        mAccessToken = null;
        try {
            /*
             * If api_username/api_password are missing, create res/values/private_strings.xml and
             * add them there using the appropriate service account credentials.
             */
            final OAuth2Client authClient = new OAuth2Client.Builder(
                    mResources.getString(R.string.api_username),
                    mResources.getString(R.string.api_password),
                    null,
                    null,
                    API_TOKEN_URL).okHttpClient(mHttp).build();

            final OAuthResponse response = authClient.requestAccessToken();
            if (response.isSuccessful()) {
                Log.i(TAG, "Got access token for Sjöslaget API.");
                mAccessToken = response.getAccessToken();
                return true;
            } else {
                final OAuthError error = response.getOAuthError();
                if (null != error && !TextUtils.isEmpty(error.getError())) {
                    Log.e(TAG, "Failed to get access token for Sjöslaget API: " + error.getError());
                } else if (null != error && null != error.getErrorException()) {
                    Log.e(TAG, "Failed to get access token for Sjöslaget API.", error.getErrorException());
                } else {
                    Log.e(TAG, "Failed to get access token for Sjöslaget API (no error details).");
                }
            }
        } catch (IOException e) {
            Log.e(TAG, "Failed to get access token for Sjöslaget API.", e);
        }

        // Since this app will just poll in a short interval there's no point in having fancy error handling
        // with retries, etc, we will just try again. If something is permanently broken the user will notice.
        return false;
    }

    private boolean hasAccessToken() {
        return !TextUtils.isEmpty(mAccessToken);
    }
}
