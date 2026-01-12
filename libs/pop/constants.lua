---@alias gui_option integer
---@alias playback_type integer

-- these come from data/scripts/lib/utilities.lua, and is modified
-----------------------------------------------------

-- These options are exposed to the modding API due to public demand but are completely unsupported.
-- They don't work and haven't been tested with all widgets.
-- We're aware of many bugs that occur when using these in uninteded ways,
-- but we also probably never have time to fix them (and all the code that has various workarounds to get around the bugs :) ).
-- You just have to live with the fact that the gui library exists mainly to support the game, and we have limited time to work on it.

-- volatile: must be kept in sync with the ImGuiWidgetOptions enum in imgui.h
---@class gui_options
local GUI_OPTION = {
	None = 0,

	IsDraggable = 1, -- you might not want to use this, because there will be various corner cases and bugs, but feel free to try anyway.
	NonInteractive = 2, -- works with GuiButton
	AlwaysClickable = 3,
	ClickCancelsDoubleClick = 4,
	IgnoreContainer = 5,
	NoPositionTween = 6,
	ForceFocusable = 7,
	HandleDoubleClickAsClick = 8,
	GamepadDefaultWidget = 9, -- it's recommended you use this to communicate the widget where gamepad input will focus when entering a new menu

	-- these work as intended (mostly)
	Layout_InsertOutsideLeft = 10,
	Layout_InsertOutsideRight = 11,
	Layout_InsertOutsideAbove = 12,
	Layout_ForceCalculate = 13,
	Layout_NextSameLine = 14,
	Layout_NoLayouting = 15,

	-- these work as intended (mostly)
	Align_HorizontalCenter = 16,
	Align_Left = 17,

	FocusSnapToRightEdge = 18,

	NoPixelSnapY = 19,

	DrawAlwaysVisible = 20,
	DrawNoHoverAnimation = 21,
	DrawWobble = 22,
	DrawFadeIn = 23,
	DrawScaleIn = 24,
	DrawWaveAnimateOpacity = 25,
	DrawSemiTransparent = 26,
	DrawActiveWidgetCursorOnBothSides = 27,
	DrawActiveWidgetCursorOff = 28,

	TextRichRendering = 29,

	NoSound = 47,
	Hack_ForceClick = 48,
	Hack_AllowDuplicateIds = 49,

	ScrollContainer_Smooth = 50,
	IsExtraDraggable = 51,

	_SnapToCenter = 62,
	Disabled = 63,
}

-- volatile: must be kept in sync with the ImGuiRectAnimationPlaybackType enum in imgui.h
---@class playback_types
local GUI_RECT_ANIMATION_PLAYBACK = {
	PlayToEndAndHide = 0,
	PlayToEndAndPause = 1,
	Loop = 2,
}

---@class gui_constants
return {
	options = GUI_OPTION,
	playback_types = GUI_RECT_ANIMATION_PLAYBACK,
}
