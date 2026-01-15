dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "data/scripts/lib/mod_settings.lua" )

local cc = (function() -- clikclak.lua
	local a={}function a.load_lang(b,c)local function d(e)local f=e.transl[c]e.ui_name=f.name;e.ui_description=f.desc;if e.id then if e.values_raw and f.values then e.values={}for g,h in ipairs(e.values_raw)do e.values[#e.values+1]={h,f.values[h]}end end;e.scope=e.scope or MOD_SETTING_SCOPE_RUNTIME elseif e.category_id then for g,i in ipairs(e.settings)do d(i)end end end;for g,i in ipairs(b)do d(i)end end;local function j(self,k)for l,h in pairs(k)do self[l]=h end;return self end;a.extra=j;function a.enum(m)return function(n,o)return function(f)return{id=m,value_default=o or n[1],values_raw=n,transl=f,extra=j}end end end;function a.checkbox(m)return function(o)return function(f)return{id=m,value_default=o,transl=f,extra=j}end end end;local function p(q,e)return ModSettingGetNextValue(mod_setting_get_id(q,e))end;local function r(q,e,s)return ModSettingSetNextValue(mod_setting_get_id(q,e),s,false)end;local function t(q,u,v,w,e)local s=p(q,e)if type(s)~="number"then s=e.value_default or 0.0 end;if e.value_min==nil or e.value_max==nil or e.value_default==nil then GuiText(u,mod_setting_group_x_offset,0,e.ui_name.." - not all required values are defined in setting definition")return end;local x=GuiSlider(u,w,mod_setting_group_x_offset,0,e.ui_name,s,e.value_min,e.value_max,e.value_default,0,e.value_formatter(s),64)if s~=x then r(q,e,x)mod_setting_handle_change_callback(q,u,v,e,s,x)end;mod_setting_tooltip(q,u,v,e)end;function a.slider(m)return function(o,y,z,A)return function(f)return{id=m,value_default=o,value_min=y,value_max=z,value_formatter=A,ui_fn=t,transl=f,extra=j}end end end;function a.input_int(m)return function(o,B)return function(f)return{id=m,value_default=tostring(o),text_max_length=B,allowed_characters="0123456789",transl=f,extra=j}end end end;function a.cat(m)return function(b)return function(f)return{category_id=m,settings=b,foldable=true,_folded=true,transl=f,extra=j}end end end;return a
end)()

local _ = (function() -- shortcut_setting.lua
	local function a(b)if not b then return"{}"end local c={'{"'}for d=1,#b do c[d+1]=b[d]end;c[#c+1]='"}'return table.concat(c,'","')end;local function e(b)ModTextFileSetContent("mods/shortcut_set.lua","return "..b)return loadfile("mods/shortcut_set.lua")()end;local f=(function()local g={MINUS="-",EQUALS="=",LEFTBRACKET="[",RIGHTBRACKET="]",BACKSLASH="\\",NONUSHASH="#",SEMICOLON=";",APOSTROPHE="'",GRAVE="`",COMMA=",",PERIOD=".",SLASH="/",NUMLOCKCLEAR="NUMLOCK",KP_DIVIDE="/",KP_MULTIPLY="*",KP_MINUS="-",KP_PLUS="+",KP_PERIOD=".",NONUSBACKSLASH="\\",APPLICATION="MENU",POWER="SHUTDOWN",KP_EQUALS="=",KP_COMMA=",",KP_EQUALSAS400="=",KP_LEFTPAREN="(",KP_RIGHTPAREN=")",KP_LEFTBRACE="{",KP_RIGHTBRACE="}",KP_XOR="^",KP_POWER="SHUTDOWN",KP_PERCENT="%",KP_LESS="<",KP_GREATER=">",KP_AMPERSAND="&",KP_DBLAMPERSAND="&&",KP_VERTICALBAR="|",KP_DBLVERTICALBAR="||",KP_COLON=":",KP_HASH="#",KP_AT="@",KP_EXCLAM="!",KP_PLUSMINUS="+-",LGUI="LEFT WINDOWS",RGUI="RIGHT WINDOWS"}local h={Key_CTRL="Ctrl",Key_SHIFT="Shift",Key_ALT="Alt",JOY_BUTTON_0="$input_xboxbutton_a",JOY_BUTTON_1="$input_xboxbutton_b",JOY_BUTTON_2="$input_xboxbutton_x",JOY_BUTTON_3="$input_xboxbutton_y",Mouse_x1="$input_mousebutton4",Mouse_x2="$input_mousebutton5"}local i={["简体中文"]={Mouse_left="左键",Mouse_right="右键"},DEFAULT={Mouse_left="Left-click",Mouse_right="Right-click"}}do local j={"喵体中文","汪体中文","完全汉化"}for k,l in ipairs(j)do i[l]=i["简体中文"]end end;local function m(n,d)local o=h[n]if o then return GameTextGetTranslatedOrNot(o)end;local p=i[d]or i.DEFAULT;o=p[n]if o then return o end;if n:find"^Mouse_"then return GameTextGet("$input_"..n:gsub("_",""):lower()):upper()elseif n:find"^Key_"then local q=n:sub(5):upper()o=g[q]if o then return o end;local r=0;o,r=q:gsub("^KP_","KEYPAD ")if r>0 then return o end;o,r=q:gsub("^AC_","AC ")if r>0 then return o end;return q elseif n:find"^JOY_BUTTON_"then local o=GameTextGet("$input_xboxbutton_"..n:sub(12):lower())if n:find"%d%d_DOWN$"then o=o.." DOWN"elseif n:find"%d%d_MOVED$"then o=o.." MOVED"else o=("(%s)"):format(o)end;return o end;return GameTextGet("$menuoptions_configurecontrols_keyname_unknown")end;local s={Key_CTRL=-100,Key_ALT=-99,Key_SHIFT=-98,DEFAULT=0,Mouse_left=99,Mouse_right=100}local function t(u)table.sort(u,function(v,w)local x=s[v]or s.DEFAULT;local y=s[w]or s.DEFAULT;if x~=y then return x<y end;local z=#v;local A=#w;if z~=A then return z>A end;return v<w end)end;function shortcut_tostring(u,d)local B={}for C,l in pairs(u)do B[C]=l end;local D=B[#B]B[#B]=nil;t(B)B[#B+1]=D;local E={}for k,F in ipairs(B)do E[#E+1]=m(F,d)end;return table.concat(E," + ")end end)()local G=(function()local g,h=unpack((function()local i=loadfile("data/scripts/debug/keycodes.lua")local j={}setfenv(i,j)()local k={Mouse={},Keyboard={},Joystick={}}for l,m in pairs(j)do if l:find"^Mouse_"then k.Mouse[l]=m elseif l:find"^Key_"then k.Keyboard[l]=m elseif l:find"^JOY_BUTTON_"then k.Joystick[l]=m end end;local n={"JOY_BUTTON_0","JOY_BUTTON_1","JOY_BUTTON_2","JOY_BUTTON_3"}for d,o in ipairs({j,k.Mouse,k.Keyboard,k.Joystick})do for d,p in ipairs(n)do o[p]=nil end end;return{j,k}end)())local q={}local r={}for s,t in pairs(h.Keyboard)do r[s]={function()return InputIsKeyDown(t)end,function()return InputIsKeyJustDown(t)end}end;for s,t in pairs(h.Mouse)do if s~="Mouse_left"or s~="Mouse_right"then r[s]={function()return InputIsMouseButtonDown(t)end,function()return InputIsMouseButtonJustDown(t)end}end end;do local u={Key_ALT={"Key_LALT","Key_RALT"},Key_CTRL={"Key_LCTRL","Key_RCTRL"},Key_SHIFT={"Key_LSHIFT","Key_RSHIFT"}}local v=function(w)return function()for g,n in ipairs(w)do if n()then return true end end end end;for x,y in pairs(u)do local z,A={},{}for g,B in ipairs(y)do local C,D=unpack(r[B])z[#z+1]=C;A[#A+1]=D;r[B]=nil end;r[x]={v(z),v(A)}end end;local E={}local F={JOY_BUTTON_A=true,JOY_BUTTON_B=true,JOY_BUTTON_LEFT_STICK_LEFT=true,JOY_BUTTON_LEFT_STICK_RIGHT=true,JOY_BUTTON_LEFT_STICK_UP=true,JOY_BUTTON_LEFT_STICK_DOWN=true}for H,I in pairs(h.Joystick)do if F[H]then local C=function()for J=0,7 do if E[J]and InputIsJoystickButtonDown(J,I)then return true end end;return false end;r[H]={C,nil}end end;do local K={}for B,g in pairs(r)do K[#K+1]=B end;for B,g in ipairs(h.Joystick)do K[#K+1]=B end;q.listened_keys=K end;local L={}for B,g in pairs(r)do L[B]=0 end;q.just_down={}q.down={}function q:update()local M=self.just_down;local N=self.down;for p=0,7 do E[p]=InputIsJoystickConnected(p)end;for H,O in pairs(r)do local C,D=unpack(O)local P=L[H]local Q=C()if D then M[H]=D()else M[H]=not N[H]and Q end;if P>30 then M[H]=true end;N[H]=Q;if N[H]then L[H]=P+1 else L[H]=0 end end end;return q end)()local R={["简体中文"]={done="[完成]",clear="[清空]",cancel="[取消]"},DEFAULT={done="[Done]",clear="[Clear]",cancel="[Cancel]"}}for f,S in ipairs({"喵体中文","汪体中文","完全汉化"})do R[S]=R["简体中文"]end;Shortcut_Type={OneShot=0,Sustained=1}local T=nil;local U=nil;local function V(W)local X=true;for f,Y in ipairs(U)do if W==Y then X=false;break end end;if X then U[#U+1]=W end end;function mod_setting_shortcut(Z,_,a0,a1,a2)GuiLayoutBeginHorizontal(_,0,0,true,2,2)GuiButton(_,4*a1,mod_setting_group_x_offset,0,a2.ui_name)local a3=GuiGetTextDimensions(_,a2.ui_name)local f,f,f,C,D=GuiGetPreviousWidgetInfo(_)local a4=GameTextGet("$current_language")GuiIdPushString(_,"spell_lab_shugged.shortcut_setting.extra_button")local a5=false;if T==a2.id then G:update()for W,a6 in pairs(G.just_down)do if a6 then V(W)end end;local a7;if#U>0 then a7=shortcut_tostring(U,a4)else a7="$menuoptions_configurecontrols_pressakey"end;GuiOptionsAddForNextWidget(_,GUI_OPTION.Layout_NoLayouting)GuiColorSetForNextWidget(_,1,1,0.5,1)local a8,a9=GuiButton(_,a1,C+120,D,a7)if a2.shortcut_type~=Shortcut_Type.Sustained then if a8 then V("Mouse_left")elseif a9 then V("Mouse_right")end end;if a8 or a9 then a5=true;ModSettingSetNextValue(mod_setting_get_id(Z,a2),a(U),false)T=nil;U=nil end;mod_setting_tooltip(Z,_,a0,a2)GuiLayoutEnd(_)GuiLayoutBeginHorizontal(_,mod_setting_group_x_offset+120,0,true,2,2)if GuiButton(_,4*a1+1,0,0,(R[a4]or R.DEFAULT).done)then a5=true;ModSettingSetNextValue(mod_setting_get_id(Z,a2),a(U),false)T=nil;U=nil end;if GuiButton(_,4*a1+2,0,0,(R[a4]or R.DEFAULT).clear)then U={}end;if GuiButton(_,4*a1+3,0,0,(R[a4]or R.DEFAULT).cancel)then T=nil;U=nil end;GuiLayoutEnd(_)else local a7;do local aa=ModSettingGetNextValue(mod_setting_get_id(Z,a2))if type(aa)~="string"then aa=a2.value_default or"{}"end;local b;do local a6,f=pcall(function()b=e(aa)end)if not a6 then b={}end end;if#b==0 then a7="$menuoptions_configurecontrols_action_unbound"else a7=shortcut_tostring(b,GameTextGet("$current_language"))end end;GuiOptionsAddForNextWidget(_,GUI_OPTION.Layout_NoLayouting)local a8,a9=GuiButton(_,a1,C+120,D,a7)if a8 and not a9 then T=a2.id;U={}elseif not a8 and a9 then ModSettingSetNextValue(mod_setting_get_id(Z,a2),a2.value_default,false)a5=true end;mod_setting_tooltip(Z,_,a0,a2)GuiLayoutEnd(_)end;GuiIdPop(_)if a5 then ModSettingSetNextValue(Z..".shortcut_changed",true,false)end end
end)()

local function format_percent( value )
	return (" %.0f%%"):format( value * 100 )
end

function cc.shortcut( id )
	return function( value_default )
		return function( transl )
			return {
				id = id,
				transl = transl,
				ui_fn = mod_setting_shortcut,
				extra = cc.extra,
			}
		end
	end
end

mod_settings_version = 1

mod_settings = {
	cc.cat "wand_edit_panel" {
		cc.input_int "wand_edit_panel_max_rows" (5,3) {
			zh_cn = {
				name = "最大行数",
				desc = "法杖编辑面板最多可以同时显示的行数，默认为 5",
			},
			en = {
				name = "Max Rows",
				desc = "How many rows should the wand edit panel show at most at the same time?\n5 by default",
			},
		},
		cc.input_int "wand_edit_panel_max_actions_per_row" (0,3) {
			zh_cn = {
				name = "单行格数限制",
				desc = "限制法杖编辑面板单行最多可以显示的格数\n单行最多能容纳的格数自动由虚拟分辨率计算得出，然后应用此限制\n0 = 不进行限制",
			},
			en = {
				name = "Max Slots In One Row Limit",
				desc = "How many slots should one row of the wand edit panel contain at most?\nNote: That is calculated with your virtual resolution magic numbers\n0 = No extra limit to it",
			},
		},
		cc.input_int "wand_edit_panel_history_limit" (30,3) {
			zh_cn = {
				name = "历史记录最大条数",
				desc = "法杖编辑面板保留最近操作的数量，默认为 30",
			},
			en = {
				name = "Max Histories",
				desc = "How many recent operations should the wand edit panel remember?\n30 by default",
			},
		},
		cc.enum "wand_listener_type" {"INV","HAND","PANEL"} {
			zh_cn = {
				name = "法杖监听",
				desc = "法杖编辑面板应该从哪些法杖监听外部操作？",
				values = {
					INV = "背包中所有法杖",
					HAND = "手持法杖",
					PANEL = "手持法杖（仅法杖编辑面板显示时）",
				},
			},
			en = {
				name = "Wand Listening",
				desc = "From which wand(s) should be listened to track any external options?\nValue doesn't change the way you edit wand, but changes how many histories will be created",
				values = {
					INV = "All Wands in Inventory",
					HAND = "Held Wand",
					PANEL = "Held Wand(Only when the wand edit panel is shown)",
				},
			},
		},
	} {
		zh_cn = {
			name = "法杖编辑面板",
		},
		en = {
			name = "Wand Edit Panel",
		},
	},
	cc.cat "spell_picker" {
		cc.enum "filter_buttons_trigger" {"HOVER","CLICK"} {
			zh_cn = {
				name = "法术类别切换方式",
				desc = "法术类别按钮应该如何触发？",
				values = {
					HOVER = "悬浮",
					CLICK = "点击",
				},
			},
			en = {
				name = "Switch between types",
				desc = "How to trigger the spell type buttons?",
				values = {
					HOVER = "Hover",
					CLICK = "Click",
				},
			},
		},
		cc.checkbox "show_icon_unlocked" (false) {
			zh_cn = {
				name = "标记已解锁法术",
				desc = "开启时，将在已解锁法术右上角显示图标，以便重新锁定它们",
			},
			en = {
				name = "Mark Out Unlocked Spells",
				desc = "Should we mark out unlocked spells with a small icon in the top right corner?",
			},
		},
		cc.input_int "action_history_limit" (96,3) {
			zh_cn = {
				name = "法术使用记录最大条数",
				desc = "法术选取菜单保留的法术使用记录条数，默认为 96",
			},
			en = {
				name = "Recently Used Spells Limit",
				desc = "How many recently used spells should the spell picker menu remember?\n96 by default",
			},
		},
		cc.checkbox "include_spells_in_non_inv_wand" (false) {
			zh_cn = {
				name = "背包/附近页面显示附近法杖中法术",
			},
			en = {
				name = "Include Spells In Nearby Wands",
			},
		},
		cc.checkbox "show_screen_keyboard" (false) {
			zh_cn = {
				name = "法术搜索页面显示软键盘",
			},
			en = {
				name = "Show Screen Keyboard In Spell Search Page",
			},
		},
	} {
		zh_cn = {
			name = "法术选取菜单",
		},
		en = {
			name = "Spell Picker",
		},
	},
	cc.cat "creative_mode_flight_speed" {
		cc.input_int "creative_mode_flight_speed_normal" (200,6) {
			zh_cn = {
				name = "正常",
				desc = "默认：200",
			},
			en = {
				name = "Faster",
				desc = "200 by default",
			},
		},
		cc.input_int "creative_mode_flight_speed_faster" (450,6) {
			zh_cn = {
				name = "加速",
				desc = "默认：450",
			},
			en = {
				name = "Faster",
				desc = "450 by default",
			},
		},
		cc.input_int "creative_mode_flight_speed_no_clip" (300,6) {
			zh_cn = {
				name = "穿墙",
				desc = "默认：300",
			},
			en = {
				name = "No Clip",
				desc = "300 by default",
			},
		},
	} {
		zh_cn = {
			name = "超级飞行速度",
		},
		en = {
			name = "Superflight Speed",
		},
	},
	cc.cat "all_seeing_eye" {
		cc.slider "all_seeing_eye_lighting" (0,0,1,format_percent) {
			zh_cn = {
				name = "照明",
			},
			en = {
				name = "Lighting",
			},
		},
		cc.slider "all_seeing_eye_fog_of_war_removing" (1,0,1,format_percent) {
			zh_cn = {
				name = "移除战争迷雾",
			},
			en = {
				name = "Fog of War Removing",
			},
		},
	} {
		zh_cn = {
			name = "全视之眼效果",
		},
		en = {
			name = "Effect of All-seeing Eye",
		},
	},
	cc.checkbox "no_weather" (false) {
		zh_cn = {
			name = "禁用天气",
			desc = "开启时，天气将锁定为晴朗状态",
		},
		en = {
			name = "Disable Weather",
			desc = "Should we disable all kinds of rain or snow?",
		},
	}:extra{ scope = MOD_SETTING_SCOPE_RUNTIME_RESTART },
	cc.checkbox "dummy_target_show_full_damage_number" (false) {
		zh_cn = {
			name = "靶标假人显示完整伤害数字",
			desc = "开启时，将总是以完整形式显示伤害数字，不会使用科学计数法",
		},
		en = {
			name = "Show Full Damage Number For Dummy Targets",
			desc = "Should dummy targets always has full-length damage numbers shown?",
		},
	},
	cc.checkbox "button_click_sound" (true) {
		zh_cn = {
			name = "按钮点击音效",
		},
		en = {
			name = "Button Click Sound",
		},
	},
	cc.checkbox "action_button_click_sound" (true) {
		zh_cn = {
			name = "法术按钮点击音效",
		},
		en = {
			name = "Spell Button Click sound",
		},
	},
	cc.enum "spellbox_pack" { "GOKIS", "VANILLA" } {
		zh_cn = {
			name = "法术框贴图",
			values = {
				GOKIS = "Goki 经典方案",
				VANILLA = "Noita 原版方案",
			},
		},
		en = {
			name = "Spell Box Sprites",
			values = {
				GOKIS = "Goki's Classics",
				VANILLA = "Noita Vanilla",
			},
		},
	},
}

local function load_mod_settings( cur_lang )
	local lang_id = "en"
	if cur_lang:find "中文" or cur_lang:find "汉化" then
		lang_id = "zh_cn"
	end
	cc.load_lang( mod_settings, lang_id )
end

load_mod_settings( GameTextGet "$current_language"  )

local mod_id = "spell_lab_shugged"

function ModSettingsUpdate( init_scope )
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

local last_cur_lang
function ModSettingsGui( gui, in_main_menu )
	local cur_lang = GameTextGet "$current_language"
	if cur_lang ~= last_cur_lang then
		load_mod_settings( cur_lang )
		last_cur_lang = cur_lang
	end
    mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end