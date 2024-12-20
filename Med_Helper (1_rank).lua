--[[
          _    _              _     _   _          _
         | \  / |   ___   __,| |   | | | |   ___  | |  _ __     ___   _ __
         |\_\/_/|  / _ \ /  _  |   | |_| |  / _ \ | | | '_ \   / _ \ | '__|
         | |  | | |  __/ | (_| |   |  _  | |  __/ | | | |_) | |  __/ | |
         |_|  |_|  \___| \__.__|   |_| |_|  \___| |_| | .__/   \___| |_|
                                                      |_|

	[ñòèëè imgui]
		1-ûé imgui ñòèëü (ïåðåäåëàí ïîä ëàä mimgui): https://www.blast.hk/threads/25442/post-310168
		2-îé imgui ñòèëü (ïåðåäåëàí ïîä ëàä mimgui): https://www.blast.hk/threads/25442/post-262906
		4-ûé imgui ñòèëü (ïåðåäåëàí ïîä ëàä mimgui): https://www.blast.hk/threads/25442/post-555626

	[áèáëèîòåêè]
		mimgui: https://www.blast.hk/threads/66959/
		SAMP.lua: https://www.blast.hk/threads/14624/
		lfs: https://github.com/keplerproject/luafilesystem
		MoonMonet: https://www.blast.hk/threads/105945/

	[ãàéäû]
		Êàðòèíêè è øðèôò â base85: https://www.blast.hk/threads/28761/ | https://www.blast.hk/threads/28761/post-289682
		Îáíîâëåíèå ñêðèïòà: https://www.blast.hk/threads/30501/

	[ôóíêöèè]
		string.separate: https://www.blast.hk/threads/13380/post-220949
		imgui.BoolButton: https://www.blast.hk/threads/59761/
		imgui.Hint: https://www.blast.hk/threads/13380/post-778921
		imgui.AnimButton (ñëåãêà èçìåí¸í): https://www.blast.hk/threads/13380/post-793501
		getTimeAfter: bank helper
]]

script_name('Med Helper')
script_description('Óäîáíûé ïîìîùíèê äëÿ Áîëüíèöû.')
script_author('EvilDukky')
script_version('1.2')
script_dependencies('mimgui; samp events; lfs; MoonMonet')

require 'moonloader'
local dlstatus					= require 'moonloader'.download_status
local inicfg					= require 'inicfg'
local vkeys						= require 'vkeys'
local bit 						= require 'bit'
local ffi 						= require 'ffi'

local encodingcheck, encoding	= pcall(require, 'encoding')
local imguicheck, imgui			= pcall(require, 'mimgui')
local monetluacheck, monetlua 	= pcall(require, 'MoonMonet')
local lfscheck, lfs 			= pcall(require, 'lfs')
local sampevcheck, sampev		= pcall(require, 'lib.samp.events')

if not imguicheck or not sampevcheck or not encodingcheck or not lfscheck or not monetluacheck or not doesFileExist('moonloader/Med Helper/Images/MedH_Images.png') then
	function main()
		if not isSampLoaded() or not isSampfuncsLoaded() then return end
		while not isSampAvailable() do wait(1000) end

		local MedHfont = renderCreateFont('trebucbd', 11, 9)
		local progressfont = renderCreateFont('trebucbd', 9, 9)
		local downloadingfont = renderCreateFont('trebucbd', 7, 9)

		local progressbar = {
			max = 0,
			downloaded = 0,
			downloadedvisual = 0,
			downloadedclock = 0,
			downloadinglibname = '',
			downloadingtheme = '',
		}

		function bringFloatTo(from, to, start_time, duration)
			local timer = os.clock() - start_time
			if timer >= 0.00 and timer <= duration then
				local count = timer / (duration / 100)
				return from + (count * (to - from) / 100), true
			end
			return (timer > duration) and to or from, false
		end

		function DownloadFiles(table)
			progressbar.max = #table
			progressbar.downloadingtheme = table.theme
			for k = 1, #table do
				progressbar.downloadinglibname = table[k].name
				downloadUrlToFile(table[k].url,table[k].file,function(id,status)
					if status == dlstatus.STATUSEX_ENDDOWNLOAD then
						progressbar.downloaded = k
						progressbar.downloadedclock = os.clock()
						if table[k+1] then
							progressbar.downloadinglibname = table[k+1].name
						end
					end
				end)
				while progressbar.downloaded ~= k do
					wait(500)
				end
			end
			progressbar.max = nil
			progressbar.downloaded = 1
		end
		
		lua_thread.create(function()
			local x = select(1,getScreenResolution()) * 0.5 - 100
			local y = select(2, getScreenResolution()) - 70
			while true do
				if progressbar and progressbar.max ~= nil and progressbar.downloadinglibname and progressbar.downloaded and progressbar.downloadingtheme then
					local jj = (200-10)/progressbar.max
					local downloaded = progressbar.downloadedvisual * jj
					renderDrawBoxWithBorder(x, y-39, 200, 20, 0xFFFF33F2, 1, 0xFF808080)
					renderFontDrawText(MedHfont, 'Med Helper', x+ 5, y - 37, 0xFFFFFFFF)
					renderDrawBoxWithBorder(x, y-20, 200, 70, 0xFF1C1C1C, 1, 0xFF808080)
					renderFontDrawText(progressfont, string.format('Ñêà÷èâàíèå: %s', progressbar.downloadingtheme), x + 5, y - 15, 0xFFFFFFFF)
					renderDrawBox(x + 5, y + 5, downloaded, 20, 0xFF00FF00)
					renderFontDrawText(progressfont, string.format('Progress: %s%%', math.ceil(progressbar.downloadedvisual / progressbar.max * 100), progressbar.max), x + 100 - renderGetFontDrawTextLength(progressfont, string.format('Progress: %s%%', progressbar.downloaded, progressbar.max)) * 0.5, y + 7, 0xFFFFFFFF)
					renderFontDrawText(downloadingfont, string.format('Downloading: \'%s\'', progressbar.downloadinglibname), x + 5, y + 32, 0xFFFFFFFF)
				end
				progressbar.downloadedvisual = bringFloatTo(progressbar.downloaded-1, progressbar.downloaded, progressbar.downloadedclock, 0.2)
				wait(0)
			end
		end)

		sampAddChatMessage(('[MedHelper]{EBEBEB} Íà÷àëîñü ñêà÷èâàíèå íåîáõîäèìûõ ôàéëîâ. Åñëè ñêà÷èâàíèå íå óäàñòñÿ, òî îáðàòèòåñü ê {FF33F2}vk.com/evil.duckky{ebebeb}.'),0xFF33F2)

		if not imguicheck then -- Íàøåë òîëüêî ðåëèçíóþ âåðñèþ â àðõèâå, òàê ÷òî ïðèøëîñü çàëèòü ôàéëû ñþäà, ïðè îáíîâëåíèè áóäó îáíîâëÿòü è ó ñåáÿ
			print('{FFFF00}Ñêà÷èâàíèå: mimgui')
			createDirectory('moonloader/lib/mimgui')
			DownloadFiles({theme = 'mimgui',
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/init.lua', file = 'moonloader/lib/mimgui/init.lua', name = 'init.lua'},
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/imgui.lua', file = 'moonloader/lib/mimgui/imgui.lua', name = 'imgui.lua'},
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/dx9.lua', file = 'moonloader/lib/mimgui/dx9.lua', name = 'dx9.lua'},
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/cimguidx9.dll', file = 'moonloader/lib/mimgui/cimguidx9.dll', name = 'cimguidx9.dll'},
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/cdefs.lua', file = 'moonloader/lib/mimgui/cdefs.lua', name = 'cdefs.lua'},
			})
			print('{00FF00}mimgui óñïåøíî ñêà÷àí')
		end

		if not monetluacheck then
			print('{FFFF00}Ñêà÷èâàíèå: MoonMonet')
			createDirectory('moonloader/lib/MoonMonet')
			DownloadFiles({theme = 'MoonMonet',
				{url = 'https://github.com/Northn/MoonMonet/releases/download/0.1.0/init.lua', file = 'moonloader/lib/MoonMonet/init.lua', name = 'init.lua'},
				{url = 'https://github.com/Northn/MoonMonet/releases/download/0.1.0/moonmonet_rs.dll', file = 'moonloader/lib/MoonMonet/moonmonet_rs.dll', name = 'moonmonet_rs.dll'},
			})
			print('{00FF00}MoonMonet óñïåøíî ñêà÷àí')
		end

		if not sampevcheck then -- C îôôèöèàëüíîãî èñòî÷íèêà
			print('{FFFF00}Ñêà÷èâàíèå: sampev')
			createDirectory('moonloader/lib/samp')
			createDirectory('moonloader/lib/samp/events')
			DownloadFiles({theme = 'samp events',
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events.lua', file = 'moonloader/lib/samp/events.lua', name = 'events.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/raknet.lua', file = 'moonloader/lib/samp/raknet.lua', name = 'raknet.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/synchronization.lua', file = 'moonloader/lib/samp/synchronization.lua', name = 'synchronization.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/bitstream_io.lua', file = 'moonloader/lib/samp/events/bitstream_io.lua', name = 'bitstream_io.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/core.lua', file = 'moonloader/lib/samp/events/core.lua', name = 'core.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/extra_types.lua', file = 'moonloader/lib/samp/events/extra_types.lua', name = 'extra_types.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/handlers.lua', file = 'moonloader/lib/samp/events/handlers.lua', name = 'handlers.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/utils.lua', file = 'moonloader/lib/samp/events/utils.lua', name = 'utils.lua'}
			})
			print('{00FF00}sampev óñïåøíî ñêà÷àí')
		end

		if not encodingcheck then -- Îáíîâëåíèé áûòü íå äîëæíî
			print('{FFFF00}Ñêà÷èâàíèå: encoding')
			DownloadFiles({ theme = 'encoding.lua',
				{url = 'https://raw.githubusercontent.com/Just-Mini/biblioteki/main/encoding.lua', file = 'moonloader/lib/encoding.lua', name = 'encoding.lua'}
			})
			print('{00FF00}encoding óñïåøíî ñêà÷àí')
		end

		if not lfscheck then -- Îáíîâëåíèé áûòü íå äîëæíî
			print('{FFFF00}Ñêà÷èâàíèå: lfs')
			DownloadFiles({theme = 'lfs.dll',
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/lfs.dll', file = 'moonloader/lib/lfs.dll', name = 'lfs.dll'}
			})
			print('{00FF00}lfs óñïåøíî ñêà÷àí')
		end

		if not doesFileExist('moonloader/Med Helper/Images/MedH_Images.png') then
			print('{FFFF00}Ñêà÷èâàíèå: PNG Ôàéëû')
			createDirectory('moonloader/Med Helper')
			createDirectory('moonloader/Med Helper/Images')
			DownloadFiles({theme = 'PNG Ôàéëû',
				{url = 'https://raw.githubusercontent.com/EvilDukky/MedHelper/main/MedH_Images.png', file = 'moonloader/Med Helper/Images/MedH_Images.png', name = 'MedH_Images.png'},
			})
			print('{00FF00}PNG Ôàéëû óñïåøíî ñêà÷àíû')
		end

		print('{FFFF00}Ôàéëû áûëè óñïåøíî ñêà÷àíû, ñêðèïò ïåðåçàãðóæåí.')
		thisScript():reload()
	end
	return
end

local print, clock, sin, cos, floor, ceil, abs, format, gsub, gmatch, find, char, len, upper, lower, sub, u8, new, str, sizeof = print, os.clock, math.sin, math.cos, math.floor, math.ceil, math.abs, string.format, string.gsub, string.gmatch, string.find, string.char, string.len, string.upper, string.lower, string.sub, encoding.UTF8, imgui.new, ffi.string, ffi.sizeof

encoding.default = 'CP1251'

local configuration = inicfg.load({
	main_settings = {
		myrankint = 1,
		gender = 0,
		location = 0,
		style = 1,
		rule_align = 1,
		lection_delay = 10,
		lection_type = 1,
		fmtype = 0,
		playcd = 2000,
		myname = '',
		myaccent = '',
		astag = 'ÌÇ',
		expelreason = 'Í.Ï.Á.',
		usefastmenucmd = 'ashfm',
		createmarker = false,
		dorponcmd = true,
		replacechat = true,
		replaceash = false,
		dofastscreen = true,
		dofastexpel = true,
		noscrollbar = true,
		playdubinka = false,
		changelog = false,
		autoupdate = false,
		getbetaupd = false,
		bodyrank = false,
		chatrank = false,
		autodoor = true,
		usefastmenu = 'E',
		fastscreen = 'F4',
		fastexpel = 'G',
		heal = 10000,
		medcard74 = 1000,
		medcard7 = 30000,
		medcard14 = 50000,
		medcard30 = 70000,
		medcard60 = 100000,
		recept = 10000,
		narko = 6000,
		antibio = 40000,
		korona = 600000,
		str7 = 400000,
		str14 = 800000,
		str21 = 1200000,
		tatu = 50000,
		osm = 1000000,
		RChatColor = 4282626093,
		DChatColor = 4294940723,
		ASChatColor = 4281558783,
		monetstyle = -16729410,
		monetstyle_chroma = 1.0,
	},

	imgui_pos = {
		posX = 100,
		posY = 300
	},

	RankNames = {
		'Èíòåðí',
		'Ôåëüäøåð',
		'Ïîìîùíèê âðà÷à',
		'Äåæóðíûé âðà÷',
		'Ïàðàìåäèê',
		'Ñïåöèàëèñò',
		'Õèðóðã',
		'Çàâåäóþùèé îòäåëåíèåì',
		'Çàìåñòèòåëü Ãëàâíîãî Âðà÷à',
		'Ãëàâíûé Âðà÷',
	},

	Checker = {
    	state = true,
    	delay = 10,
    	afk_max_l = 300,
    	afk_max_h = 300,
    	posX = 200,
    	posY = 400,

    	col_title = 0xFFFF33F2,
    	col_default = 0xFFFFFFFF,
    	col_no_work = 0xFFAA3333,
    	col_afk_max = 0xFFFF0000,
    	col_note = 0xFF909090,

		font_name = 'Arial',
    	font_size = 9,
    	font_flag = 5,
    	font_offset = 14,
    	font_alpha = 255,

    	show_id = true,
    	show_rank = true,
    	show_afk = true,
    	show_warn = false,
    	show_mute = false,
    	show_uniform = true,
    	show_near = false,

		[1] = true, [6] = true,
    	[2] = true, [7] = true,
    	[3] = true, [8] = true,
    	[4] = true, [9] = true,
    	[5] = true, [10] = true,
	},
	Checker_Notes = {},
	
	sobes_settings = {
		pass = true,
		medcard = true,
		wbook = false,
		licenses = false,
	},

	med_settings = {
		pass = true,
	},

	BindsName = {},
	BindsDelay = {},
	BindsType = {},
	BindsAction = {},
	BindsCmd = {},
	BindsKeys = {}
}, 'Med Helper')

-- icon fonts
	local fa = {
		['ICON_FA_FILE_ALT'] = '\xee\x80\x80',
		['ICON_FA_PALETTE'] = '\xee\x80\x81',
		['ICON_FA_TIMES'] = '\xee\x80\x82',
		['ICON_FA_QUESTION_CIRCLE'] = '\xee\x80\x83',
		['ICON_FA_BOOK_OPEN'] = '\xee\x80\x84',
		['ICON_FA_INFO_CIRCLE'] = '\xee\x80\x85',
		['ICON_FA_SEARCH'] = '\xee\x80\x86',
		['ICON_FA_ALIGN_LEFT'] = '\xee\x80\x87',
		['ICON_FA_ALIGN_CENTER'] = '\xee\x80\x88',
		['ICON_FA_ALIGN_RIGHT'] = '\xee\x80\x89',
		['ICON_FA_TRASH'] = '\xee\x80\x8a',
		['ICON_FA_REDO_ALT'] = '\xee\x80\x8b',
		['ICON_FA_HAND_PAPER'] = '\xee\x80\x8c',
		['ICON_FA_FILE_SIGNATURE'] = '\xee\x80\x8d',
		['ICON_FA_REPLY'] = '\xee\x80\x8e',
		['ICON_FA_USER_PLUS'] = '\xee\x80\x8f',
		['ICON_FA_USER_MINUS'] = '\xee\x80\x90',
		['ICON_FA_EXCHANGE_ALT'] = '\xee\x80\x91',
		['ICON_FA_USER_SLASH'] = '\xee\x80\x92',
		['ICON_FA_USER'] = '\xee\x80\x93',
		['ICON_FA_FROWN'] = '\xee\x80\x94',
		['ICON_FA_SMILE'] = '\xee\x80\x95',
		['ICON_FA_VOLUME_MUTE'] = '\xee\x80\x96',
		['ICON_FA_VOLUME_UP'] = '\xee\x80\x97',
		['ICON_FA_STAMP'] = '\xee\x80\x98',
		['ICON_FA_ELLIPSIS_V'] = '\xee\x80\x99',
		['ICON_FA_ARROW_UP'] = '\xee\x80\x9a',
		['ICON_FA_ARROW_DOWN'] = '\xee\x80\x9b',
		['ICON_FA_ARROW_RIGHT'] = '\xee\x80\x9c',
		['ICON_FA_CODE'] = '\xee\x80\x9d',
		['ICON_FA_ARROW_ALT_CIRCLE_DOWN'] = '\xee\x80\x9e',
		['ICON_FA_LINK'] = '\xee\x80\x9f',
		['ICON_FA_CAR'] = '\xee\x80\xa0',
		['ICON_FA_MOTORCYCLE'] = '\xee\x80\xa1',
		['ICON_FA_FISH'] = '\xee\x80\xa2',
		['ICON_FA_SHIP'] = '\xee\x80\xa3',
		['ICON_FA_CROSSHAIRS'] = '\xee\x80\xa4',
		['ICON_FA_SKULL_CROSSBONES'] = '\xee\x80\xa5',
		['ICON_FA_DIGGING'] = '\xee\x80\xa6',
		['ICON_FA_PLUS_CIRCLE'] = '\xee\x80\xa7',
		['ICON_FA_PAUSE'] = '\xee\x80\xa8',
		['ICON_FA_PEN'] = '\xee\x80\xa9',
		['ICON_FA_MINUS_SQUARE'] = '\xee\x80\xaa',
		['ICON_FA_CLOCK'] = '\xee\x80\xab',
		['ICON_FA_COG'] = '\xee\x80\xac',
		['ICON_FA_TAXI'] = '\xee\x80\xad',
		['ICON_FA_FOLDER'] = '\xee\x80\xae',
		['ICON_FA_CHEVRON_LEFT'] = '\xee\x80\xaf',
		['ICON_FA_CHEVRON_RIGHT'] = '\xee\x80\xb0',
		['ICON_FA_CHECK_CIRCLE'] = '\xee\x80\xb1',
		['ICON_FA_EXCLAMATION_CIRCLE'] = '\xee\x80\xb2',
		['ICON_FA_AT'] = '\xee\x80\xb3',
		['ICON_FA_HEADING'] = '\xee\x80\xb4',
		['ICON_FA_WINDOW_RESTORE'] = '\xee\x80\xb5',
		['ICON_FA_TOOLS'] = '\xee\x80\xb6',
		['ICON_FA_GEM'] = '\xee\x80\xb7',
		['ICON_FA_ARROWS_ALT'] = '\xee\x80\xb8',
		['ICON_FA_QUOTE_RIGHT'] = '\xee\x80\xb9',
		['ICON_FA_CHECK'] = '\xee\x80\xba',
		['ICON_FA_LIGHT_COG'] = '\xee\x80\xbb',
		['ICON_FA_LIGHT_INFO_CIRCLE'] = '\xee\x80\xbc',
		['ICON_FA_DESKTOP'] = '\xee\x80\xbd',
		['ICON_FA_TIMES_CIRCLE'] = '\xee\x80\xbe',
	}

	setmetatable(fa, {
		__call = function(t, v)
			if (type(v) == 'string') then
				return t['ICON_' .. upper(v)] or '?'
			elseif (type(v) == 'number' and v >= fa.min_range and v <= fa.max_range) then
				local t, h = {}, 128
				while v >= h do
					t[#t + 1] = 128 + v % 64
					v = floor(v / 64)
					h = h > 32 and 32 or h * 0.5
				end
				t[#t + 1] = 256 - 2 * h + v
				return char(unpack(t)):reverse()
			end
			return '?'
		end,

		__index = function(t, i)
			if type(i) == 'string' then
				if i == 'min_range' then
					return 0xe000
				elseif i == 'max_range' then
					return 0xe03e
				end
			end
		
			return t[i]
		end
	})
-- icon fonts

function imgui.ColorConvertFloat4ToARGB(float4)
	local abgr = imgui.ColorConvertFloat4ToU32(float4)
	local a, b, g, r = explode_U32(abgr)
	return join_argb(a, r, g, b)
end

function changeColorAlpha(argb, alpha)
	local _, r, g, b = explode_U32(argb)
	return join_argb(alpha, r, g, b)
end

function explode_U32(u32)
	local a = bit.band(bit.rshift(u32, 24), 0xFF)
	local r = bit.band(bit.rshift(u32, 16), 0xFF)
	local g = bit.band(bit.rshift(u32, 8), 0xFF)
	local b = bit.band(u32, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8)) 
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end

function vec4ToFloat4(vec4, type)
	type = type or 1
	if type == 1 then
		return new.float[4](vec4.x, vec4.y, vec4.z, vec4.w)
	else
		return new.float[4](vec4.z, vec4.y, vec4.x, vec4.w)
	end
end

function ARGBtoStringRGB(abgr)
	local a, r, g, b = explode_U32(abgr)
	local argb = join_argb(a, r, g, b)
	local color = ('%x'):format(bit.band(argb, 0xFFFFFF))
	return ('{%s%s}'):format(('0'):rep(6 - #color), color)
end

function ColorAccentsAdapter(color)
	local function ARGBtoRGB(color)
		return bit.band(color, 0xFFFFFF)
	end
	local a, r, g, b = explode_argb(color)

	local ret = {a = a, r = r, g = g, b = b}

	function ret:apply_alpha(alpha)
		self.a = alpha
		return self
	end

	function ret:as_u32()
		return join_argb(self.a, self.b, self.g, self.r)
	end

	function ret:as_vec4()
		return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
	end

	function ret:as_argb()
		return join_argb(self.a, self.r, self.g, self.b)
	end

	function ret:as_rgba()
		return join_argb(self.r, self.g, self.b, self.a)
	end

	function ret:as_chat()
		return format('%06X', ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)))
	end

	return ret
end

local ScreenSizeX, ScreenSizeY			= getScreenResolution()
local alphaAnimTime					= 0.3
local getmyrank						= false
local windowtype						= new.int(0)
local sobesetap						= new.int(0)
local medtap						= new.int(0)
local osmtap						= new.int(0)
local rectap						= new.int(0)
local narkotap						= new.int(0)
local koronatap						= new.int(0)
local strtap						= new.int(0)
local tatutap						= new.int(0)
local osmotrtap						= new.int(0)
local psihtap						= new.int(0)
local lastsobesetap					= new.int(0)
local lastmedtap						= new.int(0)
local medtimeid						= new.int(0)
local newwindowtype					= new.int(1)
local clienttype						= new.int(0)
local leadertype						= new.int(0)
local Licenses_select					= new.int(0)
local QuestionType_select				= new.int(0)
local Ranks_select					= new.int(0)
local sobesdecline_select				= new.int(0)
local uninvitebuf						= new.char[256]()
local blacklistbuf					= new.char[256]()
local uninvitebox						= new.bool(false)
local blacklistbuff					= new.char[256]()
local fwarnbuff						= new.char[256]()
local fmutebuff						= new.char[256]()
local fmuteint						= new.int(0)
local lastq							= new.int(0)
local autoupd						= new.int(-600)
local now_zametka						= new.int(1)
local zametka_window					= new.int(1)
local search_rule						= new.char[256]()
local rule_align						= new.int(configuration.main_settings.rule_align)
local auto_update_box					= new.bool(configuration.main_settings.autoupdate)
local get_beta_upd_box					= new.bool(configuration.main_settings.getbetaupd)
local lections						= {}
local questions						= {}
local serverquestions					= {}
local ruless						= {}
local zametki						= {}
local dephistory						= {}
local updateinfo						= {}
local LastActiveTime					= {}
local LastActive						= {}
local notf_sX, notf_sY					= convertGameScreenCoordsToWindowScreenCoords(605, 438)
local notify						= {
	msg = {},
	pos = {x = notf_sX - 200, y = notf_sY - 70}
}
notf_sX, notf_sY = nil, nil

local mainwindow						= new.int(0)
local settingswindow					= new.int(1)
local additionalwindow					= new.int(1)
local infowindow						= new.int(1)
local monetstylechromaselect				= new.float[1](configuration.main_settings.monetstyle_chroma)
local alpha							= new.float[1](0)

local windows = {
	imgui_settings 					= new.bool(),
	imgui_fm 						= new.bool(),
	imgui_binder 					= new.bool(),
	imgui_lect						= new.bool(),
	imgui_depart					= new.bool(),
	imgui_changelog					= new.bool(configuration.main_settings.changelog),
	imgui_zametka					= new.bool(false),
}
local bindersettings = {
	binderbuff 						= new.char[4096](),
	bindername 						= new.char[40](),
	binderdelay 					= new.char[7](),
	bindertype 						= new.int(0),
	bindercmd 						= new.char[15](),
	binderbtn						= '',
}
local chatcolors = {
	RChatColor 						= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.RChatColor)),
	DChatColor 						= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.DChatColor)),
	ASChatColor 					= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor)),
}
local usersettings = {
	createmarker 					= new.bool(configuration.main_settings.createmarker),
	dorponcmd						= new.bool(configuration.main_settings.dorponcmd),
	replacechat						= new.bool(configuration.main_settings.replacechat),
	replaceash						= new.bool(configuration.main_settings.replaceash),
	dofastscreen					= new.bool(configuration.main_settings.dofastscreen),
	dofastexpel						= new.bool(configuration.main_settings.dofastexpel),
	noscrollbar						= new.bool(configuration.main_settings.noscrollbar),
	playdubinka						= new.bool(configuration.main_settings.playdubinka),
	bodyrank						= new.bool(configuration.main_settings.bodyrank),
	chatrank						= new.bool(configuration.main_settings.chatrank),
	autodoor						= new.bool(configuration.main_settings.autodoor),
	playcd						= new.float[1](configuration.main_settings.playcd / 1000),
	myname 						= new.char[256](configuration.main_settings.myname),
	myaccent 						= new.char[256](configuration.main_settings.myaccent),
	gender 						= new.int(configuration.main_settings.gender),
	location 						= new.int(configuration.main_settings.location),
	fmtype						= new.int(configuration.main_settings.fmtype),
	expelreason						= new.char[256](u8(configuration.main_settings.expelreason)),
	usefastmenucmd					= new.char[256](u8(configuration.main_settings.usefastmenucmd)),
	moonmonetcolorselect				= vec4ToFloat4(ColorAccentsAdapter(configuration.main_settings.monetstyle):as_vec4()),
}
local pricelist = {
	heal							= new.char[7](tostring(configuration.main_settings.heal)),
	medcard74						= new.char[7](tostring(configuration.main_settings.medcard74)),	
	medcard7						= new.char[7](tostring(configuration.main_settings.medcard7)),
	medcard14						= new.char[7](tostring(configuration.main_settings.medcard14)),
	medcard30						= new.char[7](tostring(configuration.main_settings.medcard30)),
	medcard60						= new.char[7](tostring(configuration.main_settings.medcard60)),
	recept							= new.char[7](tostring(configuration.main_settings.recept)),
	narko							= new.char[7](tostring(configuration.main_settings.narko)),
	korona							= new.char[8](tostring(configuration.main_settings.korona)),
	str7							= new.char[8](tostring(configuration.main_settings.str7)),
	str14							= new.char[8](tostring(configuration.main_settings.str14)),
	str21							= new.char[8](tostring(configuration.main_settings.str21)),
	tatu							= new.char[7](tostring(configuration.main_settings.tatu)),
	osm								= new.char[8](tostring(configuration.main_settings.osm)),
	antibio							= new.char[7](tostring(configuration.main_settings.antibio)),
}
local tHotKeyData = {
	edit 							= nil,
	save 							= {},
	lasted 						= clock(),
}
local lectionsettings = {
	lection_type					= new.int(configuration.main_settings.lection_type),
	lection_delay					= new.int(configuration.main_settings.lection_delay),
	lection_name					= new.char[256](),
	lection_text					= new.char[65536](),
}
local zametkisettings = {
	zametkaname						= new.char[256](),
	zametkatext						= new.char[4096](),
	zametkacmd						= new.char[256](),
	zametkabtn						= '',
}
local departsettings = {
	myorgname						= new.char[50](u8(configuration.main_settings.astag)),
	toorgname						= new.char[50](),
	frequency						= new.char[7](),
	myorgtext						= new.char[256](),
}
local questionsettings = {
	questionname					= new.char[256](),
	questionhint					= new.char[256](),
	questionques					= new.char[256](),
}
local sobes_settings = {
	pass							= new.bool(configuration.sobes_settings.pass),
	medcard						= new.bool(configuration.sobes_settings.medcard),
	wbook							= new.bool(configuration.sobes_settings.wbook),
	licenses						= new.bool(configuration.sobes_settings.licenses),
}
local med_settings = {
	pass							= new.bool(configuration.med_settings.pass),
}
local tagbuttons = {
	{name = '{my_id}',text = 'Ïèøåò Âàø ID.',hint = '/n /showpass {my_id}\n(( /showpass \'Âàø ID\' ))'},
	{name = '{my_name}',text = 'Ïèøåò Âàø íèê èç íàñòðîåê.',hint = 'Çäðàâñòâóéòå, ÿ {my_name}\n- Çäðàâñòâóéòå, ÿ Âàøå èìÿ.'},
	{name = '{my_rank}',text = 'Ïèøåò Âàø ðàíã èç íàñòðîåê.',hint = format('/do Íà ãðóäè áåéäæèê {my_rank}\nÍà ãðóäè áåéäæèê %s', configuration.RankNames[configuration.main_settings.myrankint])},
	{name = '{my_score}',text = 'Ïèøåò Âàø óðîâåíü.',hint = 'ß ïðîæèâàþ â øòàòå óæå {my_score} ëåò!\n- ß ïðîæèâàþ â øòàòå óæå \'Âàø óðîâåíü\' ëåò!'},
	{name = '{H}',text = 'Ïèøåò ñèñòåìíîå âðåìÿ â ÷àñû.',hint = 'Äàâàé âñòðåòèìñÿ çàâòðà òóò æå â {H} \n- Äàâàé âñòðåòèìñÿ çàâòðà òóò æå â ÷÷'},
	{name = '{HM}',text = 'Ïèøåò ñèñòåìíîå âðåìÿ â ÷àñû:ìèíóòû.',hint = 'Ñåãîäíÿ â {HM} áóäåò êîíöåðò!\n- Ñåãîäíÿ â ÷÷:ìì áóäåò êîíöåðò!'},
	{name = '{HMS}',text = 'Ïèøåò ñèñòåìíîå âðåìÿ â ÷àñû:ìèíóòû:ñåêóíäû.',hint = 'Ó ìåíÿ íà ÷àñàõ {HMS}\n- Ó ìåíÿ íà ÷àñàõ \'÷÷:ìì:ññ\''},
	{name = '{gender:Òåêñò1|Òåêñò2}',text = 'Ïèøåò ñîîáùåíèå â çàâèñèìîñòè îò âàøåãî ïîëà.',hint = 'ß â÷åðà {gender:áûë|áûëà} â áàíêå\n- Åñëè ìóæñêîé ïîë: áûë â áàíêå\n- Åñëè æåíñêèé ïîë: áûëà â áàíêå'},
	{name = '{location:Òåêñò1|Òåêñò2|Òåêñò3|Òåêñò4}',text = 'Ïèøåò ñîîáùåíèå â çàâèñèìîñòè îò âàøåé áîëüíèöû.',hint = 'ß â áîëüíèöå {ËÑ|ÑÔ|ËÂ|ÄÔ}\n- Åñëè áîëüíèöà ËÑ: ß â áîëüíèöå ËÑ\n- Åñëè áîëüíèöà ÑÔ: ß â áîëüíèöå ÑÔ\n- Åñëè áîëüíèöà ËÂ: ß â áîëüíèöå ËÂ\n- Åñëè áîëüíèöà ÄÔ: ß â áîëüíèöå ÄÔ'},
	{name = '@{ID}',text = 'Óçíà¸ò èìÿ èãðîêà ïî ID.',hint = 'Òû íå âèäåë ãäå ñåé÷àñ @{43}?\n- Òû íå âèäåë ãäå ñåé÷àñ \'Èìÿ 43 èäà\''},
	{name = '{close_id}',text = 'Óçíà¸ò ID áëèæàéøåãî ê Âàì èãðîêà',hint = 'Î, à âîò è @{{close_id}}?\nÎ, à âîò è \'Èìÿ áëèæàéøåãî èäà\''},
	{name = '{delay_*}',text = 'Äîáàâëÿåò çàäåðæêó ìåæäó ñîîáùåíèÿìè',hint = 'Äîáðûé äåíü, ÿ ñîòðóäíèê äàííîé áîëüíèöû, ÷åì ìîãó Âàì ïîìî÷ü?\n{delay_2000}\n/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ ðàáîòíèê áîëüíèöû.\n\n[10:54:29] Äîáðûé äåíü, ÿ ñîòðóäíèê äàííîé áîëüíèöû, ÷åì ìîãó Âàì ïîìî÷ü?\n[10:54:31] Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ ðàáîòíèê áîëüíèöû.'},
}
local buttons = {
	{name='Íàñòðîéêè',text='Ïîëüçîâàòåëü, âèä\nñêðèïòà, öåíû',icon=fa.ICON_FA_LIGHT_COG,y_hovered=10,timer=0},
	{name='Äîïîëíèòåëüíî',text='Ïðàâèëà, çàìåòêè,\nîòûãðîâêè, ÷åêåð',icon=fa.ICON_FA_FOLDER,y_hovered=10,timer=0},
	{name='Èíôîðìàöèÿ',text='Îáíîâëåíèÿ, àâòîð,\nî ñêðèïòå',icon=fa.ICON_FA_LIGHT_INFO_CIRCLE,y_hovered=10,timer=0},
}
local fmbuttons = {
	{name = u8'Ëå÷åíèå', rank = 1},
	{name = u8'Ìåä.êàðòà', rank = 1},
	{name = u8'Ìåä.îñìîòð', rank = 1},
	{name = u8'Ðåöåïò', rank = 1},
	{name = u8'Íàðêîçàâèñèìîñòü', rank = 1},
	{name = u8'Ñòðàõîâêà', rank = 1},
	{name = u8'Âûâåäåíèå òàòó', rank = 1},
	{name = u8'Îñìîòð', rank = 1},
	{name = u8'Ïñèõîëîãè÷åñêèé îñìîòð', rank = 1},
	{name = u8'Ñîáåñåäîâàíèå', rank = 5},
	{name = u8'Ïðîâåðêà óñòàâà', rank = 5},
	{name = u8'Ëèäåðñêèå äåéñòâèÿ', rank = 9},
}
local settingsbuttons = {
	fa.ICON_FA_USER..u8(' Ïîëüçîâàòåëü'),
	fa.ICON_FA_PALETTE..u8(' Âèä ñêðèïòà'),
	fa.ICON_FA_FILE_ALT..u8(' Öåíû'),
}
local additionalbuttons = {
	fa.ICON_FA_BOOK_OPEN..u8(' Ïðàâèëà'),
	fa.ICON_FA_QUOTE_RIGHT..u8(' Çàìåòêè'),
	fa.ICON_FA_HEADING..u8(' Îòûãðîâêè'),
	fa.ICON_FA_DESKTOP..u8(' ×åêåð'),
}
local infobuttons = {
	fa.ICON_FA_ARROW_ALT_CIRCLE_DOWN..u8(' Îáíîâëåíèÿ'),
	fa.ICON_FA_AT..u8(' Àâòîð'),
	fa.ICON_FA_CODE..u8(' Î ñêðèïòå'),
}
local checker_variables = {
	state = imgui.new.bool(configuration.Checker.state),
	delay = imgui.new.int(configuration.Checker.delay),
	note_input = imgui.new.char[256](),

	font_input = imgui.new.char[256](u8(configuration.Checker.font_name)),
	font_size = imgui.new.int(configuration.Checker.font_size),
	font_flag = imgui.new.int(configuration.Checker.font_flag),
	font_offset = imgui.new.int(configuration.Checker.font_offset),
	font_alpha = imgui.new.int(configuration.Checker.font_alpha / 2.55),

	afk_max_l = imgui.new.int(configuration.Checker.afk_max_l),
	afk_max_h = imgui.new.int(configuration.Checker.afk_max_h),

	show = {
		id = imgui.new.bool(configuration.Checker.show_id),
		rank = imgui.new.bool(configuration.Checker.show_rank),
		afk = imgui.new.bool(configuration.Checker.show_afk),
		warn = imgui.new.bool(configuration.Checker.show_warn),
		mute = imgui.new.bool(configuration.Checker.show_mute),
		uniform = imgui.new.bool(configuration.Checker.show_uniform),
		near = imgui.new.bool(configuration.Checker.show_near),
	},

	col = {
		title = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_title), 2),
		default = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_default), 2),
		no_work = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_no_work), 2),
		afk_max = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_afk_max), 2),
		note = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_note), 2),
	},

	online = {afk = 0, online = 0},
	bodyranks = {},

	await = {
		members = false,
		next_page = {
			bool = false,
			i = 0
		}
	},

	temp_player_data = nil,
	last_check = 0,
	dontShowMeMembers = false,
	lastDialogWasActive = clock(),
	font = renderCreateFont(configuration.Checker.font_name, configuration.Checker.font_size, configuration.Checker.font_flag)
}

local medh_image
local font = {}

imgui.OnInitialize(function()
	-- >> BASE85 DATA <<
		local circle_data = '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x30\x00\x00\x00\x30\x08\x06\x00\x00\x00\x57\x02\xF9\x87\x00\x00\x00\x06\x62\x4B\x47\x44\x00\xFF\x00\xFF\x00\xFF\xA0\xBD\xA7\x93\x00\x00\x09\xC8\x49\x44\x41\x54\x68\x81\xED\x99\x4B\x6C\x5C\xE7\x75\xC7\x7F\xE7\x7C\x77\x5E\xE4\x50\x24\x25\xCA\x7A\x90\xB4\x4D\xD3\x92\x9C\xBA\x8E\x8B\x48\xB2\xA4\xB4\x40\xEC\x04\x79\xD4\x81\xD1\x64\x93\x3E\x9C\x45\xBC\x71\x1D\xD7\x06\x8A\xAE\x5A\x20\x0B\x25\x6D\x36\x45\xBB\x69\xA5\xB4\x46\x90\x02\x2E\xEC\x3E\x50\x20\xC9\xA6\x8B\x3A\x80\xA3\x45\x92\x56\xAA\x92\x58\x71\x6D\x90\x52\x6C\xD9\xA2\x45\x51\xA2\x24\x4A\x7C\x0D\xE7\xF1\x9D\xD3\xC5\xCC\x90\x33\x73\x47\x7C\xA4\x41\xBB\xA8\x0E\xF0\xE1\xBB\x73\xEE\xBD\xDF\xFD\xFD\xBF\x73\xBE\xC7\xBD\x03\x77\xED\xAE\xFD\xFF\x36\xF9\x65\x34\xE2\x1C\xD7\x89\x47\x26\x8F\x54\xA9\x7D\xCC\x6B\x7E\x38\xE2\xFB\xDC\x6C\xC4\xCC\xB6\xED\x1B\x75\x73\xF3\x45\xDC\xA7\xCD\x6D\x52\x22\x67\x1D\xFF\xFE\xF6\x1F\x1E\x39\x23\x1C\xB7\xFF\x53\x01\x17\x8E\x3C\x3D\xE2\x15\x79\xC1\x2C\x3E\x6D\xEE\x23\xD1\x0C\x33\xC3\xDC\x30\x73\xCC\x8C\x07\x87\x0D\xDC\x71\x37\x30\xC7\xAD\x59\xFB\x07\xE6\xF1\x95\xA0\x76\x72\xC7\xE9\x53\x1F\xFC\xAF\x0A\x98\x3E\xF8\xEC\x50\x49\x2A\x7F\xE6\x1E\x9F\x31\xB3\x6C\x1D\xDA\xE9\x2A\x60\x6F\xEC\x02\x6F\xAB\x3E\x33\xAB\xA8\xD9\xDF\x95\xCB\xE5\xAF\x8C\x4C\x9C\xB9\xB1\x55\x16\xDD\xEA\x0D\x97\x8E\x3D\xF3\xBB\x95\x50\x9D\x14\xFC\xF7\x81\xEC\x46\xD7\xAF\x07\xEF\x66\x88\x59\xD6\xCC\x9F\xCB\x84\x64\x72\xE6\x43\x47\x7E\x67\xAB\x3C\x9B\x8E\x80\x1F\x7C\x36\x73\x39\x6B\x27\xCC\xED\xD9\x66\xEF\xD6\x7B\xBA\xD9\xEB\xDD\x23\x30\xBE\xAB\x72\x47\x78\xCC\x70\xF3\x46\x6D\xB8\x3B\x78\xFC\xDB\xDD\x7B\x8A\x2F\xCA\xA9\x53\xB5\xCD\x70\x6D\x2A\x02\xDF\x7F\xF8\x64\xF1\x52\x2E\xF9\x37\xE0\xD9\xCD\x0A\x5E\x15\xBE\x15\x78\x33\x3C\xF2\xDC\x95\x4B\xF3\xDF\xBD\xF6\xFC\xCE\xE2\x66\xDA\xDF\x30\x02\x2F\x1D\x3C\x9B\x59\x9C\xBB\xFD\xDD\x87\x7A\xDF\x7E\xF2\xD1\xE2\xB9\xB6\xDE\x6D\x8F\x00\x50\xC8\xA2\xFD\x45\xA4\x58\x80\x44\x21\x97\xB0\x77\xD0\xF0\x95\x32\x56\x2E\x63\xB7\xE7\x89\xD7\x6F\xE2\x0B\x0B\xDD\xE1\x1B\xBE\xFC\x93\xD3\xE4\x3F\x31\x7B\xAA\x30\x10\x3F\x29\x4F\xB0\x6E\x24\x92\x8D\x04\x54\x16\x4A\x27\x42\x08\x4F\x4E\x2C\xFD\x0A\xE6\xCE\xA3\xC5\x37\x52\x7D\x90\x0C\xF6\x91\x1D\xDE\x05\x85\xEC\x5A\x1A\x35\x04\xA2\x02\xF9\x2C\x9A\xCD\x20\xBD\x3D\xE8\xEE\x7B\xF0\xE5\x12\xB5\xF7\xA6\x88\xB3\xD7\xD3\xF0\xBF\x39\x4D\xCF\x93\x33\x00\x8F\x97\x97\x39\x01\x3C\xB7\x1E\xDF\xBA\x11\x78\xE9\x91\xD3\xBF\x57\x8B\xF1\xD5\x18\x23\x66\x91\x18\x23\xFB\x0A\xFF\xC5\x87\x7B\xDF\xC0\xCC\x20\x9B\x90\x1F\x1F\x81\x9E\x5C\x3D\x2A\x6E\x29\x01\x7B\x06\x6B\x6B\x29\x64\x8D\x29\xB5\x91\x42\x36\xBF\x40\x75\xE2\xE7\x58\x69\xA5\x0E\xFF\x99\x69\x0A\x75\xF8\x56\xC2\xA7\x0B\x9F\xE5\x1F\xB6\x2C\xE0\xE5\xC7\x4E\xEF\x58\x59\x96\x09\xC7\x87\x62\x03\x7E\x55\x44\xFE\x4D\x7E\x6D\xD7\x24\xF9\x7D\xA3\x78\xD0\x06\xF4\x1D\x04\xF4\x57\xBB\xC2\x37\x7B\xDC\x2A\x15\xAA\x13\x17\xC8\x1E\x9D\xA4\xF0\x99\x99\x34\x88\x70\xB3\x26\x1C\xD8\xF6\x14\xD7\xBB\x71\xDE\x71\x10\x57\xAB\xC9\xD7\x35\xE8\x90\x88\x10\x34\x10\x42\x40\x1B\xF5\x54\xF6\x23\xCC\xDC\xFB\x38\x92\xD9\x30\x03\xD7\x85\x77\x33\x44\x95\xE2\x33\x03\xF4\x3C\xB5\x02\x46\xBA\x44\xB6\x67\x6A\x7C\xED\x4E\xED\x77\x8D\xC0\x37\x3F\x7C\x6E\x24\x04\x7B\xC7\xDC\xB2\xEE\xF5\x01\xEB\xEE\x44\x8B\x48\x02\xF7\x3C\x5C\xC4\x83\x31\x9A\x79\x87\xB1\xFC\x85\x75\x23\xB0\xAB\xB7\x74\x47\x78\xCC\xC8\x1E\xBE\x4E\xF6\xE8\x4D\xDC\xAA\xC4\xAB\x3F\x81\x58\xEA\xDA\x9F\x92\x30\xDE\xF3\x39\xA6\x3A\x4F\x74\xED\xC2\x24\xE3\x2F\xE0\x92\x55\x14\xC3\x50\x55\xCC\x8C\xA0\x81\xA1\x87\x7A\xC9\xE4\x95\x18\x23\x53\xD5\x71\xDC\x9D\xFB\x72\xE7\x57\xEF\xD5\x42\x8E\xEC\xD0\x20\x5A\xEC\xC1\x73\x09\xB9\xDE\x88\x95\x56\xB0\xB9\x39\x6A\x33\xD7\x60\x71\x69\x0D\xFE\xD0\x75\xB2\x8F\xDD\x04\x03\x21\x43\x18\xFC\x10\xF1\xDA\x4F\xBA\x21\x65\xA8\xF0\x3C\xF0\x27\x1B\x46\xE0\x38\xAE\xF7\x1F\xFC\xD9\xFB\xC0\x88\xBB\xE3\x5E\xEF\x59\x77\x27\x37\x98\xB0\x63\xBC\xA7\x3E\x7D\xBA\x11\x63\x24\x5A\x64\x6F\xF8\x39\xF7\xE7\xCF\x93\xBD\x77\x17\x61\x68\x70\x35\x0A\xD1\x8C\xC1\xDE\xB8\xD6\xFB\x31\x52\x9B\xBE\x4A\xED\xE2\xFB\x64\x3E\x72\x8D\xEC\xE1\x9B\x29\x52\xBB\xF1\x16\xB6\x32\xDB\x4D\xC4\x54\xEF\x04\xF7\xCB\x71\xDA\x36\x80\xA9\x08\x8C\x3D\xF6\xE6\x11\x4C\x46\xDC\x1D\x91\xBA\xBE\x66\x24\xB6\x8F\xF6\x20\x2A\xA8\x35\x86\x4E\xA8\x57\x57\xFC\x41\xB6\x8F\xDD\xC3\xDE\xA1\x39\x62\x8C\x6D\xED\xAD\xA5\x4E\xBD\x13\x74\xD7\x10\x85\x47\x97\x91\x9D\x93\x78\xB7\xBD\x68\xDF\x18\x2C\x75\x15\x30\x5A\xDA\xC7\x21\xE0\x4C\xAB\x33\x3D\x88\xCD\x9F\x00\x56\xE1\x45\x04\x11\x21\x57\xCC\x90\x14\x02\x2A\x5A\x17\x21\x8A\x8A\x12\x42\x60\x68\x6C\x1B\x8B\x7D\x63\x5C\xAD\xEE\x49\x3F\xB6\x09\xDF\x28\xC9\x03\xF3\x64\x1E\x09\x84\xBE\x07\x21\x92\x2A\x22\x3D\x78\xE8\xC3\x8D\x54\xA9\x19\x1F\xEB\x6C\x3E\x2D\xC0\xF5\x50\xF3\xB0\x55\x44\x61\x7B\x06\x9A\x11\x69\x11\x91\xEB\xC9\xD0\xBF\xBB\x80\xAA\x72\xDB\xF6\x30\x5B\xDB\xDB\xDE\x5C\x2B\xFC\xD8\x3C\xC9\xD8\x42\x3D\xE7\xF3\xC3\x10\x8A\x5D\x41\x25\xB7\xA3\xAB\x1F\xE3\xB1\x8D\x05\x88\xEF\x6F\x1D\x1A\x4D\x11\xB9\x62\x68\x3A\xDA\x44\x14\x77\xE5\xD6\x22\xA2\xCA\x3C\xC3\xDC\x88\xC3\x29\x01\xE1\xBE\x79\xC2\x7D\x0B\x78\xA4\x5E\x0C\x24\xBF\xBB\x7B\x14\xC2\x40\x57\x3F\x91\x7D\x9D\xB8\xA9\x31\x20\x22\x7B\xDC\xA1\x2E\xC2\x57\x45\x68\x56\xD7\x3C\x22\xE0\x8E\x8A\x52\x18\xC8\x00\x82\x48\x7D\xAC\xA0\xB0\x60\x23\xB8\x3B\xFD\x5C\xAA\xC3\xDF\x3B\x4F\xB8\xB7\x0E\xDF\xFE\xF4\xED\x5D\xC7\x81\x4B\xB6\xFB\xF8\x80\xE1\x4E\x47\x4A\x80\x09\xFD\x0A\xA4\x44\xE4\x02\xE0\x29\x11\x92\xD3\xC6\x61\xBB\x88\x45\x1B\xC5\x3D\x32\x30\x7A\x86\x30\x5A\x4F\x9B\xB4\xE5\xD2\xA2\x1A\xFE\xEE\xD7\xD3\xB7\xA1\x80\x17\x46\x66\x22\xAB\xF3\xCB\x9A\x7D\x74\xA8\x42\xE8\xB2\x6E\xFF\x7A\xBF\x74\xF5\x03\xD0\x3F\xCE\x6F\x3C\xF0\x2E\xC7\x0A\x09\x1A\x72\x48\xC8\x81\x34\x9B\x16\x70\x23\xB7\xA3\x65\xE1\x6A\xA4\x27\x6E\x30\x5E\xE8\x98\xE4\x05\xDC\x03\xBC\xB6\xBE\x00\x11\x16\x81\xED\x9D\xFE\x9A\x19\x99\x24\xA5\x8B\x4A\x34\x7A\xBB\xF8\xBD\x2F\x8F\x0C\xE4\xF9\x69\x65\x27\x88\x70\x2C\x3F\x87\x42\x8B\x08\x07\x2B\x77\xDC\xE4\x0D\x11\xD5\xC6\x6F\x5A\x44\x38\x88\xDC\xEA\x7C\x4E\x4A\x80\xAA\x4E\xE3\x9E\x16\x10\x1D\xD5\xF4\xCE\x63\x71\x39\xD2\xDF\x93\x69\xF3\xC5\x62\x16\xB6\xE5\x91\xC6\xF5\x6F\x54\xEF\x41\x44\x38\x9A\xBB\xD9\x2E\xA2\x36\x87\x7B\x0D\x91\x16\x0C\x77\xB0\xEA\x1A\x7D\xBB\x88\x2B\x29\xDE\x4E\x47\x40\xCE\xAB\xD6\x67\x94\xD6\x32\x5F\xB2\x94\x4F\x55\xB9\x32\x57\x21\xA8\x92\x84\x40\x12\x02\xBE\x2D\x8F\x37\xE0\x5B\x05\x9F\x8B\xBB\x38\x5D\xD9\x81\xC5\x32\x1E\xCB\xE0\x35\xAC\x7C\x19\x62\x05\xF7\x8E\x77\x96\xB8\xD0\x04\x6E\xAB\x40\x26\x36\x14\x20\x2A\xFF\xA9\x8D\x87\xB7\x96\x5B\x8B\x35\x92\xA0\xA9\x52\xA9\x39\x57\x6F\x57\xC9\x24\x81\x58\xCC\x11\x8B\xD9\x55\xF8\xCE\x88\x9D\xB3\xDD\x9C\xA9\x0D\x61\xB1\x4C\x5C\x7A\x17\xAF\xCE\xE1\x56\x4E\x89\xF0\x6A\xEB\x16\xA3\x45\x84\xF3\xE3\x4E\xDE\x54\x0A\x25\x09\xA7\xDC\xD3\xA3\x72\xB9\x62\x94\xAB\x4E\x4F\x3E\x9D\xEF\x17\x67\x4A\xE4\x76\x16\x28\xF4\x26\x6D\xF0\xD2\x65\x70\x9F\xF3\x3D\xD4\x56\x16\x38\x5A\x7A\x0B\xD1\xB5\xD4\x13\xC0\x03\x88\x95\xF1\xDA\x6D\xD0\x2C\xA2\x4D\xBC\x46\x1E\x99\xBC\xDE\xD9\x5E\xEA\x11\x57\x5F\x7D\xFC\x74\x08\xFA\x7E\x08\x4A\x5B\x51\x65\x6A\xB6\xBC\x9A\x2A\xAD\xA5\x32\x98\xE7\xEC\x92\x33\xB3\x54\x5B\x15\x20\x4A\x2A\x02\xEE\x30\xB3\x7C\x8B\x97\x6F\x28\xDF\xAE\x8C\xE3\x56\xC1\x63\xB9\x5E\x37\x22\x61\xCB\xE7\xC1\x9A\xBE\xD6\xD4\xF2\x4B\x3C\x7C\x74\xE3\x08\x80\x78\x08\x3F\xF8\x47\x90\x3F\xEE\x3C\x73\x63\xA9\xCA\x72\xD9\xD8\xD6\xB3\x76\xDB\x72\x5F\x96\x72\x7F\x16\x05\xDE\xB9\x55\xE5\x5A\xC9\xD8\xB3\x2D\xC3\xF6\xDE\x40\x4F\x10\xDC\x8D\x4A\xAD\xCA\xFC\xCA\x0A\xD7\xCB\xF3\xAC\x78\x0D\x51\xE5\x35\xDB\x8F\x54\x85\xCF\x67\x2E\xAC\x21\xC6\xDB\xF8\xCA\x65\x44\xB3\x2D\x2B\x10\xF5\x48\x08\xAF\x88\xA4\x3F\x45\x76\x7F\xA5\x32\x3D\x91\x64\xE4\x8F\xE8\xF2\xE1\x6A\xE2\x83\x25\x0E\xEF\x1F\x20\x9B\x28\x0B\xBD\x09\xA5\xBE\x0C\x2A\x6B\x3D\xBE\x1C\x9D\x8B\xB7\xAB\xBC\xB7\x50\x43\x14\xB2\x99\x0B\x48\x50\x44\xEB\x45\x5B\x16\x8D\xD7\xFC\x00\x44\xE1\xF3\x9C\xAF\x8F\x81\xA5\x73\x2D\xD8\xAD\xCB\x28\x65\xC9\xC8\x37\xBA\xA1\x76\x5D\x82\x3E\xF8\xFB\x8F\x5E\x4E\x82\x7E\x2B\x95\x46\x41\xA9\x46\xE7\xED\xA9\x45\x16\x7A\x12\x96\x3A\xE0\xD7\xD2\xA7\x7B\x0A\x75\xB3\xEF\xF1\x10\xDF\x89\xE3\xD8\xFC\x8F\xB1\xEA\x7C\x4B\x4A\x55\xF0\x58\x69\xA6\xD3\x37\xE5\xC0\xEB\x97\x37\x2D\x00\x20\x17\xE3\x57\x92\x10\xAE\x77\xCB\xF9\x2B\xF9\x2C\x3F\x2A\x19\x35\x63\x5D\xF8\xE6\x46\x70\x3D\xAB\x79\xE4\xAF\x6E\x0D\x70\xA2\xB4\xBF\x05\xBC\x4D\xC4\x0D\xAD\xAC\x7C\xF5\x4E\xF7\xA7\xA7\x94\x86\xCD\xFE\xF4\x5B\xA5\xDD\xC7\x9E\xBB\x18\x54\xBE\x10\x54\x68\x96\xC5\xC1\x3C\x0B\x83\x79\xAA\x06\x37\xCB\x91\xFE\x42\x20\x9F\xD1\xAE\xF0\xAA\x82\x70\xAE\xEE\x6F\xBC\x57\xB4\x1E\x2F\xD6\xCA\x4C\xDC\xBA\xCC\x72\xAC\xF0\xA6\x0C\x53\x71\xE5\xB0\x5C\x5A\x83\x10\x41\xC4\xBF\x14\x0E\xBD\x79\x76\xCB\x02\x00\x66\xCF\xBC\xF4\xF6\x9E\x63\xCF\xEF\x0E\xAA\x87\x54\x95\x5B\xFD\x39\x6E\x0F\xE4\x56\x67\x99\x88\x70\x6D\xD9\x28\x45\x28\xE6\x94\x6C\x46\xDA\xE1\x15\xF0\xB4\x80\x95\x58\xE1\xBD\x85\x6B\x5C\x5A\xBA\x4E\xC4\x56\xCF\xFD\x4C\x46\x1A\x22\xDE\xAF\xF3\x23\x27\x33\x47\x2E\xFE\xC5\x7A\x8C\x1B\x7E\x17\xD9\x3F\x3D\xF9\xC2\xBB\xF7\xFF\xEA\x03\x37\x7B\xF5\x53\xB7\x8A\xC9\x2A\x58\x6B\xCA\xDC\x28\x45\xE6\xCA\x46\x5F\x3E\x30\xD4\x1B\x18\x2C\x24\xE4\x33\xD0\x13\x20\xBA\x51\x8D\x35\x2A\xD1\x59\xA8\x96\x98\xAF\x95\x58\x8E\xD5\x7A\x1B\x41\xE9\x7C\x2D\x7F\x45\x8E\x20\x2E\x7C\xD9\xFE\xE3\x5F\x33\xD5\xD9\x3F\xDC\x88\x6F\x53\x5F\xA7\x77\x1E\x7F\xAB\x58\x2E\xE6\xFE\x49\x55\x3E\xDB\x09\x2F\x42\x4B\xFA\x08\xAA\xB4\x44\x40\x08\xFA\xA7\xF5\x73\x8D\x99\x48\xB5\x39\x23\x49\xFB\xEC\xA4\xB2\x7A\x5C\xD4\xEA\xEB\x2F\xC6\x7F\xFF\xAD\x2F\x3C\x71\x6A\x71\x23\xB6\x4D\x7D\x9D\x9E\x3D\xFE\xF0\xE2\xFC\xE2\xD4\xE7\x24\xF0\x37\x5B\x81\xEF\xB6\x12\x6F\x64\x82\x7C\x23\xC4\xDC\xA7\x37\x03\x5F\xBF\x7E\x8B\xB6\xF3\xAF\x2F\xFE\x36\x41\x4E\x88\x30\xB4\x11\xBC\xAA\x80\x7D\x6D\x53\x11\x10\x95\x1B\x2A\xF2\xE5\x37\x3E\xF1\xF5\x7F\xD9\x0A\xCF\x96\xFB\x68\xF6\xC5\xB1\x7F\xCE\x65\xC3\x01\x55\x3D\x29\x2A\xE5\xF5\xE0\x9B\xDB\xE9\x0D\xAC\x0C\x9C\x8C\xB5\xEC\xFE\xAD\xC2\xC3\xFF\xF0\x4F\xBE\x91\x97\xA7\x86\xC5\xFD\x0F\x40\xBF\xA8\x2A\xA3\x9D\xF0\x22\x82\x55\x8F\xDF\x21\x02\x5C\xD2\x44\x5F\xAD\x06\x3D\x31\xF9\xA9\x3F\x9F\xFE\x45\x19\x7E\x29\x7F\xB3\x72\xDC\x75\x6C\xDF\xCC\x21\x11\xFF\x38\x41\x0E\xAA\xC8\x01\x11\x19\x16\xF5\xFE\x58\xFE\x6A\x4D\x54\x97\x44\x65\x8A\xA0\x17\x54\xE4\x4C\x92\x24\xA7\xDE\x7A\xEA\x2F\xCF\x22\x2D\xFB\x86\xBB\x76\xD7\xEE\xDA\x2F\x64\xFF\x0D\xB3\xFD\xCF\x34\x8B\x75\x5E\xF4\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82'
		local font85 = "7])#######-Nudj'/###[),##1xL$#Q6>##e@;*>mnM]g8g@J1NA'o/fY;99)M7%#>(m<-0;Bk0'Tx-3HTVck7+:GDAk=qAqV,-GU;P1oK3Qlf&bY98<gXG-$ogl8T(ofL,i;;$%J%/GT_Ae?eaQ3UZAkW%,5LsCaOZ2@<3bKV9*U2Ub';9C8A'YS#9^ooU2cD4AJr9.wYhlJ5drV.V3dW.;h^`I(A_4fH$4>d.hiW%o6Q<B8nXJ;)qBe*T4b(N0iR/G^Hm7[)nC2:V'q?-qmnUCko,.D39N?6O'WHa@C=GH+?k=YJ^k&u^hmiUn_>C#*lpFA=Jws'alVP&S9w0#7EL37WZ3N0*2@&v-HUn#P96&M[bm##>-Lt:EE,WebMcf1G$i--$MBDNgmH&#f:J88u0p88R+vr$8OL^#$,>>#sn&W74xD_&OG:;$W'.;Ql_o6*NT[fCuK1m9+.Vp.2h[%#?I]6E$2ffL5D,s-:pwFM8wA,2.,<6CpYw:#YZA`ah`cf1R3hP97@cA#2o&i#k7?>#EGMJ(+hX]YR;:2Lwos#v^X/&v#,###FLV2M1M#<-6q.>-?XT;-ITiiLv=lCNjCZY#P-4F7'nS2LMlw+M;p)*M_VjfLKI(DN2c7`aR:@`a]v8.$S?mxu.]]F-KWs#0P3w,vf[/&v#*tnLoU@`aT]Uk+$A=gLO%g+MrY#<-.fG<-3NvD-3r0@/*%4A#Y'N+NDET%P?CYcM9BN/NdaW^O*:$##Zp8.$c+?>#(ok&#cHwu#Fle&,GP4;-2Iq>$exdw'mA%&vYfGxkCJOV-Bbu&#*`$s$TGxjLO:?>#(WI&#%DbA#[.@W&0Q/@#<Vtn-'C<L#(I`0#SUu>#Y'9M#9i+u#w:o1$`7a%$YwQO$of0F$9C:r$5(3d$]]i4%iLH(%@`;<%Sq]E%q+]l%kYB^%_C'#&RF]9&kAEl&*un-'&[hr&$KR%'$_F6'C/`G'FSiO'I'YY'Lj?o':[BF(gKx9(%]Kb(]hg')lsfnLxA6##L5Ev5i(),#-Mc##Y@2##HJ8K%G(7B3hq^`jmb%Z#'fX&#rax6*7fx6*`Hbs$f&:;]G]eF3V$nO(]ax9.E';sC4x(cuj+CD3w45w$8A6`ai+`%b:aBj(VcQEn1.f(#d,>>#ZO1x5OZ'u$ZVd8/)$fF4R#s'4P4vr-;`tw5?3lD#XMc7*6#Ui)6gE.3Z_[@#fCb6&n/)ZuOluN'Bobs&i_gi#7+W*%Hr^B%gqk:&mpN?M;<Ilfbm_&PK-kT%ZR`e$%=4C&(_s)%%1]jLX]WV$+QX+`H_0SeUi8>,v)BJ1Xn$##6/QA#*r+gLd^xD*L@[s$tPYx69?RF4PDRv$X_EG%Dl*x'`'6(Q`cEc<<5Wk'II3LDdv2k'CPl.)A]<F3a&<;R>'wC#VB$pKHHKW7L_p]$xDF:Ks9[eur4Cw-BXbRMO=qKMvxuOMRR?>#<s%#,#*%/Cx,3(#Av.l'[cZ_#aY?C#[HSP/W>uD4R`>lLD5M.2m<2W$Zg6d)hDMs$l])mJ?@g*%@/Q,*JaiX-Blx7*YbPg1;>uu#IOxUd,Bo._Uh`i0Vh$##`bLs-;va.3Y?]s$;Go_4twC.3ig'u$&Pto7rLd&4x?7f3x8Qv$a&SF48u_qQ996DfT=Pw$`W49%]8;4'ro%L(g;vn&KR[x,wkR8/EN]a+ISg'/1b5]7Tj#;%PHT6&]Z>3'bClZ,R9,n&O;%1(u8X?6=vkZ-lPwTMOFZY#WY,]k`Qg(WV4lr-Zg>A4t(4I)YEo8%8>%&4+J,G46FVt-/,698rGt87q+gY,d;v3'e?)Q&ObHXJ;K'E<7h3I)nL3GVCRMZuMSKU%X4*p%IXD%&4F=@$s=Id%`c`W%?39A=M[wo%glLW&kZW$#]qbf(0k'u$ok&Y.%<:H*dxrB#7(RW-ep3achtGWM3Txo%D9Ou-cW,n&Jfl-$$vp>?%GnjQZtT;.S=8*+O*Lo&cjsa*Qr2d*(f.;5<:G>#Sg[%#jrgo.^nr?#&Y@C#8n&s$i<a>0bR(f)N0D.3g].HF`RP%tTv5;%T(qB%uS,>JFE-<1?AKAt95k0Eb`o6*?:5gL#W20(e6Fr.u*T*5vn4R*g0@.#'5P:vqDG`a*<li'r)#,2c6%##d#f<CA)'J3TEW@,bkh8.7Lm<-Me`=-We`=-=-f6/EUET%^@F,MCYk[t&c-NUC_39%a6We$pnd6Oenh^%KGKb.wUkA#0@D9.>5u;-Qq0I$#Sg%OU[;;$WooE[sqLF[&6+#(.gIkXs)eR*[%`AP[p7S[)i@W@;:@W$ie#W-qScDS:=(?%R%)@0vOkxu-%H<-$OsM-Kqeg+.%&?7fb&4QN0Iq7]UE=_B/EdFIPcd$_;kb[BRoC&]wC'8aXbxujtFH2%/5##9ZhR#Q`U7#[?O&#`%.63xZ*G4[m5%-IckV-a-ji0Xfgs7omrXI`DuZGAiuYucFs.Li%'/)Jg=A#Eo];1dDI-)oXV]=R9DC+EJt;0HF]:d,Bo._+c`$'w6$`48tFA#lL*L>e?85/85xD*RtC.3[5ZA#xflMri:3D#HC+[.e,_6&&VgQ&Z^(99AE&2B6L_X%g,16&n%:bQ`CYE9osC0(5Q([,0`%C#jkW999f5gLXX:T7BA$vLU,qXuHi:kk`Ia$'A#QA#Gt@m'II#d0c<jv6Z)YA#M$+mLtk*J-^(29.b6FA#^MlD4w3::)#5r1TOq[W$m`w1(gYBu$Osus-EBniL+uKb*.x_5/Lw*t$*b1hL(^p@#6kGR&W<;@G]HkT%hmT/)NUupoH]Dd*?9T'M_])w$trF,ikj5c*M3fS(?>cuu:g-o#'_U7#EPj)#cUG+#$2QA#g'ok92%?g)6f<X(@eA7/+IA8%L@Gm'VAqB#9`]q)K:n=7Z&PA#w0`.3Sh+<%VT4J*33w,*obQP//p^I*$sun&%rqX%e5_6&5<Zv#txvN'dPDg(AnN9%H*Tm&W9tP&Q*X=$;$D?Y7sM)3dew/W4Rp:%Qe3*,`lNa*Uiqm9R1s20H@L-2PObV$tNA30.:>Y%Sj(0(7_P:&D'Ot$(FK/L*oaPoRAj6tVH6I6#&JfLXq-##Wh5r#u_V4#V$(,)oQW@,t-pfL=T]s$kHuD#T^WjLOa`221n,Y%0tSc3fFs_,A8od)=Ln8%f&/F4tMFT[r;^lSD#-b<pGc40i^iB>_Q>n&cP>B,Irl>#LOT6&[VhhLXMvu#P4)eahuC`argai0c6%##O?jb$-2ZZeYAOZ6%vYT%:;gF4Woc;-#LHa$M=-Q8+`<$6N/ob4PF[p%hCBTTh2P,OM?0rm95k0EqW)J<HY.cV/Fwe4r>;@.D7u;-9,lC/XaaJ2H]k0;*6$f4D[r%,=d)J<']T.Zlv?D*3v5.Z9lh;-rVPd$6^UaSoH<eQXtDQOIkr]KO/P:vqrX>#q2dc)VaFN(K)'J3M[jJ1n`aI)`Ld5/OwAv-IBap'dvT-%,&AA4fTTM'`S[e,7)$9%FI4]u*Ki?#2muN'L(CTNwxe`*&HhH296a*.RW&F.@Z$I2-*c6&FbU'#%2Puu0HUn#]9i+9r-6Z$>(J'J`**/:P5P3D42.a3IJJ]$(Tu58/7Wd$GW>7&Bp%*'Wg53'kPU&5J:?O2]KVX,@J#v,J0.%,CUwW$T7D?#ptA'+veBG-N%r-4J`psZR:ov$`5VhLf;$##h^YfLQ*88%>u###G]o[+FFvq7o<Zcaf)P=-%Ti].4/sW#+2QD-OY@Q-r^_t%h#&R1K%h,N0UL+*Zj:9/ql4Z,o(b.3-/5[$wmm.)m7-R]e#iEOFO.W$ffew$fhq8.hb:x$P3Ih,MHB$dG-9U%R53K(W5L'#.0L`J-D]aJ@K7l17@[s$Fc7C#^oJF*&2V92/QNp%n:iDF^hsp%<1I'PLGKTS>F@W$)VnQ0:Tf=%iud(#%,Y:v*`(?#d5i$#d$(,)1Dh;-avF%&FDwW]>'af:,ZY>%Bae],MG,@&Z$VgCX;[q&]d^Q&@T_Q&*'YK1CwHC#otC0(D]Vn&J4a6&,Q,nA>)973IG:;$42I9fq@5P][bHP/]]P`<S&Ou.]*'u$`S6C#&R:a#/]NT/<PsD#FOit-puk/Mfd6l13Xrt-6hH&O.NAf3U+X=_2k3B6ENwY%OX<p%rQv@5mesP&ato60IR.W$ab:@,rU0/)NvHH)vP(n)s5hU%NXEp%)B0I$g<n=hs6E`/++t^/RG*I)qs,m:etYb-QB=X$^tm.+?_ap%mndT.#S3X.YAIL((`oC4]3570KE(K(vptg1X>IL(U%15%U8G>#B7>##eH?D*<w4x#'Ga01u?lD#/_v)4na&],4nmk%8CFA#KfZ@-MS[s/%PDZugco$5V%bK(`pVQ1wK8W$e5Zn&:q1E#N4M?-dD24'`2FP(515-3]#4_5#<kB,XfvW.JXi$#S,Qd*?sZxXlee,;nNN?6NfB.*bj9^#]ru8.KRpQ0)PkA#4.m<-QV`X-x0*+%Z####)DluulD:R#7)+&#Rb<9/#&AA4EddI%1QQJ(+w9j0)U5N'ePU:%^L4H)&4d;%AL*N0$W:<-aBND%s>seMZPr.2I+@8%1x<M&J=D?#nl,?#VYAs.USc`%GKg,*E[.O90+dg)UHuD#d@^&BgtG%B:+5gLpP#v,(d[]uaZP$B<aR#v`BmV#Zq=<MRBT_4_)wv-ZI:E4W/Ke=AcvS/KYn3QpLji-cMR#LFnZ)#v]x9vlcaL#Gh1$#j&U'#vu:9/nfZ%-DU`v#q%fX/ELsY$%-U:%erar&kC)?#2HT<$>m'-M1==2K$SRD&$UST%gVw8@<);?#Gr><-jZ9S//.0m&`c>w#3eH_u,U8&&pBop%?iXg1*G'i<A(DeNAO5hL'/6h-r=ge=>d7iLWvJO9+M)<%.;Rv$Sko;7#eXg;Nx.(63U@#:Uj=vGW'3)%/TEt&>N&r0En*IH%]]q)#QU<H'_9N0=:G>#_Yt&#`G>M9&5Kv-POEn<I3rhLZNs?#`xJ+*bX[6/w4NT/'APjLIXTC4^nr?#/xc<-Q+)X-NB@k;5Hr-MHx9+*.i)F7Akdi9A&=61M=l9/?lG>#Cwo2'dcse)x`lj)I:e8%Os5r%[^N3,e3d*7&=+K15#t^-nwr?9%m]^+[<5N'Iq:+*Qjc?6Eo_;$_`wd)6[l]UDe(HMBf$##&#5>#'8G>#0qm(#abY+#nqdT-Z-uG/-]U@,:^9a<r_l8/agocNN%,t6)&Vv-ZI:E4*NYx6?J))3)+ro.Khkj1s3vr-8GTkLTQU&$*/rv-udnX-;X^:/x<j?#BW[iLu]sFr7u$s$Y(0+*twU<-C`5>#TP.K:g/$r%4%@8%'vct$/%lM(aOrr&$^u_)=taX$.&.['2Z(6&>Rn8%w*ci(=&gU'_TBq%TOR8%A[N5&Ckns$ub:@,_l/C4j.d6<&7bs-63Nl(Fe1/)S6Op%4AXi(H(jP0Q^M7'K*#Q#2uq;$=6DhLqIci(Wn7<$/AP>#Sr[+MYV?_#',[0#n0;,#<->>#AV9+*Cid8/@n>V/a%K+*d)UM':]d8/&,]]4#cx:/.BTk+=%k^obRoU/<vKW-B1BnhM1;*%E1B]$EU@lLT$(E#?;Rv$S-2E4):Z;%+73n'*o&02SiWI)j,/]%<[^`3G/?I426w6'^nV?#</m#>+;tE4dc(/:5Emn&@02;&,/s#56-jW))ljp%:Sd9%r#:Q&FwkU%mE/g)M8Co/D@xN'`Qf8%N+AC#j+vw-h(3%$?e<t$&w@.*mu%m0NiTh3Ga',;$*og)K2Ke*G6`E4x0G4:@T$H)_996&-Y<s%J$Xp%21'X%f]V8&@M+mfx`Do&6B(:8HEV,33V`2'Y1%O=6s^=-$(nY#P5YY#@;xu,rNclAS_P_HmVl]#uF]fLl-F<%:q'E#qI[%-$V/)*t:3T%=^WI)R3*7BI&_W7dv@)GjnBH)Ym=]#jPE>/Bqmk'IXEp%9AalA&>dF+H5P?6L#;Q&jbv@&LBHT0:YtH)DONp%(cQ-Hg>6`aj+`%bN?`l8ggN^,T>V/1-<Tv-/.ji0vR7C#_Tld2gc``3J)TF43h;E4x<7f3trLI$UEW@,V])<-an@8%vA+G4Ug$&4bx&X6vjuN's1FV&[7'U)J;<^4lR4U%r>f8'9h:K(XChT7+VRD&<4K-)sH^m&'e7d$IKN8;1N_6&1V=w53+6_+TUW_&4;vP9g)$N'M(gn/?rpq/3lE]'^`49[P`mY#L-&##9*,Q/:WL7#F[P+#[N;t.26MG)`7.[#sSg*%PXkD#TgZ;.[GYd3IPsD#n`h*%]h=^,p*5gLP0vhLoMh<.ms#E36tFe-_+7g)RHKs$TSm0'2v$E3)b'n/;g=[&H.;t-`XrjM<%KB1LP4q&Lk197oTE$P,F?C+D95%lb,Fj180F#P`xP<-%w$iM,U_8Mi9MhL1_duu9^hR#*4mx3(pm(#T%T*#GEOA#B.i?#a1[s$2-Ch$Gc7C#FwIf0[Z*G4pM.)*gCSfL$#9f3bR(f)[/*E*lAqB#.v+G46`W01;?x;$D*K2'OCXk$3o(9.J=HiP3V#=R6$8]Io8@v$b=&NKw2FSR9R8/M+:HZ$UlS#,TeIv?]2ofL_KAw#OHiY(3SB[5g.t3;q,XP(f#Dk']^2IMji&gL.tVV$8;-`as+$kkkGSY,@G*T8W#r6*ffk/M3o,x#l5MG)YAOZ6aA6N':]d8/xE(E#EiaF30ACkLup'E#sJ))3a>BK24vPA#r6eKu9g+G4V1x;%lpKB#RBs%,995Y'NrKa3C<dJ(Oq@@#Z9''PZnqR[=l(?#u4ej'K$u=$js]r.Mk/B-maDgCX@w:%@ooA,.ij?#J`#Z%Id:^u)eGnAdD24'%QmB&T$]<$0>TH*G9R0%IYP>#$5D?#d&_H2kR,E4l,N6f/Lna1651S8eDeK<hR[/;=/$Z$dWq#>=a,g)Jk*W-o*6`Q71A%'F2HlLS-W,;PD3/MB9Ap&/w%'.Ylp:>m^X&#Zt6J=7_XD#<)]L(VS6N:W;Ee+?]x%B.+CJ)wObA#@hh$'@4CJ):3+V.H*.%,(*xfM)rJfLdxQ:v9q;##AQ=8%4V###CX@8%:q'E#.4Kg%R*R2L6[*#'B(`?#_R]?5i9:n/ni$qLkBa?#^ULJ#aL>-M>$;-M=u+8&,,h9;Vk,#AAvN1)`3lD#bF%U.VRI@#@u$:McYCJ)en]m&3iD1'(E*1a2[mxLFNir&KWdgL.0vL'_E0QC_F&@>w06Z$Lw9e?fJ))3oxJ+*%ABp7a/l*X[&KMXJLc>>au7p&3bLg(*tM'%BSm&M/NHMX#-Bs$o@SZP)aAB+?1$=05e+/(-Ga.qOcnW/slU:%fZX,2FsHd)sRF,MI#NT/eMXV/Z?85/1c<9/SP,G4[^<c4OJ,G4osFA#0j5F%a>_,*Q$F[TP?O2&drvv$>&cu-Njv:&>oAt%dmfw#]$<v#bt7Y-HEv3+d,]&Or])w$$O-32H[.LM:Ib70_@#G*mZaZ#GXE5&;`G(+7e:*4[c*M(KBeIM*)4a*Vd/9&1)q;.L2(E5?@%##'&>uu]4>>#JL6(#I]&*#=sgo.0X<-X,fm=7ST.29c9mG*ES%Q-WMN/%7MN=(-tx>*;iS?R$0t>-s)U:%2d7-)&KM-)&cj<%@Cp.)Cos'4L*/@#jQ[-'dtKHM-C:Q$]%WX.$_7tJ<<.k(^&Y:.eOdu-S_%u-QP:%MZL?C+&U,T%s_@C&G####R3n0#4=O5L^hHP/Y'3:.rM[L(Lov[-u?lD#TMrB#S/DD3Gq6Elg754%F>nM>%u.eaB0?MR1S+fa.+CJ)`0Ne$^f,$&8bfCMFl:p.,3h(,[Jw6*'2>;-DluNFopV]+08>5/)WHG)dR&E#^v7B.R4r?#.8'gLoeZd3$M4H)HC)?#97(wL5KihLtk9i%A2;gLBHr-MIt.>-S#fJM+e7iL9mBgMhS3<%f$g;/=V&E#,:3iMtrbI)vEjV;([xV;dPG<-ZvR/&ea*G43>km'-1em'JNXA#SH;2%@vN*']ggQ&8([gLk)JHDHH;2%1rv<_[2vR&Gbp*%i)%t?.KFm'#0$f?:Jl^??gNH*PJ))3?[^:/x)Qv$8^t'>Pp#8/W%am&ob*9%uAg8%WB_ihURxa+HU+`&owr8%(t&4MX$?d$(L@M9VB')3ig'u$C]R_#=qj7%8jE.3TDj?BG?,na_w6u6-E1l:0xoG3w3Tgsia+,%lsRF4K)^/LdB]@#gYgu:P,'F*lKfN0>jD+=Dn8@#wrdN'EUrV$)G6,EAgxkE0uBX%L[<9%cK,m:TxA5=+DAL(tgJ@#Q1iB78(Gj':4P@5Xd52*q:npIDu(v#kI?b>],kI,>nSm&pEEm/jMRiuO^C/)@bL/)9),##kw>V#aC)4#-'Vl-93$4ixVwZ?8&[#6<TIg)rXd+u-GrB#ANU1;#ki-*[*'u$($_O-C_39%l?^;-pMcpRhIblA5Zs>&GiI-?>abA#-oYGMu;gL:bc9N(nN*20KUNK)55%&4Z&:I$(%x[-&8b5A0;nw'*0F6jSNCD3U+BJ)u'nofu1>;-E$V0,PE;61LG+t&hC5Y#or3R/uV?L2Y[3VR`Uo&,Jgma3+_AG2'&>uu@Rl>#TN7%#6&*)#)$B?&qP[]4wj`a4G+^C4D2$w-YpVa4Bl$],Soxu,E'Yt(jtn8%>B940NT^:%PEZd3gtONDlr1jr#4l:&)KqV(5P3(7Z]hQEWFFb3:?)G#,'Vw.'=.g:n7X_$Oj?H)(Jb.)?$Ym&cAJu.XfrS)bDVO'6^`S&xt#I6G,OL)Z8MsA5GeT%kiLA=fR:J)@Le<$^&hg:VF6T.PEHR&r2Z(-LXnq.9&.Qkfx5Q'k4+gL`2Rha'_A`a-l68%?3GJ(Wo8>,;NHD*R<*H*'k$H3@.OF3(@*Q/P$8s$Wt'E#4`d5/v5qSC2OCau$$4n<Ye&[Jreci9rYtL#<iBWJI@,@')$s<Mq]g%u*85##<vHo#e37:vUoIfLG@Huuq#AsT0C=)#Z]e^$5GU%6(K2^>KC,H3o]d8/;60T.kiic)`'Nu&ML*/3?4HN<?TtD<(vvE3V9LE<7,9u&>oT4(Ppx8RM,bbN'3hQ&cVBp&-h](P[4$##D%`a%E&3>5?n<Q8IuJ,3evTS%3D-T8l?e1,<nS^)=lXZ%SQ^6&g*Td<.+CJ)AOMe2JeGJ)nMOW'voQN'kFe),csJ_/9oF&#&k=m/';P>#cWGG)G&JJ&.%Vu&`9*?#L5koX^V2<%LZL:qvfGb%.6=(jE$qAXl*7T.8LVX-1P)C&':rk%(`c@$Frd@b/v,Da%gf%FlDq1K;8q2:vk>)4uueV%8drk'ds>V/AHaa4PdGg1Q0g://sId)a[2Q/MNBu$lYe)*;2QA#C`WF3U:Ix6_s$-3Y#c;-*^?.%Eg>G(pnO6')uBF*+kRlL-OY2(p2GX$XOmY##md11-;N[$-h)[,C1Z(+4>58.C8rh1NMWm/*dm(5&J)h3u'^:/cTf$5#0%-)u$-0)Gqe<$uSdj'#n4k05B.-)'#9;-)F:)4X',b+;eM`+G%Yi(uR&A$u%IN'K?mV);>cKhtGP&5'*U-HBkA?7FH)M%wE(,),s:D3F]tr-iL0+*I5^+4sUlo7t'vG*+'V*uEiUC,kKe6%RXkD#3^4.-NT_r?RU#pL1e3IfQ+;mQOg]j-<D:I$o,K9.(f>C+Tf=WM[Eo>-c&-p/o,UiIOE,n&YQ>s-q%TH:1]'^#7)hs-Z>?j:n@Im0G=61MJE:Z-+dfF47of1;F8`I3hbtM(ft(%,$xUC(<kuN'KmLEMMxg6(M8kn/4-Vo7kpHJ)*:V9..EVO'ZA,L2?SOS7Hr.cV$lQ=lM3l1+Q:ENrUG6^=032H*Z%AA4VC8j0q_.<8duiW%cljv%)@vV%v>[h*0ViIRqGojLpA$##5=S5#+.MT.<e[%#c@`T.-Yu##;A`T.,Mc##QsG<-5X`=-nsG<-*fG<-:B`T.8.`$#m#XN03c:?#-5>##_RFgLOJhkL0=`T.6:r$#34xU.3xL$#AsG<-5X`=-YsG<-*fG<-&B`T.H9F&#@tG<-JPI+3Ze/*#Xst.#e)1/#I<x-#-#krL;,;'#2_jjL/u@(#0Q?(#Xp/kL<LoqL0xc.#wC.v6F+U.G5E+7DHX5p/W%C,38q:417=vLFa-'##jS3rLP@]qLbqP.#pm-qL5T->>9l7FH5m?n2MT4oLkL#.#6^mL-Kr;Y0BvZ6D.gcdGBh%nLPKCsL3T,.#+W;qLFm%hEgdJX9J%Un=p&Ck=%8)_Sk+=L5B+?']l<4eHR`?F%X<8w^egCSC7;ZhFhXHL28-IL2ce:qWG/5##vO'#vMnBHM4c^;-UU=U%V9YY#*J(v#.c_V$2%@8%6=wo%:UWP&>n82'B0pi'FHPJ(Ja1,)N#ic)R;ID*VS*&+Zla]+_.B>,cF#v,g_YV-kw:8.o9ro.sQRP/wj320%-ki0)EKJ1-^,,21vcc258DD39P%&4=i[]4A+=>5ECtu5I[TV6Mt58761*WHnDmmLJ[#<-WY#<-XY#<-YY#<-ZY#<-[Y#<-]Y#<-^Y#<-_Y#<-`Y#<-hY#<-iY#<-jY#<-kY#<-lY#<-m`>W-hrQF%WuQF%%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2'0O,3rX:d-juQF%&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3(9kG3rX:d-kuQF%'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3)?tG3A:w0#H,P:vv039B[-<$#i(ofL^@6##0F;=-345dM,MlCj[O39MdX4Fh5L*##G)-Fq93;At30+:D"
	-- >> BASE85 DATA <<

	imgui.GetIO().IniFilename = nil

	medh_image = imgui.CreateTextureFromFile(getGameDirectory()..'\\moonloader\\Med Helper\\Images\\MedH_Images.png')
	rainbowcircle = imgui.CreateTextureFromFileInMemory(new('const char*', circle_data), #circle_data)
	
	local config = imgui.ImFontConfig()
	config.MergeMode, config.PixelSnapH = true, true
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	local faIconRanges = new.ImWchar[3](fa.min_range, fa.max_range, 0)
	local font_path = getFolderPath(0x14) .. '\\trebucbd.ttf'

	imgui.GetIO().Fonts:Clear()
	imgui.GetIO().Fonts:AddFontFromFileTTF(font_path, 13.0, nil, glyph_ranges)
	imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(font85, 13.0, config, faIconRanges)
	
	for k,v in pairs({8, 11, 15, 16, 20, 25}) do
		font[v] = imgui.GetIO().Fonts:AddFontFromFileTTF(font_path, v, nil, glyph_ranges)
		imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(font85, v, config, faIconRanges)
	end

	checkstyle()
end)

function checkstyle()
	imgui.SwitchContext()
	local style 							= imgui.GetStyle()
	local colors 							= style.Colors
	local clr 								= imgui.Col
	local ImVec4 							= imgui.ImVec4
	local ImVec2 							= imgui.ImVec2

	style.WindowTitleAlign 					= ImVec2(0.5, 0.5)
	style.WindowPadding 					= ImVec2(15, 15)
	style.WindowRounding 					= 6.0
	style.FramePadding 						= ImVec2(5, 5)
	style.FrameRounding 					= 5.0
	style.ItemSpacing						= ImVec2(12, 8)
	style.ItemInnerSpacing 					= ImVec2(8, 6)
	style.IndentSpacing 					= 25.0
	style.ScrollbarSize 					= 15
	style.ScrollbarRounding 				= 9.0
	style.GrabMinSize 						= 5.0
	style.GrabRounding 						= 3.0
	style.ChildRounding						= 7.0
	if configuration.main_settings.style == 0 or configuration.main_settings.style == nil then
		colors[clr.Text] 					= ImVec4(0.80, 0.80, 0.83, 1.00)
		colors[clr.TextDisabled] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.WindowBg] 				= ImVec4(0.06, 0.05, 0.07, 0.95)
		colors[clr.ChildBg] 				= ImVec4(0.10, 0.09, 0.12, 0.50)
		colors[clr.PopupBg] 				= ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.Border] 					= ImVec4(0.40, 0.40, 0.53, 0.50)
		colors[clr.Separator]				= ImVec4(0.40, 0.40, 0.53, 0.50)
		colors[clr.BorderShadow] 			= ImVec4(0.92, 0.91, 0.88, 0.00)
		colors[clr.FrameBg] 				= ImVec4(0.15, 0.14, 0.16, 0.50)
		colors[clr.FrameBgHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.FrameBgActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.TitleBg] 				= ImVec4(0.76, 0.31, 0.00, 1.00)
		colors[clr.TitleBgCollapsed] 		= ImVec4(1.00, 0.98, 0.95, 0.75)
		colors[clr.TitleBgActive] 			= ImVec4(0.80, 0.33, 0.00, 1.00)
		colors[clr.MenuBarBg] 				= ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarBg] 			= ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarGrab] 			= ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ScrollbarGrabActive] 	= ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CheckMark] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrab] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrabActive] 		= ImVec4(1.00, 0.42, 0.00, 1.00)
		colors[clr.Button] 					= ImVec4(0.15, 0.14, 0.21, 0.60)
		colors[clr.ButtonHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ButtonActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.Header] 					= ImVec4(0.15, 0.14, 0.21, 0.60)
		colors[clr.HeaderHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.HeaderActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGrip] 				= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ResizeGripHovered] 		= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGripActive] 		= ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.PlotLines] 				= ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotLinesHovered]		= ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.PlotHistogram] 			= ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotHistogramHovered] 	= ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg] 			= ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDimBg] 		= ImVec4(0.00, 0.00, 0.00, 0.30)
	elseif configuration.main_settings.style == 1 then
		colors[clr.Text]				   	= ImVec4(0.95, 0.96, 0.98, 1.00)
		colors[clr.TextDisabled] 			= ImVec4(0.65, 0.65, 0.65, 0.65)
		colors[clr.WindowBg]			   	= ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ChildBg]		  			= ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.PopupBg]					= ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.Border]				 	= ImVec4(1.00, 0.28, 0.28, 0.50)
		colors[clr.Separator]			 	= ImVec4(1.00, 0.28, 0.28, 0.50)
		colors[clr.BorderShadow]		   	= ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.FrameBg]					= ImVec4(0.22, 0.22, 0.22, 1.00)
		colors[clr.FrameBgHovered]		 	= ImVec4(0.18, 0.18, 0.18, 1.00)
		colors[clr.FrameBgActive]		  	= ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]					= ImVec4(1.00, 0.30, 0.30, 1.00)
		colors[clr.TitleBgActive]		  	= ImVec4(1.00, 0.30, 0.30, 1.00)
		colors[clr.TitleBgCollapsed]	   	= ImVec4(1.00, 0.30, 0.30, 1.00)
		colors[clr.MenuBarBg]			  	= ImVec4(0.20, 0.20, 0.20, 1.00)
		colors[clr.ScrollbarBg]				= ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]		  	= ImVec4(0.36, 0.36, 0.36, 1.00)
		colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]		= ImVec4(0.24, 0.24, 0.24, 1.00)
		colors[clr.CheckMark]			  	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrab]			 	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrabActive]	   	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.Button]				 	= ImVec4(1.00, 0.30, 0.30, 1.00)
		colors[clr.ButtonHovered]		  	= ImVec4(1.00, 0.25, 0.25, 1.00)
		colors[clr.ButtonActive]		   	= ImVec4(1.00, 0.20, 0.20, 1.00)
		colors[clr.Header]				 	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.HeaderHovered]		  	= ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.HeaderActive]		   	= ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.ResizeGrip]			 	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.ResizeGripHovered]	  	= ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.ResizeGripActive]	   	= ImVec4(1.00, 0.19, 0.19, 1.00)
		colors[clr.PlotLines]			  	= ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]	   	= ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]		  	= ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.PlotHistogramHovered]   	= ImVec4(1.00, 0.18, 0.18, 1.00)
		colors[clr.TextSelectedBg]		 	= ImVec4(1.00, 0.25, 0.25, 1.00)
		colors[clr.ModalWindowDimBg]   		= ImVec4(0.00, 0.00, 0.00, 0.30)
	elseif configuration.main_settings.style == 2 then
		colors[clr.Text]					= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.TextDisabled]   			= ImVec4(0.24, 0.24, 0.24, 0.30)
		colors[clr.WindowBg]				= ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.ChildBg]					= ImVec4(0.96, 0.96, 0.96, 1.00)
		colors[clr.PopupBg]			  		= ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.Border]			   		= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.BorderShadow]		 	= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]			  		= ImVec4(0.68, 0.68, 0.68, 0.50)
		colors[clr.FrameBgHovered]	   		= ImVec4(0.82, 0.82, 0.82, 1.00)
		colors[clr.FrameBgActive]			= ImVec4(0.76, 0.76, 0.76, 1.00)
		colors[clr.TitleBg]			  		= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgCollapsed]	 	= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgActive]			= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.MenuBarBg]				= ImVec4(0.00, 0.37, 0.78, 1.00)
		colors[clr.ScrollbarBg]		  		= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ScrollbarGrab]			= ImVec4(0.00, 0.35, 1.00, 0.78)
		colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.00, 0.33, 1.00, 0.84)
		colors[clr.ScrollbarGrabActive]  	= ImVec4(0.00, 0.31, 1.00, 0.88)
		colors[clr.CheckMark]				= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrab]		   		= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrabActive]	 	= ImVec4(0.00, 0.39, 1.00, 0.71)
		colors[clr.Button]			   		= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.ButtonHovered]			= ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.ButtonActive]		 	= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.Header]			   		= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.HeaderHovered]			= ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.HeaderActive]		 	= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.Separator]			  	= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.SeparatorHovered]	   	= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.SeparatorActive]			= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.ResizeGrip]		   		= ImVec4(0.00, 0.39, 1.00, 0.59)
		colors[clr.ResizeGripHovered]		= ImVec4(0.00, 0.27, 1.00, 0.59)
		colors[clr.ResizeGripActive]	 	= ImVec4(0.00, 0.25, 1.00, 0.63)
		colors[clr.PlotLines]				= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotLinesHovered]	 	= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogram]			= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogramHovered]	= ImVec4(0.00, 0.35, 0.92, 0.78)
		colors[clr.TextSelectedBg]			= ImVec4(0.00, 0.47, 1.00, 0.59)
		colors[clr.ModalWindowDimBg] 		= ImVec4(0.20, 0.20, 0.20, 0.35)
	elseif configuration.main_settings.style == 3 then
		colors[clr.Text]					= ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.WindowBg]				= ImVec4(0.14, 0.12, 0.16, 1.00)
		colors[clr.ChildBg]		 			= ImVec4(0.30, 0.20, 0.39, 0.00)
		colors[clr.PopupBg]					= ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border]					= ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.Separator]				= ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.BorderShadow]			= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]					= ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.FrameBgHovered]			= ImVec4(0.41, 0.19, 0.63, 0.68)
		colors[clr.FrameBgActive]		 	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TitleBg]			   		= ImVec4(0.41, 0.19, 0.63, 0.45)
		colors[clr.TitleBgCollapsed]	  	= ImVec4(0.41, 0.19, 0.63, 0.35)
		colors[clr.TitleBgActive]		 	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.MenuBarBg]			 	= ImVec4(0.30, 0.20, 0.39, 0.57)
		colors[clr.ScrollbarBg]		   		= ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.ScrollbarGrab]		 	= ImVec4(0.41, 0.19, 0.63, 0.31)
		colors[clr.ScrollbarGrabHovered]  	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ScrollbarGrabActive]   	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.CheckMark]			 	= ImVec4(0.56, 0.61, 1.00, 1.00)
		colors[clr.SliderGrab]				= ImVec4(0.41, 0.19, 0.63, 0.24)
		colors[clr.SliderGrabActive]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.Button]					= ImVec4(0.41, 0.19, 0.63, 0.44)
		colors[clr.ButtonHovered]		 	= ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.ButtonActive]		  	= ImVec4(0.64, 0.33, 0.94, 1.00)
		colors[clr.Header]					= ImVec4(0.41, 0.19, 0.63, 0.76)
		colors[clr.HeaderHovered]		 	= ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.HeaderActive]		  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ResizeGrip]				= ImVec4(0.41, 0.19, 0.63, 0.20)
		colors[clr.ResizeGripHovered]	 	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ResizeGripActive]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotLines]			 	= ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotLinesHovered]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotHistogram]		 	= ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotHistogramHovered]  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TextSelectedBg]			= ImVec4(0.41, 0.19, 0.63, 0.43)
		colors[clr.ModalWindowDimBg]  		= ImVec4(0.20, 0.20, 0.20, 0.35)
	elseif configuration.main_settings.style == 4 then
		colors[clr.Text]				   	= ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]		   	= ImVec4(0.60, 0.60, 0.60, 1.00)
		colors[clr.WindowBg]			   	= ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildBg]		  			= ImVec4(0.10, 0.10, 0.10, 1.00)
		colors[clr.PopupBg]					= ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.Border]				 	= ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.Separator]			 	= ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.BorderShadow]		   	= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]					= ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.FrameBgHovered]		 	= ImVec4(0.19, 0.19, 0.19, 0.71)
		colors[clr.FrameBgActive]		  	= ImVec4(0.34, 0.34, 0.34, 0.79)
		colors[clr.TitleBg]					= ImVec4(0.00, 0.69, 0.33, 0.80)
		colors[clr.TitleBgActive]		  	= ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.TitleBgCollapsed]	   	= ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.MenuBarBg]			  	= ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.ScrollbarBg]				= ImVec4(0.16, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarGrab]		  	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ScrollbarGrabActive]		= ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.CheckMark]			  	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrab]			 	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrabActive]	   	= ImVec4(0.00, 0.77, 0.37, 1.00)
		colors[clr.Button]				 	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ButtonHovered]		  	= ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ButtonActive]		   	= ImVec4(0.00, 0.87, 0.42, 1.00)
		colors[clr.Header]				 	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.HeaderHovered]		  	= ImVec4(0.00, 0.76, 0.37, 0.57)
		colors[clr.HeaderActive]		   	= ImVec4(0.00, 0.88, 0.42, 0.89)
		colors[clr.SeparatorHovered]	   	= ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.SeparatorActive]			= ImVec4(1.00, 1.00, 1.00, 0.80)
		colors[clr.ResizeGrip]			 	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ResizeGripHovered]	  	= ImVec4(0.00, 0.76, 0.37, 1.00)
		colors[clr.ResizeGripActive]	   	= ImVec4(0.00, 0.86, 0.41, 1.00)
		colors[clr.PlotLines]			  	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotLinesHovered]	   	= ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.PlotHistogram]		  	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotHistogramHovered]   	= ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.TextSelectedBg]		 	= ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDimBg]   		= ImVec4(0.17, 0.17, 0.17, 0.48)
	elseif configuration.main_settings.style == 5 then
		colors[clr.Text] 					= ImVec4(0.9, 0.9, 0.9, 1)
		colors[clr.TextDisabled] 			= ImVec4(1, 1, 1, 0.4)
		colors[clr.WindowBg] 				= ImVec4(0, 0, 0, 1)
		colors[clr.ChildBg] 				= ImVec4(0, 0, 0, 1)
		colors[clr.PopupBg] 				= ImVec4(0, 0, 0, 1)
		colors[clr.Border] 					= ImVec4(0.51, 0.51, 0.51, 0.6)
		colors[clr.Separator]				= ImVec4(0.51, 0.51, 0.51, 0.6)
		colors[clr.BorderShadow] 			= ImVec4(0.35, 0.35, 0.35, 0.66)
		colors[clr.FrameBg] 				= ImVec4(1, 1, 1, 0.28)
		colors[clr.FrameBgHovered] 			= ImVec4(0.68, 0.68, 0.68, 0.67)
		colors[clr.FrameBgActive] 			= ImVec4(0.79, 0.73, 0.73, 0.62)
		colors[clr.TitleBg] 				= ImVec4(0, 0, 0, 1)
		colors[clr.TitleBgActive] 			= ImVec4(0.46, 0.46, 0.46, 1)
		colors[clr.TitleBgCollapsed] 		= ImVec4(0, 0, 0, 1)
		colors[clr.MenuBarBg] 				= ImVec4(0, 0, 0, 0.8)
		colors[clr.ScrollbarBg] 			= ImVec4(0, 0, 0, 0.6)
		colors[clr.ScrollbarGrab] 			= ImVec4(1, 1, 1, 0.87)
		colors[clr.ScrollbarGrabHovered] 	= ImVec4(1, 1, 1, 0.79)
		colors[clr.ScrollbarGrabActive] 	= ImVec4(0.8, 0.5, 0.5, 0.4)
		colors[clr.CheckMark] 				= ImVec4(0.99, 0.99, 0.99, 0.52)
		colors[clr.SliderGrab] 				= ImVec4(1, 1, 1, 0.42)
		colors[clr.SliderGrabActive] 		= ImVec4(0.76, 0.76, 0.76, 1)
		colors[clr.Button] 					= ImVec4(0.51, 0.51, 0.51, 0.6)
		colors[clr.ButtonHovered] 			= ImVec4(0.68, 0.68, 0.68, 1)
		colors[clr.ButtonActive] 			= ImVec4(0.67, 0.67, 0.67, 1)
		colors[clr.Header] 					= ImVec4(0.72, 0.72, 0.72, 0.54)
		colors[clr.HeaderHovered] 			= ImVec4(0.92, 0.92, 0.95, 0.77)
		colors[clr.HeaderActive] 			= ImVec4(0.82, 0.82, 0.82, 0.8)
		colors[clr.SeparatorHovered] 		= ImVec4(0.81, 0.81, 0.81, 1)
		colors[clr.SeparatorActive] 		= ImVec4(0.74, 0.74, 0.74, 1)
		colors[clr.ResizeGrip] 				= ImVec4(0.8, 0.8, 0.8, 0.3)
		colors[clr.ResizeGripHovered] 		= ImVec4(0.95, 0.95, 0.95, 0.6)
		colors[clr.ResizeGripActive] 		= ImVec4(1, 1, 1, 0.9)
		colors[clr.PlotLines] 				= ImVec4(1, 1, 1, 1)
		colors[clr.PlotLinesHovered] 		= ImVec4(1, 1, 1, 1)
		colors[clr.PlotHistogram] 			= ImVec4(1, 1, 1, 1)
		colors[clr.PlotHistogramHovered] 	= ImVec4(1, 1, 1, 1)
		colors[clr.TextSelectedBg] 			= ImVec4(1, 1, 1, 0.35)
		colors[clr.ModalWindowDimBg] 		= ImVec4(0.88, 0.88, 0.88, 0.35)
	elseif configuration.main_settings.style == 6 then
		local generated_color				= monetlua.buildColors(configuration.main_settings.monetstyle, configuration.main_settings.monetstyle_chroma, true)
		colors[clr.Text]					= ColorAccentsAdapter(generated_color.accent2.color_50):as_vec4()
		colors[clr.TextDisabled]			= ColorAccentsAdapter(generated_color.neutral1.color_600):as_vec4()
		colors[clr.WindowBg]				= ColorAccentsAdapter(generated_color.accent2.color_900):as_vec4()
		colors[clr.ChildBg]					= ColorAccentsAdapter(generated_color.accent2.color_800):as_vec4()
		colors[clr.PopupBg]					= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
		colors[clr.Border]					= ColorAccentsAdapter(generated_color.accent3.color_300):apply_alpha(0xcc):as_vec4()
		colors[clr.Separator]					= ColorAccentsAdapter(generated_color.accent3.color_300):apply_alpha(0xcc):as_vec4()
		colors[clr.BorderShadow]			= imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x60):as_vec4()
		colors[clr.FrameBgHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x70):as_vec4()
		colors[clr.FrameBgActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x50):as_vec4()
		colors[clr.TitleBg]					= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
		colors[clr.TitleBgCollapsed]		= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0x7f):as_vec4()
		colors[clr.TitleBgActive]			= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
		colors[clr.MenuBarBg]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x91):as_vec4()
		colors[clr.ScrollbarBg]				= imgui.ImVec4(0,0,0,0)
		colors[clr.ScrollbarGrab]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x85):as_vec4()
		colors[clr.ScrollbarGrabHovered]	= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.ScrollbarGrabActive]		= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
		colors[clr.CheckMark]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
		colors[clr.SliderGrab]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
		colors[clr.SliderGrabActive]		= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x80):as_vec4()
		colors[clr.Button]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
		colors[clr.ButtonHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.ButtonActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
		colors[clr.Header]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
		colors[clr.HeaderHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.HeaderActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
		colors[clr.ResizeGrip]				= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
		colors[clr.ResizeGripHovered]		= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
		colors[clr.ResizeGripActive]		= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xb3):as_vec4()
		colors[clr.PlotLines]				= ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
		colors[clr.PlotLinesHovered]		= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.PlotHistogram]			= ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
		colors[clr.PlotHistogramHovered]	= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.TextSelectedBg]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.ModalWindowDimBg]		= ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0x26):as_vec4()
	else
		configuration.main_settings.style = 0
		checkstyle()
	end
end

function string.split(inputstr, sep)
	if sep == nil then
		sep = '%s'
	end
	local t={} ; i=1
	for str in gmatch(inputstr, '([^'..sep..']+)') do
		t[i] = str
		i = i + 1
	end
	return t
end

function string.separate(a)
	if type(a) ~= 'number' then
		return a
	end
	local b, e = gsub(format('%d', a), '^%-', '')
	local c = gsub(b:reverse(), '%d%d%d', '%1.')
	local d = gsub(c:reverse(), '^%.', '')
	return (e == 1 and '-' or '')..d
end

function string.rlower(s)
	local russian_characters = {
		[155] = '[', [168] = '¨', [184] = '¸', [192] = 'À', [193] = 'Á', [194] = 'Â', [195] = 'Ã', [196] = 'Ä', [197] = 'Å', [198] = 'Æ', [199] = 'Ç', [200] = 'È', [201] = 'É', [202] = 'Ê', [203] = 'Ë', [204] = 'Ì', [205] = 'Í', [206] = 'Î', [207] = 'Ï', [208] = 'Ð', [209] = 'Ñ', [210] = 'Ò', [211] = 'Ó', [212] = 'Ô', [213] = 'Õ', [214] = 'Ö', [215] = '×', [216] = 'Ø', [217] = 'Ù', [218] = 'Ú', [219] = 'Û', [220] = 'Ü', [221] = 'Ý', [222] = 'Þ', [223] = 'ß', [224] = 'à', [225] = 'á', [226] = 'â', [227] = 'ã', [228] = 'ä', [229] = 'å', [230] = 'æ', [231] = 'ç', [232] = 'è', [233] = 'é', [234] = 'ê', [235] = 'ë', [236] = 'ì', [237] = 'í', [238] = 'î', [239] = 'ï', [240] = 'ð', [241] = 'ñ', [242] = 'ò', [243] = 'ó', [244] = 'ô', [245] = 'õ', [246] = 'ö', [247] = '÷', [248] = 'ø', [249] = 'ù', [250] = 'ú', [251] = 'û', [252] = 'ü', [253] = 'ý', [254] = 'þ', [255] = 'ÿ',
	}
	s = lower(s)
	local strlen = len(s)
	if strlen == 0 then return s end
	s = lower(s)
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 192 and ch <= 223 then output = output .. russian_characters[ch + 32]
		elseif ch == 168 then output = output .. russian_characters[184]
		else output = output .. char(ch)
		end
	end
	return output
end

function isKeysDown(keylist, pressed)
	if keylist == nil then return end
	keylist = (find(keylist, '.+ %p .+') and {keylist:match('(.+) %p .+'), keylist:match('.+ %p (.+)')} or {keylist})
	local tKeys = keylist
	if pressed == nil then
		pressed = false
	end
	if tKeys[1] == nil then
		return false
	end
	local bool = false
	local key = #tKeys < 2 and tKeys[1] or tKeys[2]
	local modified = tKeys[1]
	if #tKeys < 2 then
		if wasKeyPressed(vkeys.name_to_id(key, true)) and not pressed then
			bool = true
		elseif isKeyDown(vkeys.name_to_id(key, true)) and pressed then
			bool = true
		end
	else
		if isKeyDown(vkeys.name_to_id(modified,true)) and not wasKeyReleased(vkeys.name_to_id(modified, true)) then
			if wasKeyPressed(vkeys.name_to_id(key, true)) and not pressed then
				bool = true
			elseif isKeyDown(vkeys.name_to_id(key, true)) and pressed then
				bool = true
			end
		end
	end
	if nextLockKey == keylist then
		if pressed and not wasKeyReleased(vkeys.name_to_id(key, true)) then
			bool = false
		else
			bool = false
			nextLockKey = ''
		end
	end
	return bool
end

function changePosition(table)
	lua_thread.create(function()
		local backup = {
			['x'] = table.posX,
			['y'] = table.posY
		}
		ChangePos = true
		sampSetCursorMode(4)
		addNotify('Íàæìèòå {MC}ËÊÌ{WC}, ÷òîáû ñîõðàíèòü\nìåñòîïîëîæåíèå, èëè {MC}ÏÊÌ{WC},\n÷òîáû îòìåíèòü', 5)
		while ChangePos do
			wait(0)
			local cX, cY = getCursorPos()
			table.posX = cX+10
			table.posY = cY+10
			if isKeyDown(0x01) then
				while isKeyDown(0x01) do wait(0) end
				ChangePos = false
				sampSetCursorMode(0)
				addNotify('Ïîçèöèÿ ñîõðàíåíà!', 5)
			elseif isKeyDown(0x02) then
				while isKeyDown(0x02) do wait(0) end
				ChangePos = false
				sampSetCursorMode(0)
				table.posX = backup['x']
				table.posY = backup['y']
				addNotify('Âû îòìåíèëè èçìåíåíèå\nìåñòîïîëîæåíèÿ', 5)
			end
		end
		ChangePos = false
		inicfg.save(configuration,'Med Helper')
	end)
end

function imgui.Link(link, text)
	text = text or link
	local tSize = imgui.CalcTextSize(text)
	local p = imgui.GetCursorScreenPos()
	local DL = imgui.GetWindowDrawList()
	local col = { 0xFFFF7700, 0xFFFF9900 }
	if imgui.InvisibleButton('##' .. link, tSize) then os.execute('explorer ' .. link) end
	local color = imgui.IsItemHovered() and col[1] or col[2]
	DL:AddText(p, color, text)
	DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end

function imgui.BoolButton(bool, name)
	if type(bool) ~= 'boolean' then return end
	if bool then
		local button = imgui.Button(name)
		return button
	else
		local col = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
		local r, g, b, a = col.x, col.y, col.z, col.w
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		local button = imgui.Button(name)
		imgui.PopStyleColor(2)
		return button
	end
end

function imgui.LockedButton(text, size)
	local col = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
	local r, g, b, a = col.x, col.y, col.z, col.w
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
	imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
	local button = imgui.Button(text, size)
	imgui.PopStyleColor(4)
	return button
end

function imgui.ChangeLogCircleButton(str_id, bool, color4, choosedcolor4, radius, filled)
	local rBool = false

	local p = imgui.GetCursorScreenPos()
	local radius = radius or 10
	local choosedcolor4 = choosedcolor4 or imgui.GetStyle().Colors[imgui.Col.Text]
	local filled = filled or false
	local draw_list = imgui.GetWindowDrawList()
	if imgui.InvisibleButton(str_id, imgui.ImVec2(23, 23)) then
		rBool = true
	end

	if filled then
		draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius, p.y + radius), radius+1, imgui.ColorConvertFloat4ToU32(choosedcolor4))
	else
		draw_list:AddCircle(imgui.ImVec2(p.x + radius, p.y + radius), radius+1, imgui.ColorConvertFloat4ToU32(choosedcolor4),_,2)
	end

	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius, p.y + radius), radius-3, imgui.ColorConvertFloat4ToU32(color4))
	imgui.SetCursorPosY(imgui.GetCursorPosY()+radius)
	return rBool
end

function imgui.CircleButton(str_id, bool, color4, radius, isimage)
	local rBool = false

	local p = imgui.GetCursorScreenPos()
	local isimage = isimage or false
	local radius = radius or 10
	local draw_list = imgui.GetWindowDrawList()
	if imgui.InvisibleButton(str_id, imgui.ImVec2(23, 23)) then
		rBool = true
	end
	
	if imgui.IsItemHovered() then
		imgui.SetMouseCursor(imgui.MouseCursor.Hand)
	end

	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius, p.y + radius), radius-3, imgui.ColorConvertFloat4ToU32(isimage and imgui.ImVec4(0,0,0,0) or color4))

	if bool then
		draw_list:AddCircle(imgui.ImVec2(p.x + radius, p.y + radius), radius, imgui.ColorConvertFloat4ToU32(color4),_,1.5)
		imgui.PushFont(font[8])
		draw_list:AddText(imgui.ImVec2(p.x + 6, p.y + 6), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]),fa.ICON_FA_CHECK);
		imgui.PopFont()
	end

	imgui.SetCursorPosY(imgui.GetCursorPosY()+radius)
	return rBool
end

function imgui.TextColoredRGB(text,align)
	local width = imgui.GetWindowWidth()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4

	local col = imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor)
	local r,g,b,a = col.x*255, col.y*255, col.z*255, col.w*255
	text = gsub(text, '{WC}', '{EBEBEB}')
	text = gsub(text, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))

	local getcolor = function(color)
		if upper(color:sub(1, 6)) == 'SSSSSS' then
			local r, g, b = colors[0].x, colors[0].y, colors[0].z
			local a = color:sub(7, 8) ~= 'FF' and (tonumber(color:sub(7, 8), 16)) or (colors[0].w * 255)
			return ImVec4(r, g, b, a / 255)
		end
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return ImVec4(r / 255, g / 255, b / 255, a / 255)
	end

	local render_text = function(text_)
		for w in gmatch(text_, '[^\r\n]+') do
			local textsize = gsub(w, '{.-}', '')
			local text_width = imgui.CalcTextSize(u8(textsize))
			if align == 1 then imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
			elseif align == 2 then imgui.SetCursorPosX(imgui.GetCursorPosX() + width - text_width.x - imgui.GetScrollX() - 2 * imgui.GetStyle().ItemSpacing.x - imgui.GetStyle().ScrollbarSize)
			end
			local text, colors_, m = {}, {}, 1
			w = gsub(w, '{(......)}', '{%1FF}')
			while find(w, '{........}') do
				local n, k = find(w, '{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end
			if text[0] then
				for i = 0, #text do
					imgui.TextColored(colors_[i] or colors[0], u8(text[i]))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	render_text(text)
end

function imgui.Hint(str_id, hint_text, color, no_center)
	if str_id == nil or hint_text == nil then
		return false
	end
	color = color or imgui.GetStyle().Colors[imgui.Col.PopupBg]
	local p_orig = imgui.GetCursorPos()
	local hovered = imgui.IsItemHovered()
	imgui.SameLine(nil, 0)

	local animTime = 0.2
	local show = true

	if not POOL_HINTS then POOL_HINTS = {} end
	if not POOL_HINTS[str_id] then
		POOL_HINTS[str_id] = {
			status = false,
			timer = 0
		}
	end

	if hovered then
		for k, v in pairs(POOL_HINTS) do
			if k ~= str_id and imgui.GetTime() - v.timer <= animTime  then
				show = false
			end
		end
	end

	if show and POOL_HINTS[str_id].status ~= hovered then
		POOL_HINTS[str_id].status = hovered
		POOL_HINTS[str_id].timer = imgui.GetTime()
	end

	local rend_window = function(alpha)
		local size = imgui.GetItemRectSize()
		local scrPos = imgui.GetCursorScreenPos()
		local DL = imgui.GetWindowDrawList()
		local center = imgui.ImVec2( scrPos.x - (size.x * 0.5), scrPos.y + (size.y * 0.5) - (alpha * 4) + 10 )
		local a = imgui.ImVec2( center.x - 7, center.y - size.y - 4 )
		local b = imgui.ImVec2( center.x + 7, center.y - size.y - 4)
		local c = imgui.ImVec2( center.x, center.y - size.y + 3 )
		local col = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color.x, color.y, color.z, alpha))

		DL:AddTriangleFilled(a, b, c, col)
		imgui.SetNextWindowPos(imgui.ImVec2(center.x, center.y - size.y - 3), imgui.Cond.Always, imgui.ImVec2(0.5, 1.0))
		imgui.PushStyleColor(imgui.Col.PopupBg, color)
		imgui.PushStyleColor(imgui.Col.Border, color)
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 8))
		imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 6)
		imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)

		local max_width = function(text)
			local result = 0
			for line in gmatch(text, '[^\n]+') do
				local len = imgui.CalcTextSize(line).x
				if len > result then
					result = len
				end
			end
			return result
		end

		local hint_width = max_width(u8(hint_text)) + (imgui.GetStyle().WindowPadding.x * 2)
		imgui.SetNextWindowSize(imgui.ImVec2(hint_width, -1), imgui.Cond.Always)
		imgui.Begin('##' .. str_id, _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
			for line in gmatch(hint_text, '[^\n]+') do
				if no_center then
					imgui.TextColoredRGB(line)
				else
					imgui.TextColoredRGB(line, 1)
				end
			end
		imgui.End()

		imgui.PopStyleVar(3)
		imgui.PopStyleColor(2)
	end

	if show then
		local between = imgui.GetTime() - POOL_HINTS[str_id].timer
		if between <= animTime then
			local alpha = hovered and ImSaturate(between / animTime) or ImSaturate(1 - between / animTime)
			rend_window(alpha)
		elseif hovered then
			rend_window(1.00)
		end
	end

	imgui.SetCursorPos(p_orig)
end

function bringVec4To(from, to, start_time, duration)
	local timer = clock() - start_time
	if timer >= 0.00 and timer <= duration then
		local count = timer / (duration / 100)
		return imgui.ImVec4(
			from.x + (count * (to.x - from.x) / 100),
			from.y + (count * (to.y - from.y) / 100),
			from.z + (count * (to.z - from.z) / 100),
			from.w + (count * (to.w - from.w) / 100)
		), true
	end
	return (timer > duration) and to or from, false
end

function getNote(note, post_color)
	local color = ARGBtoStringRGB(configuration.Checker.col_note)
	local post_c = ARGBtoStringRGB(post_color)

	note = note:gsub('\n.*', '...')
	note = note:gsub('{%x+}', '')

	return string.format('%s // %s%s', color, note, post_c)
end

function getAfk(rank, afk, post_color)
	local color = ARGBtoStringRGB(configuration.Checker.col_afk_max)
	local post_c = ARGBtoStringRGB(post_color)
	if rank <= 4 then
		if configuration.Checker.afk_max_l > 0 and afk >= configuration.Checker.afk_max_l then
			return string.format(' - %sAFK: %s%s', color, afk, post_c)
		end
	else
		if configuration.Checker.afk_max_h > 0 and afk >= configuration.Checker.afk_max_h then
			return string.format(' - %sAFK: %s%s', color, afk, post_c)
		end
	end
	return string.format(' - AFK: %s', afk)
end

function imgui.AnimButton(label, size, duration)
	if not duration then
		duration = 1.0
	end

	local cols = {
		default = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button]),
		hovered = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]),
		active  = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonActive])
	}

	if UI_ANIMBUT == nil then
		UI_ANIMBUT = {}
	end
	if not UI_ANIMBUT[label] then
		UI_ANIMBUT[label] = {
			color = cols.default,
			hovered = {
				cur = false,
				old = false,
				clock = nil,
			}
		}
	end
	local pool = UI_ANIMBUT[label]

	if pool['hovered']['clock'] ~= nil then
		if clock() - pool['hovered']['clock'] <= duration then
			pool['color'] = bringVec4To( pool['color'], pool['hovered']['cur'] and cols.hovered or cols.default, pool['hovered']['clock'], duration)
		else
			pool['color'] = pool['hovered']['cur'] and cols.hovered or cols.default
		end
	else
		pool['color'] = cols.default
	end

	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(pool['color']))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(pool['color']))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(pool['color']))
	local result = imgui.Button(label, size or imgui.ImVec2(0, 0))
	imgui.PopStyleColor(3)

	pool['hovered']['cur'] = imgui.IsItemHovered()
	if pool['hovered']['old'] ~= pool['hovered']['cur'] then
		pool['hovered']['old'] = pool['hovered']['cur']
		pool['hovered']['clock'] = clock()
	end

	return result
end

function imgui.ToggleButton(str_id, bool)
	local rBool = false

	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()
	local height = 20
	local width = height * 1.55
	local radius = height * 0.50
	local animTime = 0.13
	
	local color_active = imgui.GetStyle().Colors[imgui.Col.CheckMark]
	local color_inactive = imgui.ImVec4(100 / 255, 100 / 255, 100 / 255, 180 / 255)

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool[0] = not bool[0]
		rBool = true
		LastActiveTime[tostring(str_id)] = clock()
		LastActive[tostring(str_id)] = true
	end

	local hovered = imgui.IsItemHovered()

	imgui.SameLine()
	imgui.SetCursorPosY(imgui.GetCursorPosY()+3)
	imgui.Text(str_id)

	local t = bool[0] and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = clock() - LastActiveTime[tostring(str_id)]
		if time <= animTime then
			local t_anim = ImSaturate(time / animTime)
			t = bool[0] and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg = bringVec4To(not bool[0] and color_active or color_inactive, bool[0] and color_active or color_inactive, LastActiveTime[tostring(str_id)] or 0, animTime)

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), imgui.ColorConvertFloat4ToU32(col_bg), 10.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + (bool[0] and radius + 1.5 or radius - 3) + t * (width - radius * 2.0), p.y + radius), radius - 6, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]))

	return rBool
end

function getDownKeys()
	local curkeys = ''
	local bool = false
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT) then
			if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
				curkeys = v
			end
		end
	end
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT) then
			if len(tostring(curkeys)) == 0 then
				curkeys = v
				return curkeys,true
			else
				curkeys = curkeys .. ' ' .. v
				return curkeys,true
			end
			bool = false
		end
	end
	return curkeys, bool
end

function imgui.GetKeysName(keys)
	if type(keys) ~= 'table' then
	   	return false
	else
	  	local tKeysName = {}
	  	for k = 1, #keys do
			tKeysName[k] = vkeys.id_to_name(tonumber(keys[k]))
	  	end
	  	return tKeysName
	end
end

function imgui.HotKey(name, path, pointer, defaultKey, width)
	local width = width or 90
	local cancel = isKeyDown(0x08)
	local tKeys, saveKeys = string.split(getDownKeys(), ' '),select(2,getDownKeys())
	local name = tostring(name)
	local keys, bool = path[pointer] or defaultKey, false

	local sKeys = keys
	for i=0,2 do
		if imgui.IsMouseClicked(i) then
			tKeys = {i==2 and 4 or i+1}
			saveKeys = true
		end
	end

	if tHotKeyData.edit ~= nil and tostring(tHotKeyData.edit) == name then
		if not cancel then
			if not saveKeys then
				if #tKeys == 0 then
					sKeys = (ceil(imgui.GetTime()) % 2 == 0) and '______' or ' '
				else
					sKeys = table.concat(imgui.GetKeysName(tKeys), ' + ')
				end
			else
				path[pointer] = table.concat(imgui.GetKeysName(tKeys), ' + ')
				tHotKeyData.edit = nil
				tHotKeyData.lasted = clock()
				inicfg.save(configuration,'Med Helper')
			end
		else
			path[pointer] = defaultKey
			tHotKeyData.edit = nil
			tHotKeyData.lasted = clock()
			inicfg.save(configuration,'Med Helper')
		end
	end

	imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.FrameBg])
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.FrameBgActive])
	if imgui.Button((sKeys ~= '' and sKeys or u8'Ñâîáîäíî') .. '## '..name, imgui.ImVec2(width, 0)) then
		tHotKeyData.edit = name
	end
	imgui.PopStyleColor(3)
	return bool
end

function addNotify(msg, time)
	local col = imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor)
	local r,g,b = col.x*255, col.y*255, col.z*255
	msg = gsub(msg, '{WC}', '{SSSSSS}')
	msg = gsub(msg, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))

	notify.msg[#notify.msg+1] = {text = msg, time = time, active = true, justshowed = nil}
end

local imgui_fm = imgui.OnFrame(
	function() return windows.imgui_fm[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		if not IsPlayerConnected(fastmenuID) then
			windows.imgui_fm[0] = false
			MedHelperMessage('Èãðîê ñ êîòîðûì Âû âçàèìîäåéñòâîâàëè âûøåë èç èãðû!')
			return false
		end
			imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.Always)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.7),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0,0))
			imgui.Begin(u8'Ìåíþ áûñòðîãî äîñòóïà', windows.imgui_fm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
				if imgui.IsWindowAppearing() then
					newwindowtype[0] = 1
					clienttype[0] = 0
				end
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 300, p.y), imgui.ImVec2(p.x + 300, p.y + 330), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 2)
				imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 300, p.y + 75), imgui.ImVec2(p.x + 500, p.y + 75), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 2)

				imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0,0,0,0))
				imgui.SetCursorPos(imgui.ImVec2(0, 25))
				imgui.BeginChild('##fmmainwindow', imgui.ImVec2(300, -1), false)
					if newwindowtype[0] == 1 then
						if clienttype[0] == 0 then
							imgui.SetCursorPos(imgui.ImVec2(7.5,15))
							imgui.BeginGroup()
								if configuration.main_settings.myrankint >= 1 then
									if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30)) then
										getmyrank = true
										sampSendChat('/stats')
										if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
											sendchatarray(configuration.main_settings.playcd, {
												{'Äîáðîå óòðî. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
												{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											})
										elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
											sendchatarray(configuration.main_settings.playcd, {
												{'Äîáðûé äåíü. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
												{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											})
										elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
											sendchatarray(configuration.main_settings.playcd, {
												{'Äîáðûé âå÷åð. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
												{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											})
										elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
											sendchatarray(configuration.main_settings.playcd, {
												{'Äîáðîé íî÷è. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
												{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											})
										end
									end
								else
									imgui.LockedButton(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30))
									imgui.Hint('firstranghello', 'Ñ 1-ãî ðàíãà')
								end
								if configuration.main_settings.myrankint >= 1  then
									if imgui.Button(fa.ICON_FA_FILE_ALT..u8' ×òî áîëèò?', imgui.ImVec2(285,30)) then
										sendchatarray(configuration.main_settings.playcd, {
											{'×òî ó Âàñ áîëèò?'},
											{'/n Óêàæèòå ÐÏ ïðè÷èíó.'},
										})
									end
								else
									imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Âûëå÷èòü èãðîêà', imgui.ImVec2(285,30))
									imgui.Hint('firstrangpricelist', 'Ñ 1-ãî ðàíãà')
								end
								if configuration.main_settings.myrankint >= 1  then
									if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Âûëå÷èòü èãðîêà', imgui.ImVec2(285,30)) then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me íûðíóâ ïðàâîé ðóêîé â êàðìàí, {gender:âûòÿíóë|âûòÿíóëà} îòòóäà áëîêíîò è ðó÷êó'},
											{'/todo Òàê-òàê, õîðîøî, íå âîëíóéòåñü*çàïèñàâ âñå ñêàçàííîå ÷åëîâåêîì íàïðîòèâ'},
											{'/me äâèæåíèåì ïðàâîé ðóêè {gender:îòêðûë|îòêðûëà} ìåä.êåéñ'},
											{'/me íåñêîëüêèìè äâèæåíèÿìè ðóê {gender:íàøåë|íàøëà} íóæíîå ëåêàðñòâî â ìåä.÷åìîäàíå'},
											{'/do Ëåêàðñòâî â ïðàâîé ðóêå.'},
											{'/me àêêóðàòíûì äâèæåíèåì ðóêè {gender:ïåðåäàë|ïåðåäàëà} ëåêàðñòâî ïàöèåíòó'},
											{'Ïðèíèìàéòå ýòè òàáëåòêè, è ÷åðåç íåêîòîðîå âðåìÿ âàì ñòàíåò ëó÷øå.'},
											{'/heal %s %s',fastmenuID, configuration.main_settings.heal},
										})
									end
								else
									imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Âûëå÷èòü èãðîêà', imgui.ImVec2(285,30))
									imgui.Hint('firstrangpricelist', 'Ñ 1-ãî ðàíãà')
								end
								if configuration.main_settings.myrankint >= 2  then
									if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Ëå÷åíèå â êàðåòå', imgui.ImVec2(285,30)) then
										sendchatarray(configuration.main_settings.playcd, {
											{'/do Ìåäèöèíñêàÿ ñóìêà íà ïëå÷å %s.', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											{'/me ïðàâîé ðóêîé {gender:ðàññòåãíóë|ðàññòåãíóëà} ìåäèöèíñêóþ ñóìêó è äîñòàë íóæíîå ëåêàðñòâî'},
											{'/me {gender:ïðîòÿíóë|ïðîòÿíóëà} ëåêàðñòâî ÷åëîâåêó'},
											{'/heal %s %s',fastmenuID, configuration.main_settings.heal},
										})
									end
								else
									imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Ëå÷åíèå â êàðåòå', imgui.ImVec2(285,30))
									imgui.Hint('firstrangpricelist', 'Ñî 2-ãî ðàíãà')
								end
								if configuration.main_settings.myrankint >= 1  then
									if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Âûäàòü àíòèáèîòèêè', imgui.ImVec2(285,30)) then
										sendchatarray(configuration.main_settings.playcd, {
											{'Ñòîèìîñòü îäíîãî àíòèáèîòèêà %s$.', string.separate(configuration.main_settings.antibio)},
											{'Ïîäîæäèòå íåìíîãî,ñåé÷àñ ÿ âñå ïîäãîòîâëþ.'},
											{'/me îñòîðîæíûì äâèæåíèåì ïðàâîé ðóêè {gender:îòêðûë|îòêðûëà} øêàô÷èê ðåñåïøåíà'},
											{'/do Øêàô÷èê îòêðûò.'},
											{'/me ïðàâîé ðóêîé {gender:âçÿë|âçÿëà} ëèñò áóìàãè íà êîòîðîì íàïèñàíî "Àíòèáèîòèêè"'},
											{'/do Ëèñò áóìàãè íà êîòîðîì íàïèñàíî "Àíòèáèîòèêè" â ïðàâîé ðóêå.'},
											{'/me çàïîëíÿåò áëàíê íà ëåêàðñòâà'},
											{'/me {gender:ïîëîæë|ïîëîæèëà} ëèñò áóìàãè è ðó÷êó â øêàô÷èê,ïîñëå ÷åãî {gender:çàêðûë|çàêðûëà} åãî'},
											{'/todo Îòëè÷íî*îáðàùàÿñü ê ïàöèåíòó'},
											{'Ñåé÷àñ ÿ âàì âûäàì àíòèáèîòèêè.'},
											{'/me {gender:îòêðûë|îòêðûëà} ïðàâîé ðóêîé ìåä.êåéñ'},
											{'/me ëåâîé ðóêîé {gender:äîñòàë|äîñòàëà} íóæíîå êîëè÷åñòâî àíòèáèîòèêîâ è {gender:ïåðåäàë|ïåðåäàëà} èõ ïàöèåíòó'},
											{'/todo Óäà÷íîãî âàì äíÿ,íå áîëåéòå*îáðàùàÿñü ê ïàöèåíòó.'},
										})
										sampSetChatInputEnabled(true)
										sampSetChatInputText('/antibiotik')
									end
								else
									imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Âûäàòü àíòèáèîòèê', imgui.ImVec2(285,30))
									imgui.Hint('firstrangpricelist', 'Ñ 4-ãî ðàíãà')
								end
								if configuration.main_settings.myrankint >= 1  then
									if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Ðåàíèìàöèÿ', imgui.ImVec2(285,30)) then
										sendchatarray(configuration.main_settings.playcd, {
											{'/todo ×òî-òî åìó âîîáùå íå õîðîøî*ñíèìàÿ ìåäèöèíñêóþ ñóìêó ñ ïëå÷à'},
											{'/me ñòàâèò ìåäèöèíñêóþ ñóìêó âîçëå ïîñòðàäàâøåãî'},
											{'/do Ìåä. ñóìêà íà çåìëå.'},
											{'/me íàêëîíÿåòñÿ íàä òåëîì, çàòåì ïðîùóïûâàåò ïóëüñ íà ñîííîé àðòåðèè'},
											{'/do Ïóëüñ ñëàáûé.'},
											{'/me íà÷èíàåò íåïðÿìîé ìàññàæ ñåðäöà, âðåìÿ îò âðåìåíè ïðîâåðÿÿ ïóëüñ'},
											{'/do Ñåðäöå ïàöèåíòà íà÷àëî áèòüñÿ.'},
											{'/cure %s',fastmenuID},
										})
									end
								else
									imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Ðåàíèìàöèÿ', imgui.ImVec2(285,30))
									imgui.Hint('firstrangpricelist', 'Ñ 5-ãî ðàíãà')
								end
								if configuration.main_settings.myrankint >= 2 then
									if imgui.Button(fa.ICON_FA_REPLY..u8' Âûãíàòü èç áîëüíèöû', imgui.ImVec2(285,30)) then
										imgui.OpenPopup('##changeexpelreason')
									end
									imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
									if imgui.BeginPopup('##changeexpelreason') then
										imgui.Text(u8'Ïðè÷èíà /expel:')
										if imgui.InputText('##expelreasonbuff',usersettings.expelreason, sizeof(usersettings.expelreason)) then
											configuration.main_settings.expelreason = u8:decode(str(usersettings.expelreason))
											inicfg.save(configuration,'Med Helper')
										end
										if imgui.Button(u8"Âûãíàòü", imgui.ImVec2(-1, 25)) then
											if not sampIsPlayerPaused(fastmenuID) then
												windows.imgui_fm[0] = false
												sendchatarray(configuration.main_settings.playcd, {
													{'/me {gender:ñõâàòèë|ñõâàòèëà} ÷åëîâåêà çà ðóêó è {gender:ïîâåë|ïîâåëà} ê âûõîäó'},
													{'/me îòêðûâ äâåðü ðóêîé, {gender:âûâåë|âûâåëà} ÷åëîâåêà íà óëèöó'},
													{'/expel %s %s', fastmenuID, configuration.main_settings.expelreason},
												})
											else
												MedHelperMessage('Èãðîê íàõîäèòñÿ â ÀÔÊ!')
											end
										end
										imgui.EndPopup()
									end
									imgui.PopStyleVar()
								else
									imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Âûãíàòü èç áîëüíèöû', imgui.ImVec2(285,30))
									imgui.Hint('secondrangexpel', 'Ñî 2-ãî ðàíãà')
								end
							imgui.EndGroup()				
						end

					elseif newwindowtype[0] == 2 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if medtap[0] == 0 then
							imgui.TextColoredRGB('Ìåä.êàðòà: Ýòàï 1',1)
							imgui.Separator()
							medtimeid = 0
							imgui.SetCursorPosX(7.5)
							if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30)) then
								getmyrank = true
								sampSendChat('/stats')
								if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîå óòðî. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé äåíü. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé âå÷åð. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîé íî÷è. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïîïðîñèòü äîêóìåíòû '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local result, mid = sampGetPlayerIdByCharHandle(playerPed)
										local m = configuration.med_settings
										sendchatarray(configuration.main_settings.playcd, {
											{'Äëÿ îôîðìëåíèÿ ìåäèöèíñêîé êàðòû ïðåäîñòàâüòå, ïîæàëóéñòà, Âàø ïàñïîðò.'},
											{'/b /showpass %s', mid},
										})
										medtap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if medtap[0] == 1 then
							imgui.TextColoredRGB('Ìåä.êàðòà: Ýòàï 2',1)
							imgui.Separator()
							if configuration.med_settings.pass then
								imgui.TextColoredRGB(med_results.pass and 'Ïàñïîðò - ïîêàçàí ('..med_results.pass..')' or 'Ïàñïîðò - íå ïîêàçàí',1)
							end
							if (med_results.pass == 'ìåíüøå 4 ëåò â øòàòå') then
								imgui.SetCursorPosX(7.5)
								if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/todo Áëàãîäîðþ âàñ!*âçÿâ ïàñïîðò â ðóêè è {gender:íà÷àë|íà÷àëà} åãî èçó÷àòü'},
											{'Äëÿ îôîðìëåíèÿ êàðòû íåîáõîäèìî çàïëàòèòü ãîñ.ïîøëèíó, êîòîðàÿ çàâèñèò îò ñðîêà êàðòû.'},
											{'Íà 7 äíåé - %s$, Íà 14 äíåé - %s$.',string.separate(configuration.main_settings.medcard74),string.separate(configuration.main_settings.medcard14)},
											{'Íà 30 äíåé - %s$, Íà 60 äíåé - %s$.',string.separate(configuration.main_settings.medcard30),string.separate(configuration.main_settings.medcard60)},
											{'Íà êàêîé ñðîê Âû õîòèòå îôîðìèòü ìåä.êàðòó?'},
											{'/b Îïëà÷èâàòü íå íóæíî, ñèñòåìà ñàìà îòíèìåò ó âàñ äåíüãè (ïðè ñîãëàñèè).'},
										})
										medtap[0] = 2
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
								
							end
							if (med_results.pass == 'â ïîðÿäêå') then
								imgui.SetCursorPosX(7.5)
								if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/todo Áëàãîäîðþ âàñ!*âçÿâ ïàñïîðò â ðóêè è {gender:íà÷àë|íà÷àëà} åãî èçó÷àòü'},
											{'Äëÿ îôîðìëåíèÿ êàðòû íåîáõîäèìî çàïëàòèòü ãîñ.ïîøëèíó, êîòîðàÿ çàâèñèò îò ñðîêà êàðòû.'},
											{'Íà 7 äíåé - %s$, Íà 14 äíåé - %s$.',string.separate(configuration.main_settings.medcard7),string.separate(configuration.main_settings.medcard14)},
											{'Íà 30 äíåé - %s$, Íà 60 äíåé - %s$.',string.separate(configuration.main_settings.medcard30),string.separate(configuration.main_settings.medcard60)},
											{'Íà êàêîé ñðîê Âû õîòèòå îôîðìèòü ìåä.êàðòó?'},
											{'/b Îïëà÷èâàòü íå íóæíî, ñèñòåìà ñàìà îòíèìåò ó âàñ äåíüãè (ïðè ñîãëàñèè).'},
										})
										medtap[0] = 2
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if medtap[0] == 2 then
							imgui.TextColoredRGB('Ìåä.êàðòà: Ýòàï 3',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'7 äíåé', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Õîðîøî, òîãäà ïðèñòóïèì ê îôîðìëåíèþ.'},
										{'/me {gender:âûòàùèë|âûòàùèëà} èç íàãðóäíîãî êàðìàíà øàðèêîâóþ ðó÷êó'},
										{'/do Ðó÷êà â ïðàâîé ðóêå.'},
										{'/me {gender:îòêðûë|îòêðûëà} øêàô÷èê, çàòåì {gender:äîñòàë|äîñòàëà} îòòóäà ïóñòûå áëàíêè äëÿ ìåä.êàðòû'},
										{'/me {gender:ðàçëîæèë|ðàçëîæèëà} ïàëüöàìè ïðàâîé ðóêè ïàñïîðò íà íóæíîé ñòðàíè÷êå è {gender:íà÷àë|íà÷àëà} ïåðåïèñûâàòü äàííûå â áëàíê'},
										{'/me {gender:îòêðûë|îòêðûëà} ïóñòóþ ìåä.êàðòó è ïàñïîðò, çàòåì {gender:íà÷àë|íà÷àëà} ïåðåïèñûâàòü äàííûå èç ïàñïîðòà'},
										{'/do Ñïóñòÿ ìèíóòó äàííûå ïàñïîðòà áûëè ïåðåïèñàíû íà áëàíê.'},
										{'/me {gender:îòëîæèë|îòëîæèëà} ïàñïîðò â ñòîðîíó åãî õîçÿèíà è {gender:ïðèãîòîâèëñÿ|ïðèãîòîâèëàñü} ê ïðîäîëæåíèþ çàíåñåíèÿ èíôîðìàöèè'},
										{'Òàê, ñåé÷àñ çàäàì íåñêîëüêî âîïðîñîâ êàñàåìî çäîðîâüÿ...'},
									})
									medtimeid = 0
									medtap[0] = 3
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'14 äíåé', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Õîðîøî, òîãäà ïðèñòóïèì ê îôîðìëåíèþ.'},
										{'/me {gender:âûòàùèë|âûòàùèëà} èç íàãðóäíîãî êàðìàíà øàðèêîâóþ ðó÷êó'},
										{'/do Ðó÷êà â ïðàâîé ðóêå.'},
										{'/me {gender:îòêðûë|îòêðûëà} øêàô÷èê, çàòåì {gender:äîñòàë|äîñòàëà} îòòóäà ïóñòûå áëàíêè äëÿ ìåä.êàðòû'},
										{'/me {gender:ðàçëîæèë|ðàçëîæèëà} ïàëüöàìè ïðàâîé ðóêè ïàñïîðò íà íóæíîé ñòðàíè÷êå è {gender:íà÷àë|íà÷àëà} ïåðåïèñûâàòü äàííûå â áëàíê'},
										{'/me {gender:îòêðûë|îòêðûëà} ïóñòóþ ìåä.êàðòó è ïàñïîðò, çàòåì {gender:íà÷àë|íà÷àëà} ïåðåïèñûâàòü äàííûå èç ïàñïîðòà'},
										{'/do Ñïóñòÿ ìèíóòó äàííûå ïàñïîðòà áûëè ïåðåïèñàíû íà áëàíê.'},
										{'/me {gender:îòëîæèë|îòëîæèëà} ïàñïîðò â ñòîðîíó åãî õîçÿèíà è {gender:ïðèãîòîâèëñÿ|ïðèãîòîâèëàñü} ê ïðîäîëæåíèþ çàíåñåíèÿ èíôîðìàöèè'},
										{'Òàê, ñåé÷àñ çàäàì íåñêîëüêî âîïðîñîâ êàñàåìî çäîðîâüÿ...'},
									})
									medtimeid = 1
									medtap[0] = 3
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'30 äíåé', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Õîðîøî, òîãäà ïðèñòóïèì ê îôîðìëåíèþ.'},
										{'/me {gender:âûòàùèë|âûòàùèëà} èç íàãðóäíîãî êàðìàíà øàðèêîâóþ ðó÷êó'},
										{'/do Ðó÷êà â ïðàâîé ðóêå.'},
										{'/me {gender:îòêðûë|îòêðûëà} øêàô÷èê, çàòåì {gender:äîñòàë|äîñòàëà} îòòóäà ïóñòûå áëàíêè äëÿ ìåä.êàðòû'},
										{'/me {gender:ðàçëîæèë|ðàçëîæèëà} ïàëüöàìè ïðàâîé ðóêè ïàñïîðò íà íóæíîé ñòðàíè÷êå è {gender:íà÷àë|íà÷àëà} ïåðåïèñûâàòü äàííûå â áëàíê'},
										{'/me {gender:îòêðûë|îòêðûëà} ïóñòóþ ìåä.êàðòó è ïàñïîðò, çàòåì {gender:íà÷àë|íà÷àëà} ïåðåïèñûâàòü äàííûå èç ïàñïîðòà'},
										{'/do Ñïóñòÿ ìèíóòó äàííûå ïàñïîðòà áûëè ïåðåïèñàíû íà áëàíê.'},
										{'/me {gender:îòëîæèë|îòëîæèëà} ïàñïîðò â ñòîðîíó åãî õîçÿèíà è {gender:ïðèãîòîâèëñÿ|ïðèãîòîâèëàñü} ê ïðîäîëæåíèþ çàíåñåíèÿ èíôîðìàöèè'},
										{'Òàê, ñåé÷àñ çàäàì íåñêîëüêî âîïðîñîâ êàñàåìî çäîðîâüÿ...'},
									})
									medtimeid = 2
									medtap[0] = 3
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'60 äíåé', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Õîðîøî, òîãäà ïðèñòóïèì ê îôîðìëåíèþ.'},
										{'/me {gender:âûòàùèë|âûòàùèëà} èç íàãðóäíîãî êàðìàíà øàðèêîâóþ ðó÷êó'},
										{'/do Ðó÷êà â ïðàâîé ðóêå.'},
										{'/me {gender:îòêðûë|îòêðûëà} øêàô÷èê, çàòåì {gender:äîñòàë|äîñòàëà} îòòóäà ïóñòûå áëàíêè äëÿ ìåä.êàðòû'},
										{'/me {gender:ðàçëîæèë|ðàçëîæèëà} ïàëüöàìè ïðàâîé ðóêè ïàñïîðò íà íóæíîé ñòðàíè÷êå è {gender:íà÷àë|íà÷àëà} ïåðåïèñûâàòü äàííûå â áëàíê'},
										{'/me {gender:îòêðûë|îòêðûëà} ïóñòóþ ìåä.êàðòó è ïàñïîðò, çàòåì {gender:íà÷àë|íà÷àëà} ïåðåïèñûâàòü äàííûå èç ïàñïîðòà'},
										{'/do Ñïóñòÿ ìèíóòó äàííûå ïàñïîðòà áûëè ïåðåïèñàíû íà áëàíê.'},
										{'/me {gender:îòëîæèë|îòëîæèëà} ïàñïîðò â ñòîðîíó åãî õîçÿèíà è {gender:ïðèãîòîâèëñÿ|ïðèãîòîâèëàñü} ê ïðîäîëæåíèþ çàíåñåíèÿ èíôîðìàöèè'},
										{'Òàê, ñåé÷àñ çàäàì íåñêîëüêî âîïðîñîâ êàñàåìî çäîðîâüÿ...'},
									})
									medtimeid = 3
									medtap[0] = 3
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end
					
						if medtap[0] == 3 then
							imgui.TextColoredRGB('Ìåä.êàðòà: Ýòàï 4',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Æàëîáû íà çäîðîâüå...', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Æàëîáû íà çäîðîâüå èìåþòñÿ?')
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Âðåäíûå ïðèâû÷êè...', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Èìåþòñÿ ëè âðåäíûå ïðèâû÷êè, à òàêæå àëëåðãè÷åñêèå ðåàêöèè?')
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïðîäîëæèòü', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Õîðîøî, ñåé÷àñ ñïðîøó ïàðó âîïðîñîâ ïî îöåíêå ïñèõè÷åñêîãî ñîñòîÿíèÿ.')
									medtap[0] = 4
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end
					
						if medtap[0] == 4 then
							imgui.TextColoredRGB('Ìåä.êàðòà: Ýòàï 5',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ñîí', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Êàê âû ñïèòå?'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Íà âàñ åäåò àâòî...', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Ïðåäñòàâüòå, ÷òî Âû íàõîäèòåñü â öåíòðå äîðîãè...'},
										{' ...è íà âàñ åäåò ñ áîëüøîé ñêîðîñòüþ ìàññèâíîå àâòî.'},
										{'×òî âû ñäåëàåòå?'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïñèõîëîãè÷åñêîå ñîñòîÿíèå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Êàê áû âû îïèñàëè ñâîå ïñèõîëîãè÷åñêîå ñîñòîÿíèå?')
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Íàïðÿæåíèå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Êàê äîëãî âû ïåðåæèâàåòå íàïðÿæåíèå?')
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïðîäîëæèòü', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('/me {gender:çàïèñàë|çàïèñàëà} âñå ñêàçàííîå ïàöèåíòîì â ìåä.êàðòó')
									medtap[0] = 5
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end
					
						if medtap[0] == 5 then
							imgui.TextColoredRGB('Ìåä.êàðòà: Âûäà÷à',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïîëíîñòüþ çäîðîâ(à)', imgui.ImVec2(285,30)) then
								if not inprocess then
									if (medtimeid == 0 and sampGetPlayerScore(fastmenuID) < 5) then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïîëíîñòüþ çäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 3 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard74},
										})
									elseif (medtimeid == 0 and sampGetPlayerScore(fastmenuID) > 4) then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïîëíîñòüþ çäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 3 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard7},
										})
									elseif medtimeid == 1 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïîëíîñòüþ çäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 3 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard14},
										})
									elseif medtimeid == 2 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïîëíîñòüþ çäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 3 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard30},
										})
									elseif medtimeid == 3 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïîëíîñòüþ çäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 3 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard60},
										})
									end
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Íàáëþäàþòñÿ îòêëîíåíèÿ', imgui.ImVec2(285,30)) then
								if not inprocess then
									if (medtimeid == 0 and med_results.pass == 'ìåíüøå 4 ëåò â øòàòå') then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íàáëþäàþòñÿ îòêëîíåíèÿ."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 2 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard74},
										})
									elseif (medtimeid == 0 and med_results.pass == 'â ïîðÿäêå') then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íàáëþäàþòñÿ îòêëîíåíèÿ."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 2 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard7},
										})
									elseif medtimeid == 1 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íàáëþäàþòñÿ îòêëîíåíèÿ."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 2 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard14},
										})
									elseif medtimeid == 2 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íàáëþäàþòñÿ îòêëîíåíèÿ."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 2 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard30},
										})
									elseif medtimeid == 3 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íàáëþäàþòñÿ îòêëîíåíèÿ."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 2 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard60},
										})
									end
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïñèõè÷åñêè íåçäîðîâ(à)', imgui.ImVec2(285,30)) then
								if not inprocess then
									if (medtimeid == 0 and med_results.pass == 'ìåíüøå 4 ëåò â øòàòå') then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïñèõè÷åñêè íåçäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 1 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard74},
										})
									elseif (medtimeid == 0 and med_results.pass == 'â ïîðÿäêå') then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïñèõè÷åñêè íåçäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 1 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard7},
										})
									elseif medtimeid == 1 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïñèõè÷åñêè íåçäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 1 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard14},
										})
									elseif medtimeid == 2 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïñèõè÷åñêè íåçäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 1 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard30},
										})
									elseif medtimeid == 3 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Ïñèõè÷åñêè íåçäîðîâ(à)."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 1 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard60},
										})
									end
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Íå îïðåäåëåí', imgui.ImVec2(285,30)) then
								if not inprocess then
									if (medtimeid == 0 and med_results.pass == 'ìåíüøå 4 ëåò â øòàòå') then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íå îïðåäåëåíî."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 0 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard74},
										})
									elseif (medtimeid == 0 and med_results.pass == 'â ïîðÿäêå') then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íå îïðåäåëåíî."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 0 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard7},
										})
									elseif medtimeid == 1 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íå îïðåäåëåíî."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 0 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard14},
										})
									elseif medtimeid == 2 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íå îïðåäåëåíî."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 0 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard30},
										})
									elseif medtimeid == 3 then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñü íàïðîòèâ ïóíêòà "Ïñèõ. Çäîðîâüå." - "Íå îïðåäåëåíî."'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ïðàâóþ ðóêó èç ÿùèêà ñòîëà è {gender:íàíåñ|íàíåñëà} îòòèñê â óãëó áëàíêà'},
											{'/do Ïå÷àòü íàíåñåíà.'},
											{'/me îòëîæèâ øòàìï â ñòîðîíó, {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü è ñåãîäíÿøíþþ äàòó'},
											{'/do Ñòðàíèöà ìåä.êàðòû çàïîëíåíà.'},
											{'Âñ¸ ãîòîâî, äåðæèòå ñâîþ ìåä.êàðòó, íå áîëåéòå.'},
											{'Óäà÷íîãî äíÿ.'},
											{'/medcard %s 0 %s %s', fastmenuID, medtimeid, configuration.main_settings.medcard60},
										})
									end
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if medtap[0] ~= 0 then
							if imgui.InvisibleButton('##medbackbutton',imgui.ImVec2(55,15)) then
								if medtap[0] ~= 0 then medtap[0] = medtap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if medtap[0] ~= 5 and medtap[0] ~= 2 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##medforwardbutton',imgui.ImVec2(125,15)) then
								medtap[0] = medtap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end

					elseif newwindowtype[0] == 3 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if osmtap[0] == 0 then
							imgui.TextColoredRGB('Ìåä.Îñìîòð: Ïðèâåòñòâèå',1)
							imgui.Separator()
							medtimeid = 0
							imgui.SetCursorPosX(7.5)
							if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30)) then
								getmyrank = true
								sampSendChat('/stats')
								if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîå óòðî. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé äåíü. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé âå÷åð. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîé íî÷è. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïðîâåñòè â îïåðàöèîííóþ '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local result, mid = sampGetPlayerIdByCharHandle(playerPed)
										sendchatarray(configuration.main_settings.playcd, {
											{'Ñòîèìîñòü ìåä.îñòàòðà - %s$.', string.separate(configuration.main_settings.osm)},
											{'Åñëè âû ñîãëàñíû, òîãäà ïðîéäåìòå â îïåðàöèîííóþ.'},
										})
										osmtap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if osmtap[0] == 1 then
							imgui.TextColoredRGB('Ïðîâåäåíèå ìåä.îñìîòðà',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ñïðîñèòü ìåä.êàðòó', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Ïîæàëóéñòà, ïðåäîñòàâüòå Âàøó ìåä.êàðòó'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Âîïðîñû î çäîðîâüå', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:âçÿë|âçÿëà} ìåä.êàðòó èç ðóê ÷åëîâåêà íàïðîòèâ'},
											{'/do Ìåä.êàðòà â ðóêàõ.'},
											{'/me {gender:äîñòàë|äîñòàëà} ðó÷êó èç íàãðóäíîãî êàðìàíà, ïðèãîòîâèâøèñü ê çàïîëíåíèþ'},
											{'Èòàê, ñåé÷àñ ÿ çàäàì íåêîòîðûå âîïðîñû äëÿ îöåíêè ñîñòîÿíèÿ çäîðîâüÿ.'},
											{'Äàâíî ëè Âû áîëåëè? Åñëè äà, òî êàêèìè áîëåçíÿìè.'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Áûëè ëè òðàâìû?', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Áûëè ëè ó Âàñ òðàâìû?'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Àëëåðãè÷åñêèå ðåàêöèè', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Èìåþòñÿ ëè êàêèå-òî àëëåðãè÷åñêèå ðåàêöèè?'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Âèçóàëüíûé îñìîòð', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/medcheck %s %s', fastmenuID, configuration.main_settings.osm},
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñè â ìåä. êàðòå'},
											{'/do Â êàðìàíå ôîíàðèê.'},
											{'/me {gender:äîñòàë|äîñòàëà} ôîíàðèê èç êàðìàíà è âêëþ÷èë åãî'},
											{'/me {gender:ïðîâåðèë|ïðîâåðèëà} ðåàêöèÿ çðà÷êîâ ïàöèåíòà íà ñâåò, ïîñâåòèâ â ãëàçà'},
											{'/do Çðà÷îêè ãëàç îáñëåäóåìîãî ñóçèëèñü.'},
											{'/me {gender:âûêëþ÷èë|âûêëþ÷èëà} ôîíàðèê è {gender:óáðàë|óáðàëà} åãî â êàðìàí'},
											{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñè â ìåä. êàðòå'},
											{'/me {gender:âåðíóë|âåðíóëà} ìåä.êàðòó ÷åëîâåêó íàïðîòèâ'},
											{'Ñïàñèáî, ìîæåòå áûòü ñâîáîäíû'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if osmtap[0] ~= 0 then
							if imgui.InvisibleButton('##medbackbutton',imgui.ImVec2(55,15)) then
								if osmtap[0] ~= 0 then osmtap[0] = osmtap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if osmtap[0] ~= 1 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##medforwardbutton',imgui.ImVec2(125,15)) then
								osmtap[0] = osmtap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end
						
						elseif newwindowtype[0] == 4 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if rectap[0] == 0 then
							imgui.TextColoredRGB('Ðåöåïò: Ïðèâåòñòâèå',1)
							imgui.Separator()
							medtimeid = 0
							imgui.SetCursorPosX(7.5)
							if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30)) then
								getmyrank = true
								sampSendChat('/stats')
								if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîå óòðî. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé äåíü. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé âå÷åð. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîé íî÷è. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ñòîèìîñòü ðåöåïòîâ '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local result, mid = sampGetPlayerIdByCharHandle(playerPed)
										sendchatarray(configuration.main_settings.playcd, {
											{'ß ïðàâèëüíî {gender:ïîíÿë|ïîíÿëà}, Âàì íóæåí ðåöåïò?'},
											{'Ñòîèìîñòü 1 ðåöåïòà %s$.', string.separate(configuration.main_settings.recept)},
											{'Ñêîëüêî ðåöåïòîâ âàì íóæíî?'},
											{'/b Îïëà÷èâàòü íå íóæíî, ñèñòåìà ñàìà îòíèìåò ó âàñ äåíüãè (ïðè ñîãëàñèè).'},
											{'/b Âíèìàíèå! Â òå÷åíèå ÷àñà âûäàåòñÿ ìàêñèìóì 5 ðåöåïòîâ!'},
										})
										rectap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if rectap[0] == 1 then
							imgui.TextColoredRGB('Ðåöåïò: Âûäà÷à',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'1 ðåöåïò', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/do Íà ïëå÷å âåñèò ìåä. ñóìêà.'},
											{'/me {gender:ñíÿë|ñíÿëà} ìåä. ñóìêó ñ ïëå÷à, ïîñëå ÷åãî {gender:îòêðûë|îòêðûëà} åå'},
											{'/me {gender:äîñòàë|äîñòàëà} áëàíêè è ðó÷êó, ïðèãîòîâèâøèñü ê çàïîëíåíèþ'},
											{'/me çàïîëíÿåò áëàíêè íà îôîðìëåíèå ëåêàðñòâ, âïèñûâàÿ âñå äàííûå'},
											{'/do Áëàíêè çàïîëíåíû.'},
											{'/me {gender:ïîñòàâèë|ïîñòàâèëà} ïå÷àòü ìåäèöèíñêîãî öåíòðà è ñâîþ ïîäïèñü'},
											{'/me {gender:çàêðûë|çàêðûëà} ìåä. ñóìêó, âåøàÿ åå îáðàòíî íà ïëå÷î'},
											{'/recept %s 1', fastmenuID},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'2 ðåöåïòà', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/do Íà ïëå÷å âåñèò ìåä. ñóìêà.'},
											{'/me {gender:ñíÿë|ñíÿëà} ìåä. ñóìêó ñ ïëå÷à, ïîñëå ÷åãî {gender:îòêðûë|îòêðûëà} åå'},
											{'/me {gender:äîñòàë|äîñòàëà} áëàíêè è ðó÷êó, ïðèãîòîâèâøèñü ê çàïîëíåíèþ'},
											{'/me çàïîëíÿåò áëàíêè íà îôîðìëåíèå ëåêàðñòâ, âïèñûâàÿ âñå äàííûå'},
											{'/do Áëàíêè çàïîëíåíû.'},
											{'/me {gender:ïîñòàâèë|ïîñòàâèëà} ïå÷àòü ìåäèöèíñêîãî öåíòðà è ñâîþ ïîäïèñü'},
											{'/me {gender:çàêðûë|çàêðûëà} ìåä. ñóìêó, âåøàÿ åå îáðàòíî íà ïëå÷î'},
											{'/recept %s 2', fastmenuID},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'3 ðåöåïòà', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/do Íà ïëå÷å âåñèò ìåä. ñóìêà.'},
											{'/me {gender:ñíÿë|ñíÿëà} ìåä. ñóìêó ñ ïëå÷à, ïîñëå ÷åãî {gender:îòêðûë|îòêðûëà} åå'},
											{'/me {gender:äîñòàë|äîñòàëà} áëàíêè è ðó÷êó, ïðèãîòîâèâøèñü ê çàïîëíåíèþ'},
											{'/me çàïîëíÿåò áëàíêè íà îôîðìëåíèå ëåêàðñòâ, âïèñûâàÿ âñå äàííûå'},
											{'/do Áëàíêè çàïîëíåíû.'},
											{'/me {gender:ïîñòàâèë|ïîñòàâèëà} ïå÷àòü ìåäèöèíñêîãî öåíòðà è ñâîþ ïîäïèñü'},
											{'/me {gender:çàêðûë|çàêðûëà} ìåä. ñóìêó, âåøàÿ åå îáðàòíî íà ïëå÷î'},
											{'/recept %s 3', fastmenuID},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'4 ðåöåïòà', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/do Íà ïëå÷å âåñèò ìåä. ñóìêà.'},
											{'/me {gender:ñíÿë|ñíÿëà} ìåä. ñóìêó ñ ïëå÷à, ïîñëå ÷åãî {gender:îòêðûë|îòêðûëà} åå'},
											{'/me {gender:äîñòàë|äîñòàëà} áëàíêè è ðó÷êó, ïðèãîòîâèâøèñü ê çàïîëíåíèþ'},
											{'/me çàïîëíÿåò áëàíêè íà îôîðìëåíèå ëåêàðñòâ, âïèñûâàÿ âñå äàííûå'},
											{'/do Áëàíêè çàïîëíåíû.'},
											{'/me {gender:ïîñòàâèë|ïîñòàâèëà} ïå÷àòü ìåäèöèíñêîãî öåíòðà è ñâîþ ïîäïèñü'},
											{'/me {gender:çàêðûë|çàêðûëà} ìåä. ñóìêó, âåøàÿ åå îáðàòíî íà ïëå÷î'},
											{'/recept %s 4', fastmenuID},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'5 ðåöåïòîâ', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/do Íà ïëå÷å âåñèò ìåä. ñóìêà.'},
											{'/me {gender:ñíÿë|ñíÿëà} ìåä. ñóìêó ñ ïëå÷à, ïîñëå ÷åãî {gender:îòêðûë|îòêðûëà} åå'},
											{'/me {gender:äîñòàë|äîñòàëà} áëàíêè è ðó÷êó, ïðèãîòîâèâøèñü ê çàïîëíåíèþ'},
											{'/me çàïîëíÿåò áëàíêè íà îôîðìëåíèå ëåêàðñòâ, âïèñûâàÿ âñå äàííûå'},
											{'/do Áëàíêè çàïîëíåíû.'},
											{'/me {gender:ïîñòàâèë|ïîñòàâèëà} ïå÷àòü ìåäèöèíñêîãî öåíòðà è ñâîþ ïîäïèñü'},
											{'/me {gender:çàêðûë|çàêðûëà} ìåä. ñóìêó, âåøàÿ åå îáðàòíî íà ïëå÷î'},
											{'/recept %s 5', fastmenuID},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if rectap[0] ~= 0 then
							if imgui.InvisibleButton('##medbackbutton',imgui.ImVec2(55,15)) then
								if rectap[0] ~= 0 then rectap[0] = rectap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if rectap[0] ~= 1 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##medforwardbutton',imgui.ImVec2(125,15)) then
								rectap[0] = rectap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end

					elseif newwindowtype[0] == 5 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if narkotap[0] == 0 then
							imgui.TextColoredRGB('Íàðêîçàâèñèìîñòü: Ïðèâåòñòâèå',1)
							imgui.Separator()
							medtimeid = 0
							imgui.SetCursorPosX(7.5)
							if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30)) then
								getmyrank = true
								sampSendChat('/stats')
								if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîå óòðî. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé äåíü. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé âå÷åð.ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîé íî÷è. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local result, mid = sampGetPlayerIdByCharHandle(playerPed)
										sendchatarray(configuration.main_settings.playcd, {
											{'Ïåðåä ñåàíñîì ëå÷åíèÿ ÿ {gender:äîëæåí|äîëæåíà} âàñ óâåäîìèòü î öåíîâîé ïîëèòèêå äàííîé ïðîöåäóðû.'},
											{'Ñòîèìîñòü îäíîãî ñåàíñà ñîñòàâëÿåò -  %s$.', string.separate(configuration.main_settings.narko)},
											{'Åñëè âû ñîãëàñíû, òî äàâàéòå ïðîäîëæèì â îïåðàöèîííîé.'},
											{'/b Îïëà÷èâàòü íå íóæíî, ñèñòåìà ñàìà îòíèìåò ó âàñ äåíüãè (ïðè ñîãëàñèè).'},
										})
										narkotap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if narkotap[0] == 1 then
							imgui.TextColoredRGB('Íàðêîçàâèñèìîñòü: Óêîë',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïðèñàæèâàéòåñü..', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Ïðèñàæèâàéòåñü è çàêàòàéòå ðóêàâ.'},
											{'/me íàäåâ ïåð÷àòêè, äîñòàåò èç ìåä ñóìêè øïðèö è ëåêàðñòâî'},
											{'/do Â ðóêå âðà÷à íà êîëáå ñ ïðåïàðàòîì âèäíååòñÿ ÷àñòü íàçâàíèÿ "Ðåàì".'},
											{'/me îòëîìèâ êîëáó, íàáèðàåò â øïðèö ëåêàðñòâî'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Óêîë', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me äîñòàåò ïðîñïèðòîâàííóþ âàòó è ïðîòèðàåò ìåñòî ïîä óêîë'},
											{'/me ïðèëîæèâ øïðèö, ïðîêàëûâàåò êîæó'},
											{'/do Èãëà ìÿãêî âîøëà â êîæó è ëåêàðñòâî ââåäåíî.'},
											{'/todo Âîò è âñå, ìîæåòå èäòè *âûòàñêèâàÿ èãëó'},
											{'/me âûêèäûâàåò èñïîëüçîâàííûé øïðèö â ìóñîðíîå âåäðî'},
											{'/healbad %s', fastmenuID},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if narkotap[0] ~= 0 then
							if imgui.InvisibleButton('##medbackbutton',imgui.ImVec2(55,15)) then
								if narkotap[0] ~= 0 then narkotap[0] = narkotap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if narkotap[0] ~= 1 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##medforwardbutton',imgui.ImVec2(125,15)) then
								narkotap[0] = narkotap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end


					elseif newwindowtype[0] == 6 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if strtap[0] == 0 then
							imgui.TextColoredRGB('Ñòðàõîâêà: Ïðèâåòñòâèå',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30)) then
								getmyrank = true
								sampSendChat('/stats')
								if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîå óòðî. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé äåíü. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé âå÷åð. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîé íî÷è. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïðàéñ ëèñò', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Õîðîøî, ñåé÷àñ îôîðìëþ Âàì ñòðàõîâêó.'},
											{'ß ìîãó îôîðìèòü Âàì ñòðàõîâêó òîëüêî íà îäèí èç òð¸õ ñðîêîâ.'},
											{'Íà 7 äíåé, íà 14 äíåé è íà 21 äåíü.'},
											{'/do Íà ñòîëå ëåæèò ïðàéñ-ëèñò.'},
											{'/todo Âîò íàø ïðàéñ-ëèñò*ïîäîäâèíóâ ïðàéñ-ëèñò ê ïàöèåíòó'},
											{'/do Íà ïðàéñ-ëèñòå íàïèñàíî:'},
											{'/do Íà Ñåìü äíåé: %s$.', string.separate(configuration.main_settings.str7)},
											{'/do Íà ×åòûðíàäöàòü äíåé: %s$.', string.separate(configuration.main_settings.str14)},
											{'/do Íà Äâàäöàòü îäèí äåíü: %s$.', string.separate(configuration.main_settings.str21)},
											{'Êàêîé ñðîê Âû õîòèòå îôîðìèòü?'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'íà 7 äíåé '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							local result, mid = sampGetPlayerIdByCharHandle(playerPed)
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Õîðîøî, îôîðìëþ Âàì ñòðàõîâêó íà 7 äíåé.'},
											{'Íî ïåðåä íà÷àëîì ìíå íóæíî èçó÷èòü Âàø ïàñïîðò.'},
											{'/b /showpass %s', mid},
										})
										strtap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Íà 14 äíåé '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							local result, mid = sampGetPlayerIdByCharHandle(playerPed)
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Õîðîøî, îôîðìëþ Âàì ñòðàõîâêó íà 14 äíåé.'},
											{'Íî ïåðåä íà÷àëîì ìíå íóæíî èçó÷èòü Âàø ïàñïîðò.'},
											{'/b /showpass %s', mid},
										})
										strtap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Íà 21 äåíü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							local result, mid = sampGetPlayerIdByCharHandle(playerPed)
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Õîðîøî, îôîðìëþ Âàì ñòðàõîâêó íà 21 äíåíü.'},
											{'Íî ïåðåä íà÷àëîì ìíå íóæíî èçó÷èòü Âàø ïàñïîðò.'},
											{'/b /showpass %s', mid},
										})
										strtap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if strtap[0] == 1 then
							imgui.TextColoredRGB('Ñòðàõîâêà: Âûäà÷à',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Çàïîëíåíèå áëàíêà', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/todo Áëàãîäàðþ!*âçÿâ ïàñïîðò â ðóêè è {gender:ïðèíÿëñÿ|ïðèíÿëàñü} åãî èçó÷àòü'},
											{'/do Íà ñòîëå ñòîÿò íîóòáóê è ïîäêëþ÷¸ííûé ê íåìó ïðèíòåð.'},
											{'/me {gender:ïðèíÿëñÿ|ïðèíÿëàñü} ÷òî-òî ïå÷àòàòü â íîóòáóêå'},
											{'/me {gender:çàêîí÷èë|çàêîí÷èëà} çàïîëíÿòü áëàíê íà âûäà÷ó ñòðàõîâêè è {gender:ðàñïå÷àòàë|ðàñïå÷àòàëà} äîêóìåíò'},
											{'/do Â áëàíêå ñòðàõîâêè íàïèñàíà ñåãîäíÿøíÿÿ äàòà è äàííûå î ïàöèåíòå.'},
											{'Âîò òóò íóæíà Âàøà ïîäïèñü.'},
											{'/me {gender:ïîâåðíóë|ïîâåðíóëà} áëàíê ê ÷åëîâåêó è {gender:óêàçàë|óêàçàëà} ïàëüöåì íà îáëàñòü â áëàíêå'},
											{'/n /me ïîñòàâèë(à) ñâîþ ïîäïèñü'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Âûäà÷à', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:ïîâåðíóë|ïîâåðíóëà} áëàíê â ñâîþ ñòîðîíó, {gender:âçÿë|âçÿëà} ðó÷êó â ðóêè è {gender:ïîñòàâèë|ïîñòàâèëà} ñâîþ ïîäïèñü'},
											{'/me {gender:âçÿë|âçÿëà} øòàìï â ðóêè è {gender:ïîñòàâèë|ïîñòàâèëà} øòàìï %s', configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
											{'/todo Âîò Âàøà ñòðàõîâêà*ïåðåäàâ äîêóìåíò è ïàñïîðò ÷åëîâåêó íàïðîòèâ'},
											{'/givemedinsurance %s', fastmenuID},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if strtap[0] ~= 0 then
							if imgui.InvisibleButton('##medbackbutton',imgui.ImVec2(55,15)) then
								if strtap[0] ~= 0 then strtap[0] = strtap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if strtap[0] ~= 1 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##medforwardbutton',imgui.ImVec2(125,15)) then
								strtap[0] = strtap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end

					elseif newwindowtype[0] == 7 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if tatutap[0] == 0 then
							imgui.TextColoredRGB('Âûâåäåíèå òàòó: Ïðèâåòñòâèå',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30)) then
								getmyrank = true
								sampSendChat('/stats')
								if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîå óòðî. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé äåíü. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðûé âå÷åð. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîáðîé íî÷è. ß, %s, {gender:ñîòðóäíèê|ñîòðóäíèöà} %s, ÷òî Âàñ áåñïîêîèò?', #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname), configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïîïðîñèòü äîêóìåíòû ', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local result, mid = sampGetPlayerIdByCharHandle(playerPed)
										sendchatarray(configuration.main_settings.playcd, {
											{'Âû íàñ÷åò âûâåäåíèÿ òàòóèðîâêè?'},
											{'Ïîêàæèòå Âàø ïàñïîðò, ïîæàëóéñòà.'},
											{'/b /showmc %s', mid},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïðîâåðêà ïàñïîðòà', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me âçÿâ ïàñïîðò {gender:ïðîâåðèë|ïðîâåðèëà} åãî ïî áàçå äàííûõ'},
											{'/todo Âû îòëè÷íî ïîëó÷èëèñü íà ôîòî â ïàñïîðòå*óëûáàÿñü'},
											{'/me {gender:âåðíóë|âåðíóëà} ïàñïîðò ÷åëîâåêó íàïðîòèâ'},
											{'Ñòîèìîñòü âûâåäåíèÿ òàòóèðîâêè ñîñòàâèò - %s$.',string.separate(configuration.main_settings.tatu)},
											{'Åñëè âû ñîãëàñíû, òî äàâàéòå ïðîäîëæèì â îïåðàöèîííîé.'},
										})
										tatutap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if tatutap[0] == 1 then
							imgui.TextColoredRGB('Óäàëåíèå òàòó: Âûâåäåíèå',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïîêàæèòå òóòó..', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'Îòëè÷íî. À òåïåðü ñíèìàéòå ñ ñåáÿ ðóáàøêó, ÷òîá ÿ {gender:âûâåë|âûâåëà} âàøè òàòó.'},
											{'/b /showtatu'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Âûâåäåíèå', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/do Àïïàðàò äëÿ âûâåäåíèÿ òàòó â ìåä.ñóìêå.'},
											{'/me {gender:ïîòÿíóëñÿ|ïîòÿíóëàñü} ðóêîé â ìåä.ñóìêó çà àïïàðàòîì äëÿ âûâåäåíèÿ òàòóèðîâêè'},
											{'/do Àïïàðàò â ïðàâîé ðóêå.'},
											{'/me âçÿâ àïïàðàò, {gender:îòìîòðåë|îòñìîòðåëà} ïàöèåíòà è {gender:ïðèíÿëñÿ|ïðèíÿëàñü} âûâîäèòü òàòóèðîâêó'},
											{'/unstuff %s %s', fastmenuID, configuration.main_settings.tatu},
											{'Âñ¸, âàø ñåàíñ îêîí÷åí.'},
											{'Âñåãî Âàì õîðîøåãî!'},
										})
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if tatutap[0] ~= 0 then
							if imgui.InvisibleButton('##medbackbutton',imgui.ImVec2(55,15)) then
								if tatutap[0] ~= 0 then tatutap[0] = tatutap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if tatutap[0] ~= 1 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##medforwardbutton',imgui.ImVec2(125,15)) then
								tatutap[0] = tatutap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end

					elseif newwindowtype[0] == 8 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if osmotrtap[0] == 0 then
							imgui.TextColoredRGB('Îñìîòð: Ýòàï 1',1)
							imgui.Separator()
							medtimeid = 0
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïîïðîñèòü ìåä.êàðòó ', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local result, mid = sampGetPlayerIdByCharHandle(playerPed)
										sendchatarray(configuration.main_settings.playcd, {
											{'Çäðàâñòâóéòå, ñåé÷àñ ÿ ïðîâåäó äëÿ Âàñ íåáîëüøîå ìåä.îáñëåäîâàíèå.'},
											{'Ïðåäîñòàâüòå ïîæàëóéñòà, ìåä. êàðòó.'},
										})
										osmotrtap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if osmotrtap[0] == 1 then
							imgui.TextColoredRGB('Îñìîòð: Ýòàï 2',1)
							imgui.Separator()
							if configuration.med_settings.pass then
								imgui.TextColoredRGB(sobes_results.medcard and 'Ìåä. êàðòà - ïîêàçàíà ('..sobes_results.medcard..')' or 'Ìåä. êàðòà - íå ïîêàçàíà',1)
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:âçÿë|âçÿëà} ìåä.êàðòó èç ðóê ÷åëîâåê'},
										{'/do Ìåä.êàðòà â ðóêàõ.'},
										{'Èòàê, ñåé÷àñ ÿ çàäàì íåêîòîðûå âîïðîñû äëÿ îöåíêè ñîñòîÿíèÿ çäîðîâüÿ.'},
									})
									osmotrtap[0] = 2
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
								
						end

						if osmotrtap[0] == 2 then
							imgui.TextColoredRGB('Îñìîòð: Ýòàï 3',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Äàâíî áîëåëè?', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat("Äàâíî ëè Âû áîëåëè? Åñëè äà, òî êàêèìè áîëåçíÿìè.")
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Áûëè ëè ó Âàñ òðàâìû?', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat("Áûëè ëè ó Âàñ òðàâìû?")
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Àëëåðãè÷åñêèå ðåàêöèè', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat("Èìåþòñÿ ëè êàêèå-òî àëëåðãè÷åñêèå ðåàêöèè?")
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
								if not inprocess then
									osmotrtap[0] = 3
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end

						if osmotrtap[0] == 3 then
							imgui.TextColoredRGB('Îñìîòð: Ýòàï 4',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Çàïèñè â ìåä. êàðòå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñè â ìåä.êàðòå'},
										{'Òàê, îòêðîéòå ðîò.'},
										{'/b /me îòêðûë(à) ðîò'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Âèçóàëüíûé îñìîòð', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'/do Â êàðìàíå ôîíàðèê.'},
										{'/me {gender:äîñòàë|äîñòàëà} ôîíàðèê èç êàðìàíà è {gender:âêëþ÷èë|âêëþ÷èëà} åãî'},
										{'/me {gender:îñìîòðåë|îñìîòðåëà} ãîðëî ïàöèåíòà'},
										{'Ìîæåòå çàêðûòü ðîò.'},
										{'/me {gender:ïðîâåðèë|ïðîâåðèëà} ðåàêöèþ çðà÷êîâ ïàöèåíòà íà ñâåò, ïîñâåòèâ â ãëàçà'},
										{'/do Çðà÷êè ãëàç îáñëåäóåìîãî ñóçèëèñü.'},
										{'/me {gender:âûêëþ÷èë|âûêëþ÷èëà} ôîíàðèê è {gender:óáðàë|óáðàëà} åãî â êàðìàí'},
										{'Ïðèñÿäüòå, ïîæàëóéñòà, íà êîðòî÷êè è êîñíèòåñü êîí÷èêîì ïàëüöà äî íîñà.'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Âîçâðàò ìåä.êàðòû', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñè â ìåä.êàðòå'},
										{'/me {gender:âåðíóë|âåðíóëà} ìåä.êàðòó ÷åëîâåêó íàïðîòèâ'},
										{'Ñïàñèáî, ìîæåòå áûòü ñâîáîäíû.'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if osmotrtap[0] ~= 0 then
							if imgui.InvisibleButton('##medbackbutton',imgui.ImVec2(55,15)) then
								if osmotrtap[0] ~= 0 then osmotrtap[0] = osmotrtap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if osmotrtap[0] ~= 3 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##medforwardbutton',imgui.ImVec2(125,15)) then
								osmotrtap[0] = osmotrtap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end

					elseif newwindowtype[0] == 9 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if psihtap[0] == 0 then
							imgui.TextColoredRGB('Ïñèõîëîãè÷åñêèé îñìîòð: Ýòàï 1',1)
							imgui.Separator()
							medtimeid = 0
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïîïðîñèòü ìåä.êàðòó ', imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local result, mid = sampGetPlayerIdByCharHandle(playerPed)
										sendchatarray(configuration.main_settings.playcd, {
											{'Çäðàâñòâóéòå, ñåé÷àñ ÿ ïðîâåäó ó Âàñ íåáîëüøîé ïñèõîëîãè÷åñêèé îñìîòð.'},
											{'Ïðåäîñòàâüòå ïîæàëóéñòà, ìåä. êàðòó.'},
										})
										psihtap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if psihtap[0] == 1 then
							imgui.TextColoredRGB('Ïñèõîëîãè÷åñêèé îñìîòð: Ýòàï 2',1)
							imgui.Separator()
							if configuration.med_settings.pass then
								imgui.TextColoredRGB(sobes_results.medcard and 'Ìåä. êàðòà - ïîêàçàíà ('..sobes_results.medcard..')' or 'Ìåä. êàðòà - íå ïîêàçàíà',1)
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:âçÿë|âçÿëà} ìåä.êàðòó èç ðóê ÷åëîâåê'},
										{'/do Ìåä.êàðòà â ðóêàõ.'},
										{'Èòàê, ñåé÷àñ ÿ çàäàì íåêîòîðûå âîïðîñû äëÿ îöåíêè ïñèõîëîãè÷åñêîãî ñîñòîÿíèÿ.'},
									})
									psihtap[0] = 2
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
								
						end

						if psihtap[0] == 2 then
							imgui.TextColoredRGB('Ïñèõîëîãè÷åñêèé îñìîòð: Ýòàï 3',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïñèõîëîãè÷åñêîå ñîñòîÿíèå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat("Êàê áû âû îïèñàëè ñâîå ïñèõîëîãè÷åñêîå ñîñòîÿíèå?")
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Íàïðÿæåíèå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat("Êàê äîëãî âû ïåðåæèâàåòå íàïðÿæåíèå?")
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Íåóâåðåííîñòü â ñåáå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat("Îùóùàåòå ëè âû íåóâåðåííîñòü â ñåáå?")
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
								if not inprocess then
									psihtap[0] = 3
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end

						if psihtap[0] == 3 then
							imgui.TextColoredRGB('Ïñèõîëîãè÷åñêèé îñìîòð: Ýòàï 3',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ýìîöèîíàëüíîå ñîñòîÿíèå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat("Èçìåíèëîñü ëè âàøå ýìîöèîíàëüíîå ñîñòîÿíèå?")
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïåðåïàäû íàñòðîåíèÿ', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat("Áûâàþò ëè ó âàñ ðåçêèå ïåðåïàäû íàñòðîåíèÿ?")
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Îùóùåíèå ðèñêà', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Äîñòàâëÿåò ëè âàì óäîâîëüñòâèå îùóùåíèå ðèñêà?'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
								if not inprocess then
									psihtap[0] = 4
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end

						if psihtap[0] == 4 then
							imgui.TextColoredRGB('Ïñèõîëîãè÷åñêèé îñìîòð: Ýòàï 4',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Èçìåíåíèÿ â ñåêñóàëüíîé ñôåðå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Ïðîèçîøëè ëè ó âàñ èçìåíåíèÿ â ñåêñóàëüíîé ñôåðå?'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ñîí', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Êàê âû ñïèòå?'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïðîáëåìû ñ àïïåòèòîì', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Ó âàñ åñòü ïðîáëåìû ñ àïïåòèòîì?'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Äûõàíèå', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'Åñòü ëè ó âàñ íåïðèÿòíûå îùóùåíèÿ ïî ÷àñòè îðãàíîâ äûõàíèÿ?'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Âîçâðàò ìåä.êàðòû', imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:ñäåëàë|ñäåëàëà} çàïèñè â ìåä.êàðòå'},
										{'/me {gender:âåðíóë|âåðíóëà} ìåä.êàðòó ÷åëîâåêó íàïðîòèâ'},
										{'Ñïàñèáî, ìîæåòå áûòü ñâîáîäíû.'},
									})
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if psihtap[0] ~= 0 then
							if imgui.InvisibleButton('##medbackbutton',imgui.ImVec2(55,15)) then
								if psihtap[0] ~= 0 then psihtap[0] = psihtap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if psihtap[0] ~= 4 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##medforwardbutton',imgui.ImVec2(125,15)) then
								psihtap[0] = psihtap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end

					elseif newwindowtype[0] == 10 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if sobesetap[0] == 0 then
							imgui.TextColoredRGB('Ñîáåñåäîâàíèå: Ýòàï 1',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïîïðèâåòñòâîâàòü', imgui.ImVec2(285,30)) then
								sendchatarray(configuration.main_settings.playcd, {
									{'Çäðàâñòâóéòå, ÿ %s %s, Âû ïðèøëè íà ñîáåñåäîâàíèå?', configuration.RankNames[configuration.main_settings.myrankint], configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
									{'/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
								})
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Ïîïðîñèòü äîêóìåíòû '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(5, 5))
								imgui.BeginTooltip()
								imgui.Text(u8'ËÊÌ äëÿ òîãî, ÷òîáû ïðîäîëæèòü\nÏÊÌ äëÿ òîãî, ÷òîáû íàñòðîèòü äîêóìåíòû')
								imgui.EndTooltip()
								imgui.PopStyleVar()

								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local s = configuration.sobes_settings
										local out = (s.pass and 'ïàñïîðò' or '')..
													(s.medcard and (s.pass and ', ìåä. êàðòó' or 'ìåä. êàðòó') or '')..
													(s.wbook and ((s.pass or s.medcard) and ', òðóäîâóþ êíèæêó' or 'òðóäîâóþ êíèæêó') or '')..
													(s.licenses and ((s.pass or s.medcard or s.wbook) and ', ëèöåíçèè' or 'ëèöåíçèè') or '')
										sendchatarray(0, {
											{'Õîðîøî, ïîêàæèòå ìíå âàøè äîêóìåíòû, à èìåííî: %s', out},
											{'/n Îáÿçàòåëüíî ïî ðï!'},
										})
										sobesetap[0] = 1
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
								if imgui.IsMouseReleased(1) then
									imgui.OpenPopup('##redactdocuments')
								end
							end
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
							if imgui.BeginPopup('##redactdocuments') then
								if imgui.ToggleButton(u8'Ïðîâåðÿòü ïàñïîðò', sobes_settings.pass) then
									configuration.sobes_settings.pass = sobes_settings.pass[0]
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.ToggleButton(u8'Ïðîâåðÿòü ìåä. êàðòó', sobes_settings.medcard) then
									configuration.sobes_settings.medcard = sobes_settings.medcard[0]
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.ToggleButton(u8'Ïðîâåðÿòü òðóäîâóþ êíèãó', sobes_settings.wbook) then
									configuration.sobes_settings.wbook = sobes_settings.wbook[0]
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.ToggleButton(u8'Ïðîâåðÿòü ëèöåíçèè', sobes_settings.licenses) then
									configuration.sobes_settings.licenses = sobes_settings.licenses[0]
									inicfg.save(configuration,'Med Helper')
								end
								imgui.EndPopup()
							end
							imgui.PopStyleVar()
						end
					
						if sobesetap[0] == 1 then
							imgui.TextColoredRGB('Ñîáåñåäîâàíèå: Ýòàï 2',1)
							imgui.Separator()
							if configuration.sobes_settings.pass then
								imgui.TextColoredRGB(sobes_results.pass and 'Ïàñïîðò - ïîêàçàí ('..sobes_results.pass..')' or 'Ïàñïîðò - íå ïîêàçàí',1)
							end
							if configuration.sobes_settings.medcard then
								imgui.TextColoredRGB(sobes_results.medcard and 'Ìåä. êàðòà - ïîêàçàíà ('..sobes_results.medcard..')' or 'Ìåä. êàðòà - íå ïîêàçàíà',1)
							end
							if configuration.sobes_settings.wbook then
								imgui.TextColoredRGB(sobes_results.wbook and 'Òðóäîâàÿ êíèæêà - ïîêàçàíà' or 'Òðóäîâàÿ êíèæêà - íå ïîêàçàíà',1)
							end
							if configuration.sobes_settings.licenses then
								imgui.TextColoredRGB(sobes_results.licenses and 'Ëèöåíçèè - ïîêàçàíû ('..sobes_results.licenses..')' or 'Ëèöåíçèè - íå ïîêàçàíû',1)
							end
							if (configuration.sobes_settings.pass == true and sobes_results.pass == 'â ïîðÿäêå' or configuration.sobes_settings.pass == false) and
							(configuration.sobes_settings.medcard == true and sobes_results.medcard == 'â ïîðÿäêå' or configuration.sobes_settings.medcard == false) and
							(configuration.sobes_settings.wbook == true and sobes_results.wbook == 'ïðèñóòñòâóåò' or configuration.sobes_settings.wbook == false) and
							(configuration.sobes_settings.licenses == true and sobes_results.licenses ~= nil or configuration.sobes_settings.licenses == false) then
								imgui.SetCursorPosX(7.5)
								if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me âçÿâ äîêóìåíòû èç ðóê ÷åëîâåêà íàïðîòèâ {gender:íà÷àë|íà÷àëà} èõ ïðîâåðÿòü'},
											{'/todo Õîðîøî...* îòäàâàÿ äîêóìåíòû îáðàòíî'},
											{'Ñåé÷àñ ÿ çàäàì Âàì íåñêîëüêî âîïðîñîâ, Âû ãîòîâû íà íèõ îòâå÷àòü?'},
										})
										sobesetap[0] = 2
									else
										MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
									end
								end
							end
						end
					
						if sobesetap[0] == 2 then
							imgui.TextColoredRGB('Ñîáåñåäîâàíèå: Ýòàï 3',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ðàññêàæèòå íåìíîãî î ñåáå.', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Ðàññêàæèòå íåìíîãî î ñåáå.')
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïî÷åìó âûáðàëè èìåííî íàñ?', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Ïî÷åìó Âû âûáðàëè èìåííî íàñ?')
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ðàáîòàëè Âû ó íàñ ðàíåå? '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Ðàáîòàëè Âû ó íàñ ðàíåå? Åñëè äà, òî ðàññêàæèòå ïîäðîáíåå')
									sobesetap[0] = 3
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
						end
					
						if sobesetap[0] == 3 then
							imgui.TextColoredRGB('Ñîáåñåäîâàíèå: Ðåøåíèå',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
							if imgui.Button(u8'Ïðèíÿòü', imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Îòëè÷íî, ÿ äóìàþ Âû íàì ïîäõîäèòå!'},
										{'/do Êëþ÷è îò øêàô÷èêà â êàðìàíå.'},
										{'/me âñóíóâ ðóêó â êàðìàí áðþê, {gender:äîñòàë|äîñòàëà} îòòóäà êëþ÷ îò øêàô÷èêà'},
										{'/me {gender:ïåðåäàë|ïåðåäàëà} êëþ÷ ÷åëîâåêó íàïðîòèâ'},
										{'Äîáðî ïîæàëîâàòü! Ïåðåîäåòüñÿ âû ìîæåòå â ðàçäåâàëêå.'},
										{'Ñî âñåé èíôîðìàöèåé Âû ìîæåòå îçíàêîìèòüñÿ íà îô. ïîðòàëå.'},
										{'/invite %s', fastmenuID},
									})
								else
									sendchatarray(configuration.main_settings.playcd, {
										{'Îòëè÷íî, ÿ äóìàþ Âû íàì ïîäõîäèòå!'},
										{'/r %s óñïåøíî ïðîø¸ë ñîáåñåäîâàíèå! Ïðîøó ïîäîéòè êî ìíå, ÷òîáû ïðèíÿòü åãî.', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')},
										{'/rb %s id', fastmenuID},
									})
								end
								windows.imgui_fm[0] = false
							end
							imgui.PopStyleColor(2)
							imgui.SetCursorPosX(7.5)
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
							if imgui.Button(u8'Îòêëîíèòü', imgui.ImVec2(285,30)) then
								lastsobesetap[0] = sobesetap[0]
								sobesetap[0] = 7
							end
							imgui.PopStyleColor(2)
						end
					
						if sobesetap[0] == 7 then
							imgui.TextColoredRGB('Ñîáåñåäîâàíèå: Îòêëîíåíèå',1)
							imgui.Separator()
							imgui.PushItemWidth(270)
							imgui.SetCursorPosX(15)
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
							imgui.Combo('##declinesobeschoosereasonselect',sobesdecline_select, new['const char*'][6]({u8'Ïëîõîå ÐÏ',u8'Íå áûëî ÐÏ',u8'Ïëîõàÿ ãðàììàòèêà',u8'Íè÷åãî íå ïîêàçàë',u8'Îïå÷àòêà â ïàñïîðòå',u8'Äðóãîå'}), 6)
							imgui.PopStyleVar()
							imgui.PopItemWidth()
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) * 0.5)
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
							if imgui.Button(u8'Îòêëîíèòü', imgui.ImVec2(270,30)) then
								if not inprocess then
									if sobesdecline_select[0] == 0 then
										sampSendChat('Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü Âàñ èç-çà òîãî, ÷òî Âû ïðîô. íåïðèãîäíû.')
										sampSendChat('/b Î÷åíü ïëîõîå ÐÏ.')
									elseif sobesdecline_select[0] == 1 then
										sampSendChat('Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü Âàñ èç-çà òîãî, ÷òî Âû ïðîô. íåïðèãîäíû.')
										sampSendChat('/b Íå áûëî ÐÏ.')
									elseif sobesdecline_select[0] == 2 then
										sampSendChat('Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü Âàñ èç-çà òîãî, ÷òî Âû ïðîô. íåïðèãîäíû.')
										sampSendChat('/b Ïëîõàÿ ãðàììàòèêà.')
									elseif sobesdecline_select[0] == 3 then
										sampSendChat('Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü Âàñ èç-çà òîãî, ÷òî Âû ïðîô. íåïðèãîäíû.')
										sampSendChat('/b Íè÷åãî íå ïîêàçàë.')
									elseif sobesdecline_select[0] == 4 then
										sampSendChat('Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü Âàñ èç-çà îïå÷àòêè â ïàñïîðòå.')
										sampSendChat('/b ÍîíÐÏ íèê.')
									elseif sobesdecline_select[0] == 5 then
										sampSendChat('Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü Âàñ èç-çà òîãî, ÷òî Âû ïðîô. íåïðèãîäíû.')
									end
									windows.imgui_fm[0] = false
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.PopStyleColor(2)
						end
					
						if sobesetap[0] ~= 3 and sobesetap[0] ~= 7  then
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
							if imgui.Button(u8'Îòêëîíèòü', imgui.ImVec2(285,30)) then
								if not inprocess then
									local reasons = {
										pass = {
											['ìåíüøå 3 ëåò â øòàòå'] = {'Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû íå ïðîæèâàåòå â øòàòå 3 ãîäà.'},
											['íå çàêîíîïîñëóøíûé'] = {'Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû íåäîñòàòî÷íî çàêîíîïîñëóøíûé.'},
											['èãðîê â îðãàíèçàöèè'] = {'Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû óæå ðàáîòàåòå â äðóãîé îðãàíèçàöèè.'},
											['â ÷ñ áîëüíèöû'] = {'Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû íàõîäèòåñü â ×Ñ ÌÇ.'},
											['åñòü âàðíû'] = {'Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû ïðîô. íåïðèãîäíû.', '/n åñòü âàðíû'},
											['áûë â äåìîðãàíå'] = {'Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû ëå÷èëèñü â ïñèõ. áîëüíèöå.', '/n îáíîâèòå ìåä. êàðòó'}
										},
										mc = {
											['íàðêîçàâèñèìîñòü'] = {'Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû ñëèøêîì íàðêîçàâèñèìûé.'},
											['íå ïîëíîñòüþ çäîðîâûé'] = {'Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû íå ïîëíîñòüþ çäîðîâûé.'},
										},
									}
									if reasons.pass[sobes_results.pass] then
										for k, v in pairs(reasons.pass[sobes_results.pass]) do
											sampSendChat(v)
										end
										windows.imgui_fm[0] = false
									elseif reasons.mc[sobes_results.medcard] then
										for k, v in pairs(reasons.mc[sobes_results.medcard]) do
											sampSendChat(v)
										end
										windows.imgui_fm[0] = false
									else
										lastsobesetap[0] = sobesetap[0]
										sobesetap[0] = 7
									end
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							imgui.PopStyleColor(2)
						end
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if sobesetap[0] ~= 0 then
							if imgui.InvisibleButton('##sobesbackbutton',imgui.ImVec2(55,15)) then
								if sobesetap[0] == 7 then sobesetap[0] = lastsobesetap[0]
								elseif sobesetap[0] ~= 0 then sobesetap[0] = sobesetap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if sobesetap[0] ~= 3 and sobesetap[0] ~= 7 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##sobesforwardbutton',imgui.ImVec2(125,15)) then
								sobesetap[0] = sobesetap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ïðîïóñòèòü '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end

					elseif newwindowtype[0] == 11 then
						imgui.SetCursorPos(imgui.ImVec2(7.5, 15))
						imgui.BeginGroup()
							if not serverquestions['server'] then
								QuestionType_select[0] = 1
							end
							if QuestionType_select[0] == 0 then
								imgui.TextColoredRGB(serverquestions['server'], 1)
								for k = 1, #serverquestions do
									if imgui.Button(u8(serverquestions[k].name)..'##'..k, imgui.ImVec2(275, 30)) then
										if not inprocess then
											MedHelperMessage('Ïîäñêàçêà: '..serverquestions[k].answer)
											sampSendChat(serverquestions[k].question)
											lastq[0] = clock()
										else
											MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
										end
									end
								end
							elseif QuestionType_select[0] == 1 then
								if #questions.questions ~= 0 then
									for k,v in pairs(questions.questions) do
										if imgui.Button(u8(v.bname)..'##'..k, imgui.ImVec2(questions.active.redact and 200 or 275,30)) then
											if not inprocess then
												MedHelperMessage('Ïîäñêàçêà: '..v.bhint)
												sampSendChat(v.bq)
												lastq[0] = clock()
											else
												MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
											end
										end
										if questions.active.redact then
											imgui.SameLine()
											imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
											imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
											imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
											if imgui.Button(fa.ICON_FA_PEN..'##'..k, imgui.ImVec2(20,25)) then
												question_number = k
												imgui.StrCopy(questionsettings.questionname, u8(v.bname))
												imgui.StrCopy(questionsettings.questionhint, u8(v.bhint))
												imgui.StrCopy(questionsettings.questionques, u8(v.bq))
												imgui.OpenPopup(u8('Ðåäàêòîð âîïðîñîâ'))
											end
											imgui.SameLine()
											if imgui.Button(fa.ICON_FA_TRASH..'##'..k, imgui.ImVec2(20,25)) then
												table.remove(questions.questions,k)
												local file = io.open(getWorkingDirectory()..'\\Med Helper\\Questions.json', 'w')
												file:write(encodeJson(questions))
												file:close()
											end
											imgui.PopStyleColor(3)
										end
									end
								end
							end
						imgui.EndGroup()
						imgui.NewLine()
						imgui.SetCursorPosX(7.5)
						imgui.Text(fa.ICON_FA_CLOCK..' '..(lastq[0] == 0 and u8'0 ñ. íàçàä' or floor(clock()-lastq[0])..u8' ñ. íàçàä'))
						imgui.Hint('lastustavquesttime','Ïðîøåäøåå âðåìÿ ñ ïîñëåäíåãî âîïðîñà.')
						imgui.SetCursorPosX(7.5)
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
						imgui.Button(u8'Îäîáðèòü', imgui.ImVec2(130,30))
						if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
							if imgui.IsMouseReleased(0) then
								if not inprocess then
									windows.imgui_fm[0] = false
									sampSendChat(format('Ïîçäðàâëÿþ, %s, Âû ñäàëè óñòàâ!', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
								else
									MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
								end
							end
							if imgui.IsMouseReleased(1) then
								if configuration.main_settings.myrankint >= 9 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'Ïîçäðàâëÿþ, %s, Âû ñäàëè óñòàâ!', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')},
										{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
										{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
										{'/me {gender:âûáðàë|âûáðàëà} â ðàçäåëå íóæíîãî ñîòðóäíèêà'},
										{'/me {gender:èçìåíèë|èçìåíèëà} èíôîðìàöèþ î äîëæíîñòè ñîòðóäíèêà, ïîñëå ÷åãî {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
										{'/do Èíôîðìàöèÿ î ñîòðóäíèêå áûëà èçìåíåíà.'},
										{'Ïîçäðàâëÿþ ñ ïîâûøåíèåì. Íîâûé áåéäæèê Âû ìîæåòå âçÿòü â ðàçäåâàëêå.'},
										{'/giverank %s 2', fastmenuID},
									})
								else
									MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
								end
							end
						end
						imgui.Hint('ustavhint','ËÊÌ äëÿ èíôîðìèðîâàíèÿ î ñäà÷å óñòàâà\nÏÊÌ äëÿ ïîâûøåíèÿ äî 2-ãî ðàíãà')
						imgui.PopStyleColor(2)
						imgui.SameLine()

						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
						if imgui.Button(u8'Îòêàçàòü', imgui.ImVec2(130,30)) then
							if not inprocess then
								windows.imgui_fm[0] = false
								sampSendChat(format('Ñîæàëåþ, %s, íî Âû íå ñìîãëè ñäàòü óñòàâ. Ïîäó÷èòå è ïðèõîäèòå â ñëåäóþùèé ðàç.', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
							else
								MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
							end
						end
						imgui.PopStyleColor(2)
						imgui.Separator()

						imgui.SetCursorPosX(7.5)
						imgui.BeginGroup()
							if serverquestions['server'] then
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
								imgui.Text(u8'Âîïðîñû')
								imgui.SameLine()
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 3)
								imgui.PushItemWidth(90)
								imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
								imgui.Combo(u8'##choosetypequestion', QuestionType_select, new['const char*'][8]{u8'Ñåðâåðíûå', u8'Âàøè'}, 2)
								imgui.PopStyleVar()
								imgui.PopItemWidth()
								imgui.SameLine()
							end
							if QuestionType_select[0] == 1 then
								if not questions.active.redact then
									imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.80, 0.25, 0.25, 1.00))
									imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.70, 0.25, 0.25, 1.00))
									imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.90, 0.25, 0.25, 1.00))
								else
									if #questions.questions <= 7 then
										if imgui.Button(fa.ICON_FA_PLUS_CIRCLE,imgui.ImVec2(25,25)) then
											question_number = nil
											imgui.StrCopy(questionsettings.questionname, '')
											imgui.StrCopy(questionsettings.questionhint, '')
											imgui.StrCopy(questionsettings.questionques, '')
											imgui.OpenPopup(u8('Ðåäàêòîð âîïðîñîâ'))
										end
										imgui.SameLine()
									end
									imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.70, 0.00, 1.00))
									imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.60, 0.00, 1.00))
									imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.50, 0.00, 1.00))
								end
								if imgui.Button(fa.ICON_FA_COG, imgui.ImVec2(25,25)) then
									questions.active.redact = not questions.active.redact
								end
								imgui.PopStyleColor(3)
							end
						imgui.EndGroup()
						imgui.Spacing()
						imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15,15))
						if imgui.BeginPopup(u8'Ðåäàêòîð âîïðîñîâ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
							imgui.Text(u8'Íàçâàíèå êíîïêè:')
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							imgui.InputText('##questeditorname', questionsettings.questionname, sizeof(questionsettings.questionname))
							imgui.Text(u8'Âîïðîñ: ')
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							imgui.InputText('##questeditorques', questionsettings.questionques, sizeof(questionsettings.questionques))
							imgui.Text(u8'Ïîäñêàçêà: ')
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							imgui.InputText('##questeditorhint', questionsettings.questionhint, sizeof(questionsettings.questionhint))
							imgui.SetCursorPosX(17)
							if #str(questionsettings.questionhint) > 0 and #str(questionsettings.questionques) > 0 and #str(questionsettings.questionname) > 0 then
								if imgui.Button(u8'Ñîõðàíèòü####questeditor', imgui.ImVec2(150, 25)) then
									if question_number == nil then
										questions.questions[#questions.questions + 1] = {
											bname = u8:decode(str(questionsettings.questionname)),
											bq = u8:decode(str(questionsettings.questionques)),
											bhint = u8:decode(str(questionsettings.questionhint)),
										}
									else
										questions.questions[question_number].bname = u8:decode(str(questionsettings.questionname))
										questions.questions[question_number].bq = u8:decode(str(questionsettings.questionques))
										questions.questions[question_number].bhint = u8:decode(str(questionsettings.questionhint))
									end
									local file = io.open(getWorkingDirectory()..'\\Med Helper\\Questions.json', 'w')
									file:write(encodeJson(questions))
									file:close()
									imgui.CloseCurrentPopup()
								end
							else
								imgui.LockedButton(u8'Ñîõðàíèòü####questeditor', imgui.ImVec2(150, 25))
								imgui.Hint('notallparamsquesteditor','Âû ââåëè íå âñå ïàðàìåòðû. Ïåðåïðîâåðüòå âñ¸.')
							end
							imgui.SameLine()
							if imgui.Button(u8'Îòìåíèòü##questeditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
							imgui.Spacing()
							imgui.EndPopup()
						end
						imgui.PopStyleVar()
					elseif newwindowtype[0] == 12 then
						if leadertype[0] == 0 then
							imgui.SetCursorPos(imgui.ImVec2(7.5, 15))
							imgui.BeginGroup()
								imgui.Button(fa.ICON_FA_USER_PLUS..u8' Ïðèíÿòü â îðãàíèçàöèþ', imgui.ImVec2(275,30))
								if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/do Êëþ÷è îò øêàô÷èêà â êàðìàíå.'},
										{'/me âñóíóâ ðóêó â êàðìàí áðþê, {gender:äîñòàë|äîñòàëà} îòòóäà êëþ÷ îò øêàô÷èêà'},
										{'/me {gender:ïåðåäàë|ïåðåäàëà} êëþ÷ ÷åëîâåêó íàïðîòèâ'},
										{'Äîáðî ïîæàëîâàòü! Ïåðåîäåòüñÿ âû ìîæåòå â ðàçäåâàëêå.'},
										{'Ñî âñåé èíôîðìàöèåé Âû ìîæåòå îçíàêîìèòüñÿ íà îô. ïîðòàëå.'},
										{'/invite %s', fastmenuID},
									})
								end
								imgui.Hint('invitehint','ËÊÌ äëÿ ïðèíÿòèÿ ÷åëîâåêà â îðãàíèçàöèþ\nÏÊÌ äëÿ ïðèíÿòèÿ íà äîëæíîñòü Êîíñóëüòàíòà')
								if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Óâîëèòü èç îðãàíèçàöèè', imgui.ImVec2(275,30)) then
									leadertype[0] = 1
									imgui.StrCopy(uninvitebuf, '')
									imgui.StrCopy(blacklistbuf, '')
									uninvitebox[0] = false
								end
								if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Èçìåíèòü äîëæíîñòü', imgui.ImVec2(275,30)) then
									Ranks_select[0] = 0
									leadertype[0] = 2
								end
								if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Çàíåñòè â ÷¸ðíûé ñïèñîê', imgui.ImVec2(275,30)) then
									leadertype[0] = 3
									imgui.StrCopy(blacklistbuff, '')
								end
								if imgui.Button(fa.ICON_FA_USER..u8' Óáðàòü èç ÷¸ðíîãî ñïèñêà', imgui.ImVec2(275,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
										{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'×¸ðíûé ñïèñîê\''},
										{'/me {gender:ââ¸ë|ââåëà} èìÿ ãðàæäàíèíà â ïîèñê'},
										{'/me {gender:óáðàë|óáðàëà} ãðàæäàíèíà èç ðàçäåëà \'×¸ðíûé ñïèñîê\''},
										{'/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
										{'/do Èçìåíåíèÿ áûëè ñîõðàíåíû.'},
										{'/unblacklist %s', fastmenuID},
									})
								end
								if imgui.Button(fa.ICON_FA_FROWN..u8' Âûäàòü âûãîâîð ñîòðóäíèêó', imgui.ImVec2(275,30)) then
									imgui.StrCopy(fwarnbuff, '')
									leadertype[0] = 4
								end
								if imgui.Button(fa.ICON_FA_SMILE..u8' Ñíÿòü âûãîâîð ñîòðóäíèêó', imgui.ImVec2(275,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
										{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
										{'/me {gender:çàø¸ë|çàøëà} â ðàçäåë \'Âûãîâîðû\''},
										{'/me íàéäÿ â ðàçäåëå íóæíîãî ñîòðóäíèêà, {gender:óáðàë|óáðàëà} èç åãî ëè÷íîãî äåëà îäèí âûãîâîð'},
										{'/do Âûãîâîð áûë óáðàí èç ëè÷íîãî äåëà ñîòðóäíèêà.'},
										{'/unfwarn %s', fastmenuID},
									})
								end
								if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Âûäàòü ìóò ñîòðóäíèêó', imgui.ImVec2(275,30)) then
									imgui.StrCopy(fmutebuff, '')
									fmuteint[0] = 0
									leadertype[0] = 5
								end
								if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Ñíÿòü ìóò ñîòðóäíèêó', imgui.ImVec2(275,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
										{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
										{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè %s\'', configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
										{'/me {gender:âûáðàë|âûáðàëà} íóæíîãî ñîòðóäíèêà'},
										{'/me {gender:âûáðàë|âûáðàëà} ïóíêò \'Âêëþ÷èòü ðàöèþ ñîòðóäíèêà\''},
										{'/me {gender:íàæàë|íàæàëà} íà êíîïêó \'Ñîõðàíèòü èçìåíåíèÿ\''},
										{'/funmute %s', fastmenuID},
									})
								end
							imgui.EndGroup()
						elseif leadertype[0] == 1 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.TextColoredRGB('Ïðè÷èíà óâîëüíåíèÿ:',1)
							imgui.SetCursorPosX(52)
							imgui.InputText(u8'##inputuninvitebuf', uninvitebuf, sizeof(uninvitebuf))
							if uninvitebox[0] then
								imgui.TextColoredRGB('Ïðè÷èíà ×Ñ:',1)
								imgui.SetCursorPosX(52)
								imgui.InputText(u8'##inputblacklistbuf', blacklistbuf, sizeof(blacklistbuf))
							end
							imgui.SetCursorPosX(7.5)
							imgui.ToggleButton(u8'Óâîëèòü ñ ×Ñ', uninvitebox)
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Óâîëèòü '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									if #str(uninvitebuf) > 0 then
										if uninvitebox[0] then
											if #str(blacklistbuf) > 0 then
												windows.imgui_fm[0] = false
												sendchatarray(configuration.main_settings.playcd, {
													{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
													{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óâîëüíåíèå\''},
													{'/do Ðàçäåë îòêðûò.'},
													{'/me {gender:âí¸ñ|âíåñëà} ÷åëîâåêà â ðàçäåë \'Óâîëüíåíèå\''},
													{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'×¸ðíûé ñïèñîê\''},
													{'/me {gender:çàí¸ñ|çàíåñëà} ñîòðóäíèêà â ðàçäåë, ïîñëå ÷åãî {gender:ïîäòâåðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
													{'/do Èçìåíåíèÿ áûëè ñîõðàíåíû.'},
													{'/uninvite %s %s', fastmenuID, u8:decode(str(uninvitebuf))},
													{'/blacklist %s %s', fastmenuID, u8:decode(str(blacklistbuf))},
												})
											else
												MedHelperMessage('Ââåäèòå ïðè÷èíó çàíåñåíèÿ â ×Ñ!')
											end
										else
											windows.imgui_fm[0] = false
											sendchatarray(configuration.main_settings.playcd, {
												{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
												{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óâîëüíåíèå\''},
												{'/do Ðàçäåë îòêðûò.'},
												{'/me {gender:âí¸ñ|âíåñëà} ÷åëîâåêà â ðàçäåë \'Óâîëüíåíèå\''},
												{'/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ, çàòåì {gender:âûêëþ÷èë|âûêëþ÷èëà} ïëàíøåò è {gender:ïîëîæèë|ïîëîæèëà} åãî îáðàòíî â êàðìàí'},
												{'/uninvite %s %s', fastmenuID, u8:decode(str(uninvitebuf))},
											})
										end
									else
										MedHelperMessage('Ââåäèòå ïðè÷èíó óâîëüíåíèÿ.')
									end
								else
									MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
						elseif leadertype[0] == 2 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.SetCursorPosX(47.5)
							imgui.PushItemWidth(200)
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
							imgui.Combo('##chooserank9', Ranks_select, new['const char*'][9]({u8('[1] '..configuration.RankNames[1]), u8('[2] '..configuration.RankNames[2]),u8('[3] '..configuration.RankNames[3]),u8('[4] '..configuration.RankNames[4]),u8('[5] '..configuration.RankNames[5]),u8('[6] '..configuration.RankNames[6]),u8('[7] '..configuration.RankNames[7]),u8('[8] '..configuration.RankNames[8]),u8('[9] '..configuration.RankNames[9])}), 9)
							imgui.PopStyleVar()
							imgui.PopItemWidth()
							imgui.SetCursorPosX(7.5)
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
							if imgui.Button(u8'Ïîâûñèòü ñîòðóäíèêà '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(285,40)) then
								if configuration.main_settings.myrankint >= 9 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
										{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
										{'/me {gender:âûáðàë|âûáðàëà} â ðàçäåëå íóæíîãî ñîòðóäíèêà'},
										{'/me {gender:èçìåíèë|èçìåíèëà} èíôîðìàöèþ î äîëæíîñòè ñîòðóäíèêà, ïîñëå ÷åãî {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
										{'/do Èíôîðìàöèÿ î ñîòðóäíèêå áûëà èçìåíåíà.'},
										{'Ïîçäðàâëÿþ ñ ïîâûøåíèåì. Íîâûé áåéäæèê Âû ìîæåòå âçÿòü â ðàçäåâàëêå.'},
										{'/giverank %s %s', fastmenuID, Ranks_select[0]+1},
									})
								else
									MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
								end
							end
							imgui.PopStyleColor(3)
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Ïîíèçèòü ñîòðóäíèêà '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
										{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
										{'/me {gender:âûáðàë|âûáðàëà} â ðàçäåëå íóæíîãî ñîòðóäíèêà'},
										{'/me {gender:èçìåíèë|èçìåíèëà} èíôîðìàöèþ î äîëæíîñòè ñîòðóäíèêà, ïîñëå ÷åãî {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
										{'/do Èíôîðìàöèÿ î ñîòðóäíèêå áûëà èçìåíåíà.'},
										{'/giverank %s %s', fastmenuID, Ranks_select[0]+1},
									})
								else
									MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
								end
							end
							
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
						elseif leadertype[0] == 3 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.TextColoredRGB('Ïðè÷èíà çàíåñåíèÿ â ×Ñ:',1)
							imgui.SetCursorPosX(52)
							imgui.InputText(u8'##inputblacklistbuff', blacklistbuff, sizeof(blacklistbuff))
							imgui.NewLine()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Çàíåñòè â ×Ñ '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									if #str(blacklistbuff) > 0 then
										windows.imgui_fm[0] = false
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
											{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'×¸ðíûé ñïèñîê\''},
											{'/me {gender:ââ¸ë|ââåëà} èìÿ íàðóøèòåëÿ'},
											{'/me {gender:âí¸ñ|âíåñëà} íàðóøèòåëÿ â ðàçäåë \'×¸ðíûé ñïèñîê\''},
											{'/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
											{'/do Èçìåíåíèÿ áûëè ñîõðàíåíû.'},
											{'/blacklist %s %s', fastmenuID, u8:decode(str(blacklistbuff))},
										})
									else
										MedHelperMessage('Ââåäèòå ïðè÷èíó çàíåñåíèÿ â ×Ñ!')
									end
								else
									MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
								end
							end

							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
						elseif leadertype[0] == 4 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.TextColoredRGB('Ïðè÷èíà âûãîâîðà:',1)
							imgui.SetCursorPosX(50)
							imgui.InputText(u8'##giverwarnbuffinputtext', fwarnbuff, sizeof(fwarnbuff))
							imgui.NewLine()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Âûäàòü âûãîâîð '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
								if #str(fwarnbuff) > 0 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
										{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
										{'/me {gender:çàø¸ë|çàøëà} â ðàçäåë \'Âûãîâîðû\''},
										{'/me íàéäÿ â ðàçäåëå íóæíîãî ñîòðóäíèêà, {gender:äîáàâèë|äîáàâèëà} â åãî ëè÷íîå äåëî âûãîâîð'},
										{'/do Âûãîâîð áûë äîáàâëåí â ëè÷íîå äåëî ñîòðóäíèêà.'},
										{'/fwarn %s %s', fastmenuID, u8:decode(str(fwarnbuff))},
									})
								else
									MedHelperMessage('Ââåäèòå ïðè÷èíó âûäà÷è âûãîâîðà!')
								end
							end

							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
						elseif leadertype[0] == 5 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.TextColoredRGB('Ïðè÷èíà ìóòà:',1)
							imgui.SetCursorPosX(52)
							imgui.InputText(u8'##fmutereasoninputtext', fmutebuff, sizeof(fmutebuff))
							imgui.TextColoredRGB('Âðåìÿ ìóòà:',1)
							imgui.SetCursorPosX(52)
							imgui.InputInt(u8'##fmutetimeinputtext', fmuteint, 5)
							imgui.NewLine()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Âûäàòü ìóò '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									if #str(fmutebuff) > 0 then
										if tonumber(fmuteint[0]) and tonumber(fmuteint[0]) > 0 then
											windows.imgui_fm[0] = false
											sendchatarray(configuration.main_settings.playcd, {
												{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
												{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
												{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè %s\'', configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
												{'/me {gender:âûáðàë|âûáðàëà} íóæíîãî ñîòðóäíèêà'},
												{'/me {gender:âûáðàë|âûáðàëà} ïóíêò \'Îòêëþ÷èòü ðàöèþ ñîòðóäíèêà\''},
												{'/me {gender:íàæàë|íàæàëà} íà êíîïêó \'Ñîõðàíèòü èçìåíåíèÿ\''},
												{'/fmute %s %s %s', fastmenuID, u8:decode(fmuteint[0]), u8:decode(str(fmutebuff))},
											})
										else
											MedHelperMessage('Ââåäèòå êîððåêòíîå âðåìÿ ìóòà!')
										end
									else
										MedHelperMessage('Ââåäèòå ïðè÷èíó âûäà÷è ìóòà!')
									end
								else
									MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
								end
							end
							
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Íàçàä')
							imgui.PopFont()
						end
						imgui.Spacing()
					end
				imgui.EndChild()

				imgui.SetCursorPos(imgui.ImVec2(300, 25))
				imgui.BeginChild('##fmplayerinfo', imgui.ImVec2(200, 75), false)
					imgui.SetCursorPosY(17)
					imgui.TextColoredRGB('Èìÿ: {SSSSSS}'..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', 1)
					imgui.Hint('lmb to copy name', 'ËÊÌ - ñêîïèðîâàòü íèê')
					if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
						local name, result = gsub(u8(sampGetPlayerNickname(fastmenuID)), '_', ' ')
						imgui.SetClipboardText(name)
					end
					imgui.TextColoredRGB('Ëåò â øòàòå: '..sampGetPlayerScore(fastmenuID), 1)
				imgui.EndChild()

				imgui.SetCursorPos(imgui.ImVec2(300, 100))
				imgui.BeginChild('##fmchoosewindowtype', imgui.ImVec2(200, -1), false)
					imgui.SetCursorPos(imgui.ImVec2(20, 17.5))
					imgui.BeginGroup()
						for k, v in pairs(fmbuttons) do
							if configuration.main_settings.myrankint >= v.rank then
								if newwindowtype[0] == k then
									local p = imgui.GetCursorScreenPos()
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + 159, p.y + 10),imgui.ImVec2(p.x + 162, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Left)
								end
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,newwindowtype[0] == k and 0.1 or 0))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0.15))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0.1))
								if imgui.AnimButton(v.name, imgui.ImVec2(162,35)) then
									if newwindowtype[0] ~= k then
										newwindowtype[0] = k
										medtap[0] = 0
										osmtap[0] = 0
										rectap[0] = 0
										narkotap[0] = 0
										koronatap[0] = 0
										strtap[0] = 0
										tatutap[0] = 0
										osmotrtap[0] = 0
										psihtap[0] = 0
										sobesetap[0] = 0
										sobesdecline_select[0] = 0
										lastq[0] = 0
										sobes_results = {
											pass = nil,
											medcard = nil,
											wbook = nil,
											licenses = nil
										}
										med_results = {
											pass = nil,
											}
									end
								end
								imgui.PopStyleColor(3)
							end
						end
					imgui.EndGroup()
				imgui.EndChild()
				imgui.PopStyleColor()
				imgui.End()
			imgui.PopStyleVar()
	end
)

local imgui_settings = imgui.OnFrame(
	function() return windows.imgui_settings[0] and not ChangePos end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(600, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
		imgui.Begin(u8'#MainSettingsWindow', windows.imgui_settings, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.SetCursorPos(imgui.ImVec2(15,15))
			imgui.BeginGroup()
			imgui.Image(medh_image,imgui.ImVec2(198,25),imgui.ImVec2(0.25,configuration.main_settings.style ~= 2 and 0.8 or 0.9),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.9 or 1))
				imgui.SameLine(510)
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
				if imgui.Button(fa.ICON_FA_QUESTION_CIRCLE..'##allcommands',imgui.ImVec2(23,23)) then
					imgui.OpenPopup(u8'Âñå êîìàíäû')
				end
				imgui.SameLine()
				if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
					windows.imgui_settings[0] = false
				end
				imgui.PopStyleColor(3)
				imgui.SetCursorPos(imgui.ImVec2(217, 23))
				imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.Border],'v. '..thisScript().version)
				imgui.Hint('lastupdate','Îáíîâëåíèå îò 08.02.2023')
				imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15,15))
				if imgui.BeginPopupModal(u8'Âñå êîìàíäû', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
					imgui.PushFont(font[16])
					imgui.TextColoredRGB('Âñå äîñòóïíûå êîìàíäû è ãîðÿ÷èå êëàâèøè', 1)
					imgui.PopFont()
					imgui.Spacing()
					imgui.TextColoredRGB('Êîìàíäû ñêðèïòà:')
					imgui.SetCursorPosX(20)
					imgui.BeginGroup()
						imgui.TextColoredRGB('/mhm - Ãëàâíîå ìåíþ ñêðèïòà')
						imgui.TextColoredRGB('/mhmbind - Áèíäåð ñêðèïòà')
						imgui.TextColoredRGB('/mhmlect - Ìåíþ ëåêöèé ñêðèïòà')
						imgui.TextColoredRGB('/mhmdep - Ìåíþ äåïàðòàìåíòà ñêðèïòà')
						if configuration.main_settings.fmtype == 1 then
							imgui.TextColoredRGB('/'..configuration.main_settings.usefastmenucmd..' [id] - Ìåíþ âçàèìîäåéñòâèÿ ñ êëèåíòîì')
						end
					imgui.EndGroup()
					imgui.Spacing()
					imgui.TextColoredRGB('Êîìàíäû ñåðâåðà ñ ÐÏ îòûãðîâêàìè:')
					imgui.SetCursorPosX(20)
					imgui.BeginGroup()
						imgui.TextColoredRGB('/invite [id] | /uninvite [id] [ïðè÷èíà] - Ïðèíÿòèå/Óâîëüíåíèå ÷åëîâåêà âî ôðàêöèþ (9+)')
						imgui.TextColoredRGB('/blacklist [id] [ïðè÷èíà] | /unblacklist [id] - Çàíåñåíèå/Óäàëåíèå ÷åëîâåêà â ×Ñ ôðàêöèè (9+)')
						imgui.TextColoredRGB('/fwarn [id] [ïðè÷èíà] | /unfwarn [id] - Âûäà÷à/Óäàëåíèå âûãîâîðà ÷åëîâåêà âî ôðàêöèè (9+)')
						imgui.TextColoredRGB('/fmute [id] [âðåìÿ] [ïðè÷èíà] | /funmute [id] - Âûäà÷à/Óäàëåíèå ìóòà ÷åëîâåêó âî ôðàêöèè (9+)')
						imgui.TextColoredRGB('/giverank [id] [ðàíã] - Èçìåíåíèå ðàíãà ÷åëîâåêà â ôðàêöèè (9+)')
						imgui.TextColoredRGB('/expel [id] [ïðè÷èíà] - Âûãíàòü ÷åëîâåêà èç áîëüíèöû (3+)')
						imgui.TextColoredRGB('/heal [id] [öåíà] - Âûëå÷èòü ÷åëîâåêà (1+)')
						imgui.TextColoredRGB('/cure [id] - Ðåàíèìèðîâàòü ÷åëîâåêà (1+)')
					imgui.EndGroup()
					imgui.Spacing()
					imgui.TextColoredRGB('Ãîðÿ÷èå êëàâèøè:')
					imgui.SetCursorPosX(20)
					imgui.BeginGroup()
						if configuration.main_settings.fmtype == 0 then
							imgui.TextColoredRGB('ÏÊÌ + '..configuration.main_settings.usefastmenu..' - Ìåíþ âçàèìîäåéñòâèÿ ñ êëèåíòîì')
						end
						if configuration.main_settings.dofastexpel then
							imgui.TextColoredRGB('ÏÊÌ + '..configuration.main_settings.fastexpel..' - Áûñòðûé /expel')
						end
						imgui.TextColoredRGB(configuration.main_settings.fastscreen..' - Áûñòðûé ñêðèíøîò')
						imgui.TextColoredRGB('Page down - Îñòàíîâèòü îòûãðîâêó')
					imgui.EndGroup()
					imgui.Spacing()
					if imgui.Button(u8'Çàêðûòü##êîìàíäû', imgui.ImVec2(-1, 30)) then imgui.CloseCurrentPopup() end
					imgui.EndPopup()
				end
				imgui.PopStyleVar()
			imgui.EndGroup()
			imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 0)
			imgui.BeginChild('##MainSettingsWindowChild',imgui.ImVec2(-1,-1),false, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
				if mainwindow[0] == 0 then
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					imgui.SetCursorPos(imgui.ImVec2(25,50))
					imgui.BeginGroup()
						for k,v in pairs(buttons) do
							imgui.BeginGroup()
								local p = imgui.GetCursorScreenPos()
								if imgui.InvisibleButton(v.name, imgui.ImVec2(150,130)) then
									mainwindow[0] = k
									alpha[0] = clock()
								end

								if v.timer == 0 then
									v.timer = imgui.GetTime()
								end
								if imgui.IsItemHovered() then
									v.y_hovered = ceil(v.y_hovered) > 0 and 10 - ((imgui.GetTime() - v.timer) * 100) or 0
									v.timer = ceil(v.y_hovered) > 0 and v.timer or 0
									imgui.SetMouseCursor(imgui.MouseCursor.Hand)
								else
									v.y_hovered = ceil(v.y_hovered) < 10 and (imgui.GetTime() - v.timer) * 100 or 10
									v.timer = ceil(v.y_hovered) < 10 and v.timer or 0
								end
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + v.y_hovered), imgui.ImVec2(p.x + 150, p.y + 110 + v.y_hovered), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button]), 7)
								imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x-4, p.y + v.y_hovered - 4), imgui.ImVec2(p.x + 154, p.y + 110 + v.y_hovered + 4), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]), 10, nil, 1.9)
								imgui.SameLine(10)
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 10 + v.y_hovered)
								imgui.PushFont(font[25])
								imgui.Text(v.icon)
								imgui.PopFont()
								imgui.SameLine(10)
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 30 + v.y_hovered)
								imgui.BeginGroup()
									imgui.PushFont(font[16])
									imgui.Text(u8(v.name))
									imgui.PopFont()
									imgui.Text(u8(v.text))
								imgui.EndGroup()
							imgui.EndGroup()
							if k ~= #buttons then
								imgui.SameLine(k*200)
							end
						end
					imgui.EndGroup()
					imgui.PopStyleVar()
				elseif mainwindow[0] == 1 then
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					if imgui.InvisibleButton('##settingsbackbutton',imgui.ImVec2(10,15)) then
						mainwindow[0] = 0
						alpha[0] = clock()
					end
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					imgui.PushFont(font[16])
					imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT)
					imgui.PopFont()
					imgui.SameLine()
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 5, p.y - 10),imgui.ImVec2(p.x + 5, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
					imgui.SetCursorPos(imgui.ImVec2(60,15))
					imgui.PushFont(font[25])
					imgui.Text(u8'Íàñòðîéêè')
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(15,65))
					imgui.BeginGroup()
						imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.05,0.5))
						for k, i in pairs(settingsbuttons) do
							local clr = imgui.GetStyle().Colors[imgui.Col.Text].x
							if settingswindow[0] == k then
								local p = imgui.GetCursorScreenPos()
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,settingswindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton(i, imgui.ImVec2(162,35)) then
								if settingswindow[0] ~= k then
									settingswindow[0] = k
									alpha[0] = clock()
								end
							end
							imgui.PopStyleColor(3)
						end
						imgui.PopStyleVar()
					imgui.EndGroup()
					imgui.SetCursorPos(imgui.ImVec2(187, 0))
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					imgui.BeginChild('##usersettingsmainwindow',_,false)
						if settingswindow[0] == 1 then
							imgui.SetCursorPos(imgui.ImVec2(15,15))
							imgui.BeginGroup()
								imgui.PushFont(font[16])
								imgui.Text(u8'Îñíîâíàÿ èíôîðìàöèÿ')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
						
									imgui.BeginGroup()
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
										imgui.Text(u8'Âàøå èìÿ')
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
										imgui.Text(u8'Àêöåíò')
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
										imgui.Text(u8'Âàø ïîë')
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
										imgui.Text(u8'Âàøà áîëüíèöà')
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
										imgui.Text(u8'Âàø ðàíã')
									imgui.EndGroup()
						
									imgui.SameLine(90)
									imgui.PushItemWidth(120)
									imgui.BeginGroup()
										if imgui.InputTextWithHint(u8'##mynickinroleplay', u8((gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' '))), usersettings.myname, sizeof(usersettings.myname)) then
											configuration.main_settings.myname = str(usersettings.myname)
											inicfg.save(configuration,'Med Helper')
										end
										imgui.SameLine()
										imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
										imgui.Hint('NoNickNickFromTab','Åñëè íå áóäåò óêàçàíî, òî èìÿ áóäåò áðàòüñÿ èç íèêà')
									
										if imgui.InputText(u8'##myaccentintroleplay', usersettings.myaccent, sizeof(usersettings.myaccent)) then
											configuration.main_settings.myaccent = str(usersettings.myaccent)
											inicfg.save(configuration,'Med Helper')
										end
									
										imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
										if imgui.Combo(u8'##choosegendercombo',usersettings.gender, new['const char*'][2]({u8'Ìóæñêîé',u8'Æåíñêèé'}), 2) then
											configuration.main_settings.gender = usersettings.gender[0]
											inicfg.save(configuration,'Med Helper')
										end
										imgui.PopStyleVar()
									
										imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
										if imgui.Combo(u8'##chooselocationcombo',usersettings.location, new['const char*'][4]({u8'Áîëüíèöà ËÑ',u8'Áîëüíèöà ÑÔ',u8'Áîëüíèöà ËÂ',u8'Áîëüíèöà ÄÔ'}), 4) then
											configuration.main_settings.location = usersettings.location[0]
											inicfg.save(configuration,'Med Helper')
										end
										imgui.PopStyleVar()
									
										if imgui.Button(u8(configuration.RankNames[configuration.main_settings.myrankint]..' ('..u8(configuration.main_settings.myrankint)..')'), imgui.ImVec2(120, 23)) then
											getmyrank = true
											sampSendChat('/stats')
										end
										imgui.Hint('clicktoupdaterang','Íàæìèòå, ÷òîáû ïåðåïðîâåðèòü')
									imgui.EndGroup()
									imgui.PopItemWidth()
									
								imgui.EndGroup()
								imgui.NewLine()
									
								imgui.PushFont(font[16])
								imgui.Text(u8'Ìåíþ áûñòðîãî äîñòóïà')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
									imgui.Text(u8'Òèï àêòèâàöèè')
									imgui.SameLine(100)
									imgui.SetCursorPosY(imgui.GetCursorPosY() - 3)
									imgui.PushItemWidth(120)
									imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
									if imgui.Combo(u8'##choosefmtypecombo',usersettings.fmtype, new['const char*'][2]({u8'Êëàâèøà',u8'Êîìàíäà'}), 2) then
										configuration.main_settings.fmtype = usersettings.fmtype[0]
										inicfg.save(configuration,'Med Helper')
									end
									imgui.PopStyleVar()
									imgui.PopItemWidth()
								
									imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
									imgui.Text(u8'Àêòèâàöèÿ')
									imgui.SameLine(100)
								
									if configuration.main_settings.fmtype == 0 then
										imgui.Text(u8' ÏÊÌ +')
										imgui.SameLine(nil, 5)
										imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
										imgui.HotKey('ìåíþ áûñòðîãî äîñòóïà', configuration.main_settings, 'usefastmenu', 'E', find(configuration.main_settings.usefastmenu, '+') and 150 or 75)
									
										if imgui.ToggleButton(u8'Ñîçäàâàòü ìàðêåð ïðè âûäåëåíèè',usersettings.createmarker) then
											if marker ~= nil then
												removeBlip(marker)
											end
											marker = nil
											oldtargettingped = 0
											configuration.main_settings.createmarker = usersettings.createmarker[0]
											inicfg.save(configuration,'Med Helper')
										end
									elseif configuration.main_settings.fmtype == 1 then
										imgui.Text(u8'/')
										imgui.SameLine(110)
										imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
										imgui.PushItemWidth(110)
										if imgui.InputText(u8'[id]##usefastmenucmdbuff',usersettings.usefastmenucmd,sizeof(usersettings.usefastmenucmd)) then
											configuration.main_settings.usefastmenucmd = str(usersettings.usefastmenucmd)
											inicfg.save(configuration,'Med Helper')
										end
										imgui.PopItemWidth()
									end
									
								imgui.EndGroup()
								imgui.NewLine()
								
								imgui.PushFont(font[16])
								imgui.Text(u8'Îñòàëüíîå')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
								
									if imgui.ToggleButton(u8'Çàìåíÿòü ñåðâåðíûå ñîîáùåíèÿ', usersettings.replacechat) then
										configuration.main_settings.replacechat = usersettings.replacechat[0]
										inicfg.save(configuration,'Med Helper')
									end

									if imgui.ToggleButton(u8'Îòêðûâàòü äâåðè àâòîìàòè÷åñêè', usersettings.autodoor) then
										configuration.main_settings.autodoor = usersettings.autodoor[0]
										inicfg.save(configuration,'Med Helper')
									end
									
									if imgui.ToggleButton(u8'Ïîêàçûâàòü ðàíã ïåðåä ñîîáùåíèåì â ðàöèè', usersettings.chatrank) then
										configuration.main_settings.chatrank = usersettings.chatrank[0]
										inicfg.save(configuration,'Med Helper')
									end

									if imgui.ToggleButton(u8'Ïîêàçûâàòü ðàíã íà ãðóäè ñîòðóäíèêà', usersettings.bodyrank) then
										configuration.main_settings.bodyrank = usersettings.bodyrank[0]
										inicfg.save(configuration,'Med Helper')
									end
								
									if imgui.ToggleButton(u8'Áûñòðûé ñêðèí íà', usersettings.dofastscreen) then
										configuration.main_settings.dofastscreen = usersettings.dofastscreen[0]
										inicfg.save(configuration,'Med Helper')
									end
									imgui.SameLine()
									imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
									imgui.HotKey('áûñòðîãî ñêðèíà', configuration.main_settings, 'fastscreen', 'F4', find(configuration.main_settings.fastscreen, '+') and 150 or 75)

									if imgui.ToggleButton(u8'Áûñòðûé expel íà', usersettings.dofastexpel) then
										configuration.main_settings.dofastexpel = usersettings.dofastexpel[0]
										inicfg.save(configuration,'Med Helper')
									end
									imgui.SameLine(nil, 20)
									imgui.Text(u8'ÏÊÌ +')
									imgui.SameLine(nil, 5)
									imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
									imgui.HotKey('áûñòðûé /expel', configuration.main_settings, 'fastexpel', 'G', find(configuration.main_settings.fastexpel, '+') and 150 or 75)

									imgui.PushItemWidth(85)
									if imgui.InputText(u8'##expelreasonbuff',usersettings.expelreason,sizeof(usersettings.expelreason)) then
										configuration.main_settings.expelreason = u8:decode(str(usersettings.expelreason))
										inicfg.save(configuration,'Med Helper')
									end
									imgui.PopItemWidth()
									imgui.SameLine()
									imgui.Text(u8'Ïðè÷èíà /expel')
								imgui.EndGroup()
								imgui.Spacing()
							imgui.EndGroup()
						elseif settingswindow[0] == 2 then
							imgui.SetCursorPos(imgui.ImVec2(15,15))
							imgui.BeginGroup()
								imgui.PushFont(font[16])
								imgui.Text(u8'Âûáîð ñòèëÿ')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.CircleButton('##choosestyle0', configuration.main_settings.style == 0, imgui.ImVec4(1.00, 0.42, 0.00, 0.90)) then
										configuration.main_settings.style = 0
										inicfg.save(configuration, 'Med Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle1', configuration.main_settings.style == 1, imgui.ImVec4(1.00, 0.28, 0.28, 0.90)) then
										configuration.main_settings.style = 1
										inicfg.save(configuration, 'Med Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle2', configuration.main_settings.style == 2, imgui.ImVec4(0.00, 0.35, 1.00, 0.90)) then
										configuration.main_settings.style = 2
										inicfg.save(configuration, 'Med Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle3', configuration.main_settings.style == 3, imgui.ImVec4(0.41, 0.19, 0.63, 0.90)) then
										configuration.main_settings.style = 3
										inicfg.save(configuration, 'Med Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle4', configuration.main_settings.style == 4, imgui.ImVec4(0.00, 0.69, 0.33, 0.90)) then
										configuration.main_settings.style = 4
										inicfg.save(configuration, 'Med Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle5', configuration.main_settings.style == 5, imgui.ImVec4(0.51, 0.51, 0.51, 0.90)) then
										configuration.main_settings.style = 5
										inicfg.save(configuration, 'Med Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									local pos = imgui.GetCursorPos()
									imgui.SetCursorPos(imgui.ImVec2(pos.x + 1.5, pos.y + 1.5))
									imgui.Image(rainbowcircle,imgui.ImVec2(17,17))
									imgui.SetCursorPos(pos)
									if imgui.CircleButton('##choosestyle6', configuration.main_settings.style == 6, imgui.GetStyle().Colors[imgui.Col.Button], nil, true) then
										configuration.main_settings.style = 6
										inicfg.save(configuration, 'Med Helper.ini')
										checkstyle()
									end
									imgui.Hint('MoonMonetHint','MoonMonet')
								imgui.EndGroup()
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 25)
								imgui.NewLine()
								if configuration.main_settings.style == 6 then
									imgui.PushFont(font[16])
									imgui.Text(u8'Öâåò àêöåíòà Monet')
									imgui.PopFont()
									imgui.SetCursorPosX(25)
									imgui.BeginGroup()
										imgui.PushItemWidth(200)
										if imgui.ColorPicker3('##moonmonetcolorselect', usersettings.moonmonetcolorselect, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.PickerHueWheel + imgui.ColorEditFlags.NoSidePreview) then
											local r,g,b = usersettings.moonmonetcolorselect[0] * 255,usersettings.moonmonetcolorselect[1] * 255,usersettings.moonmonetcolorselect[2] * 255
											local argb = join_argb(255,r,g,b)
											configuration.main_settings.monetstyle = argb
											inicfg.save(configuration, 'Med Helper.ini')
											checkstyle()
										end
										if imgui.SliderFloat('##CHROMA', monetstylechromaselect, 0.5, 2.0, u8'%0.2f c.m.') then
											configuration.main_settings.monetstyle_chroma = monetstylechromaselect[0]
											checkstyle()
										end
										imgui.PopItemWidth()
									imgui.EndGroup()
									imgui.NewLine()
								end
								imgui.PushFont(font[16])
								imgui.Text(u8'Äîïîëíèòåëüíî')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.ColorEdit4(u8'##RSet', chatcolors.RChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										configuration.main_settings.RChatColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.RChatColor[0], chatcolors.RChatColor[1], chatcolors.RChatColor[2], chatcolors.RChatColor[3]))
										inicfg.save(configuration, 'Med Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Öâåò ÷àòà îðãàíèçàöèè')
									imgui.SameLine(190)
									if imgui.Button(u8'Ñáðîñèòü##RCol',imgui.ImVec2(65,25)) then
										configuration.main_settings.RChatColor = 4282626093
										if inicfg.save(configuration, 'Med Helper.ini') then
											chatcolors.RChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.RChatColor))
										end
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Òåñò##RTest',imgui.ImVec2(37,25)) then
										local result, myid = sampGetPlayerIdByCharHandle(playerPed)
										local color4 = imgui.ColorConvertU32ToFloat4(configuration.main_settings.RChatColor)
										local r, g, b, a = color4.x * 255, color4.y * 255, color4.z * 255, color4.w * 255
										sampAddChatMessage('[R] '..configuration.RankNames[configuration.main_settings.myrankint]..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: (( Ýòî ñîîáùåíèå âèäèòå òîëüêî Âû! ))', join_argb(a, r, g, b))
									end
								
									if imgui.ColorEdit4(u8'##DSet', chatcolors.DChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										configuration.main_settings.DChatColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.DChatColor[0], chatcolors.DChatColor[1], chatcolors.DChatColor[2], chatcolors.DChatColor[3]))
										inicfg.save(configuration, 'Med Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Öâåò ÷àòà äåïàðòàìåíòà')
									imgui.SameLine(190)
									if imgui.Button(u8'Ñáðîñèòü##DCol',imgui.ImVec2(65,25)) then
										configuration.main_settings.DChatColor = 4294940723
										if inicfg.save(configuration, 'Med Helper.ini') then
											chatcolors.DChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.DChatColor))
										end
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Òåñò##DTest',imgui.ImVec2(37,25)) then
										local result, myid = sampGetPlayerIdByCharHandle(playerPed)
										local color4 = imgui.ColorConvertU32ToFloat4(configuration.main_settings.DChatColor)
										local r, g, b, a = color4.x * 255, color4.y * 255, color4.z * 255, color4.w * 255
										sampAddChatMessage('[D] '..configuration.RankNames[configuration.main_settings.myrankint]..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: Ýòî ñîîáùåíèå âèäèòå òîëüêî Âû!', join_argb(a, r, g, b))
									end
								
									if imgui.ColorEdit4(u8'##SSet', chatcolors.ASChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										configuration.main_settings.ASChatColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.ASChatColor[0], chatcolors.ASChatColor[1], chatcolors.ASChatColor[2], chatcolors.ASChatColor[3]))
										inicfg.save(configuration, 'Med Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Öâåò Med Helper â ÷àòå')
									imgui.SameLine(190)
									if imgui.Button(u8'Ñáðîñèòü##SCol',imgui.ImVec2(65,25)) then
										configuration.main_settings.ASChatColor = 4281558783
										if inicfg.save(configuration, 'Med Helper.ini') then
											chatcolors.ASChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor))
										end
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Òåñò##ASTest',imgui.ImVec2(37,25)) then
										MedHelperMessage('Ýòî ñîîáùåíèå âèäèòå òîëüêî Âû!')
									end
									if imgui.ToggleButton(u8'Óáèðàòü ïîëîñó ïðîêðóòêè', usersettings.noscrollbar) then
										configuration.main_settings.noscrollbar = usersettings.noscrollbar[0]
										inicfg.save(configuration,'Med Helper')
										checkstyle()
									end
								imgui.EndGroup()
								imgui.Spacing()
							imgui.EndGroup()
						elseif settingswindow[0] == 3 then
							imgui.SetCursorPosY(10)
							imgui.TextColoredRGB('Öåíû {808080}(?)',1)
							imgui.Hint('pricelisthint','Ýòè ÷èñëà áóäóò èñïîëüçîâàòüñÿ ïðè îçâó÷èâàíèè ïðàéñ ëèñòà')
							imgui.PushItemWidth(62)
							imgui.SetCursorPosX(40)
							imgui.BeginGroup()
								if imgui.InputText(u8'Ëå÷åíèå', pricelist.heal, sizeof(pricelist.heal), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.heal = str(pricelist.heal)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ìåä.êàðòà íà 7', pricelist.medcard7, sizeof(pricelist.medcard7), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.medcard7 = str(pricelist.medcard7)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ìåä.êàðòà íà 30', pricelist.medcard30, sizeof(pricelist.medcard30), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.medcard30 = str(pricelist.medcard30)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ðåöåïò', pricelist.recept, sizeof(pricelist.recept), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.recept = str(pricelist.recept)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Êîðîíàâèðóñ', pricelist.korona, sizeof(pricelist.korona), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.korona = str(pricelist.korona)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ñòðàõîâêà íà 7', pricelist.str7, sizeof(pricelist.str7), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.str7 = str(pricelist.str7)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ñòðàõîâêà íà 21', pricelist.str21, sizeof(pricelist.str21), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.str21 = str(pricelist.str21)
									inicfg.save(configuration,'Med Helper')
								end
							imgui.EndGroup()
							imgui.SameLine(220)
							imgui.BeginGroup()
								if imgui.InputText(u8'Ìåä.êàðòà äëÿ 4', pricelist.medcard74, sizeof(pricelist.medcard74), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.medcard74 = str(pricelist.medcard74)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ìåä.êàðòà íà 14', pricelist.medcard14, sizeof(pricelist.medcard14), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.medcard14 = str(pricelist.medcard14)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ìåä.êàðòà íà 60', pricelist.medcard60, sizeof(pricelist.medcard60), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.medcard60 = str(pricelist.medcard60)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Íàðêîçàâèñèìîñòü', pricelist.narko, sizeof(pricelist.narko), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.narko = str(pricelist.narko)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Àíòèáèîòèê', pricelist.antibio, sizeof(pricelist.antibio), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.antibio = str(pricelist.antibio)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ñòðàõîâêà íà 14', pricelist.str14, sizeof(pricelist.str14), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.str14 = str(pricelist.str14)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Òàòó', pricelist.tatu, sizeof(pricelist.tatu), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.tatu = str(pricelist.tatu)
									inicfg.save(configuration,'Med Helper')
								end
								if imgui.InputText(u8'Ìåä.Îñìîòð', pricelist.osm, sizeof(pricelist.osm), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.osm = str(pricelist.osm)
									inicfg.save(configuration,'Med Helper')
								end
							imgui.EndGroup()
							imgui.PopItemWidth()
						end
					imgui.EndChild()
					imgui.PopStyleVar()
				elseif mainwindow[0] == 2 then
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					if imgui.InvisibleButton('##settingsbackbutton',imgui.ImVec2(10,15)) then
						mainwindow[0] = 0
						alpha[0] = clock()
					end
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					imgui.PushFont(font[16])
					imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT)
					imgui.PopFont()
					imgui.SameLine()
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 5, p.y - 10),imgui.ImVec2(p.x + 5, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
					imgui.SetCursorPos(imgui.ImVec2(60,15))
					imgui.PushFont(font[25])
					imgui.Text(u8'Äîïîëíèòåëüíî')
					imgui.PopFont()
				
					imgui.SetCursorPos(imgui.ImVec2(15,65))
					imgui.BeginGroup()
						imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.05,0.5))
						for k, i in pairs(additionalbuttons) do
							local clr = imgui.GetStyle().Colors[imgui.Col.Text].x
							if additionalwindow[0] == k then
								local p = imgui.GetCursorScreenPos()
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,additionalwindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton(i, imgui.ImVec2(186,35)) then
								if additionalwindow[0] ~= k then
									additionalwindow[0] = k
									alpha[0] = clock()
								end
							end
							imgui.PopStyleColor(3)
						end
						imgui.PopStyleVar()
					imgui.EndGroup()
					
					imgui.SetCursorPos(imgui.ImVec2(235, 0))
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					if additionalwindow[0] == 1 then
						imgui.BeginChild('##rulesswindow',_,false, imgui.WindowFlags.NoScrollbar)
							imgui.SetCursorPosY(20)
							if ruless['server'] then
								imgui.TextColoredRGB('Ïðàâèëà ñåðâåðà '..ruless['server']..' + Âàøè {808080}(?)',1)
							else
								imgui.TextColoredRGB('Âàøè ïðàâèëà {808080}(?)',1)
							end
							imgui.Hint('txtfileforrules','Âû äîëæíû ñîçäàòü .txt ôàéë ñ êîäèðîâêîé ANSI\nËÊÌ äëÿ îòêðûòèÿ ïàïêè ñ ïðàâèëàìè')
							if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
								createDirectory(getWorkingDirectory()..'\\Med Helper\\Rules')
								os.execute('explorer '..getWorkingDirectory()..'\\Med Helper\\Rules')
							end
							imgui.SetCursorPos(imgui.ImVec2(15, 20))
							imgui.Text(fa.ICON_FA_REDO_ALT)
							if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
								checkRules()
							end
							imgui.Hint('updateallrules','Íàæìèòå äëÿ îáíîâëåíèÿ âñåõ ïðàâèë')
							for i = 1, #ruless do
								imgui.SetCursorPosX(15)
								if imgui.Button(u8(ruless[i].name..'##'..i), imgui.ImVec2(330,35)) then
									imgui.StrCopy(search_rule, '')
									RuleSelect = i
									imgui.OpenPopup(u8('Ïðàâèëà'))
								end
							end
							imgui.Spacing()
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15,15))
							if imgui.BeginPopupModal(u8('Ïðàâèëà'), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
								imgui.TextColoredRGB(ruless[RuleSelect].name,1)
								imgui.SetCursorPosX(416)
								imgui.PushItemWidth(200)
								imgui.InputTextWithHint('##search_rule', fa.ICON_FA_SEARCH..u8' Èñêàòü', search_rule, sizeof(search_rule), imgui.InputTextFlags.EnterReturnsTrue)
								imgui.SameLine(928)
								if imgui.BoolButton(rule_align[0] == 1,fa.ICON_FA_ALIGN_LEFT, imgui.ImVec2(40, 20)) then
									rule_align[0] = 1
									configuration.main_settings.rule_align = rule_align[0]
									inicfg.save(configuration,'Med Helper.ini')
								end
								imgui.SameLine()
								if imgui.BoolButton(rule_align[0] == 2,fa.ICON_FA_ALIGN_CENTER, imgui.ImVec2(40, 20)) then
									rule_align[0] = 2
									configuration.main_settings.rule_align = rule_align[0]
									inicfg.save(configuration,'Med Helper.ini')
								end
								imgui.SameLine()
								if imgui.BoolButton(rule_align[0] == 3,fa.ICON_FA_ALIGN_RIGHT, imgui.ImVec2(40, 20)) then
									rule_align[0] = 3
									configuration.main_settings.rule_align = rule_align[0]
									inicfg.save(configuration,'Med Helper.ini')
								end
								imgui.BeginChild('##Ïðàâèëà', imgui.ImVec2(1000, 500), true)
								for _ = 1, #ruless[RuleSelect].text do
									if sizeof(search_rule) < 1 then
										imgui.TextColoredRGB(ruless[RuleSelect].text[_],rule_align[0]-1)
										if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
											sampSetChatInputEnabled(true)
											sampSetChatInputText(gsub(ruless[RuleSelect].text[_], '%{.+%}',''))
										end
									else
										if find(string.rlower(ruless[RuleSelect].text[_]), string.rlower(gsub(u8:decode(str(search_rule)), '(%p)','(%%p)'))) then
											imgui.TextColoredRGB(ruless[RuleSelect].text[_],rule_align[0]-1)
											if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
												sampSetChatInputEnabled(true)
												sampSetChatInputText(gsub(ruless[RuleSelect].text[_], '%{.+%}',''))
											end
										end
									end
								end
								imgui.EndChild()
								imgui.SetCursorPosX(416)
								if imgui.Button(u8'Çàêðûòü',imgui.ImVec2(200,25)) then imgui.CloseCurrentPopup() end
								imgui.EndPopup()
							end
							imgui.PopStyleVar()
						imgui.EndChild()
					elseif additionalwindow[0] == 2 then
						imgui.BeginChild('##zametkimainwindow',_,false, imgui.WindowFlags.NoScrollbar)
							imgui.BeginChild('##zametkizametkichild', imgui.ImVec2(-1, 210), false)
								if zametkaredact_number == nil then
									imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(12,6))
									imgui.SetCursorPosY(10)
									imgui.Columns(4)
									imgui.Text('#')
									imgui.SetColumnWidth(-1, 30)
									imgui.NextColumn()
									imgui.Text(u8'Íàçâàíèå')
									imgui.SetColumnWidth(-1, 150)
									imgui.NextColumn()
									imgui.Text(u8'Êîìàíäà')
									imgui.SetColumnWidth(-1, 75)
									imgui.NextColumn()
									imgui.Text(u8'Êíîïêà')
									imgui.Columns(1)
									imgui.Separator()
									for i = 1, #zametki do
										if imgui.Selectable(u8('##'..i), now_zametka[0] == i) then
											now_zametka[0] = i
										end
										if imgui.IsMouseDoubleClicked(0) and imgui.IsItemHovered() then
											windows.imgui_zametka[0] = true
											zametka_window[0] = now_zametka[0]
										end
									end
									imgui.SetCursorPosY(35)
									imgui.Columns(4)
									for i = 1, #zametki do
										local name, cmd, button = zametki[i].name, zametki[i].cmd, zametki[i].button
										imgui.Text(u8(i))
										imgui.SetColumnWidth(-1, 30)
										imgui.NextColumn()
										imgui.Text(u8(name))
										imgui.SetColumnWidth(-1, 150)
										imgui.NextColumn()
										imgui.Text(u8(#cmd > 0 and '/'..cmd or ''))
										imgui.SetColumnWidth(-1, 75)
										imgui.NextColumn()
										imgui.Text(u8(button))
										imgui.NextColumn()
									end
									imgui.Columns(1)
									imgui.Separator()
									imgui.PopStyleVar()
									imgui.Spacing()
								else
									imgui.SetCursorPos(imgui.ImVec2(60, 20))
									imgui.BeginGroup()
										imgui.PushFont(font[16])
										imgui.TextColoredRGB(zametkaredact_number ~= 0 and 'Ðåäàêòèðîâàíèå çàìåòêè #'..zametkaredact_number or 'Ñîçäàíèå íîâîé çàìåòêè', 1)
										imgui.PopFont()
										imgui.Spacing()
										
										imgui.TextColoredRGB('{FF2525}* {SSSSSS}Íàçâàíèå çàìåòêè:')
										imgui.SameLine(125)
										imgui.PushItemWidth(120)
										imgui.InputText('##zametkaeditorname', zametkisettings.zametkaname, sizeof(zametkisettings.zametkaname))

										imgui.TextColoredRGB('{FF2525}* {SSSSSS}Òåêñò çàìåòêè:')
										imgui.SameLine(125)
										imgui.PushItemWidth(120)
										if imgui.Button(u8'Ðåäàêòèðîâàòü##neworredactzametka', imgui.ImVec2(120, 0)) then
											imgui.OpenPopup(u8'Ðåäàêòîð òåêñòà çàìåòêè')
										end
									
										imgui.Text(u8'Êîìàíäà àêòèâàöèè:')
										imgui.SameLine(125)
										imgui.InputText('##zametkaeditorcmd', zametkisettings.zametkacmd, sizeof(zametkisettings.zametkacmd))
										imgui.PopItemWidth()
									
										imgui.Text(u8'Áèíä àêòèâàöèè:')
										imgui.SameLine(125)
										imgui.HotKey((zametkaredact_number ~= 0 and zametkaredact_number or 'íîâîé')..' çàìåòêè', zametkisettings, 'zametkabtn', '', 120)
									imgui.EndGroup()

									imgui.SetCursorPos(imgui.ImVec2(60,190))
									if imgui.InvisibleButton('##zametkigoback',imgui.ImVec2(65,15)) then
										zametkaredact_number = nil
										imgui.StrCopy(zametkisettings.zametkacmd, '')
										imgui.StrCopy(zametkisettings.zametkaname, '')
										imgui.StrCopy(zametkisettings.zametkatext, '')
										zametkisettings.zametkabtn = ''
									end
									imgui.SetCursorPos(imgui.ImVec2(60,190))
									imgui.PushFont(font[16])
									imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Îòìåíà')
									imgui.PopFont()
									imgui.SetCursorPos(imgui.ImVec2(220,190))
									if imgui.InvisibleButton('##zametkisave',imgui.ImVec2(85,15)) then
										if #str(zametkisettings.zametkaname) > 0 then
											if #str(zametkisettings.zametkatext) > 0 then
												if zametkaredact_number ~= 0 then
													sampUnregisterChatCommand(zametki[zametkaredact_number].cmd)
												end
												zametki[zametkaredact_number == 0 and #zametki + 1 or zametkaredact_number] = {name = u8:decode(str(zametkisettings.zametkaname)), text = u8:decode(str(zametkisettings.zametkatext)), button = u8:decode(str(zametkisettings.zametkabtn)), cmd = u8:decode(str(zametkisettings.zametkacmd))}
												zametkaredact_number = nil
												local file = io.open(getWorkingDirectory()..'\\Med Helper\\Zametki.json', 'w')
												file:write(encodeJson(zametki))
												file:close()
												updatechatcommands()
											else
												MedHelperMessage('Òåêñò çàìåòêè íå ââåäåí.')
											end
										else
											MedHelperMessage('Íàçâàíèå çàìåòêè íå ââåäåíî.')
										end
									end
									imgui.SetCursorPos(imgui.ImVec2(220,190))
									imgui.PushFont(font[16])
									imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Ñîõðàíèòü '..fa.ICON_FA_CHEVRON_RIGHT)
									imgui.PopFont()

									imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15, 15))
									if imgui.BeginPopupModal(u8'Ðåäàêòîð òåêñòà çàìåòêè', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
										imgui.Text(u8'Òåêñò:')
										imgui.InputTextMultiline(u8'##zametkatexteditor', zametkisettings.zametkatext, sizeof(zametkisettings.zametkatext), imgui.ImVec2(435,200))
										if imgui.Button(u8'Çàêðûòü', imgui.ImVec2(-1, 25)) then imgui.CloseCurrentPopup() end
										imgui.EndPopup()
									end
									imgui.PopStyleVar()
								end
							imgui.EndChild()
							imgui.SetCursorPosX(7)
							if zametkaredact_number == nil then
								if imgui.Button(fa.ICON_FA_PLUS_CIRCLE..u8' Ñîçäàòü##zametkas') then
									zametkaredact_number = 0
									imgui.StrCopy(zametkisettings.zametkacmd, '')
									imgui.StrCopy(zametkisettings.zametkaname, '')
									imgui.StrCopy(zametkisettings.zametkatext, '')
									zametkisettings.zametkabtn = ''
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_PEN..u8' Èçìåíèòü') then
									if zametki[now_zametka[0]] then
										zametkaredact_number = now_zametka[0]
										imgui.StrCopy(zametkisettings.zametkacmd, u8(zametki[now_zametka[0]].cmd))
										imgui.StrCopy(zametkisettings.zametkaname, u8(zametki[now_zametka[0]].name))
										imgui.StrCopy(zametkisettings.zametkatext, u8(zametki[now_zametka[0]].text))
										zametkisettings.zametkabtn = zametki[now_zametka[0]].button
									end
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_TRASH..u8' Óäàëèòü') then
									if zametki[now_zametka[0]] then
										table.remove(zametki, now_zametka[0])
										now_zametka[0] = 1
									end
									local file = io.open(getWorkingDirectory()..'\\Med Helper\\Zametki.json', 'w')
									file:write(encodeJson(zametki))
									file:close()
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_ARROW_UP) then
									now_zametka[0] = (now_zametka[0] - 1 < 1) and #zametki or now_zametka[0] - 1
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_ARROW_DOWN) then
									now_zametka[0] = (now_zametka[0] + 1 > #zametki) and 1 or now_zametka[0] + 1
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_WINDOW_RESTORE) then
									windows.imgui_zametka[0] = true
									zametka_window[0] = now_zametka[0]
								end
							end
						imgui.EndChild()
					elseif additionalwindow[0] == 3 then
						imgui.BeginChild('##otigrovkiwindow',_,false)
							imgui.SetCursorPos(imgui.ImVec2(15,15))
							imgui.BeginGroup()

								imgui.Text(u8'Çàäåðæêà ìåæäó ñîîáùåíèÿìè:')
								imgui.PushItemWidth(200)
								if imgui.SliderFloat('##playcd', usersettings.playcd, 0.5, 10.0, '%.1f c.') then
									if usersettings.playcd[0] < 0.5 then usersettings.playcd[0] = 0.5 end
									if usersettings.playcd[0] > 10.0 then usersettings.playcd[0] = 10.0 end
									configuration.main_settings.playcd = usersettings.playcd[0] * 1000
									inicfg.save(configuration,'Med Helper')
								end
								imgui.PopItemWidth()
								imgui.Spacing()
								
								if imgui.ToggleButton(u8'Íà÷èíàòü îòûãðîâêè ïîñëå êîìàíä', usersettings.dorponcmd) then
									configuration.main_settings.dorponcmd = usersettings.dorponcmd[0]
									inicfg.save(configuration,'Med Helper')
								end
								
								if imgui.ToggleButton(u8'Àâòîîòûãðîâêà äóáèíêè', usersettings.playdubinka) then
									configuration.main_settings.playdubinka = usersettings.playdubinka[0]
									inicfg.save(configuration,'Med Helper')
								end
								
								if imgui.ToggleButton(u8'Çàìåíÿòü Áîëüíèöà íà ÌÖ â îòûãðîâêàõ', usersettings.replaceash) then
									configuration.main_settings.replaceash = usersettings.replaceash[0]
									inicfg.save(configuration,'Med Helper')
								end

							imgui.EndGroup()
						imgui.EndChild()
					elseif additionalwindow[0] == 4 then
						imgui.BeginChild('##checkerwindow',_,false)
							local p = imgui.GetWindowPos()
							imgui.SetCursorPos(imgui.ImVec2(25, 20))
							imgui.BeginGroup()
								imgui.SetCursorPosX(15)
								imgui.PushFont(font[16])
								imgui.Text(u8'Îñíîâíîå')
								imgui.PopFont()
								if imgui.ToggleButton(u8'Âêëþ÷èòü ÷åêåð', checker_variables.state) then
									configuration.Checker.state = checker_variables.state[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end

								if imgui.Button(fa.ICON_FA_ARROWS_ALT..'##checkerpos') then
									if configuration.Checker.state then
										changePosition(configuration.Checker)
									else
										addNotify('Âêëþ÷èòå ÷åêåð.', 5)
									end
								end
								imgui.SameLine()
								imgui.Text(u8'Ìåñòîïîëîæåíèå')
							
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
								imgui.Text(u8'Ëèìèò ÀÔÊ ñîòðóäíèêîâ(s):')
								imgui.SameLine()
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)

								imgui.PushItemWidth(50)
								if imgui.InputInt('##AFKMax_low', checker_variables.afk_max_l, 0, 0) then
									if checker_variables.afk_max_l[0] < 0 then checker_variables.afk_max_l[0] = 0 end
									if checker_variables.afk_max_l[0] > 3599 then checker_variables.afk_max_l[0] = 3599 end
									configuration.Checker.afk_max_l = checker_variables.afk_max_l[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.Hint('hint_slider_int_1', ('Ìëàäøèå ðàíãè (1 - 4)'))
								imgui.SameLine()
								if imgui.InputInt('##AFKMax_High', checker_variables.afk_max_h, 0, 0) then
									if checker_variables.afk_max_h[0] < 0 then checker_variables.afk_max_h[0] = 0 end
									if checker_variables.afk_max_h[0] > 3599 then checker_variables.afk_max_h[0] = 3599 end
									configuration.Checker.afk_max_h = checker_variables.afk_max_h[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.Hint('hint_slider_int_2', ('Ñòàðøèå ðàíãè (5 - 10)'))
								imgui.PopItemWidth()

								imgui.Text(u8'×àñòîòà îáíîâëåíèÿ(s):')
								imgui.SameLine(165)

								imgui.PushItemWidth(110)
								if imgui.DragInt('##checkerDelay', checker_variables.delay, 0.5, 3, 30, u8((checker_variables.delay[0]) .. ' ñåêóíä')) then
									if checker_variables.delay[0] < 3 then checker_variables.delay[0] = 3 end
									if checker_variables.delay[0] > 30 then checker_variables.delay[0] = 30 end
									configuration.Checker.delay = checker_variables.delay[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.Hint('hint_drag', 'Âðåìÿ, ñïóñòÿ êîòîðîå áóäåò îáíîâëÿòüñÿ ñïèñîê\nÇàæàòü è ïåðåäâèãàòü ìûøü')
								imgui.PopItemWidth()

							imgui.EndGroup()

							imgui.SetCursorPosX(25)
							imgui.BeginGroup()
								imgui.SetCursorPosX(15)
								imgui.PushFont(font[16])
								imgui.Text(u8'Ñòèëü')
								imgui.PopFont()
								imgui.PushItemWidth(130)
								imgui.Text(u8'Íàçâàíèå øðèôòà:')
								imgui.SameLine(140)
								if imgui.InputTextWithHint('##FontName', u8'Íàçâàíèå øðèôòà', checker_variables.font_input, sizeof(checker_variables.font_input)) then
									configuration.Checker.font_name = #str(checker_variables.font_input) > 0 and u8:decode(str(checker_variables.font_input)) or 'Arial'
									checker_variables.font = renderCreateFont(configuration.Checker.font_name, configuration.Checker.font_size, configuration.Checker.font_flag)
									inicfg.save(configuration, 'Med Helper.ini')
								end
								if not imgui.IsItemActive() and #str(checker_variables.font_input) == 0 then
									imgui.StrCopy(checker_variables.font_input, u8'Arial')
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.Text(u8'Ðàçìåð øðèôòà:')
								imgui.SameLine(140)
								if imgui.SliderInt('##FontSize', checker_variables.font_size, 1, 25, u8'%d') then
									if checker_variables.font_size[0] < 1 then checker_variables.font_size[0] = 1 end
									if checker_variables.font_size[0] > 25 then checker_variables.font_size[0] = 25 end
									configuration.Checker.font_size = checker_variables.font_size[0]
									checker_variables.font = renderCreateFont(configuration.Checker.font_name, configuration.Checker.font_size, configuration.Checker.font_flag)
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.Text(u8'Ñòèëü øðèôòà:')
								imgui.SameLine(140)
								if imgui.SliderInt('##FontFlag', checker_variables.font_flag, 1, 25, u8'%d') then
									if checker_variables.font_flag[0] < 1 then checker_variables.font_flag[0] = 1 end
									if checker_variables.font_flag[0] > 25 then checker_variables.font_flag[0] = 25 end
									configuration.Checker.font_flag = checker_variables.font_flag[0]
									checker_variables.font = renderCreateFont(configuration.Checker.font_name, configuration.Checker.font_size, configuration.Checker.font_flag)
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.Text(u8'Ðàññòîÿíèå ñòðîê:')
								imgui.SameLine(140)
								if imgui.SliderInt('##FontOffset', checker_variables.font_offset, 1, 30, u8'%d') then
									if checker_variables.font_offset[0] < 1 then checker_variables.font_offset[0] = 1 end
									if checker_variables.font_offset[0] > 30 then checker_variables.font_offset[0] = 30 end
									configuration.Checker.font_offset = checker_variables.font_offset[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.Text(u8'Íåïðîçðà÷íîñòü:')
								imgui.SameLine(140)
								if imgui.SliderInt('##FontAlpha', checker_variables.font_alpha, 1, 100, u8'%d%%') then
									if checker_variables.font_alpha[0] < 1 then checker_variables.font_alpha[0] = 1 end
									if checker_variables.font_alpha[0] > 100 then checker_variables.font_alpha[0] = 100 end
									configuration.Checker.font_alpha = checker_variables.font_alpha[0] * 2.55
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.PopItemWidth()
							imgui.EndGroup()

							imgui.NewLine()
							imgui.SetCursorPosX(25)
							imgui.BeginGroup()
								imgui.SetCursorPosX(15)
								imgui.PushFont(font[16])
								imgui.Text(u8'Îòîáðàæåíèå')
								imgui.PopFont()
								if imgui.ToggleButton(u8'Ðàáî÷àÿ ôîðìà', checker_variables.show.uniform) then
									configuration.Checker.show_uniform = checker_variables.show.uniform[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint('hint_uniform', 'Ïîêàçûâàòü êòî èç ñîòðóäíèêîâ â ôîðìå, à êòî íåò\n(Àíàëîã /members)')
								if imgui.ToggleButton(u8'Íîìåð äîëæíîñòè', checker_variables.show.rank) then
									configuration.Checker.show_rank = checker_variables.show.rank[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								if imgui.ToggleButton(u8'ID Ñîòðóäíèêà', checker_variables.show.id) then
									configuration.Checker.show_id = checker_variables.show.id[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								if imgui.ToggleButton(u8'Âðåìÿ â ÀÔÊ', checker_variables.show.afk) then
									configuration.Checker.show_afk = checker_variables.show.afk[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								if imgui.ToggleButton(u8'Êîë-âî âûãîâîðîâ', checker_variables.show.warn) then
									configuration.Checker.show_warn = checker_variables.show.warn[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								if imgui.ToggleButton(u8'Îòîáðàæàòü ìóòû', checker_variables.show.mute) then
									configuration.Checker.show_mute = checker_variables.show.mute[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint('hint_mute', 'Ó ñîòðóäíèêîâ, íà êîòîðûõ íàëîæåí îðãàíèçàöèîííûé ìóò\náóäåò ïîìåòêà Muted â ñïèñêå')
								if imgui.ToggleButton(u8'Ñîòðóäíèêè ðÿäîì', checker_variables.show.near) then
									configuration.Checker.show_near = checker_variables.show.near[0]
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint('hint_near', 'Ñîòðóäíèêè íàõîäÿùèåñÿ â âàøåé çîíå ïðîðèñîâêè\náóäóò îòìå÷àòñÿ ìåòêîé [N] â ñïèñêå')
							imgui.EndGroup()

							imgui.SameLine(nil, 25)
							imgui.BeginGroup()
								local col = checker_variables.col
								imgui.SetCursorPosX(209)
								imgui.PushFont(font[16])
								imgui.Text(u8'Öâåòà')
								imgui.PopFont()
								if imgui.ColorEdit4('##TitleColor', col.title, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.title[0],  col.title[1], col.title[2],  col.title[3])
									configuration.Checker.col_title = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'Çàãîëîâîê')
								if imgui.ColorEdit4('##DefaultColor', col.default, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.default[0], col.default[1], col.default[2], col.default[3]) 
									configuration.Checker.col_default = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'Ñòàíäàðòíûé')
								if imgui.ColorEdit4('##NoWorkColor', col.no_work, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.no_work[0], col.no_work[1], col.no_work[2], col.no_work[3]) 
									configuration.Checker.col_no_work = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'Áåç ôîðìû')
								if imgui.ColorEdit4('##AFKMaxColor', col.afk_max, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.afk_max[0], col.afk_max[1], col.afk_max[2], col.afk_max[3]) 
									configuration.Checker.col_afk_max = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'AFK Max')
								if imgui.ColorEdit4('##NoteColor', col.note, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.note[0], col.note[1], col.note[2], col.note[3]) 
									configuration.Checker.col_note = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'Med Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'Çàìåòêè')
							imgui.EndGroup()
							imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 265, p.y + 230), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 'Author: Cosmo')
							imgui.Spacing()
						imgui.EndChild()
					end
					imgui.PopStyleVar()
				elseif mainwindow[0] == 3 then
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					if imgui.InvisibleButton('##settingsbackbutton',imgui.ImVec2(10,15)) then
						mainwindow[0] = 0
						alpha[0] = clock()
					end
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					imgui.PushFont(font[16])
					imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT)
					imgui.PopFont()
					imgui.SameLine()
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 5, p.y - 10),imgui.ImVec2(p.x + 5, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
					imgui.SetCursorPos(imgui.ImVec2(60,15))
					imgui.PushFont(font[25])
					imgui.Text(u8'Èíôîðìàöèÿ')
					imgui.PopFont()
				
					imgui.SetCursorPos(imgui.ImVec2(15,65))
					imgui.BeginGroup()
						imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.05,0.5))
						for k, i in pairs(infobuttons) do
							local clr = imgui.GetStyle().Colors[imgui.Col.Text].x
							if infowindow[0] == k then
								local p = imgui.GetCursorScreenPos()
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,infowindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton(i, imgui.ImVec2(186,35)) then
								if infowindow[0] ~= k then
									infowindow[0] = k
									alpha[0] = clock()
								end
							end
							imgui.PopStyleColor(3)
						end
						imgui.PopStyleVar()
					imgui.EndGroup()

					imgui.SetCursorPos(imgui.ImVec2(208, 0))
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					imgui.BeginChild('##informationmainwindow',_,false)
					if infowindow[0] == 1 then
						imgui.PushFont(font[16])
						imgui.SetCursorPosX(20)
						imgui.BeginGroup()
							if updateinfo.version and updateinfo.version > thisScript().version then
								imgui.SetCursorPosY(20)
								imgui.TextColored(imgui.ImVec4(0.92, 0.71, 0.25, 1), fa.ICON_FA_EXCLAMATION_CIRCLE)
								imgui.SameLine()
								imgui.BeginGroup()
									imgui.Text(u8'Îáíàðóæåíî îáíîâëåíèå íà âåðñèþ '..updateinfo.version..'!')
									imgui.PopFont()
									if imgui.Button(u8'Ñêà÷àòü '..fa.ICON_FA_ARROW_ALT_CIRCLE_DOWN) then
										local function DownloadFile(url, file)
											downloadUrlToFile(url,file,function(id,status)
												if status == dlstatus.STATUSEX_ENDDOWNLOAD then
													MedHelperMessage('Îáíîâëåíèå óñïåøíî çàãðóæåíî, ñêðèïò ïåðåçàãðóæàåòñÿ...')
												end
											end)
										end
										DownloadFile(updateinfo.file, thisScript().path)
										NoErrors = true
									end
									imgui.SameLine()
									if imgui.TreeNodeStr(u8'Ñïèñîê èçìåíåíèé') then
										imgui.SetCursorPosX(135)
										imgui.TextWrapped(u8(updateinfo.change_log))
										imgui.TreePop()
									end
								imgui.EndGroup()
							elseif updateinfo.version and updateinfo.version == thisScript().version then
								imgui.SetCursorPosY(30)
								imgui.TextColored(imgui.ImVec4(0.2, 1, 0.2, 1), fa.ICON_FA_CHECK_CIRCLE)
								imgui.SameLine()
								imgui.SetCursorPosY(20)
								imgui.BeginGroup()
									imgui.Text(u8'Ó âàñ óñòàíîâëåíà ïîñëåäíÿÿ âåðñèÿ ñêðèïòà.')
									imgui.PushFont(font[11])
									imgui.TextColoredRGB('{SSSSSS90}Âðåìÿ ïîñëåäíåé ïðîâåðêè: '..(updateinfo.updatelastcheck or 'íå îïðåäåëåíî'))
									imgui.PopFont()
									imgui.PopFont()
									imgui.Spacing()
									if imgui.Button(u8'Ïðîâåðèòü íàëè÷èå îáíîâëåíèé') then
										checkUpdates('https://raw.githubusercontent.com/EvilDukky/MedHelper/main/Update/update.json', true)
									end
								imgui.EndGroup()
							else
								imgui.SetCursorPosY(30)
								imgui.TextColored(imgui.ImVec4(1, 0.2, 0.2, 1), fa.ICON_FA_TIMES_CIRCLE)
								imgui.SameLine()
								imgui.SetCursorPosY(20)
								imgui.BeginGroup()
									imgui.Text(u8'Îáíîâëåíèå íå ïðîâåðåíî.')
									imgui.PushFont(font[11])
									imgui.TextColoredRGB('{SSSSSS90}Âðåìÿ ïîñëåäíåé ïðîâåðêè: '..(updateinfo.updatelastcheck or 'íå îïðåäåëåíî'))
									imgui.PopFont()
									imgui.PopFont()
									imgui.Spacing()
									if imgui.Button(u8'Ïðîâåðèòü íàëè÷èå îáíîâëåíèé') then
										checkUpdates('https://raw.githubusercontent.com/EvilDukky/MedHelper/main/Update/update.json', true)
									end
								imgui.EndGroup()
							end
							imgui.NewLine()
							imgui.PushFont(font[15])
							imgui.Text(u8'Ïàðàìåòðû')
							imgui.PopFont()
							imgui.SetCursorPosX(30)
							if imgui.ToggleButton(u8'Àâòî-ïðîâåðêà îáíîâëåíèé', auto_update_box) then
								configuration.main_settings.autoupdate = auto_update_box[0]
								inicfg.save(configuration,'Med Helper')
							end
							imgui.SetCursorPosX(30)
							if imgui.ToggleButton(u8'Ïîëó÷àòü áåòà ðåëèçû', get_beta_upd_box) then
								configuration.main_settings.getbetaupd = get_beta_upd_box[0]
								inicfg.save(configuration,'Med Helper')
							end
							imgui.SameLine()
							imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
							imgui.Hint('betareleaseshint', 'Ïîñëå âêëþ÷åíèÿ äàííîé ôóíêöèè Âû áóäåòå ïîëó÷àòü\nîáíîâëåíèÿ ðàíüøå äðóãèõ ëþäåé äëÿ òåñòèðîâàíèÿ è\nñîîáùåíèÿ î áàãàõ ðàçðàáîò÷èêó.\n{FF1010}Ðàáîòà ýòèõ âåðñèé íå áóäåò ãàðàíòèðîâàíà.')
						imgui.EndGroup()
					elseif infowindow[0] == 2 then
						imgui.SetCursorPos(imgui.ImVec2(15,15))
						imgui.BeginGroup()
							if testCheat('dev') then
								configuration.main_settings.myrankint = 10
								addNotify('{20FF20}Ðåæèì ðàçðàáîò÷èêà âêëþ÷¸í.', 5)
								sampRegisterChatCommand('medh_temp',function()
									fastmenuID = select(2, sampGetPlayerIdByCharHandle(playerPed))
									windows.imgui_fm[0] = true
								end)
							end
							imgui.PushFont(font[15])
							imgui.TextColoredRGB('Àâòîð - {MC}EvilDukky')
							imgui.TextColoredRGB('Çà îñíîâó áûë âçÿò AS Helper - {MC}JustMini')
							imgui.PopFont()
							imgui.NewLine()

							imgui.TextWrapped(u8'Åñëè Âû íàøëè áàã èëè õîòèòå ïðåäëîæèòü óëó÷øåíèå/èçìåíåíèå äëÿ ñêðèïòà, òî ìîæåòå ñâÿçàòüñÿ ñî ìíîé â VK.')
							imgui.SetCursorPosX(25)
							imgui.Text(fa.ICON_FA_LINK)
							imgui.SameLine(40)
							imgui.Text(u8'Ñâÿçàòüñÿ ñî ìíîé â VK:')
							imgui.SameLine(190)
							imgui.Link('https://vk.com/evil.duckky', u8'vk.com/evil.duckky')

							imgui.Spacing()

							imgui.TextWrapped(u8'Åñëè Âû íàõîäèòå ýòîò ñêðèïò ïîëåçíûì, òî ìîæåòå ïîääåðæàòü ðàçðàáîòêó äåíüãàìè.')
							imgui.SetCursorPosX(25)
							imgui.TextColored(imgui.ImVec4(0.31,0.78,0.47,1), fa.ICON_FA_GEM)
							imgui.SameLine(40)
							imgui.Text(u8'Ïîääåðæàòü ðàçðàáîòêó:')
							imgui.SameLine(190)
							imgui.Link('https://www.donationalerts.com/r/evil_d', 'donationalerts.com/r/evil_d')
						imgui.EndGroup()
					elseif infowindow[0] == 3 then
						imgui.SetCursorPos(imgui.ImVec2(15,15))
						imgui.BeginGroup()
							imgui.PushFont(font[16])
							imgui.TextColoredRGB('Med Helper',1)
							imgui.PopFont()
							imgui.TextColoredRGB('Âåðñèÿ ñêðèïòà - {MC}'..thisScript().version)
							if imgui.Button(u8'Ñïèñîê èçìåíåíèé') then
								windows.imgui_changelog[0] = true
							end
							imgui.Separator()
							imgui.TextWrapped(u8[[
	* Med Helper - óäîáíûé ïîìîùíèê, êîòîðûé îáëåã÷èò Âàì ðàáîòó â Áîëüíèöå. Ñêðèïò áûë ðàçðàáîòàí ñïåöèàëüíî äëÿ ïðîåêòà Arizona RP. Ñêðèïò èìååò îòêðûòûé êîä äëÿ îçíàêîìëåíèÿ, ëþáîå âûñòàâëåíèå ñêðèïòà áåç óêàçàíèÿ àâòîðñòâà çàïðåùåíî! Îáíîâëåíèÿ ñêðèïòà ïðîèñõîäÿò áåçîïàñíî äëÿ Âàñ, àâòîîáíîâëåíèÿ íåò, óñòàíîâêó äîëæíû ïîäòâåðæäàòü Âû.

	* Ìåíþ áûñòðîãî äîñòóïà - Ïðèöåëèâøèñü íà èãðîêà ñ ïîìîùüþ ÏÊÌ è íàæàâ êíîïêó E (ïî óìîë÷àíèþ), îòêðîåòñÿ ìåíþ áûñòðîãî äîñòóïà. Â äàííîì ìåíþ åñòü âñå íóæíûå ôóíêöèè, à èìåííî: ïðèâåòñòâèå, ëå÷åíèå áîëüíûõ, ïðîäàæà àíòèáèîòèêîâ, ïðîâåäåíèå ðåàíèìàöèè, âûäà÷à ìåä.êàðò, ïðîäàæà ðåöåïòîâ, ñíÿòèå íàðêîçàâèñèìîñòè, âûêöèíàöèÿ îò êîðîíàâèðóñà, ïðîäàæà ñòðàõîâîê, âûâåäåíèå òàòóèðîâîê, ïðîâåäåíèå ìåä.îñìîòðà, âîçìîæíîñòü âûãíàòü ÷åëîâåêà èç áîëüíèöû, ïðèãëàøåíèå â îðãàíèçàöèþ, óâîëüíåíèå èç îðãàíèçàöèè, èçìåíåíèå äîëæíîñòè, çàíåñåíèå â ×Ñ, óäàëåíèå èç ×Ñ, âûäà÷à âûãîâîðîâ, óäàëåíèå âûãîâîðîâ, âûäà÷à îðãàíèçàöèîííîãî ìóòà, óäàëåíèå îðãàíèçàöèîííîãî ìóòà, àâòîìàòèçèðîâàííîå ïðîâåäåíèå ñîáåñåäîâàíèÿ ñî âñåìè íóæíûìè îòûãðîâêàìè.

	* Êîìàíäû ñåðâåðà ñ îòûãðîâêàìè - /invite, /uninvite, /giverank, /blacklist, /unblacklist, /fwarn, /unfwarn, /fmute, /funmute, /expel. Ââåäÿ ëþáóþ èç ýòèõ êîìàíä íà÷í¸òñÿ ÐÏ îòûãðîâêà, ëèøü ïîñëå íå¸ áóäåò àêòèâèðîâàíà ñàìà êîìàíäà (ýòó ôóíêöèþ ìîæíî îòêëþ÷èòü â íàñòðîéêàõ).

	* Êîìàíäû õåëïåðà - /mhm - íàñòðîéêè õåëïåðà, /mhmbind - áèíäåð õåëïåðà, /mhmlect - ìåíþ ëåêöèé, /mhmdep - ìåíþ äåïàðòàìåíòà

	* Íàñòðîéêè - Ââåäÿ êîìàíäó /mhm îòêðîþòñÿ íàñòðîéêè â êîòîðûõ ìîæíî èçìåíÿòü íèêíåéì â ïðèâåòñòâèè, àêöåíò, ñîçäàíèå ìàðêåðà ïðè âûäåëåíèè, ïîë, öåíû íà óñëóãè áîëüíèöû, ãîðÿ÷óþ êëàâèøó áûñòðîãî ìåíþ è ìíîãîå äðóãîå.

	* Ìåíþ ëåêöèé - Ââåäÿ êîìàíäó /mhmlect îòêðîåòñÿ ìåíþ ëåêöèé, â êîòîðîì âû ñìîæåòå îçâó÷èòü/äîáàâèòü/óäàëèòü ëåêöèè.

	* Áèíäåð - Ââåäÿ êîìàíäó /mhmbind îòêðîåòñÿ áèíäåð, â êîòîðîì âû ìîæåòå ñîçäàòü àáñîëþòíî ëþáîé áèíä íà êîìàíäó, èëè æå êíîïêó(è).]])
						imgui.Spacing()
						imgui.EndGroup()
					end
					imgui.EndChild()
					imgui.PopStyleVar()
				end
			imgui.EndChild()
			imgui.PopStyleVar()
		imgui.End()
		imgui.PopStyleVar()
	end
)

local imgui_binder = imgui.OnFrame(
	function() return windows.imgui_binder[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(650, 370), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Áèíäåð', windows.imgui_binder, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
		imgui.Image(medh_image,imgui.ImVec2(202,25),imgui.ImVec2(0.25,configuration.main_settings.style ~= 2 and 0.4 or 0.5),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.5 or 0.6))
		imgui.SameLine(583)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
		if choosedslot then
			if imgui.Button(fa.ICON_FA_QUESTION_CIRCLE,imgui.ImVec2(23,23)) then
				imgui.OpenPopup(u8'Òýãè')
			end
		end
		imgui.SameLine(606)
		if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
			windows.imgui_binder[0] = false
		end
		imgui.PopStyleColor(3)
		if imgui.BeginPopup(u8'Òýãè', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
			for k,v in pairs(tagbuttons) do
				if imgui.Button(u8(tagbuttons[k].name),imgui.ImVec2(150,25)) then
					imgui.StrCopy(bindersettings.binderbuff, str(bindersettings.binderbuff)..u8(tagbuttons[k].name))
					MedHelperMessage('Òýã áûë ñêîïèðîâàí.')
				end
				imgui.SameLine()
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8(tagbuttons[k].hint))
					imgui.EndTooltip()
				end
				imgui.Text(u8(tagbuttons[k].text))
			end
			imgui.EndPopup()
		end
		imgui.BeginChild('ChildWindow',imgui.ImVec2(175,270),true, (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
		imgui.SetCursorPosY(7.5)
		for key, value in pairs(configuration.BindsName) do
			imgui.SetCursorPosX(7.5)
			if imgui.Button(u8(configuration.BindsName[key]..'##'..key),imgui.ImVec2(160,30)) then
				choosedslot = key
				imgui.StrCopy(bindersettings.binderbuff, gsub(u8(configuration.BindsAction[key]), '~', '\n' ) or '')
				imgui.StrCopy(bindersettings.bindername, u8(configuration.BindsName[key] or ''))
				imgui.StrCopy(bindersettings.bindercmd, u8(configuration.BindsCmd[key] or ''))
				imgui.StrCopy(bindersettings.binderdelay, u8(configuration.BindsDelay[key] or ''))
				bindersettings.bindertype[0] = configuration.BindsType[key] or 0
				bindersettings.binderbtn = configuration.BindsKeys[key] or ''
			end
		end
		imgui.EndChild()
		if choosedslot ~= nil and choosedslot <= 50 then
			imgui.SameLine()
			imgui.BeginChild('ChildWindow2',imgui.ImVec2(435,200),false)
			imgui.InputTextMultiline('##bindertexteditor', bindersettings.binderbuff, sizeof(bindersettings.binderbuff), imgui.ImVec2(435,200))
			imgui.EndChild()
			imgui.SetCursorPos(imgui.ImVec2(206.5, 261))
			imgui.Text(u8'Íàçâàíèå áèíäà:')
			imgui.SameLine()
			imgui.PushItemWidth(150)
			if choosedslot ~= 50 then imgui.InputText('##bindersettings.bindername', bindersettings.bindername,sizeof(bindersettings.bindername),imgui.InputTextFlags.ReadOnly)
			else imgui.InputText('##bindersettings.bindername', bindersettings.bindername, sizeof(bindersettings.bindername))
			end
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.PushItemWidth(162)
			imgui.Combo('##binderchoosebindtype', bindersettings.bindertype, new['const char*'][2]({u8'Èñïîëüçîâàòü êîìàíäó', u8'Èñïîëüçîâàòü êëàâèøè'}), 2)
			imgui.PopItemWidth()
			imgui.SetCursorPos(imgui.ImVec2(206.5, 293))
			imgui.TextColoredRGB('Çàäåðæêà ìåæäó ñòðîêàìè {FF4500}(ms):'); imgui.SameLine()
			imgui.Hint('msbinderhint','Óêàçûâàéòå çíà÷åíèå â ìèëëèñåêóíäàõ\n1 ñåêóíäà = 1.000 ìèëëèñåêóíä')
			imgui.PushItemWidth(64)
			imgui.InputText('##bindersettings.binderdelay', bindersettings.binderdelay, sizeof(bindersettings.binderdelay), imgui.InputTextFlags.CharsDecimal)
			if tonumber(str(bindersettings.binderdelay)) and tonumber(str(bindersettings.binderdelay)) > 60000 then
				imgui.StrCopy(bindersettings.binderdelay, '60000')
			elseif tonumber(str(bindersettings.binderdelay)) and tonumber(str(bindersettings.binderdelay)) < 1 then
				imgui.StrCopy(bindersettings.binderdelay, '1')
			end
			imgui.PopItemWidth()
			imgui.SameLine()
			if bindersettings.bindertype[0] == 0 then
				imgui.Text('/')
				imgui.SameLine()
				imgui.PushItemWidth(145)
				imgui.InputText('##bindersettings.bindercmd',bindersettings.bindercmd,sizeof(bindersettings.bindercmd),imgui.InputTextFlags.CharsNoBlank)
				imgui.PopItemWidth()
			elseif bindersettings.bindertype[0] == 1 then
				imgui.HotKey('##binderbinder', bindersettings, 'binderbtn', '', 162)
			end
			imgui.NewLine()
			imgui.SetCursorPos(imgui.ImVec2(535, 330))
			if #str(bindersettings.binderbuff) > 0 and #str(bindersettings.bindername) > 0 and #str(bindersettings.binderdelay) > 0 and bindersettings.bindertype[0] ~= nil then
				if imgui.Button(u8'Ñîõðàíèòü',imgui.ImVec2(100,30)) then
					local kei = nil
					if not inprocess then
						for key, value in pairs(configuration.BindsName) do
							if u8:decode(str(bindersettings.bindername)) == tostring(value) then
								sampUnregisterChatCommand(configuration.BindsCmd[key])
								kei = key
							end
						end
						local refresh_text = gsub(u8:decode(str(bindersettings.binderbuff)), '\n', '~')
						if kei ~= nil then
							configuration.BindsName[kei] = u8:decode(str(bindersettings.bindername))
							configuration.BindsDelay[kei] = str(bindersettings.binderdelay)
							configuration.BindsAction[kei] = refresh_text
							configuration.BindsType[kei]= bindersettings.bindertype[0]
							if bindersettings.bindertype[0] == 0 then
								configuration.BindsCmd[kei] = u8:decode(str(bindersettings.bindercmd))
							elseif bindersettings.bindertype[0] == 1 then
								configuration.BindsKeys[kei] = bindersettings.binderbtn
							end
							if inicfg.save(configuration, 'Med Helper') then
								MedHelperMessage('Áèíä óñïåøíî ñîõðàí¸í!')
							end
						else
							configuration.BindsName[#configuration.BindsName + 1] = u8:decode(str(bindersettings.bindername))
							configuration.BindsDelay[#configuration.BindsDelay + 1] = str(bindersettings.binderdelay)
							configuration.BindsAction[#configuration.BindsAction + 1] = refresh_text
							configuration.BindsType[#configuration.BindsType + 1] = bindersettings.bindertype[0]
							if bindersettings.bindertype[0] == 0 then
								configuration.BindsCmd[#configuration.BindsCmd + 1] = u8:decode(str(bindersettings.bindercmd))
							elseif bindersettings.bindertype[0] == 1 then
								configuration.BindsKeys[#configuration.BindsKeys + 1] = bindersettings.binderbtn
							end
							if inicfg.save(configuration, 'Med Helper') then
								MedHelperMessage('Áèíä óñïåøíî ñîçäàí!')
							end
						end
						imgui.StrCopy(bindersettings.bindercmd, '')
						imgui.StrCopy(bindersettings.binderbuff, '')
						imgui.StrCopy(bindersettings.bindername, '')
						imgui.StrCopy(bindersettings.binderdelay, '')
						imgui.StrCopy(bindersettings.bindercmd, '')
						bindersettings.bindertype[0] = 0
						choosedslot = nil
						updatechatcommands()
					else
						MedHelperMessage('Âû íå ìîæåòå âçàèìîäåéñòâîâàòü ñ áèíäåðîì âî âðåìÿ ëþáîé îòûãðîâêè!')
					end	
				end
			else
				imgui.LockedButton(u8'Ñîõðàíèòü',imgui.ImVec2(100,30))
				imgui.Hint('notallparamsbinder','Âû ââåëè íå âñå ïàðàìåòðû. Ïåðåïðîâåðüòå âñ¸.')
			end
			imgui.SameLine()
			imgui.SetCursorPosX(202)
			if imgui.Button(u8'Îòìåíèòü',imgui.ImVec2(100,30)) then
				imgui.StrCopy(bindersettings.bindercmd, '')
				imgui.StrCopy(bindersettings.binderbuff, '')
				imgui.StrCopy(bindersettings.bindername, '')
				imgui.StrCopy(bindersettings.binderdelay, '')
				imgui.StrCopy(bindersettings.bindercmd, '')
				bindersettings.bindertype[0] = 0
				choosedslot = nil
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(240,180))
			imgui.Text(u8'Îòêðîéòå áèíä èëè ñîçäàéòå íîâûé äëÿ ìåíþ ðåäàêòèðîâàíèÿ.')
		end
		imgui.SetCursorPos(imgui.ImVec2(14, 330))
		if imgui.Button(u8'Äîáàâèòü',imgui.ImVec2(82,30)) then
			choosedslot = 50
			imgui.StrCopy(bindersettings.binderbuff, '')
			imgui.StrCopy(bindersettings.bindername, '')
			imgui.StrCopy(bindersettings.bindercmd, '')
			imgui.StrCopy(bindersettings.binderdelay, '')
			bindersettings.bindertype[0] = 0
		end
		imgui.SameLine()
		if choosedslot ~= nil and choosedslot ~= 50 then
			if imgui.Button(u8'Óäàëèòü',imgui.ImVec2(82,30)) then
				if not inprocess then
					for key, value in pairs(configuration.BindsName) do
						local value = tostring(value)
						if u8:decode(str(bindersettings.bindername)) == configuration.BindsName[key] then
							sampUnregisterChatCommand(configuration.BindsCmd[key])
							table.remove(configuration.BindsName,key)
							table.remove(configuration.BindsKeys,key)
							table.remove(configuration.BindsAction,key)
							table.remove(configuration.BindsCmd,key)
							table.remove(configuration.BindsDelay,key)
							table.remove(configuration.BindsType,key)
							if inicfg.save(configuration,'Med Helper') then
								imgui.StrCopy(bindersettings.bindercmd, '')
								imgui.StrCopy(bindersettings.binderbuff, '')
								imgui.StrCopy(bindersettings.bindername, '')
								imgui.StrCopy(bindersettings.binderdelay, '')
								imgui.StrCopy(bindersettings.bindercmd, '')
								bindersettings.bindertype[0] = 0
								choosedslot = nil
								MedHelperMessage('Áèíä óñïåøíî óäàë¸í!')
							end
						end
					end
					updatechatcommands()
				else
					MedHelperMessage('Âû íå ìîæåòå óäàëÿòü áèíä âî âðåìÿ ëþáîé îòûãðîâêè!')
				end
			end
		else
			imgui.LockedButton(u8'Óäàëèòü',imgui.ImVec2(82,30))
			imgui.Hint('choosedeletebinder','Âûáåðèòå áèíä êîòîðûé õîòèòå óäàëèòü')
		end
		imgui.End()
	end
)

local imgui_lect = imgui.OnFrame(
	function() return windows.imgui_lect[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(445, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Ëåêöèè', windows.imgui_lect, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Image(medh_image,imgui.ImVec2(199,25),imgui.ImVec2(0.25,configuration.main_settings.style ~= 2 and 0.6 or 0.7),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.7 or 0.8))
		imgui.SameLine(401)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
		if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
			windows.imgui_lect[0] = false
		end
		imgui.PopStyleColor(3)
		imgui.Separator()
		if imgui.RadioButtonIntPtr(u8('×àò'), lectionsettings.lection_type, 1) then
			configuration.main_settings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(configuration,'Med Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/s'), lectionsettings.lection_type, 4) then
			configuration.main_settings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(configuration,'Med Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/r'), lectionsettings.lection_type, 2) then
			configuration.main_settings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(configuration,'Med Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/rb'), lectionsettings.lection_type, 3) then
			configuration.main_settings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(configuration,'Med Helper')
		end
		imgui.SameLine()
		imgui.SetCursorPosX(245)
		imgui.PushItemWidth(50)
		if imgui.DragInt('##lectionsettings.lection_delay', lectionsettings.lection_delay, 0.1, 1, 30, u8('%d ñ.')) then
			if lectionsettings.lection_delay[0] < 1 then lectionsettings.lection_delay[0] = 1 end
			if lectionsettings.lection_delay[0] > 30 then lectionsettings.lection_delay[0] = 30 end
			configuration.main_settings.lection_delay = lectionsettings.lection_delay[0]
			inicfg.save(configuration,'Med Helper')
			end
		imgui.Hint('lectiondelay','Çàäåðæêà ìåæäó ñîîáùåíèÿìè')
		imgui.PopItemWidth()
		imgui.SameLine()
		imgui.SetCursorPosX(307)
		if imgui.Button(u8'Ñîçäàòü íîâóþ '..fa.ICON_FA_PLUS_CIRCLE, imgui.ImVec2(112, 24)) then
			lection_number = nil
			imgui.StrCopy(lectionsettings.lection_name, '')
			imgui.StrCopy(lectionsettings.lection_text, '')
			imgui.OpenPopup(u8('Ðåäàêòîð ëåêöèé'))
		end
		imgui.SetCursorPos(imgui.ImVec2(15,100))
		if #lections.data == 0 then
			imgui.SetCursorPosY(120)
			imgui.TextColoredRGB('Ó Âàñ íåò íè îäíîé ëåêöèè.',1)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 250) * 0.5)
			if imgui.Button(u8'Âîññòàíîâèòü èçíà÷àëüíûå ëåêöèè', imgui.ImVec2(250, 25)) then
				local function copy(obj, seen)
					if type(obj) ~= 'table' then return obj end
					if seen and seen[obj] then return seen[obj] end
					local s = seen or {}
					local res = setmetatable({}, getmetatable(obj))
					s[obj] = res
					for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
					return res
				end
				lections = copy(default_lect)
				local file = io.open(getWorkingDirectory()..'\\Med Helper\\Lections.json', 'w')
				file:write(encodeJson(lections))
				file:close()
			end
		else
			for i = 1, #lections.data do
				if lections.active.bool == true then
					if lections.data[i].name == lections.active.name then
						if imgui.Button(fa.ICON_FA_PAUSE..'##'..u8(lections.data[i].name), imgui.ImVec2(280, 25)) then
							inprocess = nil
							lections.active.bool = false
							lections.active.name = nil
							lections.active.handle:terminate()
							lections.active.handle = nil
						end
					else
						imgui.LockedButton(u8(lections.data[i].name), imgui.ImVec2(280, 25))
					end
					imgui.SameLine()
					imgui.LockedButton(fa.ICON_FA_PEN..'##'..u8(lections.data[i].name), imgui.ImVec2(50, 25))
					imgui.SameLine()
					imgui.LockedButton(fa.ICON_FA_TRASH..'##'..u8(lections.data[i].name), imgui.ImVec2(50, 25))
				else
					if imgui.Button(u8(lections.data[i].name), imgui.ImVec2(280, 25)) then
						lections.active.bool = true
						lections.active.name = lections.data[i].name
						lections.active.handle = lua_thread.create(function()
							for key = 1, #lections.data[i].text do
								if lectionsettings.lection_type[0] == 2 then
									if lections.data[i].text[key]:sub(1,1) == '/' then
										sampSendChat(lections.data[i].text[key])
									else
										sampSendChat(format('/r %s', lections.data[i].text[key]))
									end
								elseif lectionsettings.lection_type[0] == 3 then
									if lections.data[i].text[key]:sub(1,1) == '/' then
										sampSendChat(lections.data[i].text[key])
									else
										sampSendChat(format('/rb %s', lections.data[i].text[key]))
									end
								elseif lectionsettings.lection_type[0] == 4 then
									if lections.data[i].text[key]:sub(1,1) == '/' then
										sampSendChat(lections.data[i].text[key])
									else
										sampSendChat(format('/s %s', lections.data[i].text[key]))
									end
								else
									sampSendChat(lections.data[i].text[key])
								end
								if key ~= #lections.data[i].text then
									wait(lectionsettings.lection_delay[0] * 1000)
								end
							end
							lections.active.bool = false
							lections.active.name = nil
							lections.active.handle = nil
						end)
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_FA_PEN..'##'..u8(lections.data[i].name), imgui.ImVec2(50, 25)) then
						lection_number = i
						imgui.StrCopy(lectionsettings.lection_name, u8(tostring(lections.data[i].name)))
						imgui.StrCopy(lectionsettings.lection_text, u8(tostring(table.concat(lections.data[i].text, '\n'))))
						imgui.OpenPopup(u8'Ðåäàêòîð ëåêöèé')
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_FA_TRASH..'##'..u8(lections.data[i].name), imgui.ImVec2(50, 25)) then
						lection_number = i
						imgui.OpenPopup('##delete')
					end
				end
			end
		end
		if imgui.BeginPopup('##delete') then
			imgui.TextColoredRGB('Âû óâåðåíû, ÷òî õîòèòå óäàëèòü ëåêöèþ \n\''..(lections.data[lection_number].name)..'\'',1)
			imgui.SetCursorPosX( (imgui.GetWindowWidth() - 100 - imgui.GetStyle().ItemSpacing.x) * 0.5 )
			if imgui.Button(u8'Äà',imgui.ImVec2(50,25)) then
				imgui.CloseCurrentPopup()
				table.remove(lections.data, lection_number)
				local file = io.open(getWorkingDirectory()..'\\Med Helper\\Lections.json', 'w')
				file:write(encodeJson(lections))
				file:close()
			end
			imgui.SameLine()
			if imgui.Button(u8'Íåò',imgui.ImVec2(50,25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
		if imgui.BeginPopupModal(u8'Ðåäàêòîð ëåêöèé', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.InputTextWithHint('##lecteditor', u8'Íàçâàíèå ëåêöèè', lectionsettings.lection_name, sizeof(lectionsettings.lection_name))
			imgui.Text(u8'Òåêñò ëåêöèè: ')
			imgui.InputTextMultiline('##lecteditortext', lectionsettings.lection_text, sizeof(lectionsettings.lection_text), imgui.ImVec2(700, 300))
			imgui.SetCursorPosX(209)
			if #str(lectionsettings.lection_name) > 0 and #str(lectionsettings.lection_text) > 0 then
				if imgui.Button(u8'Ñîõðàíèòü##lecteditor', imgui.ImVec2(150, 25)) then
					local pack = function(text, match)
						local array = {}
						for line in gmatch(text, '[^'..match..']+') do
							array[#array + 1] = line
						end
						return array
					end
					if lection_number == nil then
						lections.data[#lections.data + 1] = {
							name = u8:decode(str(lectionsettings.lection_name)),
							text = pack(u8:decode(str(lectionsettings.lection_text)), '\n')
						}
					else
						lections.data[lection_number].name = u8:decode(str(lectionsettings.lection_name))
						lections.data[lection_number].text = pack(u8:decode(str(lectionsettings.lection_text)), '\n')
					end
					local file = io.open(getWorkingDirectory()..'\\Med Helper\\Lections.json', 'w')
					file:write(encodeJson(lections))
					file:close()
					imgui.CloseCurrentPopup()
				end
			else
				imgui.LockedButton(u8'Ñîõðàíèòü##lecteditor', imgui.ImVec2(150, 25))
				imgui.Hint('notallparamslecteditor','Âû ââåëè íå âñå ïàðàìåòðû. Ïåðåïðîâåðüòå âñ¸.')
			end
			imgui.SameLine()
			if imgui.Button(u8'Îòìåíèòü##lecteditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
			imgui.Spacing()
			imgui.EndPopup()
		end
		imgui.End()
	end
)

local imgui_depart = imgui.OnFrame(
	function() return windows.imgui_depart[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 365), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'#depart', windows.imgui_depart, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Image(medh_image,imgui.ImVec2(266,25),imgui.ImVec2(0,configuration.main_settings.style ~= 2 and 0 or 0.1),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.1 or 0.2))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
		imgui.SameLine(622)
		imgui.Button(fa.ICON_FA_INFO_CIRCLE,imgui.ImVec2(23,23))
		imgui.Hint('waitwaitwait!!!','Ïîêà ÷òî ýòî îêíî ôóíêöèîíèðóåò êàê äîëæíî íå íà âñåõ ñåðâåðàõ\nÂ áóäóùèõ îáíîâëåíèÿõ áóäóò äîñòóïíû áîëåå äåòàëüíûå íàñòðîéêè')
		imgui.SameLine(645)
		if imgui.Button(fa.ICON_FA_MINUS_SQUARE,imgui.ImVec2(23,23)) then
			if #dephistory ~= 0 then
				dephistory = {}
				MedHelperMessage('Èñòîðèÿ ñîîáùåíèé óñïåøíî î÷èùåíà.')
			end
		end
		imgui.Hint('clearmessagehistory','Î÷èñòèòü èñòîðèþ ñîîáùåíèé')
		imgui.SameLine(668)
		if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
			windows.imgui_depart[0] = false
		end
		imgui.PopStyleColor(3)

		imgui.BeginChild('##depbuttons',imgui.ImVec2(180,300),true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
			imgui.PushItemWidth(150)
			imgui.TextColoredRGB('Òýã âàøåé îðãàíèçàöèè {FF2525}*',1)
			if imgui.InputTextWithHint('##myorgnamedep',u8(''),departsettings.myorgname, sizeof(departsettings.myorgname)) then
				configuration.main_settings.astag = u8:decode(str(departsettings.myorgname))
			end
			imgui.TextColoredRGB('Òýã ñ êåì ñâÿçûâàåòåñü {FF2525}*',1)
			imgui.InputTextWithHint('##toorgnamedep',u8(''),departsettings.toorgname, sizeof(departsettings.toorgname))
			imgui.Separator()
			if imgui.Button(u8'Ðàöèÿ óïàëà.',imgui.ImVec2(150,25)) then
				if #str(departsettings.myorgname) > 0 then
					sampSendChat('/d ['..u8:decode(str(departsettings.myorgname))..'] - [Âñåì]: Ðàöèÿ óïàëà.')
				else
					MedHelperMessage('Ó Âàñ ÷òî-òî íå óêàçàíî.')
				end
			end
			imgui.Hint('teh hint depart','/d ['..u8:decode(str(departsettings.myorgname))..'] - [Âñåì]: Ðàöèÿ óïàëà.')
			
			if imgui.Button(u8'Ëîæíàÿ òðåâîãà.',imgui.ImVec2(150,25)) then
				if #str(departsettings.myorgname) > 0 then
					sampSendChat('/d ['..u8:decode(str(departsettings.myorgname))..'] - [ÌÞ]: Èçâèíÿþñü çà áåñïîêîéñòâî, ëîæíàÿ òðåâîãà.')
				else
					MedHelperMessage('Ó Âàñ ÷òî-òî íå óêàçàíî.')
				end
			end
			imgui.Hint('teh hint depar','/d ['..u8:decode(str(departsettings.myorgname))..'] - [ÌÞ]: Èçâèíÿþñü çà áåñïîêîéñòâî, ëîæíàÿ òðåâîãà.')
			imgui.Separator()
			imgui.TextColoredRGB('×àñòîòà (íå Îáÿçàòåëüíî)',1)
			imgui.InputTextWithHint('##frequencydep',u8(''),departsettings.frequency, sizeof(departsettings.frequency))
			imgui.PopItemWidth()
			
		imgui.EndChild()

		imgui.SameLine()

		imgui.BeginChild('##deptext',imgui.ImVec2(480,265),true,imgui.WindowFlags.NoScrollbar)
			imgui.SetScrollY(imgui.GetScrollMaxY())
			imgui.TextColoredRGB('Èñòîðèÿ ñîîáùåíèé äåïàðòàìåíòà {808080}(?)',1)
			imgui.Hint('mytagfind depart','Åñëè â ÷àòå äåïàðòàìåíòà áóäåò òýã \''..u8:decode(str(departsettings.myorgname))..'\'\nâ ýòîò ñïèñîê äîáàâèòñÿ ýòî ñîîáùåíèå\nÐàáîòà íå ñòàáèëüíà')
			imgui.Separator()
			for k,v in pairs(dephistory) do
				imgui.TextWrapped(u8(v))
			end
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(207,323))
		imgui.PushItemWidth(368)
		imgui.InputTextWithHint('##myorgtextdep', u8'Íàïèøèòå ñîîáùåíèå', departsettings.myorgtext, sizeof(departsettings.myorgtext))
		imgui.PopItemWidth()
		imgui.SameLine()
		if imgui.Button(u8'Îòïðàâèòü',imgui.ImVec2(100,24)) then
			if #str(departsettings.myorgname) > 0 and #str(departsettings.toorgname) > 0 and #str(departsettings.myorgtext) > 0 then
				if #str(departsettings.frequency) == 0 then
					sampSendChat(format('/d [%s] - [%s] %s', u8:decode(str(departsettings.myorgname)),u8:decode(str(departsettings.toorgname)),u8:decode(str(departsettings.myorgtext))))
				else
					sampSendChat(format('/d [%s] - %s - [%s] %s', u8:decode(str(departsettings.myorgname)), gsub(u8:decode(str(departsettings.frequency)), '%.',','),u8:decode(str(departsettings.toorgname)),u8:decode(str(departsettings.myorgtext))))
				end
				imgui.StrCopy(departsettings.myorgtext, '')
			else
				MedHelperMessage('Ó Âàñ ÷òî-òî íå óêàçàíî.')
			end
		end
		imgui.End()
	end
)

local imgui_changelog = imgui.OnFrame(
	function() return windows.imgui_changelog[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(850, 600), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
		imgui.Begin(u8'##changelog', windows.imgui_changelog, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.SetCursorPos(imgui.ImVec2(15,15))
			imgui.Image(medh_image,imgui.ImVec2(238,25),imgui.ImVec2(0.10,configuration.main_settings.style ~= 2 and 0.201 or 0.3),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.3 or 0.4))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			imgui.SameLine(810)
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_changelog[0] = false
			end
			imgui.PopStyleColor(3)
			imgui.Separator()
			imgui.SetCursorPosY(49)
			imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0,0,0,0))
			imgui.BeginChild('##TEXTEXTEXT',imgui.ImVec2(-1,-1),false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(15,15))
				imgui.BeginGroup()
					for i = #changelog.versions, 1 , -1 do
						imgui.PushFont(font[25])
						imgui.Text(u8('Âåðñèÿ: '..changelog.versions[i].version..' | '..changelog.versions[i].date))
						imgui.PopFont()
						imgui.PushFont(font[16])
						for _,line in pairs(changelog.versions[i].text) do
							if find(line, '%{LINK:.*||.*%}') then
								local name, link = line:match('%{LINK:(.*)||(.*)%}')
								local symbol, lsymbol = line:find('%{.+%}')
								imgui.TextWrapped(u8(' - '..line:sub(1, symbol-1)))
								imgui.SameLine(nil, 0)
								imgui.Link(link, u8(name))
								imgui.SameLine(nil, 0)
								imgui.TextWrapped(u8(line:sub(lsymbol+1)))
							elseif find(line, '%{HINT:.*%}') then
								local text = line:match('%{HINT:(.*)%}')
								imgui.TextWrapped(u8(' - '..gsub(line, '%{HINT:.+%}', '')))
								imgui.SameLine(nil, 5)
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint(line,text)
							else
								imgui.TextWrapped(u8(' - '..line))
							end
						end
						imgui.PopFont()
						if changelog.versions[i].patches then
							imgui.Spacing()
							imgui.PushFont(font[16])
							imgui.TextColoredRGB('{25a5db}Èñïðàâëåíèÿ '..(changelog.versions[i].patches.active and '<<' or '>>'))
							imgui.PopFont()
							if imgui.IsItemHovered() and imgui.IsMouseReleased(0) then
								changelog.versions[i].patches.active = not changelog.versions[i].patches.active
							end
							if changelog.versions[i].patches.active then
								imgui.Text(u8(changelog.versions[i].patches.text))
							end
						end
						imgui.NewLine()
					end
				imgui.EndGroup()
			imgui.EndChild()
			imgui.PopStyleColor()
		imgui.End()
		imgui.PopStyleVar()
	end
)

local imgui_notify = imgui.OnFrame(
	function() return true end,
	function(player)
		player.HideCursor = true
		for k = 1, #notify.msg do
			if notify.msg[k] and notify.msg[k].active then
				local i = -1
				for d in gmatch(notify.msg[k].text, '[^\n]+') do
					i = i + 1
				end
				if notify.pos.y - i * 21 > 0 then
					if notify.msg[k].justshowed == nil then
						notify.msg[k].justshowed = clock() - 0.05
					end
					if ceil(notify.msg[k].justshowed + notify.msg[k].time - clock()) <= 0 then
						notify.msg[k].active = false
					end
					imgui.SetNextWindowPos(imgui.ImVec2(notify.pos.x, notify.pos.y - i * 21))
					imgui.SetNextWindowSize(imgui.ImVec2(250, 60 + i * 21))
					if clock() - notify.msg[k].justshowed < 0.3 then
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate((clock() - notify.msg[k].justshowed) * 3.34))
					else
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate((notify.msg[k].justshowed + notify.msg[k].time - clock()) * 3.34))
					end
					imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)
					imgui.Begin(u8('Notify ##'..k), _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)
						local style = imgui.GetStyle()
						local pos = imgui.GetCursorScreenPos()
						local DrawList = imgui.GetWindowDrawList()
						DrawList:PathClear()
	
						local num_segments = 80
						local step = 6.28 / num_segments
						local max = 6.28 * (1 - ((clock() - notify.msg[k].justshowed) / notify.msg[k].time))
						local centre = imgui.ImVec2(pos.x + 15, pos.y + 15 + style.FramePadding.y)
	
						for i = 0, max, step do
							DrawList:PathLineTo(imgui.ImVec2(centre.x + 15 * cos(i), centre.y + 15 * sin(i)))
						end
						DrawList:PathStroke(imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TitleBgActive]), false, 3)
	
						imgui.SetCursorPos(imgui.ImVec2(30 - imgui.CalcTextSize(u8(abs(ceil(notify.msg[k].time - (clock() - notify.msg[k].justshowed))))).x * 0.5, 27))
						imgui.Text(tostring(abs(ceil(notify.msg[k].time - (clock() - notify.msg[k].justshowed)))))
	
						imgui.PushFont(font[16])
						imgui.SetCursorPos(imgui.ImVec2(105, 10))
						imgui.TextColoredRGB('{MC}Med Helper')
						imgui.PopFont()

						imgui.SetCursorPosX(60)
						imgui.BeginGroup()
							imgui.TextColoredRGB(notify.msg[k].text)
						imgui.EndGroup()
					imgui.End()
					imgui.PopStyleVar(2)
					notify.pos.y = notify.pos.y - 70 - i * 21
				else
					if k == 1 then
						table.remove(notify.msg, k)
					end
				end
			else
				table.remove(notify.msg, k)
			end
		end
		local notf_sX, notf_sY = convertGameScreenCoordsToWindowScreenCoords(605, 438)
		notify.pos = {x = notf_sX - 200, y = notf_sY - 70}
	end
)

local imgui_zametka = imgui.OnFrame(
	function() return windows.imgui_zametka[0] end,
	function(player)
		if not zametki[zametka_window[0]] then return end
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(100, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8(zametki[zametka_window[0]].name..'##zametka_windoww'..zametka_window[0]), windows.imgui_zametka)
		imgui.Text(u8(zametki[zametka_window[0]].text))
		imgui.End()
	end
)

local interaction_frame = imgui.OnFrame(
	function() return checker_variables.temp_player_data ~= nil and not isPauseMenuActive() end,
	function(player)
		local data = checker_variables.temp_player_data
		
		imgui.SetNextWindowSize(imgui.ImVec2(200,300), imgui.Cond.Appearing)
		imgui.SetNextWindowPos(imgui.ImVec2( getCursorPos() ), imgui.Cond.Appearing, imgui.ImVec2(-0.2, 0.0))
		imgui.Begin(u8("##admininfo"), _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoTitleBar)
			imgui.TextColoredRGB("{909090}Äåéñòâèÿ ñ ñîòðóäíèêîì",1)

			imgui.PushFont(font[20])
			imgui.TextColoredRGB(format('%s (%s)', sub(gsub(data.nickname, "_", " "), 1, 15), data.id),1)
			imgui.PopFont()
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8("ËÊÌ - cêîïèðîâàòü íèê"))
				imgui.EndTooltip()
				if imgui.IsMouseReleased(0) then
					setClipboardText(data.nickname)
				end
			end

			imgui.PushFont(font[11])
			imgui.TextColoredRGB(format('{909090}%s%s', (data.uniform and 'Â ôîðìå' or 'Áåç ôîðìû'), (data.mute and ' * MUTED' or '')), 1)
			imgui.PopFont()
			
			imgui.Separator()

			imgui.Button(u8'Ìåñòîïîëîæåíèå', imgui.ImVec2(-1, 20))
			if imgui.IsItemClicked(1) then
				sampSendChat(string.format('/r %s, ãäå âû íàõîäèòåñü?', data.nickname:gsub('_', ' ')))
				data = nil
			elseif imgui.IsItemClicked(0) then
				sampSendChat(string.format('/rb %s, ãäå âû íàõîäèòåñü?', data.nickname:gsub('_', ' ')))
				data = nil
			end
			imgui.Hint('givemeyourpos', 'ËÊÌ - /rb | ÏÊÌ - /r')

			if configuration.main_settings.myrankint >= 9 then
				if imgui.Button(u8'Âûäàòü ìóò', imgui.ImVec2(-1, 20)) then
					local id = data.id
					local mutetime = 30
					local reason = "Ñëîìàííàÿ ðàöèÿ"
					sendchatarray(configuration.main_settings.playcd, {
						{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
						{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
						{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè %s\'', configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
						{'/me {gender:âûáðàë|âûáðàëà} íóæíîãî ñîòðóäíèêà'},
						{'/me {gender:âûáðàë|âûáðàëà} ïóíêò \'Îòêëþ÷èòü ðàöèþ ñîòðóäíèêà\''},
						{'/me {gender:íàæàë|íàæàëà} íà êíîïêó \'Ñîõðàíèòü èçìåíåíèÿ\''},
						{'/fmute %s %s %s', id, mutetime, reason},
					})
				end
				if imgui.Button(u8'+ WARN', imgui.ImVec2(78, 20)) then
					local id = data.id
					local reason = "ÍÓÌÇ"
					sendchatarray(configuration.main_settings.playcd, {
						{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
						{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
						{'/me {gender:çàø¸ë|çàøëà} â ðàçäåë \'Âûãîâîðû\''},
						{'/me íàéäÿ â ðàçäåëå íóæíîãî ñîòðóäíèêà, {gender:äîáàâèë|äîáàâèëà} â åãî ëè÷íîå äåëî âûãîâîð'},
						{'/do Âûãîâîð áûë äîáàâëåí â ëè÷íîå äåëî ñîòðóäíèêà.'},
						{'/fwarn %s %s', id, reason},
					})
				end
				imgui.SameLine()
				if imgui.Button(u8'- WARN', imgui.ImVec2(78, 20)) then
					local id = data.id
					sendchatarray(configuration.main_settings.playcd, {
						{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
						{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
						{'/me {gender:çàø¸ë|çàøëà} â ðàçäåë \'Âûãîâîðû\''},
						{'/me íàéäÿ â ðàçäåëå íóæíîãî ñîòðóäíèêà, {gender:óáðàë|óáðàëà} èç åãî ëè÷íîãî äåëà îäèí âûãîâîð'},
						{'/do Âûãîâîð áûë óáðàí èç ëè÷íîãî äåëà ñîòðóäíèêà.'},
						{'/unfwarn %s', id},
					})
				end
				if imgui.Button(u8'Óâîëèòü', imgui.ImVec2(-1, 20)) then
					local uvalid = data.id
					local reason = "ÍÓÌÇ"
					sendchatarray(configuration.main_settings.playcd, {
						{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
						{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óâîëüíåíèå\''},
						{'/do Ðàçäåë îòêðûò.'},
						{'/me {gender:âí¸ñ|âíåñëà} ÷åëîâåêà â ðàçäåë \'Óâîëüíåíèå\''},
						{'/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ, çàòåì {gender:âûêëþ÷èë|âûêëþ÷èëà} ïëàíøåò è {gender:ïîëîæèë|ïîëîæèëà} åãî îáðàòíî â êàðìàí'},
						{'/uninvite %s %s', uvalid, reason},
					})
				end
			else
				imgui.LockedButton(u8'Âûäàòü ìóò', imgui.ImVec2(-1, 20))
				imgui.LockedButton(u8'+ WARN', imgui.ImVec2(78, 20))
				imgui.SameLine()
				imgui.LockedButton(u8'- WARN', imgui.ImVec2(78, 20))
				imgui.LockedButton(u8'Óâîëèòü', imgui.ImVec2(-1, 20))
			end

			imgui.Separator()
			imgui.TextColoredRGB("{909090}Çàìåòêà",1)
			imgui.PushItemWidth(170)
			if imgui.InputText('##specialnoteforadmin', checker_variables.note_input, sizeof(checker_variables.note_input)) then
				configuration.Checker_Notes[data.nickname] = #str(checker_variables.note_input) > 0 and u8:decode(str(checker_variables.note_input)) or nil
				inicfg.save(configuration,'Med Helper')
			end
			imgui.PopItemWidth()
			if imgui.Button(u8"Çàêðûòü",imgui.ImVec2(170,25)) then
				checker_variables.temp_player_data = nil
			end
		imgui.End()
	end
)

function updatechatcommands()
	for key, value in pairs(configuration.BindsName) do
		sampUnregisterChatCommand(configuration.BindsCmd[key])
		if configuration.BindsCmd[key] ~= '' and configuration.BindsType[key] == 0 then
			sampRegisterChatCommand(configuration.BindsCmd[key], function()
				if not inprocess then
					local temp = 0
					local temp2 = 0
					for bp in gmatch(tostring(configuration.BindsAction[key]), '[^~]+') do
						temp = temp + 1
					end
					inprocess = lua_thread.create(function()
						for bp in gmatch(tostring(configuration.BindsAction[key]), '[^~]+') do
							temp2 = temp2 + 1
							if not find(bp, '%{delay_(%d+)%}') then
								sampSendChat(tostring(bp))
								if temp2 ~= temp then
									wait(configuration.BindsDelay[key])
								end
							else
								local delay = bp:match('%{delay_(%d+)%}')
								wait(delay)
							end
						end
						wait(0)
						inprocess = nil
					end)
				else
					MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
				end
			end)
		end
	end
	for k, v in pairs(zametki) do
		sampUnregisterChatCommand(v.cmd)
		sampRegisterChatCommand(v.cmd, function()
			windows.imgui_zametka[0] = true
			zametka_window[0] = k
		end)
	end
end

function sampev.onPlayerStreamIn(playerId)
	if configuration.main_settings.bodyrank then
		for i, member in ipairs(checker_variables.online) do
			if member.nickname == sampGetPlayerNickname(playerId) then
				sampCreate3dTextEx(i, string.format('%s [%s]', configuration.RankNames[member.rank], member.rank), 0XA0FFFFFF, 0, 0, -0.5, 10, false, playerId, -1)
				checker_variables.bodyranks[#checker_variables.bodyranks + 1] = { player = playerId, text = i }
				break
			end
		end
	end
end

function sampev.onPlayerStreamOut(playerId)
	for i, v in ipairs(checker_variables.bodyranks) do
		if v.player == playerId then
			sampDestroy3dText(v.text)
		end
	end
end

function sampev.onCreatePickup(id, model, pickupType, position)
	if model == 19132 and getCharActiveInterior(playerPed) == 240 then
		return {id, 1272, pickupType, position}
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if dialogId == 6 and givelic then
		local d = {
			['Ëå÷åíèå'] = 0,
			['ìîòî'] = 1,
			['ðûáîëîâñòâî'] = 3,
			['ïëàâàíèå'] = 4,
			['îðóæèå'] = 5,
			['îõîòó'] = 6,
			['ðàñêîïêè'] = 7,
			['òàêñè'] = 8,
		}
		sampSendDialogResponse(6, 1, d[lictype], nil)
		lua_thread.create(function()
			wait(1000)
			if givelic then
				sampSendChat(format('/givelicense %s',sellto))
			end
		end)
		return false

	elseif dialogId == 235 and getmyrank then
		if find(text, 'Áîëüíèöà') then
			for DialogLine in gmatch(text, '[^\r\n]+') do
				local nameRankStats, getStatsRank = DialogLine:match('Äîëæíîñòü: {B83434}(.+)%p(%d+)%p')
				if tonumber(getStatsRank) then
					local rangint = tonumber(getStatsRank)
					local rang = nameRankStats
					if rangint ~= configuration.main_settings.myrankint then
						MedHelperMessage(format('Âàø ðàíã áûë îáíîâë¸í íà %s (%s)',rang,rangint))
					end
					if configuration.RankNames[rangint] ~= rang then
						MedHelperMessage(format('Íàçâàíèå {MC}%s{WC} ðàíãà èçìåíåíî ñ {MC}%s{WC} íà {MC}%s{WC}', rangint, configuration.RankNames[rangint], rang))
					end
					configuration.RankNames[rangint] = rang
					configuration.main_settings.myrankint = rangint
					inicfg.save(configuration,'Med Helper')
				end
			end
		else
			print('{FF0000}Èãðîê íå ðàáîòàåò â áîëüíèöå. Ñêðèïò áûë âûãðóæåí.')
			MedHelperMessage('Âû íå ðàáîòàåòå â áîëüíèöå, ñêðèïò âûãðóæåí! Åñëè ýòî îøèáêà, òî îáðàòèòåñü ê {MC}vk.com/evil.duckky{WC}.')
			NoErrors = true
			thisScript():unload()
		end
		sampSendDialogResponse(235, 0, 0, nil)
		getmyrank = false
		return false

	elseif dialogId == 1234 then
		if find(text, 'Ñðîê äåéñòâèÿ') then
			if configuration.sobes_settings.medcard and sobes_results and not sobes_results.medcard then
				if not find(text, 'Èìÿ: '..sampGetPlayerNickname(fastmenuID)) then
					return {dialogId, style, title, button1, button2, text}
				end
				if not find(text, 'Ïîëíîñòüþ çäîðîâûé') then
					sobes_results.medcard = ('íå ïîëíîñòüþ çäîðîâûé')
					return {dialogId, style, title, button1, button2, text}
				end
				for DialogLine in gmatch(text, '[^\r\n]+') do
					local statusint = DialogLine:match('{CEAD2A}Íàðêîçàâèñèìîñòü: (%d+)')
					if tonumber(statusint) and tonumber(statusint) > 5 then
						sobes_results.medcard = ('íàðêîçàâèñèìîñòü')
						return {dialogId, style, title, button1, button2, text}
					end
				end
				sobes_results.medcard = ('â ïîðÿäêå')
			end
		elseif find(text, 'Ñåðèÿ') then
			if configuration.med_settings.pass and med_results and not med_results.pass then
				if not find(text, 'Èìÿ: {FFD700}'..sampGetPlayerNickname(fastmenuID)) then
					return {dialogId, style, title, button1, button2, text}
				end
				for DialogLine in gmatch(text, '[^\r\n]+') do
					local passstatusint = DialogLine:match('{FFFFFF}Ëåò â øòàòå: {FFD700}(%d+)')
					if tonumber(passstatusint) and tonumber(passstatusint) < 5 then
						med_results.pass = ('ìåíüøå 4 ëåò â øòàòå')
						return {dialogId, style, title, button1, button2, text}
					end
				end
				med_results.pass = ('â ïîðÿäêå')
			end
			if configuration.sobes_settings.pass and sobes_results and not sobes_results.pass then
				if not find(text, 'Èìÿ: {FFD700}'..sampGetPlayerNickname(fastmenuID)) then
					return {dialogId, style, title, button1, button2, text}
				end
				if find(text, '{FFFFFF}Îðãàíèçàöèÿ:') then
					sobes_results.pass = ('èãðîê â îðãàíèçàöèè')
					return {dialogId, style, title, button1, button2, text}
				end
				for DialogLine in gmatch(text, '[^\r\n]+') do
					local passstatusint = DialogLine:match('{FFFFFF}Ëåò â øòàòå: {FFD700}(%d+)')
					if tonumber(passstatusint) and tonumber(passstatusint) < 3 then
						sobes_results.pass = ('ìåíüøå 3 ëåò â øòàòå')
						return {dialogId, style, title, button1, button2, text}
					end
				end
				for DialogLine in gmatch(text, '[^\r\n]+') do
					local zakonstatusint = DialogLine:match('{FFFFFF}Çàêîíîïîñëóøíîñòü: {FFD700}(%d+)')
					if tonumber(zakonstatusint) and tonumber(zakonstatusint) < 35 then
						sobes_results.pass = ('íå çàêîíîïîñëóøíûé')
						return {dialogId, style, title, button1, button2, text}
					end
				end
				if find(text, 'Ëå÷èëñÿ â Ïñèõèàòðè÷åñêîé áîëüíèöå') then
					sobes_results.pass = ('áûë â äåìîðãàíå')
					return {dialogId, style, title, button1, button2, text}
				end
				if find(text, 'Ñîñòîèò â ×Ñ{FF6200} Áîëüíèöû') then
					sobes_results.pass = ('â ÷ñ áîëüíèöû')
					return {dialogId, style, title, button1, button2, text}
				end
				if find(text, 'Warns') then
					sobes_results.pass = ('åñòü âàðíû')
					return {dialogId, style, title, button1, button2, text}
				end
				sobes_results.pass = ('â ïîðÿäêå')
			end
		elseif find(title, 'Ëèöåíçèè') then
			if configuration.sobes_settings.licenses and sobes_results and not sobes_results.licenses then
				for DialogLine in gmatch(text, '[^\r\n]+') do
					if find(DialogLine, 'Ëèöåíçèÿ íà àâòî') then
						if find(DialogLine, 'Íåò') then
							sobes_results.licenses = ('íåò íà àâòî')
							return {dialogId, style, title, button1, button2, text}
						end
					end
					if find(DialogLine, 'Ëèöåíçèÿ íà ìîòî') then
						if find(DialogLine, 'Íåò') then
							sobes_results.licenses = ('íåò íà ìîòî')
							return {dialogId, style, title, button1, button2, text}
						end
					end
				end
				sobes_results.licenses = ('â ïîðÿäêå')
				return {dialogId, style, title, button1, button2, text}
			end
		end
	elseif dialogId == 0 then
		if find(title, 'Òðóäîâàÿ êíèæêà '..sampGetPlayerNickname(fastmenuID)) then
			sobes_results.wbook = ('ïðèñóòñòâóåò')
		end
	end

	if dialogId == 2015 then 
		for line in gmatch(text, '[^\r\n]+') do
			local name, rank = line:match('^{%x+}[A-z0-9_]+%([0-9]+%)\t(.+)%(([0-9]+)%)\t%d+ %(%d+')
			if name and rank then
				name, rank = tostring(name), tonumber(rank)
				if configuration.RankNames[rank] ~= nil and configuration.RankNames[rank] ~= name then
					MedHelperMessage(format('Íàçâàíèå {MC}%s{WC} ðàíãà èçìåíåíî ñ {MC}%s{WC} íà {MC}%s{WC}', rank, configuration.RankNames[rank], name))
					configuration.RankNames[rank] = name
					inicfg.save(configuration,'Med Helper')
				end
			end
		end
	end

	if dialogId == 2015 and checker_variables.await.members then 
		local count = 0
		checker_variables.await.next_page.bool = false
		checker_variables.online.online = title:match('{FFFFFF}.+%(Â ñåòè: (%d+)%)')
		for line in text:gmatch('[^\r\n]+') do
    		count = count + 1
    		if not line:find('Íèê') and not line:find('ñòðàíèöà') then
    			local color = string.match(line, "^{(%x+)}")
	    		local nick, id, rank_name, rank_id, warns, afk = string.match(line, '([A-z_0-9]+)%((%d+)%)\t(.+)%((%d+)%)\t(%d+) %((%d+)')
	    		local mute = string.find(line, '| MUTED')
	    		local near = select(1, sampGetCharHandleBySampPlayerId(tonumber(id)))
	    		local uniform = (color == 'FFFFFF')
				--print(nick,rank)
	    		checker_variables.online[#checker_variables.online + 1] = { 
					nickname = tostring(nick),
					id = id,
					rank = tonumber(rank_id),
					afk = tonumber(afk),
					warns = tonumber(warns),
					mute = mute,
					near = near,
					uniform = uniform
				}
			end

    		if line:match('Ñëåäóþùàÿ ñòðàíèöà') then
    			checker_variables.await.next_page.bool = true
    			checker_variables.await.next_page.i = count - 2
    		end
    	end

    	if checker_variables.await.next_page.bool then
    		sampSendDialogResponse(dialogId, 1, checker_variables.await.next_page.i, _)
    		checker_variables.await.next_page.bool = false
    		checker_variables.await.next_page.i = 0
    	else
			while #checker_variables.online > tonumber(checker_variables.online.online) do 
    			table.remove(checker_variables.online, 1) 
    		end
    		sampSendDialogResponse(dialogId, 0, _, _)
    		checker_variables.await.members = false
    	end
		return false
	elseif checker_variables.await.members and dialogId ~= 2015 then
		checker_variables.dontShowMeMembers = true
		checker_variables.await.members = false
		checker_variables.await.next_page.bool = false
    	checker_variables.await.next_page.i = 0
    	while #checker_variables.online > tonumber(checker_variables.online.online) do 
			table.remove(checker_variables.online, 1) 
		end
	elseif checker_variables.dontShowMeMembers and dialogId == 2015 then
		checker_variables.dontShowMeMembers = false
		lua_thread.create(function()
			wait(0)
			sampSendDialogResponse(dialogId, 0, nil, nil)
		end)
		return false
	end
end

function sampev.onServerMessage(color, message)
	if configuration.main_settings.replacechat then
		if find(message, 'Èñïîëüçóéòå: /jobprogress %[ ID èãðîêà %]') then
			MedHelperMessage('Âû ïðîñìîòðåëè ñâîþ ðàáî÷óþ óñïåâàåìîñòü.')
			return false
		end
		if find(message, sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' ïåðåîäåâàåòñÿ â ãðàæäàíñêóþ îäåæäó') then
			addNotify('Âû çàêîí÷èëè ðàáî÷èé äåíü,\nïðèÿòíîãî îòäûõà!', 5)
			return false
		end
		if find(message, sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' ïåðåîäåâàåòñÿ â ðàáî÷óþ îäåæäó') then
			addNotify('Âû íà÷àëè ðàáî÷èé äåíü,\nóäà÷íîé ðàáîòû!', 5)
			return false
		end
	end
	if find(message, '%[R%]') and color == 766526463 then
		if configuration.main_settings.chatrank then
			local nick = message:match('^%[R%].*%s([A-z0-9_]+)%[%d+%]:')
			if nick ~= nil then
				for i, member in ipairs(checker_variables.online) do
					if member.nickname == tostring(nick) then
						message = message:gsub('^%[R%]', '['.. member.rank ..']')
						break
					end
				end
			end
		end

		local color = imgui.ColorConvertU32ToFloat4(configuration.main_settings.RChatColor)
		local r,g,b,a = color.x*255, color.y*255, color.z*255, color.w*255
		return { join_argb(r, g, b, a), message}
	end
	if find(message, '%[D%]') and color == 865730559 or color == 865665023 then
		if find(message, u8:decode(departsettings.myorgname[0])) then
			local tmsg = gsub(message, '%[D%] ','')
			dephistory[#dephistory + 1] = tmsg
		end
		local color = imgui.ColorConvertU32ToFloat4(configuration.main_settings.DChatColor)
		local r,g,b,a = color.x*255, color.y*255, color.z*255, color.w*255
		return { join_argb(r, g, b, a), message }
	end
end

function sampev.onSendChat(message)
	if find(message, '{my_id}') then
		sampSendChat(gsub(message, '{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
		return false
	end
	if find(message, '{my_name}') then
		sampSendChat(gsub(message, '{my_name}', (configuration.main_settings.useservername and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
		return false
	end
	if find(message, '{my_rank}') then
		sampSendChat(gsub(message, '{my_rank}', configuration.RankNames[configuration.main_settings.myrankint]))
		return false
	end
	if find(message, '{my_score}') then
		sampSendChat(gsub(message, '{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
		return false
	end
	if find(message, '{H}') then
		sampSendChat(gsub(message, '{H}', os.date('%H', os.time())))
		return false
	end
	if find(message, '{HM}') then
		sampSendChat(gsub(message, '{HM}', os.date('%H:%M', os.time())))
		return false
	end
	if find(message, '{HMS}') then
		sampSendChat(gsub(message, '{HMS}', os.date('%H:%M:%S', os.time())))
		return false
	end
	if find(message, '{close_id}') then
		if select(1,getClosestPlayerId()) then
			sampSendChat(gsub(message, '{close_id}', select(2,getClosestPlayerId())))
			return false
		end
		MedHelperMessage('Â çîíå ñòðèìà íå íàéäåíî íè îäíîãî èãðîêà.')
		return false
	end
	if find(message, '@{%d+}') then
		local id = message:match('@{(%d+)}')
		if id and IsPlayerConnected(id) then
			sampSendChat(gsub(message, '@{%d+}', sampGetPlayerNickname(id)))
			return false
		end
		MedHelperMessage('Òàêîãî èãðîêà íåò íà ñåðâåðå.')
		return false
	end
	if find(message, '{gender:(%A+)|(%A+)}') then
		local male, female = message:match('{gender:(%A+)|(%A+)}')
		if configuration.main_settings.gender == 0 then
			local gendermsg = gsub(message, '{gender:%A+|%A+}', male, 1)
			sampSendChat(tostring(gendermsg))
			return false
		else
			local gendermsg = gsub(message, '{gender:%A+|%A+}', female, 1)
			sampSendChat(tostring(gendermsg))
			return false
		end
	end
	if find(message, '{location:(%A+)|(%A+)|(%A+)|(%A+)}') then
		local LS, SF, LV, JF = message:match('{location:(%A+)|(%A+)|(%A+)|(%A+)}')
		if configuration.main_settings.location == 0 then
			local locationmsg = gsub(message, '{location:%A+|%A+|%A+|%A+}', LS, 1)
			sampSendChat(tostring(locationmsg))
			return false
		elseif configuration.main_settings.location == 1 then
			local locationmsg = gsub(message, '{location:%A+|%A+|%A+|%A+}', SF, 1)
			sampSendChat(tostring(locationmsg))
			return false
		elseif configuration.main_settings.location == 2 then
			local locationmsg = gsub(message, '{location:%A+|%A+|%A+|%A+}', LV, 1)
			sampSendChat(tostring(locationmsg))
			return false
		else
			local locationmsg = gsub(message, '{location:%A+|%A+|%A+|%A+}', JF, 1)
			sampSendChat(tostring(locationmsg))
			return false
		end
	end

	if #configuration.main_settings.myaccent > 1 then
		if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == 'q' or message == ';)' then
			return{message}
		end
		if find(string.rlower(u8:decode(configuration.main_settings.myaccent)), 'àêöåíò') then
			return{format('[%s]: %s', u8:decode(configuration.main_settings.myaccent),message)}
		else
			return{format('[%s àêöåíò]: %s', u8:decode(configuration.main_settings.myaccent),message)}
		end
	end
end

function sampev.onSendCommand(cmd)
	if find(cmd, '{my_id}') then
		sampSendChat(gsub(cmd, '{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
		return false
	end
	if find(cmd, '{my_name}') then
		sampSendChat(gsub(cmd, '{my_name}', (configuration.main_settings.useservername and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
		return false
	end
	if find(cmd, '{my_rank}') then
		sampSendChat(gsub(cmd, '{my_rank}', configuration.RankNames[configuration.main_settings.myrankint]))
		return false
	end
	if find(cmd, '{my_score}') then
		sampSendChat(gsub(cmd, '{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
		return false
	end
	if find(cmd, '{H}') then
		sampSendChat(gsub(cmd, '{H}', os.date('%H', os.time())))
		return false
	end
	if find(cmd, '{HM}') then
		sampSendChat(gsub(cmd, '{HM}', os.date('%H:%M', os.time())))
		return false
	end
	if find(cmd, '{HMS}') then
		sampSendChat(gsub(cmd, '{HMS}', os.date('%H:%M:%S', os.time())))
		return false
	end
	if find(cmd, '{close_id}') then
		if select(1,getClosestPlayerId()) then
			sampSendChat(gsub(cmd, '{close_id}', select(2,getClosestPlayerId())))
			return false
		end
		MedHelperMessage('Â çîíå ñòðèìà íå íàéäåíî íè îäíîãî èãðîêà.')
		return false
	end
	if find(cmd, '@{%d+}') then
		local id = cmd:match('@{(%d+)}')
		if id and IsPlayerConnected(id) then
			sampSendChat(gsub(cmd, '@{%d+}', sampGetPlayerNickname(id)))
			return false
		end
		MedHelperMessage('Òàêîãî èãðîêà íåò íà ñåðâåðå.')
		return false
	end
	if find(cmd, '{gender:(%A+)|(%A+)}') then
		local male, female = cmd:match('{gender:(%A+)|(%A+)}')
		if configuration.main_settings.gender == 0 then
			local gendermsg = gsub(cmd, '{gender:%A+|%A+}', male, 1)
			sampSendChat(tostring(gendermsg))
			return false
		else
			local gendermsg = gsub(cmd, '{gender:%A+|%A+}', female, 1)
			sampSendChat(tostring(gendermsg))
			return false
		end
	end
	if find(cmd, '{location:(%A+)|(%A+)|(%A+)|(%A+)}') then
		local LS, SF, LV, JF = cmd:match('{location:(%A+)|(%A+)|(%A+)|(%A+)}')
		if configuration.main_settings.location == 0 then
			local locationmsg = gsub(cmd, '{location:%A+|%A+|%A+|%A+}', LS, 1)
			sampSendChat(tostring(locationmsg))
			return false
		elseif configuration.main_settings.location == 1 then
			local locationmsg = gsub(cmd, '{location:%A+|%A+|%A+|%A+}', SF, 1)
			sampSendChat(tostring(locationmsg))
			return false
		elseif configuration.main_settings.location == 2 then
			local locationmsg = gsub(cmd, '{location:%A+|%A+|%A+|%A+}', LV, 1)
			sampSendChat(tostring(locationmsg))
			return false
		else
			local locationmsg = gsub(cmd, '{location:%A+|%A+|%A+|%A+}', JF, 1)
			sampSendChat(tostring(locationmsg))
			return false
		end
	end
	if configuration.main_settings.fmtype == 1 then
		com = #cmd > #configuration.main_settings.usefastmenucmd+1 and sub(cmd, 2, #configuration.main_settings.usefastmenucmd+2) or sub(cmd, 2, #configuration.main_settings.usefastmenucmd+1)..' '
		if com == configuration.main_settings.usefastmenucmd..' ' then
			if windows.imgui_fm[0] == false then
				if find(cmd, '/'..configuration.main_settings.usefastmenucmd..' %d+') then
					local param = cmd:match('.+ (%d+)')
					if sampIsPlayerConnected(param) then
						if doesCharExist(select(2,sampGetCharHandleBySampPlayerId(param))) then
							fastmenuID = param
							MedHelperMessage(format('Âû èñïîëüçîâàëè ìåíþ áûñòðîãî äîñòóïà íà: %s [%s]',gsub(sampGetPlayerNickname(fastmenuID), '_', ' '),fastmenuID))
							MedHelperMessage('Çàæìèòå {MC}ALT{WC} äëÿ òîãî, ÷òîáû ñêðûòü êóðñîð. {MC}ESC{WC} äëÿ òîãî, ÷òîáû çàêðûòü ìåíþ.')
							windows.imgui_fm[0] = true
						else
							MedHelperMessage('Èãðîê íå íàõîäèòñÿ ðÿäîì ñ âàìè')
						end
					else
						MedHelperMessage('Èãðîê íå â ñåòè')
					end
				else
					MedHelperMessage('/'..configuration.main_settings.usefastmenucmd..' [id]')
				end
			end
			return false
		end
	end
end

function IsPlayerConnected(id)
	return (sampIsPlayerConnected(tonumber(id)) or select(2, sampGetPlayerIdByCharHandle(playerPed)) == tonumber(id))
end

function checkServer(ip)
	local servers = {
		['185.169.134.3'] = 'Phoenix',
		['185.169.134.4'] = 'Tucson',
		['185.169.134.43'] = 'Scottdale',
		['185.169.134.44'] = 'Chandler',
		['185.169.134.45'] = 'Brainburg',
		['185.169.134.5'] = 'Saint Rose',
		['185.169.134.59'] = 'Mesa',
		['185.169.134.61'] = 'Red-Rock',
		['185.169.134.107'] = 'Yuma',
		['185.169.134.109'] = 'Surprise',
		['185.169.134.166'] = 'Prescott',
		['185.169.134.171'] = 'Glendale',
		['185.169.134.172'] = 'Kingman',
		['185.169.134.173'] = 'Winslow',
		['185.169.134.174'] = 'Payson',
		['80.66.82.191'] = 'Gilbert',
		['80.66.82.190'] = 'Show Low',
		['80.66.82.188'] = 'Casa-Grande',
		['80.66.82.168'] = 'Page',
	}
	return servers[ip] or false
end

function MedHelperMessage(text)
	local col = imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor)
	local r,g,b,a = col.x*255, col.y*255, col.z*255, col.w*255
	text = gsub(text, '{WC}', '{EBEBEB}')
	text = gsub(text, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))
	sampAddChatMessage(format('[MedHelper]{EBEBEB} %s', text),join_argb(a, r, g, b)) -- ff33f2 default
end

function onWindowMessage(msg, wparam, lparam)
	if wparam == 0x1B and not isPauseMenuActive() then
		if windows.imgui_settings[0] or windows.imgui_fm[0] or windows.imgui_binder[0] or windows.imgui_lect[0] or windows.imgui_depart[0] or windows.imgui_changelog[0] then
			consumeWindowMessage(true, false)
			if(msg == 0x101)then
				windows.imgui_settings[0] = false
				windows.imgui_fm[0] = false
				windows.imgui_binder[0] = false
				windows.imgui_lect[0] = false
				windows.imgui_depart[0] = false
				windows.imgui_changelog[0] = false
			end
		end
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		if not sampIsDialogActive() then
			showCursor(false, false)
		end
		if marker ~= nil then
			removeBlip(marker)
		end

		if NoErrors then
			return false
		end

		local file = getWorkingDirectory()..'\\moonloader.log'

		local moonlog = ''
		local tags = {['%(info%)'] = 'A9EFF5', ['%(debug%)'] = 'AFA9F5', ['%(error%)'] = 'FF7070', ['%(warn%)'] = 'F5C28E', ['%(system%)'] = 'FA9746', ['%(fatal%)'] = '040404', ['%(exception%)'] = 'F5A9A9', ['%(script%)'] = '7DD156',}
		local i = 0
		local lasti = 0

		local function ftable(line)
			for key, value in pairs(tags) do
				if find(line, key) then return true end
			end
			return false
		end

		for line in io.lines(file) do
			local sameline = not ftable(line) and i-1 == lasti
			if find(line, 'Loaded successfully.') and find(line, thisScript().name) then moonlog = '' sameline = false end
			if find(line, thisScript().name) or sameline then
				for k,v in pairs(tags) do
					if find(line, k) then
						line = sub(line, 19, #line)
						line = gsub(line, '	', ' ')
						line = gsub(line, k, '{'..v..'}'..k..'{FFFFFF}')
					end
				end
				line = gsub(line, thisScript().name..':', thisScript().name..':{C0C0C0}')
				line = line..'{C0C0C0}'
				moonlog = moonlog..line..'\n'
				lasti = i
			end
			i = i + 1
		end

		sampShowDialog(536472, '{FF33F2}[Med Helper]{ffffff} Ñêðèïò áûë âûãðóæåí ñàì ïî ñåáå.', [[
{f51111}Åñëè Âû ñàìîñòîÿòåëüíî ïåðåçàãðóçèëè ñêðèïò, òî ìîæåòå çàêðûòü ýòî äèàëîãîâîå îêíî.
Â èíîì ñëó÷àå, äëÿ íà÷àëà ïîïûòàéòåñü âîññòàíîâèòü ðàáîòó ñêðèïòà ñî÷åòàíèåì êëàâèø CTRL + R.
Åñëè æå ýòî íå ïîìîãëî, òî ñëåäóéòå äàëüíåéøèì èíñòðóêöèÿì.{FF33F2}
1. Âîçìîæíî ó Âàñ óñòàíîâëåíû êîíôëèêòóþùèå LUA ôàéëû è õåëïåðû, ïîïûòàéòåñü óäàëèòü èõ.
2. Âîçìîæíî Âû íå äîóñòàíîâèëè íåêîòîðûå íóæíûå áèáëèîòåêè, à èìåííî:
 - SAMPFUNCS 5.5.1
 - CLEO 4.1+
 - MoonLoader 0.26
3. Åñëè äàííîé îøèáêè íå áûëî ðàíåå, ïîïûòàéòåñü ñäåëàòü ñëåäóþùèå äåéñòâèÿ:
- Â ïàïêå moonloader > config > Óäàëÿåì ôàéë Med Helper.ini
- Â ïàïêå moonloader > Óäàëÿåì ïàïêó Med Helper
4. Åñëè íè÷åãî èç âûøåïåðå÷èñëåííîãî íå èñïðàâèëî îøèáêó, òî ñëåäóåò óñòàíîâèòü ñêðèïò íà äðóãóþ ñáîðêó.
5. Åñëè äàæå ýòî íå ïîìîãëî Âàì, òî îòïðàâüòå àâòîðó {2594CC}(vk.com/evil.duckky){FF33F2} ñêðèíøîò îøèáêè.{FFFFFF}

{C0C0C0}]]..moonlog, 'ÎÊ', nil, 0)
	end
end

function getClosestPlayerId()
	local temp = {}
	local tPeds = getAllChars()
	local me = {getCharCoordinates(playerPed)}
	for i = 1, #tPeds do 
		local result, id = sampGetPlayerIdByCharHandle(tPeds[i])
		if tPeds[i] ~= playerPed and result then
			local pl = {getCharCoordinates(tPeds[i])}
			local dist = getDistanceBetweenCoords3d(me[1], me[2], me[3], pl[1], pl[2], pl[3])
			temp[#temp + 1] = { dist, id }
		end
	end
	if #temp > 0 then
		table.sort(temp, function(a, b) return a[1] < b[1] end)
		return true, temp[1][2]
	end
	return false
end

function sendchatarray(delay, text, start_function, end_function)
	start_function = start_function or function() end
	end_function = end_function or function() end
	if inprocess ~= nil then
		MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
		return false
	end
	inprocess = lua_thread.create(function()
		start_function()
		for i = 1, #text do
			sampSendChat(format(text[i][1], unpack(text[i], 2)))
			if i ~= #text then
				wait(delay)
			end
		end
		end_function()
		wait(0)
		inprocess = nil
	end)
	return true
end

function createJsons()
	createDirectory(getWorkingDirectory()..'\\Med Helper')
	createDirectory(getWorkingDirectory()..'\\Med Helper\\Rules')
	if not doesFileExist(getWorkingDirectory()..'\\Med Helper\\Lections.json') then
		lections = default_lect
		local file = io.open(getWorkingDirectory()..'\\Med Helper\\Lections.json', 'w')
		file:write(encodeJson(lections))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\Med Helper\\Lections.json', 'r')
		lections = decodeJson(file:read('*a'))
		file:close()
	end
	if not doesFileExist(getWorkingDirectory()..'\\Med Helper\\Questions.json') then
		questions = {
			active = { redact = false },
			questions = {}
		}
		local file = io.open(getWorkingDirectory()..'\\Med Helper\\Questions.json', 'w')
		file:write(encodeJson(questions))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\Med Helper\\Questions.json', 'r')
		questions = decodeJson(file:read('*a'))
		questions.active.redact = false
		file:close()
	end
	if not doesFileExist(getWorkingDirectory()..'\\Med Helper\\Zametki.json') then
		zametki = {}
		local file = io.open(getWorkingDirectory()..'\\Med Helper\\Zametki.json', 'w')
		file:write(encodeJson(zametki))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\Med Helper\\Zametki.json', 'r')
		zametki = decodeJson(file:read('*a'))
		file:close()
	end
	return true
end


function checkUpdates(json_url, show_notify)
	show_notify = show_notify or false
	local function getTimeAfter(unix)
		local function plural(n, forms) 
			n = abs(n) % 100
			if n % 10 == 1 and n ~= 11 then
				return forms[1]
			elseif 2 <= n % 10 and n % 10 <= 4 and (n < 10 or n >= 20) then
				return forms[2]
			end
			return forms[3]
		end
		
		local interval = os.time() - unix
		if interval < 86400 then
			return 'ñåãîäíÿ'
		elseif interval < 604800 then
			local days = floor(interval / 86400)
			local text = plural(days, {'äåíü', 'äíÿ', 'äíåé'})
			return ('%s %s íàçàä'):format(days, text)
		elseif interval < 2592000 then
			local weeks = floor(interval / 604800)
			local text = plural(weeks, {'íåäåëÿ', 'íåäåëè', 'íåäåëü'})
			return ('%s %s íàçàä'):format(weeks, text)
		elseif interval < 31536000 then
			local months = floor(interval / 2592000)
			local text = plural(months, {'ìåñÿö', 'ìåñÿöà', 'ìåñÿöåâ'})
			return ('%s %s íàçàä'):format(months, text)
		else
			local years = floor(interval / 31536000)
			local text = plural(years, {'ãîä', 'ãîäà', 'ëåò'})
			return ('%s %s íàçàä'):format(years, text)
		end
	end
	
	local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'

	if doesFileExist(json) then
		os.remove(json)
	end

	downloadUrlToFile(json_url, json, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
				local f = io.open(json, 'r')
				if f then
					local info = decodeJson(f:read('*a'))
					local updateversion = (configuration.main_settings.getbetaupd and info.beta_upd) and info.beta_version or info.version
					f:close()
					os.remove(json)
					if updateversion > thisScript().version then
						addNotify('Îáíàðóæåíî îáíîâëåíèå íà\nâåðñèþ {MC}'..updateversion..'{WC}. Ïîäðîáíîñòè:\n{MC}/mhmupd', 5)
					else
						if show_notify then
							addNotify('Îáíîâëåíèé íå îáíàðóæåíî!', 5)
						end
					end
					if configuration.main_settings.getbetaupd and info.beta_upd then
						updateinfo = {
							file = info.beta_file,
							version = updateversion,
							change_log = info.beta_changelog,
						}
					else
						updateinfo = {
							file = info.file,
							version = updateversion,
							change_log = info.change_log,
						}
					end

					updateinfo.updatelastcheck = getTimeAfter(os.time({day = os.date('%d'), month = os.date('%m'), year = os.date('%Y')}))..' â '..os.date('%X')
					inicfg.save(configuration, 'Med Helper.ini')
				end
			end
		end
	end
	)
end

function ImSaturate(f)
	return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
end

function renderFontDrawClickableText(active, font, text, posX, posY, color, color_hovered)
	local cursorX, cursorY = getCursorPos()
	local lenght = renderGetFontDrawTextLength(font, text)
	local height = renderGetFontDrawHeight(font)
	local hovered = false
	local result = false
	if active and cursorX > posX and cursorY > posY and cursorX < posX + lenght and cursorY < posY + height then
		hovered = true
		if isKeyJustPressed(0x01) then
			result = true 
		end
	end	
	local anim = floor(sin(clock() * 10) * 3 + 5)
	renderFontDrawText(font, text, posX, posY - (hovered and anim or 0), hovered and color_hovered or color)
	return result
end
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(1000) end

	createJsons()

	getmyrank = true
	sampSendChat('/stats')
	print('{00FF00}Óñïåøíàÿ çàãðóçêà')
	addNotify(format('Óñïåøíàÿ çàãðóçêà ñêðèïòà,\nâåðñèÿ {MC}%s{WC}.\nÍàñòðîèòü ñêðèïò: {MC}/mhm', thisScript().version), 10)

	if configuration.main_settings.changelog then
		windows.imgui_changelog[0] = true
		configuration.main_settings.changelog = false
		inicfg.save(configuration, 'Med Helper.ini')
	end
	
	sampRegisterChatCommand('mhm', function()
		windows.imgui_settings[0] = not windows.imgui_settings[0]
		alpha[0] = clock()
	end)
	sampRegisterChatCommand('mhmbind', function()
		choosedslot = nil
		windows.imgui_binder[0] = not windows.imgui_binder[0]
	end)
	sampRegisterChatCommand('mhmlect', function()
		if configuration.main_settings.myrankint < 3 then
			return addNotify('Äàííàÿ ôóíêöèÿ äîñòóïíà ñ 3-ãî\nðàíãà.', 3)
		end
		windows.imgui_lect[0] = not windows.imgui_lect[0]
	end)
	sampRegisterChatCommand('mhmdep', function()
		if configuration.main_settings.myrankint < 5 then
			return addNotify('Äàííàÿ ôóíêöèÿ äîñòóïíà ñ 5-ãî\nðàíãà.', 5)
		end
		windows.imgui_depart[0] = not windows.imgui_depart[0]
	end)
	sampRegisterChatCommand('mhmupd', function()
		windows.imgui_settings[0] = true
		mainwindow[0] = 3
		infowindow[0] = 1
		alpha[0] = clock()
	end)

	sampRegisterChatCommand('uninvite', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/uninvite %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local uvalid = param:match('(%d+)')
		local reason = select(2, param:match('(%d+) (.+),')) or select(2, param:match('(%d+) (.+)'))
		local withbl = select(2, param:match('(.+), (.+)'))
		if uvalid == nil or reason == nil then
			return MedHelperMessage('/uninvite [id] [ïðè÷èíà], [ïðè÷èíà ÷ñ] (íå îáÿçàòåëüíî)')
		end
		if tonumber(uvalid) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return MedHelperMessage('Âû íå ìîæåòå óâîëüíÿòü èç îðãàíèçàöèè ñàìîãî ñåáÿ.')
		end
		if withbl then
			return sendchatarray(configuration.main_settings.playcd, {
				{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
				{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óâîëüíåíèå\''},
				{'/do Ðàçäåë îòêðûò.'},
				{'/me {gender:âí¸ñ|âíåñëà} ÷åëîâåêà â ðàçäåë \'Óâîëüíåíèå\''},
				{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'×¸ðíûé ñïèñîê\''},
				{'/me {gender:çàí¸ñ|çàíåñëà} ñîòðóäíèêà â ðàçäåë, ïîñëå ÷åãî {gender:ïîäòâåðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
				{'/do Èçìåíåíèÿ áûëè ñîõðàíåíû.'},
				{'/uninvite %s %s', uvalid, reason},
				{'/blacklist %s %s', uvalid, withbl},
			})
		else
			return sendchatarray(configuration.main_settings.playcd, {
				{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
				{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óâîëüíåíèå\''},
				{'/do Ðàçäåë îòêðûò.'},
				{'/me {gender:âí¸ñ|âíåñëà} ÷åëîâåêà â ðàçäåë \'Óâîëüíåíèå\''},
				{'/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ, çàòåì {gender:âûêëþ÷èë|âûêëþ÷èëà} ïëàíøåò è {gender:ïîëîæèë|ïîëîæèëà} åãî îáðàòíî â êàðìàí'},
				{'/uninvite %s %s', uvalid, reason},
			})
		end
	end)

	sampRegisterChatCommand('invite', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/invite %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return MedHelperMessage('/invite [id]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return MedHelperMessage('Âû íå ìîæåòå ïðèãëàøàòü â îðãàíèçàöèþ ñàìîãî ñåáÿ.')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/do Êëþ÷è îò øêàô÷èêà â êàðìàíå.'},
			{'/me âñóíóâ ðóêó â êàðìàí áðþê, {gender:äîñòàë|äîñòàëà} îòòóäà êëþ÷ îò øêàô÷èêà'},
			{'/me {gender:ïåðåäàë|ïåðåäàëà} êëþ÷ ÷åëîâåêó íàïðîòèâ'},
			{'Äîáðî ïîæàëîâàòü! Ïåðåîäåòüñÿ âû ìîæåòå â ðàçäåâàëêå.'},
			{'Ñî âñåé èíôîðìàöèåé Âû ìîæåòå îçíàêîìèòüñÿ íà îô. ïîðòàëå.'},
			{'/invite %s', id},
		})
	end)

	sampRegisterChatCommand('giverank', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/giverank %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local id,rank = param:match('(%d+) (%d)')
		if id == nil or rank == nil then
			return MedHelperMessage('/giverank [id] [ðàíã]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return MedHelperMessage('Âû íå ìîæåòå ìåíÿòü ðàíã ñàìîìó ñåáå.')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
			{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
			{'/me {gender:âûáðàë|âûáðàëà} â ðàçäåëå íóæíîãî ñîòðóäíèêà'},
			{'/me {gender:èçìåíèë|èçìåíèëà} èíôîðìàöèþ î äîëæíîñòè ñîòðóäíèêà, ïîñëå ÷åãî {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
			{'/do Èíôîðìàöèÿ î ñîòðóäíèêå áûëà èçìåíåíà.'},
			{'Ïîçäðàâëÿþ ñ ïîâûøåíèåì. Íîâûé áåéäæèê Âû ìîæåòå âçÿòü â ðàçäåâàëêå.'},
			{'/giverank %s %s', id, rank},
		})
	end)

	sampRegisterChatCommand('blacklist', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/blacklist %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return MedHelperMessage('/blacklist [id] [ïðè÷èíà]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return MedHelperMessage('Âû íå ìîæåòå âíåñòè â ×Ñ ñàìîãî ñåáÿ.')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
			{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'×¸ðíûé ñïèñîê\''},
			{'/me {gender:ââ¸ë|ââåëà} èìÿ íàðóøèòåëÿ'},
			{'/me {gender:âí¸ñ|âíåñëà} íàðóøèòåëÿ â ðàçäåë \'×¸ðíûé ñïèñîê\''},
			{'/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
			{'/do Èçìåíåíèÿ áûëè ñîõðàíåíû.'},
			{'/blacklist %s %s', id, reason},
		})
	end)

	sampRegisterChatCommand('unblacklist', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/unblacklist %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return MedHelperMessage('/unblacklist [id]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
			{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'×¸ðíûé ñïèñîê\''},
			{'/me {gender:ââ¸ë|ââåëà} èìÿ ãðàæäàíèíà â ïîèñê'},
			{'/me {gender:óáðàë|óáðàëà} ãðàæäàíèíà èç ðàçäåëà \'×¸ðíûé ñïèñîê\''},
			{'/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ'},
			{'/do Èçìåíåíèÿ áûëè ñîõðàíåíû.'},
			{'/unblacklist %s', id},
		})
	end)

	sampRegisterChatCommand('fwarn', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/fwarn %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return MedHelperMessage('/fwarn [id] [ïðè÷èíà]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
			{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
			{'/me {gender:çàø¸ë|çàøëà} â ðàçäåë \'Âûãîâîðû\''},
			{'/me íàéäÿ â ðàçäåëå íóæíîãî ñîòðóäíèêà, {gender:äîáàâèë|äîáàâèëà} â åãî ëè÷íîå äåëî âûãîâîð'},
			{'/do Âûãîâîð áûë äîáàâëåí â ëè÷íîå äåëî ñîòðóäíèêà.'},
			{'/fwarn %s %s', id, reason},
		})
	end)

	sampRegisterChatCommand('unfwarn', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/unfwarn %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return MedHelperMessage('/unfwarn [id]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
			{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè\''},
			{'/me {gender:çàø¸ë|çàøëà} â ðàçäåë \'Âûãîâîðû\''},
			{'/me íàéäÿ â ðàçäåëå íóæíîãî ñîòðóäíèêà, {gender:óáðàë|óáðàëà} èç åãî ëè÷íîãî äåëà îäèí âûãîâîð'},
			{'/do Âûãîâîð áûë óáðàí èç ëè÷íîãî äåëà ñîòðóäíèêà.'},
			{'/unfwarn %s', id},
		})
	end)
	
	sampRegisterChatCommand('fmute', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/fmute %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local id,mutetime,reason = param:match('(%d+) (%d+) (.+)')
		if id == nil or reason == nil or mutetime == nil then
			return MedHelperMessage('/fmute [id] [âðåìÿ] [ïðè÷èíà]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
			{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
			{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè %s\'', configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
			{'/me {gender:âûáðàë|âûáðàëà} íóæíîãî ñîòðóäíèêà'},
			{'/me {gender:âûáðàë|âûáðàëà} ïóíêò \'Îòêëþ÷èòü ðàöèþ ñîòðóäíèêà\''},
			{'/me {gender:íàæàë|íàæàëà} íà êíîïêó \'Ñîõðàíèòü èçìåíåíèÿ\''},
			{'/fmute %s %s %s', id, mutetime, reason},
		})
	end)

	sampRegisterChatCommand('funmute', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/funmute %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return MedHelperMessage('/funmute [id]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:äîñòàë|äîñòàëà} ïëàíøåò èç êàðìàíà'},
			{'/me {gender:âêëþ÷èë|âêëþ÷èëà} ïëàíøåò'},
			{'/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë \'Óïðàâëåíèå ñîòðóäíèêàìè %s\'', configuration.main_settings.replaceash and '{location:ËÑÌÖ|ÑÔÌÖ|ËÂÌÖ|ÄÔÌÖ}' or '{location:Áîëüíèöû Ëîñ-Ñàíòîñ|Áîëüíèöû Ñàí-Ôèåððî|Áîëüíèöû Ëàñ-Âåíòóðàñ|Áîëüíèöû Ääåôôåðñîí}'},
			{'/me {gender:âûáðàë|âûáðàëà} íóæíîãî ñîòðóäíèêà'},
			{'/me {gender:âûáðàë|âûáðàëà} ïóíêò \'Âêëþ÷èòü ðàöèþ ñîòðóäíèêà\''},
			{'/me {gender:íàæàë|íàæàëà} íà êíîïêó \'Ñîõðàíèòü èçìåíåíèÿ\''},
			{'/funmute %s', id},
		})
	end)

	sampRegisterChatCommand('expel', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/expel %s',param))
		end
		if configuration.main_settings.myrankint < 2 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 2-ãî ðàíãà.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return MedHelperMessage('/expel [id] [ïðè÷èíà]')
		end
		if sampIsPlayerPaused(id) then
			return MedHelperMessage('Èãðîê íàõîäèòñÿ â ÀÔÊ!')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:ñõâàòèë|ñõâàòèëà} ÷åëîâåêà çà ðóêó è {gender:ïîâåë|ïîâåëà} ê âûõîäó'},
			{'/me îòêðûâ äâåðü ðóêîé, {gender:âûâåë|âûâåëà} ÷åëîâåêà íà óëèöó'},
			{'/expel %s %s',id,reason},
		})
	end)

	sampRegisterChatCommand('heal', function(param)
		if sampIsPlayerPaused(id) then
			return MedHelperMessage('Èãðîê íàõîäèòñÿ â ÀÔÊ!')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me íûðíóâ ïðàâîé ðóêîé â êàðìàí, {gender:âûòÿíóë|âûòÿíóëà} îòòóäà áëîêíîò è ðó÷êó'},
			{'/todo Òàê-òàê, õîðîøî, íå âîëíóéòåñü*çàïèñàâ âñå ñêàçàííîå ÷åëîâåêîì íàïðîòèâ'},
			{'/me äâèæåíèåì ïðàâîé ðóêè {gender:îòêðûë|îòêðûëà} ìåä.êåéñ'},
			{'/me íåñêîëüêèìè äâèæåíèÿìè ðóê {gender:íàøåë|íàøëà} íóæíîå ëåêàðñòâî â ìåä.÷åìîäàíå'},
			{'/do Ëåêàðñòâî â ïðàâîé ðóêå.'},
			{'/me àêêóðàòíûì äâèæåíèåì ðóêè {gender:ïåðåäàë|ïåðåäàëà} ëåêàðñòâî ïàöèåíòó'},
			{'Ïðèíèìàéòå ýòè òàáëåòêè, è ÷åðåç íåêîòîðîå âðåìÿ âàì ñòàíåò ëó÷øå.'},
			{'/heal %s %s',param,configuration.main_settings.heal},
		})
	end)

	sampRegisterChatCommand('cure', function(param)
		if sampIsPlayerPaused(id) then
			return MedHelperMessage('Èãðîê íàõîäèòñÿ â ÀÔÊ!')
		end
		if configuration.main_settings.myrankint < 5 then
			return MedHelperMessage('Äàííàÿ êîìàíäà äîñòóïíà ñ 5-ãî ðàíãà.')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/todo ×òî-òî åìó âîîáùå íå õîðîøî*ñíèìàÿ ìåäèöèíñêóþ ñóìêó ñ ïëå÷à'},
			{'/me ñòàâèò ìåäèöèíñêóþ ñóìêó âîçëå ïîñòðàäàâøåãî'},
			{'/do Ìåä. ñóìêà íà çåìëå.'},
			{'/me íàêëîíÿåòñÿ íàä òåëîì, çàòåì ïðîùóïûâàåò ïóëüñ íà ñîííîé àðòåðèè'},
			{'/do Ïóëüñ ñëàáûé.'},
			{'/me íà÷èíàåò íåïðÿìîé ìàññàæ ñåðäöà, âðåìÿ îò âðåìåíè ïðîâåðÿÿ ïóëüñ'},
			{'/do Ñåðäöå ïàöèåíòà íà÷àëî áèòüñÿ.'},
			{'/cure %s',param},
		})
	end)

	updatechatcommands()

	lua_thread.create(function()
		local function sampIsLocalPlayerSpawned()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
		while not sampIsLocalPlayerSpawned() do wait(1000) end
		if sampIsLocalPlayerSpawned() then
			wait(10000)
			getmyrank = true
			sampSendChat('/stats')
		end
	end)

	while true do
		if getCharPlayerIsTargeting() then
			if configuration.main_settings.fmtype == 0 then
				if configuration.main_settings.createmarker then
					local targettingped = select(2,getCharPlayerIsTargeting())
					if sampGetPlayerIdByCharHandle(targettingped) then
						if marker ~= nil and oldtargettingped ~= targettingped then
							removeBlip(marker)
							marker = nil
							marker = addBlipForChar(targettingped)
						elseif marker == nil and oldtargettingped ~= targettingped then
							marker = addBlipForChar(targettingped)
						end
					end
					oldtargettingped = targettingped
				end
				if isKeysDown(configuration.main_settings.usefastmenu) and not sampIsChatInputActive() then
					if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
						setVirtualKeyDown(0x02,false)
						fastmenuID = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())))
						MedHelperMessage(format('Âû èñïîëüçîâàëè ìåíþ áûñòðîãî äîñòóïà íà: %s [%s]',gsub(sampGetPlayerNickname(fastmenuID), '_', ' '),fastmenuID))
						MedHelperMessage('Çàæìèòå {MC}ALT{WC} äëÿ òîãî, ÷òîáû ñêðûòü êóðñîð. {MC}ESC{WC} äëÿ òîãî, ÷òîáû çàêðûòü ìåíþ.')
						wait(0)
						windows.imgui_fm[0] = true
					end
				end
			end

			if isKeysDown(configuration.main_settings.fastexpel) and not sampIsChatInputActive() and configuration.main_settings.dofastexpel then
				if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
					if configuration.main_settings.myrankint > 2 then
						local id, reason = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting()))), configuration.main_settings.expelreason
						if #reason > 0 then
							if not sampIsPlayerPaused(id) then
								sendchatarray(configuration.main_settings.playcd, {
									{'/me {gender:ñõâàòèë|ñõâàòèëà} ÷åëîâåêà çà ðóêó è {gender:ïîâåë|ïîâåëà} ê âûõîäó'},
									{'/me îòêðûâ äâåðü ðóêîé, {gender:âûâåë|âûâåëà} ÷åëîâåêà íà óëèöó'},
									{'/expel %s %s',id,reason},
								})
							else
								MedHelperMessage('Èãðîê íàõîäèòñÿ â ÀÔÊ!')
							end
						else
							MedHelperMessage('/expel [id] [ïðè÷èíà]')
						end
					else
						MedHelperMessage('Äàííîå äåéñòâèå äîñòóïíî ñ 2-ãî ðàíãà.')
					end
				end
			end
		end

		if isKeysDown(configuration.main_settings.fastscreen) and configuration.main_settings.dofastscreen and (clock() - tHotKeyData.lasted > 0.1) and not sampIsChatInputActive() then
			sampSendChat('/time')
			wait(500)
			setVirtualKeyDown(0x77, true)
			wait(0)
			setVirtualKeyDown(0x77, false)
		end

		if inprocess and isKeyDown(0x22)then
			inprocess:terminate()
			inprocess = nil
			MedHelperMessage('Îòûãðîâêà óñïåøíî ïðåðâàíà!')
		end
		
		if isKeyDown(0x11) and isKeyJustPressed(0x52) then
			NoErrors = true
			print('{FFFF00}Ñêðèïò áûë ïåðåçàãðóæåí êîìáèíàöèåé êëàâèø Ctrl + R')
		end

		if configuration.main_settings.playdubinka then
			local weapon = getCurrentCharWeapon(playerPed)
			if weapon == 3 and not rp_check then 
				sampSendChat('/me ñíÿâ äóáèíêó ñ ïîÿñà {gender:âçÿë|âçÿëà} â ïðàâóþ ðóêó')
				rp_check = true
			elseif weapon ~= 3 and rp_check then
				sampSendChat('/me {gender:ïîâåñèë|ïîâåñèëà} äóáèíêó íà ïîÿñ')
				rp_check = false
			end
		end

		for key = 1, #configuration.BindsName do
			if isKeysDown(configuration.BindsKeys[key]) and not sampIsChatInputActive() and configuration.BindsType[key] == 1 then
				if not inprocess then
					local temp = 0
					local temp2 = 0
					for _ in gmatch(tostring(configuration.BindsAction[key]), '[^~]+') do
						temp = temp + 1
					end

					inprocess = lua_thread.create(function()
						for bp in gmatch(tostring(configuration.BindsAction[key]), '[^~]+') do
							temp2 = temp2 + 1
							if not find(bp, '%{delay_(%d+)%}') then
								sampSendChat(tostring(bp))
								if temp2 ~= temp then
									wait(configuration.BindsDelay[key])
								end
							else
								local delay = bp:match('%{delay_(%d+)%}')
								wait(delay)
							end
						end
						wait(0)
						inprocess = nil
					end)
				else
					MedHelperMessage('Íå òîðîïèòåñü, Âû óæå îòûãðûâàåòå ÷òî-òî! Ïðåðâàòü îòûãðîâêó: {MC}page down{WC}')
				end
			end
		end

		for k = 1, #zametki do
			if isKeysDown(zametki[k].button) and not sampIsChatInputActive() then
				windows.imgui_zametka[0] = true
				zametka_window[0] = k
			end
		end

		if sampIsDialogActive() then
			checker_variables.lastDialogWasActive = clock()
		end

		if configuration.Checker.state then
			local ch = checker_variables
			local cfgch = configuration.Checker
	
			local offset = cfgch.font_offset
	
			local col_title = changeColorAlpha(cfgch.col_title, cfgch.font_alpha)
			local col_default = changeColorAlpha(cfgch.col_default, cfgch.font_alpha)
			local col_no_work = changeColorAlpha(cfgch.col_no_work, cfgch.font_alpha)
	
			if renderFontDrawClickableText(true, ch.font, 'Ñîòðóäíèêè îíëàéí ['..(ch.online.online or 0)..' | AFK: '..(ch.online.afk or 0)..']', cfgch.posX, cfgch.posY, col_title, 0x90FFFFFF) then
				if not checker_variables.await.members then
					sampSendChat('/members')
					checker_variables.await.members = true
					checker_variables.dontShowMeMembers = false
				end
			end
			--õóåòà
			for k, member in ipairs(ch.online) do
				local render_color = cfgch.show_uniform and (member.uniform and col_default or col_no_work) or col_default
	
				local rank = cfgch.show_rank and '['..member.rank..'] ' or ''
				local nick = member.nickname
				local id = cfgch.show_id and '('..member.id..')' or ''
				local afk = cfgch.show_afk and getAfk(member.rank, member.afk, render_color) or ''
				local warns = cfgch.show_warn and ' - Warns: '..member.warns or ''
				local mute = cfgch.show_mute and member.mute and ' || Muted' or ''
				local near = cfgch.show_near and (member.near and ' [N]' or '') or ''
				local note = configuration.Checker_Notes[nick] and getNote(configuration.Checker_Notes[nick], render_color) or ''
	
				local render_text = format('%s%s%s%s%s%s%s%s', rank, nick, id, afk, warns, mute, near, note)
	
				if renderFontDrawClickableText(true, ch.font, render_text, cfgch.posX, cfgch.posY + k * offset, render_color, render_color) then
					imgui.StrCopy(ch.note_input, u8(configuration.Checker_Notes[nick] or ''))
					checker_variables.temp_player_data = member
				end
			end
		end

		if configuration.main_settings.autoupdate and clock() - autoupd[0] > 600 then
			checkUpdates('https://raw.githubusercontent.com/EvilDukky/MedHelper/main/Update/update.json')
			autoupd[0] = clock()
		end

		if clock() - checker_variables.last_check >= configuration.Checker.delay and clock() - checker_variables.lastDialogWasActive > 2 then
			sampSendChat('/members')
			checker_variables.await.members = true
			checker_variables.dontShowMeMembers = false
			checker_variables.last_check = clock()
		end

		if configuration.main_settings.autodoor and getActiveInterior() ~= 0 then
            if opengate_timer == nil or (os.clock() - opengate_timer) >= 0.5 then
                local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
                for id = 0, 2047 do
                    if sampIs3dTextDefined(id) then
                        local text, _, x, y, z, _, _, _, _ = sampGet3dTextInfoById(id)
                        if string.match(text, "Îòêðûòü") then
                            if getDistanceBetweenCoords2d(pX, pY, x, y) <= 1 then
                                sampSendChat("/opengate")
                                opengate_timer = os.clock()
                            end
                        end
                    end
                end
            end
        end
		wait(0)
	end
end

changelog = {
	versions = {
		{
			version = '1.0',
			date = '08.02.2023',
			text = {
				'Ðåëèç (Çà îñíîâó áûë âçÿò AS Helper - JustMini)',
				'×åêåð ñîòðóäíèêîâ íà ýêðàíå ({LINK:èäåÿ Cosmo||https://www.blast.hk/threads/59761/})'},
		},

		{
			version = '1.1',
			date = '06.02.2023',
			text = {
				'Ìåíþ ïñèõîëîãè÷åñêîãî îñìîòðà',
				'Èñïðàâëåíèå ðàáîòû ÷åêåðà ñîòðóäíèêîâ. Ñïàñèáî çà ïîìîùü: Mart',
			},
			patches = {
				active = false,
				text = [[
 - Äîðàáîòêè ïðîöåññà âûäà÷è ìåä.êàðòû]]
			},
		},
		
		{
			version = '1.2',
			date = '20.09.2023',
			text = {
				'Ìåíþ ìåä.îñìîòðà',
				'Áûñòðîå ëå÷åíèå ÷åðåç êîìàíäó /heal',
				'Áûñòðàÿ ðåàíèìàöèÿ ÷åðåç êîìàíäó /cure',
			},
			patches = {
				active = false,
				text = [[
 - Óáðàíà ñèñòåìà âàêöèíàöèè îò êîðîíàâèðóñà]]
			},
		},
		
	},
}

default_lect = {
	active = { bool = false, name = nil, handle = nil },
	data = {
		{
			name = 'Îáùåíèå ñ ãðàæäàíàìè',
			text = {
				'Äîáðîãî âðåìåíè ñóòîê.',
				'Ñåãîäíÿ ÿ ðàññêàæó âàì î ïðàâèëàõ îáùåíèÿ ñ ãðàæäàíàìè.',
				'Âàì âñåì èçâåñòåí ïóíêò Óñòàâà.',
				'Êîòîðûé ãëàñèò:',
				'Çàïðåùåíî íåöåíçóðíî âûðàæàòüñÿ, îñêîðáëÿòü...',
				'Óãðîæàòü, ïðèìåíÿòü íàñèëèå ïî îòíîøåíèþ ê êîìó-ëèáî.',
				'Òàê âîò, õî÷ó âàì ðàññêàçàòü, ÷òîáû âû âñåãäà ñîáëþäàëè ýòî ïðàâèëî!',
				'Çà íå ñîáëþäåíèå ýòîãî ïðàâèëà, âû ìîæåòå áûòü óâîëåíû èëè ïîëó÷èòü âûãîâîð.',
				'Íèêîãäà íå õàìèòå, íå îñêîðáëÿéòå è íå ìàòåðèòåñü!',
				'Çà íàðóøåíèå äàííîãî ïðàâèëà âû ìîæåòå áûòü ïîíèæåíû â äîëæíîñòè.',
				'Ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Ñóáîðäèíàöèÿ â Áîëüíèöå',
			text = {
				'Äîáðîãî âðåìåíè ñóòîê óâ. êîëëåãè.',
				'Ñåãîäíÿ ÿ ðàññêàæó âàì î ñóáîðäèíàöèè ïî îòíîøåíèþ ê êîëëåãàì.',
				'Âû îáÿçàíû ñîáëþäàòü ñóáîðäèíàöèþ ê ñòàðøèì âàñ ïî äîëæíîñòè.',
				'Çà íå ñîáëþäåíèå ýòîãî ïðàâèëà, âû ìîæåòå áûòü óâîëåíû èëè ïîëó÷èòü âûãîâîð.',
				'Âñåãäà ñîáëþäàéòå ýòî!',
				'Åñëè âàø äðóã çàíèìàåò êàêóþ-ëèáî âûñîêóþ äîëæíîñòü, âû òàê æå îáÿçàíû ñîáëþäàòü ñóáîðäèíàöèþ.',
				'Îáðàùàòüñÿ íà "Âû", íèêàêîãî "Êàê òû?", "Çäîðîâà" è ïðî÷åãî.',
				'Íàäåþñü âû ìåíÿ ïîíÿëè.',
				'Ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Ïðàâèëà ñíà',
			text = {
				'Äîáðîãî âðåìåíè ñóòîê.',
				'Ñåãîäíÿ ÿ ðàññêàæó âàì î ïðàâèëàõ ñíà.',
				'Ñîòðóäíèêè äóìàþò ÷òî ìîæíî ñïàòü, ãäå óãîäíî.',
				'Ýòî íå òàê! Ñïàòü ìîæíî òîëüêî â Ðàçäåâàëêå.',
				'Çà íå ñîáëþäåíèå äàííîãî ïðàâèëà âû ìîæåòå ïîëó÷èòü âûãîâîð, à òî è ïîíèæåíèå â äîëæíîñòè.',
				'Ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Ïðàâèëà ïîêèäàíèÿ Áîëüíèöû â ðàá. âðåìÿ',
			text = {
				'Äîáðîãî âðåìåíè ñóòîê.',
				'Ñåãîäíÿ ÿ ðàññêàæó âàì êàê ïðàâèëüíî ïîêèäàòü Áîëüíèöó â Ðàáî÷åå âðåìÿ.',
				'Äëÿ òîãî ÷òîáû óåõàòü èç Áîëüíèöû, âû îáÿçàíû ñïðîñèòü ðàçðåøåíèå!',
				'Äëÿ ýòîãî âû áåðåòå ðàöèþ, è ñïðàøèâàåòå ìîæíî ëè ïîêèíóòü Áîëüíèöó ïî òîé èëè èíîé ïðè÷èíå.',
				'Ïðèìåð: Ðàçðåøèòå ïîêèíóòü áîëüíèöó. Ïðè÷èíà: *âàøà ïðè÷èíà*.',
				'Ïîñëå òîãî êàê âàì ðàçðåøèë, âû îáÿçàíû ñíÿòü ôîðìó!',
				'Ïîñëå êàê âåðíóëèñü â áîëüíèöó Âû äîêëàäûâàåòå â ðàöèþ, íàäåâàåòå ôîðìó.',
				'Åñëè Âû íå ïðåäóïðåäèëè Âàñ ìîãóò îáúÿâèòü âûãîâîð èëè óâîëèòü çà Ïðîãóë ðàáî÷åãî äíÿ.',
				'Ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Ðàáî÷èé ãðàôèê',
			text = {
				'Äîáðîãî âðåìåíè ñóòîê',
				'Ñåãîäíÿ ÿ ðàññêàæó ðàáî÷èé ãðàôèê íàøåé Áîëüíèöû.',
				'Êîòîðûé îáÿçàí ñîáëþäàòü êàæäûé ñîòðóäíèê Áîëüíèöû.',
				'Ñ ïîíåäåëüíèêà ïî âîñêðåñåíüå ñ 10:00 äî 21:00.',
				'Ïåðåðûâ â ëþáîé ðàáî÷èé äåíü ñ 13:00 äî 14:00.',
				'Íî÷íàÿ ñìåíà äëèòñÿ ñ 21:00 äî 10:00.',
				'Çà íàðóøåíèÿ ðàáî÷åãî ãðàôèêà âû ìîæåòå áûòü óâîëåíû èëè ïîëó÷èòü âûãîâîð.'
			}
		},
		{
			name = 'Ïåðâàÿ ïîìîùü ïðè ÄÒÏ',
			text = {
				'Çäðàâñòâóéòå, ÿ ïðî÷òó Âàì ëåêöèþ íà òåìó "Ïåðâàÿ ïîìîùü ïðè ÄÒÏ".',
				'Îêàçûâàÿ ïåðâóþ ïîìîùü, íåîáõîäèìî äåéñòâîâàòü ïî ïðàâèëàì.',
				'Íåìåäëåííî îïðåäåëèòü õàðàêòåð è èñòî÷íèê òðàâìû.',
				'Íàèáîëåå ÷àñòûå òðàâìû â ñëó÷àå ÄÒÏ - ñî÷åòàíèå ïîâðåæäåíèé ÷åðåïà..',
				'è íèæíèõ êîíå÷íîñòåé è ãðóäíîé êëåòêè.',
				'Íåîáõîäèìî èçâëå÷ü ïîñòðàäàâøåãî èç àâòîìîáèëÿ, îñìîòðåòü åãî.',
				'Äàëåå ñëåäóåò îêàçàòü ïåðâóþ ïîìîùü...',
				'â ñîîòâåòñòâèè ñ âûÿâëåííûìè òðàâìàìè.',
				'È ïåðåíåñòè ïîñòðàäàâøåãî â áåçîïàñíîå ìåñòî,..',
				'óêðûòü îò õîëîäà,çíîÿ èëè äîæäÿ è âûçâàòü âðà÷à.',
				'Îðãàíèçîâàòü òðàíñïîðòèðîâêó ïîñòðàäàâøåãî â ëå÷åáíîå ó÷ðåæäåíèå.',
				'Âñåì ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Êóðåíèå',
			text = {
				'Ñåé÷àñ ÿ ïðî÷òó âàì ëåêöèþ î âðåäå êóðåíèÿ.',
				'Ðîäèòåëè íàì âñåãäà ãîâîðèëè: "Êóðèòü âðåäíî è íåêðàñèâî"!',
				'Äà, îíè áåçóñëîâíî áûëè ïðàâû, íî ê ñîæàëåíèþ...',
				'ïî ñòàòèñòèêå, áîëüøàÿ ÷àñòü êóðèëüùèêîâ, íà÷àëè êóðèòü â ïîäðàñòêîâîì âîçðàñòå;',
				'êóðåíèå íàíîñèò î÷åíü ñèëüíûé âðåä îðãàíèçìó; êóðèëüùèê, êîòîðûé êóðèò åæåäíåâíî,',
				'óâåëè÷èâàåò ñâîé øàíñ çàáîëåòü ðàêîì ë¸ãêèõ íà 40ïðîöåíòîâ;',
				'ñòðàäàåò è íåðâíàÿ ñèñòåìà êóðèëüùèêà, êëåòêè ìîçãà;',
				'Åæåäíåâíî îðãàíèçì ïîëó÷àåò ÿä, â âèäå äûìà.',
				'Áðîñèòü êóðèòü î÷åíü ëåãêî - â ïåðâóþ î÷åðåäü íóæíî èçáàâèòüñÿ îò ïñèõîëîãè÷åñêîé çàâèñèìîñòè.',
				'Â ýòîì âàì ïîìîãóò íàøè âðà÷è, áðîñèòü êóðèòü ñàìîñòîÿòåëüíî, ó ñîñòîÿâøåãîñÿ êóðèëüùèêà...',
				'- ïî÷òè íåâîçìîæíî.',
				'Ïîñëå 12-òè ÷àñîâ îòêàçà îò êóðåíèÿ ñåðäöåáèåíèå ïðèõîäèò â íîðìó;',
				'Ïîñëå 24 ÷àñîâ îòêàçà îò ñèãàðåòû, ë¸ãêèå óñïîêàèâàþòñÿ, ñîêðàùåíèå ïðèõîäèò â íîðìó;',
				'ïîñëå íåäåëè áåç ñèãàðåòû - âàøà êîæà ñòàíîâèòñÿ ÷èùå, ñâåòëåå;',
				'×åðåç ãîä îðãàíèçì ïîëíîñòüþ âûâîäèò òîêñèíû è âðåäíûå âåùåñòâà,',
				'Ó âàñ ïîÿâëÿåòñÿ áîëüøå ýíåðãèè, ìîçã ðàáîòàåò ëó÷øå, æèçíü ñòàíîâèòñÿ êðàøå.',
				'Åñëè âû õîòèòå áðîñèòü êóðèòü - îáðàùàéòåñü ê ñïåöèàëèñòó, íå ïûòàéòåñü ñäåëàòü ýòî ñàìîñòîÿòåëüíî.',
				'Ñ÷àñòëèâîé è äîëãîé âàì æèçíè áåç ñèãàðåò, ó÷èòå ñâîèõ äåòåé òîëüêî õîðîøåìó!',
				'Âñåì ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Íàðêîòè÷åñêèå âåùñòâà',
			text = {
				'Çäðàâñòâóéòå, ñåãîäíÿ ìû ïîãîâîðèì î íàðêîòèêàõ è ïîñëåäñòâèÿõ.',
				'Âñå ìû, åù¸ ñî øêîëüíîé ñêàìüè, ñëûøàëè ïðî âðåä íàðêîòèêîâ.',
				'Íî íåêîòîðûå, íå çàäóìûâàÿñü î áóäóùåì, ïîñ÷èòàëè, ÷òî ýòî êëàññíî.',
				'Êîíå÷íî, âñå ìû âèäåëè, èëè ñëûøàëè, ïðî ñóäüáû òåõ, êòî óïîòðåáëÿë íàðêîòèêè.',
				'Ýòî âñ¸ î÷åíü ïå÷àëüíî, íî åñòü ëþäè, êîòîðûå ïðîäîëæàþò åæåäíåâíî ïðîáîâàòü íàðêîòèêè.',
				'Ïðè ïåðâîì óïîòðåáëåíèè ó ÷åëîâåêà ñðàçó æå ïîÿâëÿåòñÿ çàâèñèìîñòü,',
				'ïîýòîìó ïðîñòî ïîïðîáîâàòü íå ïîëó÷èòñÿ, âû âñ¸ ðàâíî çàõîòèòå åù¸.',
				'Ïðè óïîòðåáëåíèè íàðêîòèêîâ, ìîçã ÷åëîâåêà ïîëó÷àåò íåâåðîÿòíûé âûáðîñ ãàðìîíà ñ÷àñòüÿ.',
				'Ïîýòîìó ìîçã ñäåëàåò âñ¸, ÷òîáû èñïûòàòü ýòó ýéôîðèþ åù¸ ðàç,',
				'Ïîäóìàéòå î ñâî¸ì áóäóùåì, ïðåæäå, ÷åì ñîãëàøàòüñÿ íà ýòî.',
				'Óæå ÷åðåç ãîä óïîòðåáëåíèÿ íàðêîòèêîâ, îðãàíèçì ïîðàæåí íà 90 ïðîöåíòîâ.',
				'Íà÷èíàþòñÿ ëîìêè, êîòîðûå íàïîìèíàþò ìóêè, ñãîðåâøèõ çàæèâî,',
				'äðîæü â ðóêàõ, è ïîñòîÿííûå ìûñëè òîëüêî îá îäíîì - ìíå íóæíà äîçà.',
				'Åæåãîäíî óìèðàåò îêîëî 50-òè òûñÿ÷ ïîäðîñòêîâ, îò ïåðåäîçèðîâêè.',
				'Åæåäíåâíî, ìèð òåðÿåò ëè÷íîñòü è ïîëó÷àåò íàðêîìàíà, êîòîðûì ïðàâèò çëî.',
				'Ïîäóìàéòå, íóæíà ëè âàì òàêàÿ ó÷àñòü, ÿ äóìàþ, ÷òî - íåò.',
				'Åñëè âû çíàåòå ÷òî-ëèáî, ìîæåò êòî-òî èç âàøèõ çíàêîìûõ èëè ñîñåäåé,',
				'óïîòðåáëÿåò íàðêîòèêè, ñðî÷íî ñîîáùèòå ýòî â Ì×Ñ.',
				'Íà ðàííèõ ñòàäèÿõ âñ¸ åù¸ âîçìîæíî ñïàñòè ÷åëîâåêà!',
				'Âñåì ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Ñîòðÿñåíèå ìîçãà',
			text = {
				'Çäðàâñòâóéòå, ÿ ïðî÷òó Âàì ëåêöèþ íà òåìó "ÏÏ ïðè ñîòðÿñåíèè ìîçãà".',
				'Åãî ïðèçíàêàìè ÿâëÿþòñÿ ãîëîâîêðóæåíèå, ãîëîâíàÿ áîëü..',
				'íàðóøåíèå ïàìÿòè, âîçíèêàþùèå ïîñëå òðàâìû ÷åðåïà.',
				'Îêàçûâàÿ ïåðâóþ ïîìîùü,..',
				'íàäî ïðåæäå âñåãî îáåñïå÷èòü ïðîõîäèìîñòü äûõàòåëüíûõ ïóòåé.',
				'Äëÿ ýòîãî ïîñòðàäàâøåãî, ëåæàùåãî íà ñïèíå, ïîâåðíèòå íà áîê.',
				'Â òàêîì ïîëîæåíèè óëó÷øàåòñÿ ñíàáæåíèå ìîçãà êðîâüþ,..',
				'à ñëåäîâàòåëüíî, êèñëîðîäîì, íå çàïàäàåò ÿçûê è â äûõàòåëüíûå ïóòè.',
				'Åñëè ÷åëîâåê íå ïðèõîäèò â ñîçíàíèå áîëåå 30 ìèíóò,..',
				'ìîæíî çàïîäîçðèòü òÿæåëóþ ÷åðåïíî-ìîçãîâóþ òðàâìó  óøèá ìîçãà.',
				'Â ýòîì ñëó÷àå íåîáõîäèìî ñðî÷íî âûçâàòü âðà÷à è..',
				'äîñòàâèòü ïîñòðàäàâøåãî â ëå÷åáíîå ó÷ðåæäåíèå.',
				'Âñåì ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Êðîâîòå÷åíèå',
			text = {
				'Çäðàâñòâóéòå, ÿ ïðî÷òó Âàì ëåêöèþ íà òåìó "Ïåðâàÿ ïîìîùü ïðè êðîâîòå÷åíèè".',
				'Íóæíî ÷åòêî ïîíèìàòü, ÷òî àðòåðèàëüíîå êðîâîòå÷åíèå ïðåäñòàâëÿåò...',
				'ñìåðòåëüíóþ îïàñíîñòü äëÿ æèçíè.',
				'Ïåðâîå, ÷òî òðåáóåòñÿ  ïåðåêðûòü ñîñóä âûøå ïîâðåæäåííîãî ìåñòà.',
				'Äëÿ ýòîãî ïðèæìèòå àðòåðèþ ïàëüöàìè è ñðî÷íî ãîòîâüòå æãóò.',
				'Èñïîëüçóéòå â òàêîì ñëó÷àå ëþáûå ïîäõîäÿùèå ñðåäñòâà...',
				' øàðô, ïëàòîê, ðåìåíü, îòîðâèòå äëèííûé êóñîê îäåæäû.',
				'Ñòÿãèâàéòå æãóò äî òåõ ïîð, ïîêà êðîâü íå ïåðåñòàíåò ñî÷èòüñÿ èç ðàíû.',
				'Äî ïðèåçäà ìåäèêîâ ìîæíî íàïîèòü ðàíåíîãî...',
				'òåïëîé æèäêîñòüþ, èñêëþ÷åíèåì äëÿ ýòîé ðåêîìåíäàöèè ÿâëÿåòñÿ ðàíåíèå â æèâîò.',
				'Ïðè ñâîåâðåìåííîé ðåàêöèè è ïðàâèëüíûõ äåéñòâèÿõ, âñå îáîéäåòñÿ áëàãîïîëó÷íî.',
				'Âñåì ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Îñòàíîâêà ñåðäöà',
			text = {
				'Çäðàâñòâóéòå, ñåãîäíÿ ìû ïîãîâîðèì î ïåðâîé ïîìîùè ïðè îñòàíîâêè ñåðäöà.',
				'Íå êòî èç íàñ íå çíàåò êîãäà ó íåãî, ó çíàêîìûõ èëè áëèçêèõ îñòàíîâèòñÿ ñåðäöå...',
				'íî âû äîëæíû áûòü âñåãäà ãîòîâû îêàçàòü ïåðâóþ ïîìîùü.',
				'Ïåðâîå, ÷òî íóæíî ñäåëàòü ýòî ñíÿòü ñ ïîñòðàäàâøåãî îäåæäó è îáóâü.',
				'Âòîðûì øàãîì íóæíî ïðàâèëüíî ñäåëàòü íåïðÿìîé ìàññàæ ñåðäöà è èñêóñòâåííîå äûõàíèå.',
				'Íåïðÿìîé ìàññàæ ñåðäöà äåëàåò íàëàæèâàíèåì âàøåé îäíîé ëàäîíè íà êèñòü ñâîåé ðóêè...',
				'è ïðèäàâëèâàÿ ðóêè ê ãðóäè äåëàåì òàêèå äâèæåíèÿ 5 ðàç.',
				'Ïîñëå ìàññàæà íóæíî ñäåëàòü 2 âäîõà â ë¸ãêèå ïîñòðàäàâøåìó, ýòî äåëàåòñÿ òàê:',
				'Ïàëüöàìè çàêðûòü íîñ è äåëàåì âäîõè ïîñòðàäàâøåìó â ðîò.',
				'Ïîñëå ýòîãî ñòîèò âûçâàòü âðà÷åé-ðåàíèìàòîëîãîâ è ñëåäèòü çà âðåìåíåì ïîêà...',
				'÷åëîâåê íàõîäèòñÿ â ñîñòîÿíèè êëèíè÷åñêîé ñìåðòè.',
				'Âñåì ñïàñèáî çà âíèìàíèå.'
			}
		},
		{
			name = 'Ëåêöèÿ ïðî ñîí',
			text = {
				'Çäðàâñòâóéòå, ñåãîäíÿ ìû ïîãîâîðèì î ñíå è êàê ïðàâèëüíî ñïàòü.',
				'Ñîí  ýòî ïðîöåññ, áëàãîäàðÿ êîòîðîìó íàø îðãàíèçì îòäûõàåò è íàáèðàåòñÿ ñèë.',
				'Ïîìèìî ôèçè÷åñêîãî è ïñèõîëîãè÷åñêîãî îòäûõà ñîí áëàãîïðèÿòíî âîçäåéñòâóåò è íà çäîðîâüå,',
				'òàê êàê ïðè áîëåçíÿõ èìåííî âî ñíå îðãàíèçì ëó÷øå âñåãî áîðåòñÿ ñ...',
				'ðàçëè÷íûìè âèðóñíûìè è èíôåêöèîííûìè íåäóãàìè.',
				'Óñòàíîâëåíî, ÷òî åñëè ÷åëîâåê ïðîâåä¸ò áîëåå äâóõ ñóòîê áåç ñíà,',
				'òî ó íåãî íà÷í¸ò ðåçêî óõóäøàòüñÿ ñàìî÷óâñòâèå, áóäåò íàáëþäàòüñÿ ïàäåíèå ôèçè÷åñêîé àêòèâíîñòè,',
				'à òàê æå ýòî ïðèâåä¸ò ê ïîÿâëåíèþ ãàëëþöèíàöèé è ê ïñèõè÷åñêèì ðàññòðîéñòâàì.',
				'Ïåðâîå ñ ÷åãî íåîáõîäèìî íà÷àòü - ýòî ðåæèì äíÿ.',
				'Çàñòàâüòå ñåáÿ ëîæèòüñÿ â îäíî è òî æå âðåìÿ.',
				'Ìåäèêè ðåêîìåíäóþò ëîæèòüñÿ ñïàòü äî ïîëóíî÷è, ñàìîå áëàãîïðèÿòíîå âðåìÿ äëÿ íà÷àëà ñíà ýòî 11 ÷àñîâ íî÷è.',
				'Äëÿ òîãî ÷òîáû âûñïàòüñÿ ÷åëîâåêó íåîáõîäèìî 6-8 ÷àñîâ ñíà.',
				'Äëÿ ïîëíîãî âîññòàíîâëåíèÿ ñèë ðåêîìåíäóåòñÿ ñïàòü íå ìåíåå 8-ìè ÷àñîâ â ñóòêè.',
				'Äëÿ çäîðîâîãî è êðåïêîãî ñíà ó âàñ äîëæíà áûòü óäîáíàÿ êðîâàòü,',
				'Ïåðåä ñíîì, ìèíèìóì çà 2 ÷àñà äî åãî íà÷àëà, íå óïîòðåáëÿéòå òÿæ¸ëóþ ïèùó è íå ïåéòå ìíîãî âîäû.',
				'Ñòàðàéòåñü ïåðåä ñíîì íå ÷èòàòü è íå ñìîòðåòü òåëåâèçîð.',
				'Ëó÷øå ïîñëóøàéòå ñïîêîéíóþ è ðàññëàáëÿþùóþ ìóçûêó, êîòîðàÿ áóäåò ñïîñîáñòâîâàòü ñíó.',
				'Ïåðåä ñíîì ðåêîìåíäóåòñÿ ïðèíÿòü âàííó èëè äóø, êîòîðûå îòëè÷íî ðàññëàáëÿþò.',
				'Ñòàðàéòåñü ïîäóìàòü î õîðîøåì, ïîäóìàòü î ïëàíàõ íà çàâòðà ñ òàêèì íàñòðîåì, ÷òî âñ¸ ïîëó÷èòñÿ!',
				'Åñëè âàì ïðåäñòîèò âûñòóïëåíèå ëèáî îò÷åò íà ðàáîòå, íàñòðîéòå ñâîè ìûñëè, ÷òî âû ìîëîäåö,',
				'÷òîáû âñå ïëàíû ó âàñ ñáûâàëèñü, à íàñòðîåíèå ñ óòðà áûëî îòëè÷íûì.',
				'Áëàãîäàðþ çà âíèìàíèå, çà ýòîì íàøà ëåêöèÿ îêîí÷åíà.',
			}
		}
	}
}
