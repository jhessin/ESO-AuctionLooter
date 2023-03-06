global d: function(...: any)
global RequestReadMail: function(integer)

global zo_callLater: function(function, integer)

global IsReadMailInfoReady: function(integer): boolean

global GetNextMailId: function(integer | nil): integer | nil

global EVENT_MAIL_READABLE: function(any, integer)
global EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS: function(any, integer)
global EVENT_MAIL_REMOVED: function(any, integer)

global record EVENT_MANAGER
	UnregisterForEvent: function(EVENT_MANAGER, any, function)
	RegisterForEvent: function(EVENT_MANAGER, any, any, function)
end

global BAG_BACKPACK: number

global GetMailItemInfo: function(number): string, string, string, string, boolean, boolean, boolean, boolean, number, number, number, number | nil, number

global FindFirstEmptySlotInBag: function(number): number | nil

global DeleteMail: function(number, boolean)

global ZO_MailInboxShared_TakeAll: function(integer)

global SLASH_COMMANDS: {string: function}

global CloseMailbox: function()

global RequestOpenMailbox: function()