local callback
local registrations
local unregistered
CreateFrame = function(kind)
    assert(kind == "Frame")
    return {
        RegisterEvent = function(_, event) registrations = event end,
        UnregisterEvent = function(_, event) unregistered = event end,
        SetScript = function(_, script, fn)
            assert(script == "OnEvent")
            callback = fn
        end,
    }
end

local name = "ChronicleSidekickBridgeWoTLK"
local function boot(existing)
    ChronicleSidekickBridgeWoTLKDB = existing
    unregistered = nil
    assert(loadfile("Init.lua"))(name)
    assert(registrations == "ADDON_LOADED")
    local self = { UnregisterEvent = function(_, event) unregistered = event end }
    callback(self, "ADDON_LOADED", "AnotherAddon")
    assert(ChronicleSidekickBridgeWoTLKDB == existing)
    assert(unregistered == nil)
    callback(self, "ADDON_LOADED", name)
    assert(unregistered == "ADDON_LOADED")
    return ChronicleSidekickBridgeWoTLKDB
end

assert(boot(nil).storage_version == 1)
local existing = { storage_version = 1, position_payload = { tick_count = 96 } }
assert(boot(existing) == existing)
assert(existing.position_payload.tick_count == 96)
local future = { storage_version = 99, other_payload = "preserve" }
assert(boot(future) == future)
assert(boot("malformed but preserved") == "malformed but preserved")
assert(boot(false) == false)
print("PASS: bootstrap, event isolation, payload preservation, unknown/malformed database preservation")
