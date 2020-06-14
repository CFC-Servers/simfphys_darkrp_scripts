hook.Add( "CanEditVariable", "CFC_Simfphys_PropertiesEdit", function( ent, ply, key, val, editor )
    if not ent.IsSimfphyscar then return end
    if ply:IsSuperAdmin() then return end
    ply:ChatPrint("You can not edit simfphys properties")
    return false
end )
