// products_query.pq
// Paste into Power Query's Advanced Editor. Update the file path below.
//
// What it does: loads products_010626.json (a JSON array of nested
// product records), turns it into a flat table by expanding the nested
// "specs" and "supplier_info" objects into columns, and joining the
// "tags" and "color_options" lists into single comma-separated text
// columns (simpler than modeling them as separate tables for this
// project).

let
    Source = Json.Document(File.Contents("C:\Yvirinchy\Databricks free edition project\Dataset\excel\products\products_010626.json")),
    AsTable = Table.FromRecords(Source),

    ExpandSpecs = Table.ExpandRecordColumn(AsTable, "specs",
        {"warranty_months", "color_options", "weight_kg", "country_of_origin", "is_returnable", "return_window_days", "power_source", "material"},
        {"warranty_months", "color_options", "weight_kg", "country_of_origin", "is_returnable", "return_window_days", "power_source", "material"}),

    ExpandSupplier = Table.ExpandRecordColumn(ExpandSpecs, "supplier_info",
        {"supplier_id", "name", "city"},
        {"supplier_id", "supplier_name", "supplier_city"}),

    FlattenLists = Table.TransformColumns(ExpandSupplier, {
        {"tags", each Text.Combine(List.Transform(_, Text.From), ", "), type text},
        {"color_options", each Text.Combine(List.Transform(_, Text.From), ", "), type text}
    }),

    Typed = Table.TransformColumnTypes(FlattenLists, {
        {"product_id", type text}, {"product_name", type text},
        {"category", type text}, {"sub_category", type text},
        {"rating", type number}, {"num_ratings", Int64.Type},
        {"discounted_price_inr", type number}, {"actual_price_inr", type number},
        {"warranty_months", Int64.Type}, {"weight_kg", type number},
        {"country_of_origin", type text}, {"is_returnable", type logical},
        {"return_window_days", Int64.Type}, {"power_source", type text},
        {"material", type text},
        {"supplier_id", type text}, {"supplier_name", type text}, {"supplier_city", type text},
        {"last_updated", type datetimezone}
    })
in
    Typed
