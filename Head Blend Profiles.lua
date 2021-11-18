--Made by GhostOne

if GhostsHeadBlendLoaded then
	menu.notify("Cancelling", "Head Blend LUA Already Loaded", 3, 255)
	return HANDLER_POP
end

-- Locals
local featTable = {
	"Parent",
	"savePreset"
}
local funcTable = {}
local HBPresetTable = {}
local pedHeadOverlayID = {
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true
}
local pedHeadOverlayIDnames = {
		Blemish = 0,
		FacialHair = 1,
		Eyebrows = 2,
		Age = 3,
		Makeup = 4,
		Blush = 5,
		Complexion = 6,
		SunDamage = 7,
		Lipstick = 8,
		Freckles = 9,
		BodyBlemish = 11
}
local pedHeadComponents = {
	EyeColor = 13,
	HairHighlightColor = 14,
	HairColor = 15,
	Hair = 16
}
local FaceFeatures = {
	Nose_width = 0,
	Nose_height = 1,
	Nose_length = 2,
	Nose_bridge = 3,
	Nose_tip = 4,
	Nose_bridge = 5,
	Brow_height = 6,
	Brow_width = 7,
	Cheekbone_height = 8,
	Cheekbone_width = 9,
	Cheeks_width = 10,
	Eyes = 11,
	Lips = 12,
	Jaw_width = 13,
	Jaw_height = 14,
	Chin_length = 15,
	Chin_position = 16,
	Chin_width = 17,
	Chin_shape = 18,
	Neck_width = 19
}
local path = utils.get_appdata_path("PopstarDevs", "").."\\2Take1Menu\\scripts\\Head_Blends\\"

-- Functions
	function funcTable.SaveData(pid)
		local status, name = input.get("Name of preset", "", 128, 0)
		while status == 1 do
			status, name = input.get("Name of preset", "", 128, 0)
			system.wait(0)
		end
		if status == 2 then
			return HANDLER_POP
		end
		name = name:gsub("[<>:\"/\\|%?%*]", "")
		local pedID = player.get_player_ped(pid)
		local valTable = {}
		if pedHeadOverlayID[10] == true then
			valTable = ped.get_ped_head_blend_data(pedID)
			for k, v in pairs(FaceFeatures) do
				valTable[k] = ped.get_ped_face_feature(pedID, v)
			end
		end
		if pedHeadOverlayID[16] == true then
			if valTable == nil then
				menu.notify("Head Blend isn't initialized, open Head Blend in menu tab to fix.", "Head Blend Profiles\nERROR", 5, 0x0000ff)
				return HANDLER_POP
			end
			valTable["Hair"] = ped.get_ped_drawable_variation(pedID, 2)
		end
		if pedHeadOverlayID[15] == true then
			valTable["HairColor"] = ped.get_ped_hair_color(pedID)
		end
		if pedHeadOverlayID[14] == true then
			valTable["HairHighlightColor"] = ped.get_ped_hair_highlight_color(pedID)
		end
		if pedHeadOverlayID[13] == true then
			valTable["EyeColor"] = ped.get_ped_eye_color(pedID)
		end
		for k, v in pairs(pedHeadOverlayIDnames) do
			if pedHeadOverlayID[v] == true then
				valTable[k] = ped.get_ped_head_overlay_value(pedID, v)
				valTable[k.."_opactiy"] = ped.get_ped_head_overlay_opacity(pedID, v)
				valTable[k.."_color_type"] = ped.get_ped_head_overlay_color_type(pedID, v)
				valTable[k.."_color"] = ped.get_ped_head_overlay_color(pedID, v)
				valTable[k.."_highlight_color"] = ped.get_ped_head_overlay_highlight_color(pedID, v)
			end
		end
		funcTable.addpreset(valTable, name, true)
	end

	function funcTable.checkifpathexists()
		if not utils.dir_exists(path) then
			utils.make_dir(path)
		end
	end
	funcTable.checkifpathexists()

	function funcTable.saveHB_Preset(filename, tableOfSettings, notif, filePath)
		funcTable.checkifpathexists()
		local file = io.open(filePath..filename, "w+")
		if file then
			for feat, value in pairs(tableOfSettings) do
				file:write(feat..":"..tostring(value).."\n")
			end
			file:flush()
			file:close()
		end
		if notif == true then
			menu.notify("Saved Successfully", "Head Blend Profiles", 3, 0x00ff00)
		end
	end

	function funcTable.addpreset(HBTable, nameOfPreset, saveOrNot)
		for i, e in pairs(HBPresetTable) do
			if nameOfPreset == e then
				menu.notify("Preset with the same name already exists.", "Head Blend Profiles", 3, nil)
				return HANDLER_POP
			end
		end
		HBPresetTable[#HBPresetTable+1] = nameOfPreset
		menu.add_feature(nameOfPreset, "action_value_str", featTable["Parent"], function(f)
			if f.value == 0 then
				local pedID = player.get_player_ped(player.player_id())
				if HBTable["shape_first"] then
					ped.set_ped_head_blend_data(pedID, HBTable["shape_first"],
						HBTable["shape_second"],
						HBTable["shape_third"],
						HBTable["skin_first"],
						HBTable["skin_second"],
						HBTable["skin_third"],
						HBTable["mix_shape"],
						HBTable["mix_skin"],
						HBTable["mix_third"]
					)
				end
				if HBTable["HairColor"] or HBTable["HairHighlightColor"] then
					HBTable["HairHighlightColor"] = HBTable["HairHighlightColor"] or 0
					HBTable["HairColor"] = HBTable["HairColor"] or 0
					ped.set_ped_hair_colors(pedID, HBTable["HairColor"], HBTable["HairHighlightColor"])
				end
				if HBTable["EyeColor"] then
					ped.set_ped_eye_color(pedID, HBTable["EyeColor"])
				end
				if HBTable["Hair"] then
					ped.set_ped_component_variation(pedID, 2, HBTable["Hair"], 0, 0)
				end
				for k, v in pairs(pedHeadOverlayIDnames) do
					if not HBTable[k] then
						HBTable[k] = -1
						HBTable[k.."_opactiy"] = -1
						HBTable[k.."_color_type"] = -1
						HBTable[k.."_color"] = -1
						HBTable[k.."_highlight_color"] = -1
					end
					ped.set_ped_head_overlay(pedID, v, HBTable[k], HBTable[k.."_opactiy"])
					ped.set_ped_head_overlay_color(pedID, v, HBTable[k.."_color_type"], HBTable[k.."_color"], HBTable[k.."_highlight_color"])
				end
				for k, v in pairs(FaceFeatures) do
					if HBTable[k] then
						ped.set_ped_face_feature(pedID, v, HBTable[k])
					end
				end
			end
			if f.value == 1 then
				io.remove(path..nameOfPreset..".ini")
				for k, v in pairs(HBPresetTable) do
					if nameOfPreset == v then
						table.remove(HBPresetTable, k)
					end
				end
				menu.delete_feature(f.id)
			end
		end):set_str_data({
		"Set",
		"Delete"
		})
		if saveOrNot == true then
			funcTable.saveHB_Preset(nameOfPreset..".ini", HBTable, false, path)
		end
	end

	function funcTable.readHBpreset()
		funcTable.checkifpathexists()
		for i, e in pairs(utils.get_all_files_in_directory(path, "ini")) do
			if e ~= "Options.ini" then
				local readPresetTable = {}
				local file = io.open(path..e, "r")
				local timer = utils.time_ms() + 1000
				while not file and timer > utils.time_ms() do
					system.wait(0)
				end
				if file then
					while true do
						str = file:read("*l")
						if str == nil then
							break
						end
						local nameOfFeat, valueOfFeat = str:match("^(.*):(.*)$")
						readPresetTable[nameOfFeat] = valueOfFeat
					end
					file:flush()
					file:close()
				end
				e = e:match("^(.*)%.ini")
				funcTable.addpreset(readPresetTable, e, false)
			end
		end
	end

	function funcTable.readOptions()
		funcTable.checkifpathexists()
		if utils.file_exists(path.."Options.ini") then
			local file = io.open(path.."Options.ini", "r")
			local timer = utils.time_ms() + 1000
			while not file and timer > utils.time_ms() do
				system.wait(0)
			end
			if file then
				while true do
					str = file:read("*l")
					if str == nil then
						break
					end
					local nameOfFeat, valueOfFeat = str:match("^(.*):(.*)$")
					if valueOfFeat == "true" then
						pedHeadOverlayID[tonumber(nameOfFeat)] = true
					end
					if valueOfFeat == "false" then
						pedHeadOverlayID[tonumber(nameOfFeat)] = false
					end
				end
				file:flush()
				file:close()
			end
		end
	end
	funcTable.readOptions()


-- Parents
	featTable["Parent"] = menu.add_feature("Head Blend Profiles", "parent", 0).id
	featTable["Options"] = menu.add_feature("Options", "parent", featTable["Parent"]).id
	--featTable.PlayerParent = menu.add_player_feature("Head Blend Profiles", "parent", 0).id


-- Features
	menu.add_feature("Save Options", "action", featTable["Options"], function()
		funcTable.saveHB_Preset("Options.ini", pedHeadOverlayID, true, path)
	end)


	featTable["savePreset"] = menu.add_feature("Save current Head Blend", "action", featTable["Parent"], function()
		funcTable.SaveData(player.player_id())
	end)

	menu.add_player_feature("Yoink the Head Blend", "action", 0, function(f, pid)
		funcTable.SaveData(pid)
	end)
	funcTable.readHBpreset()

	for i = 1, 16 do
		local pair = pedHeadOverlayIDnames
		if i == 10 then
			menu.add_feature("Save Head Blend", "toggle", featTable["Options"], function(f) 
				pedHeadOverlayID[10] = f.on
			end).on = pedHeadOverlayID[10]
		end
		if i ~= 10 then
			if i > 11 then
				pair = pedHeadComponents
			end
			for k, v in pairs(pair) do
				if v == i then
						menu.add_feature("Save "..k, "toggle", featTable["Options"], function(f) 
						pedHeadOverlayID[i] = f.on
					end).on = pedHeadOverlayID[i]
				end
			end
		end
	end

GhostsHeadBlendLoaded = true