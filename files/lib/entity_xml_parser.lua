nxml = dofile_once( "mods/spell_lab_shugged/files/lib/nxml.lua" )
function parse_entity_xml( filepath )
	if not filepath or not ModDoesFileExist( filepath ) then return nil end
	local xml_content = nxml.parse( ModTextFileGetContent( filepath ) )
	local children_to_add = {}
	for basefile in xml_content:each_child() do
		if basefile.name ~= "Base" then goto continue end
		local include_children = basefile.attr.include_children
		local basefile_content = parse_entity_xml( basefile.attr.file )
		if not basefile_content then goto continue end

		for child in basefile:each_child() do
			local child_to_edit
			for c in basefile_content:each_of( child.name ) do
				if not c.attr.edited then
					child_to_edit = c
					break
				end
			end
			if child_to_edit == nil then
				print_error( "base file used incorrectly in file: " .. basefile.attr.file .. " name: " .. child.name .. " path: " .. filepath )
				break
			end

			for k, v in pairs( child.attr ) do
				child_to_edit.attr[k] = v
			end
			for object in child:each_child() do
				local object_to_edit = child_to_edit:first_of( object.name )
				if object_to_edit then
					for k, v in pairs( object.attr ) do
						object_to_edit[k] = v
					end
				else
					table.insert( child_to_edit.children, object )
				end
			end
			child_to_edit.attr.edited = true
		end
		for child in basefile_content:each_child() do
			if child.name ~= "Entity" or include_children == "1" then
				child.attr.edited = nil
				table.insert( children_to_add, child )
			end
		end
		::continue::
	end
	for _, child in ipairs( children_to_add ) do
		xml_content:add_child( child )
	end
	return xml_content
end