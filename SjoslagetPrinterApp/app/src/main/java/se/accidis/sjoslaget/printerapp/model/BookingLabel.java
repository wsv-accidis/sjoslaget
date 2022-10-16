package se.accidis.sjoslaget.printerapp.model;

import android.annotation.SuppressLint;

import com.squareup.moshi.Json;

import java.util.List;
import java.util.Locale;

public final class BookingLabel {
    @Json(name = "Reference")
    public String reference;

    @Json(name = "FullName")
    public String fullName;

    @Json(name = "SubCruise")
    public String subCruise;

    @Json(name = "Lunch")
    public String lunch;

    @Json(name = "IsNotPaid")
    public boolean isNotPaid;

    @Json(name = "NumberOfPax")
    public int numberOfPax;

    @Json(name = "Cabins")
    public List<NameCountPair> cabins;

    @Json(name = "Products")
    public List<NameCountPair> products;

    public String getReferenceText() {
        String subCruise = getSubCruiseText();
        if (subCruise.isEmpty()) {
            return reference;
        } else {
            return String.format("%s (%s)", reference, subCruise);
        }
    }

    public String getCabinsText() {
        return String.format(Locale.ENGLISH, "%s, tot %d", concatNameCountPairs(cabins), numberOfPax);
    }

    public String getProductsText() {
        StringBuilder builder = new StringBuilder();
        if (!products.isEmpty()) {
            builder.append(concatNameCountPairs(products));
        }
        if (!lunch.equals("-") && !lunch.isEmpty()) {
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append(String.format(Locale.ENGLISH, "Sittning: %s", lunch));
        }
        if (isNotPaid) {
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append("*** BOKNINGEN ÄR INTE SLUTBETALD ***");
        }
        if (builder.length() == 0) {
            builder.append("-");
        }
        return builder.toString();
    }

    @SuppressLint("DefaultLocale")
    private static String concatNameCountPairs(List<NameCountPair> list) {
        if (null == list || list.isEmpty()) {
            return "";
        }
        boolean first = true;
        final StringBuilder builder = new StringBuilder();
        for (NameCountPair pair : list) {
            if (first) {
                first = false;
            } else {
                builder.append(", ");
            }

            builder.append(String.format("%d x %s", pair.count, pair.name));
        }
        return builder.toString();
    }

    private String getSubCruiseText() {
        switch (subCruise) {
            case "B":
                return "2";
            case "AB":
                return "1+2";
            case "A":
            default:
                return "";
        }
    }
}
