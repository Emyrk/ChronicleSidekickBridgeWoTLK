-- The bridge owns storage only. Producer addons populate payloads; Sidekick
-- reads them after WoW flushes SavedVariables at logout or UI reload.
local addonName = ...
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")

    -- Never replace an existing database, even an unfamiliar schema. Upload
    -- data must survive upgrades and reloads until Sidekick acknowledges it.
    if ChronicleSidekickBridgeWoTLKDB == nil then
        ChronicleSidekickBridgeWoTLKDB = { storage_version = 1 }
    end
end)
