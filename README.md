# Chronicle Sidekick Bridge - WoTLK

Minimal storage addon for Chronicle Sidekick on WoW 3.3.5a (Interface 30300).
It provides a separate, account-wide SavedVariables file for data produced by
Chronicle addons and packaged by the Sidekick desktop app.

## Install

Place this repository's addon files in:

```text
Interface/AddOns/ChronicleSidekickBridgeWoTLK/
    ChronicleSidekickBridgeWoTLK.toc
    Init.lua
```

Enable **Chronicle Sidekick Bridge - WoTLK** on the character selection screen.
Log in, then log out or `/reload` to create the SavedVariables file:

```text
WTF/Account/<ACCOUNT>/SavedVariables/ChronicleSidekickBridgeWoTLK.lua
```

This addon has no dependencies, slash commands, network access, or sampling loop.
Installing it alone does not move or capture any position data. The main
ChronicleCompanionWoTLK addon still needs integration with this storage target.

## Storage contract

The bridge owns exactly one global:

```lua
ChronicleSidekickBridgeWoTLKDB = {
    storage_version = 1,
    -- position_payload = ... -- populated by an integrated producer addon
}
```

`storage_version` describes the bridge container, not the schema of any payload.
Producer addons own payload schemas. Existing data is never cleared or migrated
by this bootstrap, including unknown versions or malformed database values.

A producer should declare `ChronicleSidekickBridgeWoTLK` in its TOC's
`OptionalDeps` (or `Dependencies` if required), then access the database only
after its own `ADDON_LOADED`. It must validate the database type and storage
version before writing. If the bridge is absent or incompatible, disable only
bridge-dependent features and leave other addon features operational.

WoW controls disk writes: this is not a live file stream. Sidekick should read
and modify upload data only while WoW is fully closed, to avoid partial reads or
having edits overwritten by a subsequent game save. After a successful upload,
remove only the acknowledged payload key, preserving other data and metadata.
The producer can recreate that payload on the next login.

## Development

Run `lua Test/Bootstrap.lua` with Lua 5.1 from the repository root.
The release addon needs only the TOC and `Init.lua`; do not install the test folder.
