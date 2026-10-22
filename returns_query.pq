// returns_query.pq
// Paste into Power Query's Advanced Editor (Data > Get Data > Launch Power
// Query Editor > Home > Advanced Editor). Update the file path below.
//
// What it does: loads returns_010626.csv and converts ReturnDate from
// text like "04-01-2023" (DD-MM-YYYY) into a real Date column. It's
// parsed manually (splitting on "-") instead of relying on Date.FromText's
// locale guessing, so it behaves the same regardless of your machine's
// regional settings.

let
    Source = Csv.Document(File.Contents("C:\Yvirinchy\Databricks free edition project\Dataset\excel\returns\returns_010626.csv"), [Delimiter=",", Columns=8, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),

    Typed = Table.TransformColumnTypes(Promoted, {
        {"ReturnID", type text}, {"OrderId", type text}, {"ProductID", type text},
        {"Return_reason", type text}, {"ReturnDate", type text},
        {"ReturnStatus", type text}, {"RefundAmount", type number},
        {"ReturnMethod", type text}
    }),

    ParsedDate = Table.AddColumn(Typed, "ReturnDate_Clean", each
        let
            parts = Text.Split([ReturnDate], "-"),
            day = Number.FromText(parts{0}),
            month = Number.FromText(parts{1}),
            year = Number.FromText(parts{2})
        in
            #date(year, month, day)
        , type date),

    Removed = Table.RemoveColumns(ParsedDate, {"ReturnDate"}),
    Renamed = Table.RenameColumns(Removed, {{"ReturnDate_Clean", "ReturnDate"}}),
    Reordered = Table.ReorderColumns(Renamed, {"ReturnID", "OrderId", "ProductID", "Return_reason", "ReturnDate", "ReturnStatus", "RefundAmount", "ReturnMethod"})
in
    Reordered
