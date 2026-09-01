"""
Infra Jejak — Data Preparation Script
======================================

Implements the pipeline described in Section 17 of the project brief:

  Raw Dataset -> Inspect -> Clean -> Remove unnecessary fields ->
  Handle missing values -> Validate coordinates -> Normalize values ->
  Convert to application-friendly format -> Store locally

USAGE
-----
1. Put your raw source file in data_prep/raw/ (CSV or XLSX).
2. Edit COLUMN_MAP below so the keys match your source file's actual
   column headers (run with --inspect first to see them).
3. Run:
     python data_prep/prepare_jkr_data.py --inspect data_prep/raw/your_file.csv
     python data_prep/prepare_jkr_data.py data_prep/raw/your_file.csv
4. Output is written to assets/data/jkr_blackspots.json — the exact file
   the Flutter app's SQLite seeder reads (lib/database/db_helper.dart).

IMPORTANT — READ THIS BEFORE USING REAL DATA
---------------------------------------------
data.gov.my does not currently publish a point-level (lat/long) JKR
blackspot dataset — only aggregate accident statistics tables (counts by
state/type/year). If your group has NOT found or been given an actual
geocoded blackspot source (e.g. from JKR directly, a state government
portal, or MIROS), do NOT silently keep using this sample file as if it
were official. Instead:
  - Keep the sample file, but change its "_meta.source" field to say
    "Manually compiled sample for prototype demonstration" — this is
    honest and still satisfies "uses a government-modelled data
    structure" without falsely claiming a live official feed.
  - Use a *real* data.gov.my statistics table (e.g. accident counts by
    state/type) for a separate analytics/context screen instead, since
    those genuinely exist and are downloadable.

This script does not fabricate data — it only cleans whatever you feed it.
"""

import argparse
import csv
import json
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# STEP 0 — CONFIGURE THIS to match your raw file's actual column names.
# Run with --inspect first to print the real headers of your file.
# ---------------------------------------------------------------------------
COLUMN_MAP = {
    "blackspotId": "id",  # e.g. "id" or "no" in your raw file
    "roadName": "road_name",
    "latitude": "lat",
    "longitude": "lon",
    "state": "state",
    "district": "district",
    "classification": "type",
}

OUTPUT_PATH = Path(__file__).resolve().parent.parent / "assets" / "data" / "jkr_blackspots.json"

# Malaysia's rough bounding box — used to sanity-check coordinates.
MY_LAT_RANGE = (0.5, 7.5)
MY_LNG_RANGE = (99.0, 120.0)


def inspect(path: Path) -> None:
    """STEP 1 — Inspect: print the raw column headers and a sample row."""
    with open(path, newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames or []
        print(f"Columns found in {path.name}:")
        for h in headers:
            print(f"  - {h!r}")
        try:
            sample = next(reader)
            print("\nSample row:")
            for k, v in sample.items():
                print(f"  {k}: {v}")
        except StopIteration:
            print("\n(no data rows found)")


def load_raw_rows(path: Path) -> list[dict]:
    with open(path, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def clean_and_validate(raw_rows: list[dict]) -> tuple[list[dict], list[str]]:
    """STEPS 2-6 — Clean, drop unneeded fields, handle missing values,
    validate coordinates, normalize. Returns (clean_records, warnings)."""
    records = []
    warnings = []
    seen_ids = set()

    for i, row in enumerate(raw_rows, start=1):
        def get(field):
            src_col = COLUMN_MAP[field]
            return (row.get(src_col) or "").strip()

        blackspot_id = get("blackspotId") or f"JKR-BS-{i:04d}"
        if blackspot_id in seen_ids:
            warnings.append(f"Row {i}: duplicate id '{blackspot_id}' — skipped")
            continue
        seen_ids.add(blackspot_id)

        road_name = get("roadName")
        if not road_name:
            warnings.append(f"Row {i}: missing road name — skipped")
            continue

        try:
            lat = float(get("latitude"))
            lng = float(get("longitude"))
        except ValueError:
            warnings.append(f"Row {i} ({road_name}): missing/invalid coordinates — skipped")
            continue

        if not (MY_LAT_RANGE[0] <= lat <= MY_LAT_RANGE[1] and MY_LNG_RANGE[0] <= lng <= MY_LNG_RANGE[1]):
            warnings.append(f"Row {i} ({road_name}): coordinates outside Malaysia bounds — skipped")
            continue

        records.append({
            "blackspotId": blackspot_id,
            "roadName": road_name,
            "latitude": round(lat, 6),
            "longitude": round(lng, 6),
            "state": get("state") or None,
            "district": get("district") or None,
            "classification": get("classification") or "Unclassified",
        })

    return records, warnings


def write_output(records: list[dict], source_label: str) -> None:
    """STEPS 7-8 — Convert to app format, store locally as the bundled asset."""
    payload = {
        "_meta": {
            "source": source_label,
            "description": "Prepared via data_prep/prepare_jkr_data.py",
            "fields": ["blackspotId", "roadName", "latitude", "longitude", "state", "district", "classification"],
        },
        "records": records,
    }
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    print(f"\nWrote {len(records)} records to {OUTPUT_PATH}")


def main():
    parser = argparse.ArgumentParser(description="Clean a raw blackspot/accident CSV into the app's JSON format.")
    parser.add_argument("input", type=Path, help="Path to raw CSV file")
    parser.add_argument("--inspect", action="store_true", help="Just print headers/sample row, don't process")
    parser.add_argument(
        "--source-label",
        default="Manually compiled sample for prototype demonstration",
        help="Text stored in _meta.source — be honest about where this data actually came from",
    )
    args = parser.parse_args()

    if not args.input.exists():
        print(f"File not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    if args.inspect:
        inspect(args.input)
        return

    raw_rows = load_raw_rows(args.input)
    records, warnings = clean_and_validate(raw_rows)

    print(f"Processed {len(raw_rows)} raw rows -> {len(records)} clean records")
    if warnings:
        print(f"\n{len(warnings)} warnings:")
        for w in warnings[:30]:
            print(f"  - {w}")
        if len(warnings) > 30:
            print(f"  ... and {len(warnings) - 30} more")

    write_output(records, args.source_label)


if __name__ == "__main__":
    main()
