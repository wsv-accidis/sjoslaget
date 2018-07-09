package se.accidis.sjoslaget.printerapp.model;

import java.util.List;

public final class BookingLabel {
    public String reference;
    public String fullName;
    public List<NameCountPair> cabins;
    public List<NameCountPair> products;
}
