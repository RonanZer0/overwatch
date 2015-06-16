overwatch = {};
overwatch.commands = {};

function overwatch.PlayerSay(ply, text, silent)
    ply.memode = ply.memode or false;
    local silent = silent or false;
    local cmd = string.gsub(string.gsub(string.gsub(string.lower(text), " (.*)", ""), "!", ""), "/", "");
    local _args = string.gsub(string.lower(text), "(.-) ", "", 1);
    local args = {};
    local i = 0;
    for s in _args:gmatch("%S+") do
        i = i + 1;
        args[i] = s;
    end
    ok = true;
    local hasPrefix1 = string.find(text, "!");
    local hasPrefix2 = string.find(text, "/");
    if hasPrefix1 != 1 and hasPrefix2 != 1 then return end;
    if !overwatch.commands[cmd] then overwatch.Print(ply, "Unknown command.") ok = false end;
    if tostring(ply) != "[NULL Entity]" then
        if !ply:IsAdmin() then overwatch.Print(ply, "You are not an admin!") ok = false end;
    end
    if !ok then return end;
    if ply.memode then
        local args1, args2, args3, args4 = args[1], args[2], args[3], args[4];
        args[1] = ply:Nick();
        args[2] = args1;
        args[3] = args2;
        args[4] = args3;
        args[5] = args4;
    end
    timer.Simple(0.00001, function()
        overwatch.commands[cmd].func(ply, args);
    end);
    if overwatch.commands[cmd].silent == true or silent then
        return "";
    end
end

function overwatch.RegisterCommand(name, _func, _silent, _help)
    local _help = _help or "No help specified.";
    overwatch.commands[name] = {func = _func, silent = _silent, help = _help,};
end

function overwatch.FindPlayer(nick, ply)
    local r;
    for _, v in pairs(player.GetAll()) do
	if !string.find(string.lower(v:Nick()), nick) then continue end;
        if !r then
            r = v;
        else
            if ply then
                overwatch.Print(ply, "Multiple players found!");
            end
            return;
        end
    end
    return r;
end

function overwatch.Print(ply, msg)
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTTALK, "[OVERWATCH] "..msg);
    end
end

function overwatch.Broadcast(msg, caller)
    for _, v in pairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "[OVERWATCH] "..msg);
    end
    if caller then
        print("[OVERWATCH] "..msg.." ("..caller..")");
    else
        print("[OVERWATCH] "..msg);
    end
end

function overwatch.Help(ply, args)
    if !overwatch.commands[args[1]] and args[1] != "*" and args[1] != "!help" then overwatch.Print(ply, "Command does not exist!"); return end;
	
	if args[1] == "*" or args[1] == "!help" then
		for k, v in pairs(overwatch.commands) do
			overwatch.Print(ply, k.." - "..overwatch.commands[k].help);
		end
	else
		overwatch.Print(ply, args[1].." - "..overwatch.commands[args[1]].help);
	end
end

function overwatch.Kick(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    victim:Kick(args[2]);
end

function overwatch.Ban(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    overwatch.FindPlayer(args[1]):Ban(args[2], true);
end

function overwatch.Kill(ply, args)
    local victim;
    if !args[1] or args[1] == "!kill" then
        victim = ply;
    else
        victim = overwatch.FindPlayer(args[1]);
    end
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    if !victim:Alive() then overwatch.Print(ply, victim:Nick().." is already dead!") return end;
    victim:Kill();
end

function overwatch.Hurt(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    if !victim:Alive() then overwatch.Print(ply, victim:Nick().." is dead!") return end;
    victim:SetHealth(victim:Health()-args[2]);
end

function overwatch.Bring(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    if !victim:Alive() then overwatch.Print(ply, victim:Nick().." is dead!") return end;
    victim:SetPos(ply:GetPos());
end

function overwatch.Strip(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    if !victim:Alive() then overwatch.Print(ply, victim:Nick().." is dead!") return end;
    victim:StripWeapons();
end

function overwatch.SetHealth(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    if !victim:Alive() then overwatch.Print(ply, victim:Nick().." is dead!") return end;
    victim:SetHealth(args[2]);
end

function overwatch.SetActiveWeapon(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    if !victim:Alive() then overwatch.Print(ply, victim:Nick().." is dead!") return end;
    local wpn;
    for _, w in pairs(victim:GetWeapons()) do
        if w:GetClass() == args[2] then wpn = w else continue end;
    end
    victim:SetActiveWeapon(wpn);
end

function overwatch.Spawn(ply, args)
    local victim;
    if !args[1] or args[1] == "!spawn" then
        victim = ply;
    else
        victim = overwatch.FindPlayer(args[1]);
    end
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    victim:Spawn();
end

function overwatch.Pos(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    victim:SetPos(Vector(args[2], args[3], args[4]));
end

function overwatch.MeMode(ply)
    ply.memode = ply.memode or false;
    if !ply.memode then
        overwatch.Print(ply, "Me-Mode is now ON.");
        ply.memode = true;
    else
        overwatch.Print(ply, "Me-Mode is now OFF.");
        ply.memode = false;
    end
end

function overwatch.SetRank(ply, args)
    if tostring(ply) != "[NULL Entity]" then
        if !ply:IsSuperadmin() then return end;
    end
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    local o = victim:GetUserGroup();
    victim:SetUserGroup(string.lower(args[2]));
    local n = victim:GetUserGroup();
    if o == n then return end;
    if tostring(ply) == "[NULL Entity]" then ply = "Console" end;
    local vn = victim:Nick();
    if o == "superadmin" then
        overwatch.Broadcast(vn.." has been demoted to "..n.."!");
    elseif o == "admin" and n != "superadmin" then
        overwatch.Broadcast(vn.." has been demoted to "..n.."!");
    elseif n != "superadmin" and n != "admin" then
        overwatch.Broadcast(vn.." has been ranked to "..n.."!");
    else
        overwatch.Broadcast(vn.." has been promoted to "..n.."!");
    end
end

function overwatch.God(ply, args)
    local victim;
    if !args[1] or args[1] == "!god" then
        victim = ply;
    else
        victim = overwatch.FindPlayer(args[1]);
    end
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    if victim:HasGodMode() then
        victim:GodDisable();
    else
        victim:GodEnable();
    end
end

function overwatch.Give(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    victim:Give(args[2]);
end

function overwatch.Goto(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    ply:SetPos(victim:GetPos());
end

function overwatch.Noclip(ply, args)
    local victim;
    if !args[1] or args[1] == "!noclip" then
        victim = ply;
    else
        victim = overwatch.FindPlayer(args[1]);
    end
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    victim.noclip = victim.noclip or victim:GetMoveType() == MOVETYPE_NOCLIP;
    if victim:GetMoveType() != MOVETYPE_NOCLIP then
        victim:SetMoveType(MOVETYPE_NOCLIP);
        victim.noclip = true;
    else
        victim:SetMoveType(MOVETYPE_WALK);
        victim.noclip = false;
    end
end

function overwatch.KillSilent(ply, args)
    local victim = overwatch.FindPlayer(args[1]);
    if !victim or !IsValid(victim) then overwatch.Print(ply, args[1].." is not a valid player!") return end;
    victim:KillSilent();
end

function overwatch.NoclipThink()
    for _, v in pairs(player.GetAll()) do
        if v.noclip and v:GetMoveType() != MOVETYPE_NOCLIP then
            v:SetMoveType(MOVETYPE_NOCLIP);
        end
    end
end

concommand.Add("setrank", function(ply, args, argst, str)
    if tostring(ply) != "[NULL Entity]" then return end; -- only the console can call this!
    overwatch.PlayerSay(ply, "!rank "..str)
end);

concommand.Add("overwatch", function(ply, args, argst, str)
    overwatch.PlayerSay(ply, "!"..str, true);
end);

overwatch.RegisterCommand("ban", overwatch.Ban, false, "Bans the specified player.");
overwatch.RegisterCommand("bring", overwatch.Bring, false, "Brings the specified player.");
overwatch.RegisterCommand("give", overwatch.Give, false, "Gives an entity to the specified player.");
overwatch.RegisterCommand("god", overwatch.God, false, "Toggles godmode on the specified player.");
overwatch.RegisterCommand("goto", overwatch.Goto, false, "Goes to player's position.");
overwatch.RegisterCommand("help", overwatch.Help, false, "Shows the help text of a command.")
overwatch.RegisterCommand("hurt", overwatch.Hurt, false, "Hurts the specified player.");
overwatch.RegisterCommand("kick", overwatch.Kick, false, "Kicks the specified player.");
overwatch.RegisterCommand("kill", overwatch.Kill, false, "Kills the specified player.");
overwatch.RegisterCommand("killsilent", overwatch.KillSilent, true, "Silently kills the specified player.");
overwatch.RegisterCommand("memode", overwatch.MeMode, false, "Toggles Me-Mode.");
overwatch.RegisterCommand("noclip", overwatch.Noclip, false, "Toggles noclip on the specified player.");
overwatch.RegisterCommand("pos", overwatch.Pos, false, "Sets the specified player's position.");
overwatch.RegisterCommand("rank", overwatch.SetRank, false, "Sets the specified player's rank.");
overwatch.RegisterCommand("sethealth", overwatch.SetHealth, false, "Sets the specified player's health.");
overwatch.RegisterCommand("setweapon", overwatch.SetWeapon, false, "Sets the specified player's weapon.");
overwatch.RegisterCommand("spawn", overwatch.Spawn, false, "Spawns the specified player.");
overwatch.RegisterCommand("strip", overwatch.Strip, false, "Strips the specified player.");


hook.Add("PlayerSay", "overwatch.PlayerSay", overwatch.PlayerSay);
hook.Add("Think", "overwatch.NoclipThink", overwatch.NoclipThink);

print("[OVERWATCH] Successfully initialized without errors.")
