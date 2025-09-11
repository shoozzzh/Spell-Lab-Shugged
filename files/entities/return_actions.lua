dofile_once( "mods/spell_lab_shugged/files/lib/stream.lua" )

if not not_first_time then
	not_first_time = true
	return
end

local function stream_actions( wand_id )
	return stream( EntityGetAllChildren( wand_id ) or {} )
		.filter( function( e ) return EntityGetFirstComponentIncludingDisabled( e, "ItemComponent" ) ~= nil end )
		.filter( function( e ) return EntityGetFirstComponentIncludingDisabled( e, "ItemActionComponent" ) ~= nil end )
end

local var_name_prefix = "spell_lab_shugged."
local tag_dumping = "spell_lab_shugged.dumping_this_wand"
local vfile_wand_id = "mods/spell_lab_shugged/vfiles/load_to_this_wand.txt"

local entity_id = GetUpdatedEntityID()

local saving = EntityGetFirstComponentIncludingDisabled( entity_id, "VariableStorageComponent" )
local loading = ModTextFileGetContent( vfile_wand_id )
local wand_id
if saving and not loading then
	wand_id = ComponentGetValue2( saving, "value_int" )
	EntityRemoveTag( wand_id, tag_dumping )
	EntityRemoveComponent( entity_id, saving )
	EntityKill( entity_id )
elseif not saving and loading then
	wand_id = tonumber( loading )
	ModTextFileSetContent( vfile_wand_id, nil )
else
	print( "Something is very wrong!" )
	GamePrint( "Something is very wrong!" )
	GamePrintImportant( "Something is very wrong!" )
	return
end

stream_actions( entity_id )
	.foreach( function( a )
		EntityRemoveFromParent( a )
		EntityAddChild( wand_id, a )
	end )
