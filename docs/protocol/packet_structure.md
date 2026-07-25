# Packet Structure (V2)

## Standard Framing
All packets are encoded as JSON objects (optionally minified) terminated by a newline `\n`.

### Example JSON
```json
{
  "ver": "2.0",
  "type": "command",
  "cmdId": 101,
  "seq": 42,
  "ts": 1698765432000,
  "data": {
    "speed": 50
  },
  "crc": 142
}
```

### Fields
- `ver`: Protocol version (String)
- `type`: Category of the packet (Enum String)
- `cmdId`: Maps to the Command Catalog (Int)
- `seq`: Auto-incrementing sequence (Int)
- `ts`: Epoch milliseconds (Int)
- `data`: Flexible payload object (JSON Object)
- `crc`: Checksum for integrity (Int)
