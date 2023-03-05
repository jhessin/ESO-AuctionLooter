AuctionLooter = AuctionLooter or {}

AuctionLooter.name = 'AuctionLooter'

local auctionMails = {}

local function lootMails()
	if #auctionMails == 0 then
		d(AuctionLooter.name .. ": Auction Looting Complete")
		return
	end
	local mailId = auctionMails[1]
	local currentWorkingMail = mailId
	local requestResult = RequestReadMail(mailId)
	zo_callLater(function()
		if currentWorkingMail == mailId and not IsReadMailInfoReady(mailId) then
			RequestReadMail(mailId)
		end
	end, 100)
end

local function findLootableMails()
	---@diagnostic disable-next-line: missing-parameter
	local nextMail = GetNextMailId()
	if not nextMail then
		EVENT_MANAGER:UnregisterForEvent(AuctionLooter.name, EVENT_MAIL_READABLE)
		return
	end

	while nextMail do
		---@diagnostic disable-next-line: param-type-mismatch
		local _, _, subject, _, _, system, customer, _, numAtt, money = GetMailItemInfo(nextMail)
		if not customer and system then
			table.insert(auctionMails, nextMail)
		end
		---@diagnostic disable-next-line: param-type-mismatch
		nextMail = GetNextMailId(nextMail)
	end

	if #auctionMails > 0 then
		d(AuctionLooter.name .. ": " .. #auctionMails .. ' auction mails found')
		zo_callLater(lootMails, 10)
	else
		EVENT_MANAGER:UnregisterForEvent(AuctionLooter.name, EVENT_MAIL_READABLE)
	end
end

local lootReadMail
local function deleteLootedMail(mailId)
	local _, _, subject, _, _, system, customer, _, numAtt, money = GetMailItemInfo(mailId)
	---@diagnostic disable-next-line: missing-parameter
	if numAtt > 0 and FindFirstEmptySlotInBag() then
		lootReadMail(1, mailId)
		return
	end
	---@diagnostic disable-next-line: param-type-mismatch
	DeleteMail(mailId, true)
	if auctionMails[1] == mailId then
		table.remove(auctionMails, 1)
		zo_callLater(lootMails, 250)
	end
	table.remove(auctionMails, mailId)
end

function lootReadMail(_, mailId)
	if not IsReadMailInfoReady(mailId) then
		zo_callLater(lootMails, 10)
		return
	end
	local _, _, _, _, _, system, customer, _, numAtt, money = GetMailItemInfo(mailId)
	if not customer and system then
		if money > 0 then
			ZO_MailInboxShared_TakeAll(mailId)
			zo_callLater(function() deleteLootedMail(mailId) end, 250)
			return
			---@diagnostic disable-next-line: missing-parameter
		elseif numAtt > 0 and FindFirstEmptySlotInBag() then
			ZO_MailInboxShared_TakeAll(mailId)
			zo_callLater(function() deleteLootedMail(mailId) end, 250)
			return
			---@diagnostic disable-next-line: missing-parameter
		elseif FindFirstEmptySlotInBag() == nil and numAtt > 0 then
			return
		else
			deleteLootedMail(mailId)
			return
		end
	end
end

local function lootAuctions()
	d('Looting mail...')
	EVENT_MANAGER:RegisterForEvent(AuctionLooter.name, EVENT_MAIL_REMOVED, function(_, mailId)
		if auctionMails[1] == mailId then
			table.remove(auctionMails, 1)
			if #auctionMails == 0 then
				d('Finished looting Mail')
			else
				lootMails()
			end
		end
	end
	)
	EVENT_MANAGER:RegisterForEvent(AuctionLooter.name, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS,
		function(_, mailId --[[ id64 ]])
			for k, v in pairs(auctionMails) do
				if v == mailId then
					local _, _, sub = GetMailItemInfo(mailId)
					table.remove(auctionMails, k)
				end
			end
		end
	)
	findLootableMails()
	EVENT_MANAGER:RegisterForEvent(AuctionLooter.name, EVENT_MAIL_READABLE, lootReadMail)
end

-- EVENT_MANAGER:RegisterForEvent(AuctionLooter.name, EVENT_MAIL_OPEN_MAILBOX, function() lootAuctions() end)

SLASH_COMMANDS['/lootAuctions'] = function()
	CloseMailbox()
	RequestOpenMailbox()
	lootAuctions()
end
