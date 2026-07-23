#include "ScriptMgr.h"
#include "Chat.h"
#include "ChatCommand.h"
#include "DB2Stores.h"
#include "Player.h"
#include "RBAC.h"
#include "Unit.h"
#include "WorldSession.h"
#include <limits>

using namespace Trinity::ChatCommands;

class custom_command_animkit : public CommandScript
{
public:
    custom_command_animkit() : CommandScript("custom_command_animkit") { }

    std::span<ChatCommandBuilder const> GetCommands() const override
    {
        static ChatCommandTable commandTable =
        {
            { "ak", HandleAnimKitLoopCommand, rbac::RBAC_PERM_COMMAND_DEBUG, Console::No },
            { "aks", HandleAnimKitOneShotCommand, rbac::RBAC_PERM_COMMAND_DEBUG, Console::No }
        };

        return commandTable;
    }

    using MeSpecifier = EXACT_SEQUENCE("me");

    static Unit* GetCommandTarget(ChatHandler* handler, Optional<MeSpecifier> const& me)
    {
        if (WorldSession* session = handler->GetSession())
        {
            Player* player = session->GetPlayer();
            if (me)
                return player;

            if (Unit* target = handler->getSelectedUnit())
                return target;

            return player;
        }

        return nullptr;
    }

    static bool ValidateAnimKit(ChatHandler* handler, uint32 animKitId)
    {
        if (animKitId > std::numeric_limits<uint16>::max())
        {
            handler->PSendSysMessage("AnimKit ID %u is out of range for TrinityCore unit packets.", animKitId);
            handler->SetSentErrorMessage(true);
            return false;
        }

        if (animKitId != 0 && !sAnimKitStore.LookupEntry(static_cast<uint16>(animKitId)))
        {
            handler->PSendSysMessage("AnimKit ID %u was not found in AnimKit.db2.", animKitId);
            handler->SetSentErrorMessage(true);
            return false;
        }

        return true;
    }

    static bool HandleAnimKitLoopCommand(ChatHandler* handler, Optional<MeSpecifier> me, uint32 animKitId)
    {
        if (!ValidateAnimKit(handler, animKitId))
            return false;

        Unit* target = GetCommandTarget(handler, me);
        if (!target)
        {
            handler->SendSysMessage("No valid target selected.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        target->SetAIAnimKitId(static_cast<uint16>(animKitId));

        if (animKitId == 0)
            handler->PSendSysMessage("Cleared persistent AnimKit on %s.", target->GetName().c_str());
        else
            handler->PSendSysMessage("Playing persistent AnimKit %u on %s.", animKitId, target->GetName().c_str());

        return true;
    }

    static bool HandleAnimKitOneShotCommand(ChatHandler* handler, Optional<MeSpecifier> me, uint32 animKitId)
    {
        if (!ValidateAnimKit(handler, animKitId))
            return false;

        if (animKitId == 0)
        {
            handler->SendSysMessage("One-shot AnimKit requires a non-zero AnimKit ID.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        Unit* target = GetCommandTarget(handler, me);
        if (!target)
        {
            handler->SendSysMessage("No valid target selected.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        target->PlayOneShotAnimKitId(static_cast<uint16>(animKitId));
        handler->PSendSysMessage("Playing one-shot AnimKit %u on %s.", animKitId, target->GetName().c_str());
        return true;
    }
};

void AddSC_custom_command_animkit()
{
    new custom_command_animkit();
}
