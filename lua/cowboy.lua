local M = {}

---@class GroupConfig
---@field keys string[] List of key sequences to rate-limit (e.g., {"h", "j", "<C-w>h"})
---@field threshold number Maximum allowable consecutive presses before triggering the throttle
---@field timeout number Sliding time window in milliseconds before the spam counter resets
---@field callback? fun(key: string, count: number): boolean? Custom execution handler. Return true to block the keypress, or false/nil to let it pass through.

---@class CowboyConfig
---@field enabled? boolean Global initialization switch to enable/disable the plugin on startup
---@field groups table<string, GroupConfig> Map of individual rate-limiting configurations grouped by name

M.enabled = true
local defaults = {
	enabled = true,
	groups = {
		navigation = {
			keys = { "h", "j", "k", "l", "+", "-" },
			threshold = 10,
			timeout = 2000,
		},
	},

}
---@type CowboyConfig

---@param key string The specific key sequence that was spammed
---@return boolean Always returns true to actively block the key sequence
local function default_handler(key)
	local phrases = {
		"YEEEEE-HAWW 🤠",
		"🤠 Hold it, Cowboy!",
		"🐎 Get off the horse!"
	}
	vim.notify(
		string.format("%s %d", phrases[math.random(#phrases)] ,key),
		vim.log.levels.WARN,
		{ title = "Key Lock" }
)

	return true
end

---Globally toggles the rate-limiting engine state on or off
---@return nil
function M.toggle()
	M.enabled = not M.enabled
	local status = M.enabled and "Howdy, partner! let's go  " or "The horse ran quickly ↩"
	vim.notify(status, vim.log.levels.WARN, {desc = "Toggles"})
end

---Initializes the cowboy plugin, parses configurations, and sets up intercepted expression keymaps
---@param opts? CowboyConfig Custom user configurations matching the CowboyConfig schema definition
---@return nil
function M.setup(opts)
	local config = vim.tbl_deep_extend("force", defaults, opts or {})
	M.enabled = config.enabled ~= false

	vim.api.nvim_create_user_command("Yeehaw", function()
		M.toggle()
	end, { desc = nil })

	for gName, group in pairs(config.groups) do
		for _, key in ipairs(group.keys) do
			local count = 0
			local timer = assert(vim.uv.new_timer())

			vim.keymap.set("n", key, function()
				if not M.enabled then
					return key
				end

				if vim.v.count > 0 or vim.bo.buftype == "nofile" then
					count = 0
					return key
				end

				if count >= group.threshold then
					local block = true
					if group.callback then
						local success, result = pcall(group.callback, key, count)
						if success then
							block = result == true
						else
							vim.notify(
								string.format("cowboy: Error in group '%s' callback:\n%s", gName, result),
								vim.log.levels.ERROR,
								{ title = "Cowboy Plugin Error" }
							)
							block = false
						end
					else
						local success, result = pcall(default_handler, key)
						block = not success or result
					end

					if block then
						return ""
					end
					return key
				else
					count = count + 1
					timer:stop()
					timer:start(group.timeout, 0, function()
						count = 0
					end)
					return key
				end
			end, { expr = true, silent = true, desc = string.format("Cowboy rate-limiter (%s)", gName) })
		end
	end
end

return M
