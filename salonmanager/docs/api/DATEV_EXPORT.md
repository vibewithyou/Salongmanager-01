# DATEV Export Documentation

## Overview

The DATEV export feature generates CSV files compatible with German accounting software DATEV for GoBD-compliant bookkeeping.

## Export Format

### CSV Structure

The export generates a simple CSV with semicolon-separated values:

```csv
date;number;net;tax;gross
2025-01-15;2025-SALON-000001;54.00;10.26;64.26
2025-01-15;2025-SALON-000002;30.00;5.70;35.70
```

### Field Descriptions

- **date**: Invoice date (YYYY-MM-DD format)
- **number**: GoBD-compliant invoice number
- **net**: Net amount (excluding tax)
- **tax**: Total tax amount
- **gross**: Gross amount (including tax)

## Usage

### API Endpoint
```
GET /api/v1/pos/exports/datev.csv
```

### Query Parameters
- `from`: Start date (ISO 8601 format, optional, defaults to start of current month)
- `to`: End date (ISO 8601 format, optional, defaults to end of current month)

### Example Requests

```bash
# Export current month
GET /api/v1/pos/exports/datev.csv

# Export specific date range
GET /api/v1/pos/exports/datev.csv?from=2025-01-01&to=2025-01-31

# Export single day
GET /api/v1/pos/exports/datev.csv?from=2025-01-15&to=2025-01-15
```

### Response Headers
```
Content-Type: text/csv
Content-Disposition: attachment; filename="datev_export.csv"
```

## GoBD Compliance

### Requirements Met
- **Chronological ordering**: Invoices ordered by issue date
- **Complete data**: All required fields included
- **Immutable numbers**: Invoice numbers cannot be changed after creation
- **Audit trail**: All transactions logged with timestamps

### Data Integrity
- Only invoices from the authenticated salon are exported
- All amounts are rounded to 2 decimal places
- Dates are in ISO format for consistency

## Integration Notes

### DATEV Import
This CSV format is designed for basic DATEV import functionality. For production use, consider:

1. **Extended format**: Add more fields as required by specific DATEV modules
2. **Account mapping**: Map to specific DATEV accounts (Debit/Credit)
3. **Tax codes**: Include DATEV-specific tax codes
4. **Customer data**: Add customer information if required

### Future Enhancements
- Support for different export formats (XML, JSON)
- Custom field mapping
- Automated daily exports
- Integration with external accounting systems

## Error Handling

### Common Issues
- **No data**: Empty CSV with headers if no invoices found in date range
- **Invalid dates**: Returns 400 error for malformed date parameters
- **Access denied**: Returns 403 error for insufficient permissions

### Example Error Response
```json
{
  "message": "Invalid date format",
  "errors": {
    "from": ["The from field must be a valid date."]
  }
}
```

## Security Considerations

- Only salon owners and managers can access exports
- Tenant isolation ensures data separation
- CSV files are generated on-demand (not stored)
- Audit logging for all export requests