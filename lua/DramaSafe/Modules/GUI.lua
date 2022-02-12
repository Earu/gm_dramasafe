local ScreenWidth, ScreenHeight = ScrW(), ScrH()
local MidWidth, MidHeight = ScrW() / 2, ScrH() / 2

surface.CreateFont("StatusFont", {
    font = "Roboto",
    size = (40 * ScreenWidth) / ScreenHeight,
    weight = 700,
    antialias = true,
    shadow = true,
    additive = true,
})

surface.CreateFont("MenuFont", {
    font = "Roboto",
    size = (10 * ScreenWidth) / ScreenHeight,
    weight = 500,
    antialias = true,
    shadow = true,
    additive = true,
})

local PANEL = {
    Init = function(self)
        local spacing = 15
        local lname = LocalPlayer():CapitalizeName()
        local lsteamid = LocalPlayer():SteamID()
        local lugroup = LocalPlayer():GetUserGroup()
        self.Frame = self:Add("DFrame")
        self.Frame:SetSize(1200, 780)
        self.Frame:SetPos(MidWidth - self.Frame:GetWide() / 2, MidHeight - self.Frame:GetTall() / 2)
        self.Frame:ShowCloseButton(true)
        self.Frame:SetDraggable(true)
        self.Frame:SetTitle("DramaSafe")
        self.Frame.lblTitle:SetFont("MenuFont")
        self.Frame.btnMaxim:Hide()
        self.Frame.btnMinim:Hide()
        self.Frame:SetSelectable(false)
        self.Frame:MakePopup()

        local framesizex, framesizey = self.Frame:GetWide(), self.Frame:GetTall()
        EasyChat.BlurPanel(self.Frame, 0, 0, 0, 0)

        self.Frame.Paint = function()
            surface.SetDrawColor(54, 57, 62, 190)
            surface.DrawRect(0, 0, framesizex, framesizey)
            surface.SetDrawColor(100, 102, 106, 190)
            surface.DrawOutlinedRect(0, 0, framesizex, framesizey)
            surface.DrawRect(0, 0, framesizex, 25)
        end

        self.Status = self.Frame:Add("DPanel")
        self.Status:SetSize(self.Frame:GetWide() - 20, 75)
        self.Status:Dock(TOP)
        self.Status:DockMargin(5, 5, 5, 0)
        local stax, stay = self.Status:GetWide(), self.Status:GetTall()

        self.Status.Paint = function()
            local status, color = DramaSafe.Status()
            surface.SetDrawColor(46, 49, 54, 220)
            surface.DrawRect(0, 0, stax, stay)
            surface.SetDrawColor(100, 102, 106, 220)
            surface.DrawOutlinedRect(0, 0, stax, stay)

            surface.SetFont("StatusFont")
            local x, y = surface.GetTextSize(status)
            surface.SetTextPos(stax / 2 - x / 2, stay / 2 - y / 2)
            surface.SetTextColor(color)
            surface.DrawText(status)
            surface.SetTextColor(100, 102, 106)
            surface.SetTextPos(7, 3)
            surface.SetFont("MenuFont")
            surface.DrawText("Current status:")
        end

        self.LPlayer = self.Frame:Add("DPanel")
        self.LPlayer:SetSize(self.Frame:GetWide() - 20, 60)
        self.LPlayer:Dock(TOP)
        self.LPlayer:DockMargin(5, 5, 5, 0)
        local lpx, lpy = self.LPlayer:GetWide(), self.LPlayer:GetTall()

        self.Avatar = vgui.Create("AvatarImage", self.LPlayer)
        self.Avatar:SetSize(self.LPlayer:GetTall(), self.LPlayer:GetTall() - 2)
        self.Avatar:SetPos(1, 1)
        self.Avatar:SetPlayer(LocalPlayer(), 128)

        self.LPlayer.Paint = function()
            surface.SetDrawColor(46, 49, 54, 220)
            surface.DrawRect(0, 0, lpx, lpy)
            surface.SetDrawColor(100, 102, 106, 220)
            surface.DrawOutlinedRect(0, 0, lpx, lpy)

            surface.SetTextColor(100, 102, 106)
            surface.SetFont("MenuFont")
            surface.SetTextPos(self.Avatar:GetWide() + spacing, 2 + lpy / 3 - lpy / 3 + lpy / 100)
            surface.DrawText(lname)
            surface.SetTextPos(self.Avatar:GetWide() + spacing, 2 + lpy * 2 / 3 - lpy / 3 + lpy / 100)
            surface.DrawText(lsteamid)
            surface.SetTextPos(self.Avatar:GetWide() + spacing, 2 + lpy - lpy / 3 + lpy / 100)
            surface.DrawText(lugroup)
        end

        self.Graph = self.Frame:Add("DPanel")
        self.Graph:SetSize(self.Frame:GetWide() - 20, 250)
        self.Graph:Dock(TOP)
        self.Graph:DockMargin(5, 5, 5, 0)
        local grax, gray = self.Graph:GetWide(), self.Graph:GetTall()
        local scalex, scaley = (grax - 20) / DramaSafe.MaxPercCache, (gray - 20) / 100

        self.Graph.Paint = function()
            surface.SetDrawColor(46, 49, 54, 220)
            surface.DrawRect(0, 0, grax, gray)
            surface.SetDrawColor(100, 102, 106, 220)
            surface.DrawOutlinedRect(0, 0, grax, gray)
            surface.DrawLine(10, gray - 10, grax - 10, gray - 10)
            surface.DrawLine(10, 10, 10, gray - 10)

            surface.SetTextColor(100, 102, 106)
            surface.SetFont("MenuFont")
            surface.SetTextPos(13, 1)
            surface.DrawText("Drama (%)")
            surface.SetTextPos(grax - 125, gray - 26)
            surface.DrawText("Time (seconds)")
            local i = 0
            local x, y

            surface.SetDrawColor(255, 255, 255)
            for k, v in pairs(DramaSafe.CachedPerc) do
                surface.DrawCircle(10 + scalex * i, gray - 10 - (v * scaley), 1, Color(255, 255, 255))

                if i > 0 then
                    surface.DrawLine(10 + scalex * i, gray - 10 - (v * scaley), x, y)
                end

                x, y = 10 + scalex * i, gray - 10 - (v * scaley)
                i = i + 1
            end
        end

        self.PlayerList = self.Frame:Add("DListView")
        --self.PlayerList:Dock(LEFT)
        --self.PlayerList:DockMargin(5, 5, 5, 0)
        self.PlayerList:SetPos(10, 435)
        self.PlayerList:SetSize(self.Frame:GetWide() / 2 - 15, 250)
        self.PlayerList:SetMultiSelect(false)
        self.PlayerList:AddColumn("Name")
        self.PlayerList:AddColumn("SteamID")
        self.PlayerList:AddColumn("Drama Potential")

        local wlx, wly = self.PlayerList:GetWide(), self.PlayerList:GetTall()

        self.PlayerList.Paint = function()
            surface.SetDrawColor(46, 49, 54, 220)
            surface.DrawRect(0, 0, wlx, wly)
            surface.SetDrawColor(100, 102, 106, 220)
            surface.DrawOutlinedRect(0, 0, wlx, wly)
            surface.SetTextColor(255, 255, 255)
        end

        self.PlayerList.PaintOver = function()
            surface.SetDrawColor(100, 102, 106, 220)
            surface.DrawRect(0, 0, wlx, 17)
            surface.SetTextColor(255, 255, 255, 220)
        end

        self.PlayerList.OnRowSelected = function()
            self.WatchList:ClearSelection()
        end

        local old_AddLine = self.PlayerList.AddLine
        self.PlayerList.AddLine = function(self, ...)
            local line = old_AddLine(self, ...)
            for _, column in pairs(line.Columns) do
                column:SetTextColor(Color(255, 255, 255))
                column:SetFont("MenuFont")
            end

            line.Paint = function()
                local bg = Color(46, 49, 54, 150)
                if tonumber(line:GetValue(3)) >= 70 then
                    bg = Color(46 + math.abs(math.sin(CurTime()) * 200), 49 + math.abs(math.sin(CurTime()) * 100), 54, 220)
                end

                if line:IsSelected() then
                    bg = Color(100, 102, 106, 150)
                end

                surface.SetDrawColor(bg)
                surface.DrawRect(0, 0, line:GetWide(), line:GetTall())
            end

            return line
        end

        for k, v in pairs(player.GetAll()) do
            if IsValid(v) and not DramaSafe.IsWatchListed(v) then
                self.PlayerList:AddLine(v:CapitalizeName(), v:SteamID(), tostring(v.DramaPotential or 0))
            end
        end

        self.WatchList = self.Frame:Add("DListView")
        self.WatchList:SetSize(self.Frame:GetWide() / 2 - 15, 250)
        --self.WatchList:Dock(LEFT)
        --self.WatchList:DockMargin(5, 5, 5, 0)
        self.WatchList:SetPos(5 + self.Frame:GetWide() / 2, 435)
        self.WatchList:AddColumn("Watched")
        self.WatchList:AddColumn("SteamID")
        self.WatchList:AddColumn("Drama Factor")

        for k, v in pairs(DramaSafe.WatchList) do
            if IsValid(v) then
                self.WatchList:AddLine(v:CapitalizeName(), v:SteamID(), tostring(v.DramaFactor or 0))
            end
        end

        local wl2x, wl2y = self.WatchList:GetWide(), self.WatchList:GetTall()

        self.WatchList.Paint = function()
            surface.SetDrawColor(46, 49, 54, 220)
            surface.DrawRect(0, 0, wl2x, wl2y)
            surface.SetDrawColor(100, 102, 106, 220)
            surface.DrawOutlinedRect(0, 0, wl2x, wl2y)
            surface.SetTextColor(255, 255, 255)
        end

        self.WatchList.PaintOver = function()
            surface.SetDrawColor(100, 102, 106, 220)
            surface.DrawRect(0, 0, wl2x, 17)
        end

        self.WatchList.OnRowSelected = function()
            self.PlayerList:ClearSelection()
        end

        local old_AddLine = self.WatchList.AddLine
        self.WatchList.AddLine = function(self, ...)
            local line = old_AddLine(self, ...)
            for _, column in pairs(line.Columns) do
                column:SetTextColor(Color(255, 255, 255))
                column:SetFont("MenuFont")
            end

            line.Paint = function()
                local bg = Color(46, 49, 54, 150)
                if tonumber(line:GetValue(3)) >= 70 then
                    bg = Color(46 + math.abs(math.sin(CurTime()) * 200), 49 + math.abs(math.sin(CurTime()) * 100), 54, 220)
                end

                if line:IsSelected() then
                    bg = Color(100, 102, 106, 150)
                end

                surface.SetDrawColor(bg)
                surface.DrawRect(0, 0, line:GetWide(), line:GetTall())
            end

            return line
        end

        self.WLModify = self.Frame:Add("DPanel")
        self.WLModify:SetSize(self.Frame:GetWide() - 20, 80)
        self.WLModify:SetPos(10, self.Frame:GetTall() - 90)
        self.WLModify:DockMargin(5, 5, 5, 5)
        local wlmx, wlmy = self.WLModify:GetWide(), self.WLModify:GetTall()

        self.WLModify.Paint = function()
            surface.SetDrawColor(46, 49, 54, 220)
            surface.DrawRect(0, 0, wlmx, wlmy)
            surface.SetDrawColor(100, 102, 106, 220)
            surface.DrawOutlinedRect(0, 0, wlmx, wlmy)
        end

        self.MuteChat = self.WLModify:Add("DButton")
        self.MuteChat:SetSize(wlmx / 7, wlmy - 20)
        self.MuteChat:Dock(LEFT)
        self.MuteChat:DockMargin(5, 5, 0, 5)
        self.MuteChat:SetText("")
        self.MuteChat.Text = "Mute/Unmute"

        self.MuteChat.DoClick = function()
            local line = self.PlayerList:GetLine(self.PlayerList:GetSelectedLine()) or self.WatchList:GetLine(self.WatchList:GetSelectedLine())

            if line then
                local ply = player.GetBySteamID(tostring(line:GetValue(2)))
                if not IsValid(ply) then return end

                if DramaSafe.IsMutedPlayer(ply) then
                    DramaSafe.UnMutePlayer(ply)
                else
                    DramaSafe.MutePlayer(ply)
                end
            end
        end

        local mcx, mcy = self.MuteChat:GetWide(), self.MuteChat:GetTall()

        self.MuteChat.PaintOver = function()
            local bg = Color(36, 39, 44, 220)
            local txt = Color(100, 102, 106)

            if self.MuteChat:IsHovered() then
                bg = Color(100, 102, 106, 220)
                txt = Color(255, 255, 255)
            end

            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, mcx, mcy)
            surface.SetDrawColor(txt)
            surface.DrawOutlinedRect(0, 0, mcx, mcy)
            local x, y = surface.GetTextSize(self.MuteChat.Text)
            surface.SetFont("MenuFont")
            surface.SetTextColor(txt)
            surface.SetTextPos(mcx / 2 - x / 2, mcy / 2 - y / 2)
            surface.DrawText(self.MuteChat.Text)
        end

        self.UnDraw = self.WLModify:Add("DButton")
        self.UnDraw:SetSize(wlmx / 7, wlmy - 20)
        self.UnDraw:Dock(LEFT)
        self.UnDraw:DockMargin(5, 5, 0, 5)
        self.UnDraw:SetText("")
        self.UnDraw.Text = "Hide/Unhide"

        self.UnDraw.DoClick = function()
            local line = self.PlayerList:GetLine(self.PlayerList:GetSelectedLine()) or self.WatchList:GetLine(self.WatchList:GetSelectedLine())

            if line then
                local ply = player.GetBySteamID(tostring(line:GetValue(2)))
                if not IsValid(ply) then return end

                if not DramaSafe.IsUnDrewPlayer(ply) then
                    DramaSafe.UnDrawPlayer(ply)
                else
                    DramaSafe.DrawPlayer(ply)
                end
            end
        end

        local udx, udy = self.UnDraw:GetWide(), self.UnDraw:GetTall()

        self.UnDraw.PaintOver = function()
            local bg = Color(36, 39, 44, 220)
            local txt = Color(100, 102, 106)

            if self.UnDraw:IsHovered() then
                bg = Color(100, 102, 106, 220)
                txt = Color(255, 255, 255)
            end

            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, udx, udy)
            surface.SetDrawColor(txt)
            surface.DrawOutlinedRect(0, 0, udx, udy)
            local x, y = surface.GetTextSize(self.UnDraw.Text)
            surface.SetFont("MenuFont")
            surface.SetTextColor(txt)
            surface.SetTextPos(udx / 2 - x / 2, udy / 2 - y / 2)
            surface.DrawText(self.UnDraw.Text)
        end

        self.AddWatchList = self.WLModify:Add("DButton")
        self.AddWatchList:SetSize(wlmx / 7, wlmy - 20)
        self.AddWatchList:Dock(LEFT)
        self.AddWatchList:DockMargin(5, 5, 0, 5)
        self.AddWatchList:SetText("")
        self.AddWatchList.Text = "Watch/Unwatch"

        self.AddWatchList.DoClick = function()
            local id = self.PlayerList:GetSelectedLine() or self.WatchList:GetSelectedLine()
            local line = self.PlayerList:GetLine(self.PlayerList:GetSelectedLine()) or self.WatchList:GetLine(self.WatchList:GetSelectedLine())

            if line and id then
                local ply = player.GetBySteamID(tostring(line:GetValue(2)))
                if not IsValid(ply) then return  end

                if DramaSafe.IsWatchListed(ply) then
                    DramaSafe.RemoveFromWatchList(ply)
                    local l = self.PlayerList:AddLine(ply:CapitalizeName(), ply:SteamID(), tostring(ply.DramaPotential or 0))

                    l.PaintOver = function()
                        local bg = Color(46, 49, 54)
                        local txt = Color(100, 102, 106)

                        if tonumber(l:GetValue(3)) >= 70 then
                            bg = Color(46 + math.abs(math.sin(CurTime()) * 200), 49 + math.abs(math.sin(CurTime()) * 100), 54)
                            txt = Color(200, 200, 200)
                        end

                        if l:IsSelected() then
                            bg = Color(100, 102, 106, 220)
                            txt = Color(255, 255, 255)
                        end

                        surface.SetDrawColor(bg)
                        surface.DrawRect(0, 0, l:GetWide(), l:GetTall())
                        surface.SetTextColor(txt)
                        surface.SetTextPos(2, 2)
                        surface.DrawText(l:GetValue(1))
                        surface.SetTextPos(wl2x / 3, 2)
                        surface.DrawText(l:GetValue(2))
                        surface.SetTextPos(wl2x * 2.5 / 3, 2)
                        surface.DrawText(l:GetValue(3))
                    end

                    self.WatchList:RemoveLine(id)
                else
                    DramaSafe.AddToWatchList(ply)
                    local l = self.WatchList:AddLine(ply:CapitalizeName(), ply:SteamID(), tostring(ply.DramaFactor or 1))

                    l.PaintOver = function()
                        local bg = Color(46, 49, 54, 220)
                        local txt = Color(100, 102, 106)

                        if l:IsSelected() then
                            bg = Color(100, 102, 106, 220)
                            txt = Color(255, 255, 255)
                        end

                        surface.SetDrawColor(bg)
                        surface.DrawRect(0, 0, l:GetWide(), l:GetTall())
                        surface.SetTextColor(txt)
                        surface.SetTextPos(2, 2)
                        surface.DrawText(l:GetValue(1))
                        surface.SetTextPos(wl2x / 3, 2)
                        surface.DrawText(l:GetValue(2))
                        surface.SetTextPos(wl2x * 2.45 / 3, 2)
                        surface.DrawText(l:GetValue(3))
                    end

                    self.PlayerList:RemoveLine(id)
                end
            end
        end

        local awx, awy = self.AddWatchList:GetWide(), self.AddWatchList:GetTall()

        self.AddWatchList.PaintOver = function()
            local bg = Color(36, 39, 44, 220)
            local txt = Color(100, 102, 106)

            if self.AddWatchList:IsHovered() then
                bg = Color(100, 102, 106, 220)
                txt = Color(255, 255, 255)
            end

            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, awx, awy)
            surface.SetDrawColor(txt)
            surface.DrawOutlinedRect(0, 0, awx, awy)
            local x, y = surface.GetTextSize(self.AddWatchList.Text)
            surface.SetFont("MenuFont")
            surface.SetTextColor(txt)
            surface.SetTextPos(awx / 2 - x / 2, awy / 2 - y / 2)
            surface.DrawText(self.AddWatchList.Text)
        end
    end,
}

local DRAMA_SAFE_PANEL = vgui.RegisterTable(PANEL, "EditablePanel")

DramaSafe.Menu = function()
    vgui.CreateFromTable(DRAMA_SAFE_PANEL)
end

DramaSafe.Status = function()
    local perc = DramaSafe.DramaPerc

    if perc < 25 then
        return "SAFE", Color(53, 125, 188)
    elseif perc >= 25 and perc < 50 then
        return "AVERAGE", Color(92, 184, 92)
    elseif perc >= 50 and perc < 75 then
        return "DANGEROUS", Color(238, 162, 54)
    else
        return "DRAMATIC", Color(209, 62, 57)
    end
end

concommand.Add("dsgui", DramaSafe.Menu)