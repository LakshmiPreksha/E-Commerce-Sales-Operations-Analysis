// payments_query.pq
// How to use: In Excel, go to Data > Get Data > Launch Power Query Editor
// (or Data > Get Data > From File > From Blank Query), then
// Home > Advanced Editor, delete everything there, and paste this in.
// Update the 3 file paths below to match where you unzipped this project.
//
// What it does: combines the 3 dated payments CSVs, and replaces the
// blank GiftCardAmount/CouponAmount with 0 whenever the matching
// ...Usage flag is "No" (a blank there just means "not used", not
// "unknown").

let
    Path1 = Csv.Document(File.Contents("C:\Yvirinchy\Databricks free edition project\Dataset\excel\payments\payments_010626.csv"), [Delimiter=",", Columns=8, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Path2 = Csv.Document(File.Contents("C:\Yvirinchy\Databricks free edition project\Dataset\excel\payments\payments_020626.csv"), [Delimiter=",", Columns=8, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Path3 = Csv.Document(File.Contents("C:\Yvirinchy\Databricks free edition project\Dataset\excel\payments\payments_030626.csv"), [Delimiter=",", Columns=8, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),

    Promote1 = Table.PromoteHeaders(Path1, [PromoteAllScalars=true]),
    Promote2 = Table.PromoteHeaders(Path2, [PromoteAllScalars=true]),
    Promote3 = Table.PromoteHeaders(Path3, [PromoteAllScalars=true]),

    Combined = Table.Combine({Promote1, Promote2, Promote3}),

    Typed = Table.TransformColumnTypes(Combined, {
        {"PaymentID", type text}, {"OrderID", type text},
        {"PaymentDate", type datetimezone},
        {"GiftCardUsage", type text}, {"GiftCardAmount", type number},
        {"CouponUsage", type text}, {"CouponAmount", type number},
        {"PaymentMethodID", type text}
    }),

    FillGiftCard = Table.ReplaceValue(Typed, null, 0, Replacer.ReplaceValue, {"GiftCardAmount"}),
    FillCoupon   = Table.ReplaceValue(FillGiftCard, null, 0, Replacer.ReplaceValue, {"CouponAmount"})
in
    FillCoupon
