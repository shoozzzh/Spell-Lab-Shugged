dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua" )

local entity_id = EntityGetParent( GetUpdatedEntityID() )

local loading_to_this_wand = ModTextFileGetContent( VFiles.WandId )
if loading_to_this_wand and #loading_to_this_wand > 0 then
	local wand_id = tonumber( loading_to_this_wand )
	ModTextFileSetContent( VFiles.WandId, "" )

	stream_actions( entity_id )
		.foreach( function( a )
			EntityRemoveFromParent( a )
			EntityAddChild( wand_id, a )
		end )

	EntitySetComponentIsEnabled( entity_id, GetUpdatedComponentID(), false )
	EntityKill( entity_id )

	return
end

if ModTextFileGetContent( VFiles.FinishingDumping ) == "1" then
	local wand_id = tonumber( EntityGetName( entity_id ) )
	EntityRemoveTag( wand_id, EditPanelTags.Recording )
	ModTextFileSetContent( VFiles.FinishingDumping, "" )

	stream_actions( entity_id )
		.foreach( function( a )
			EntityRemoveFromParent( a )
			EntityAddChild( wand_id, a )
		end )

	EntitySetComponentIsEnabled( entity_id, GetUpdatedComponentID(), false )
	EntityKill( entity_id )

	return
end
