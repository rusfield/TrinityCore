#include "Chat.h"
#include "ChatCommand.h"
#include "Creature.h"
#include "Log.h"
#include "RBAC.h"
#include "ScriptMgr.h"
#include "SmartAI.h"
#include "SmartScriptMgr.h"

using namespace Trinity::ChatCommands;

class custom_command_reload_smart_scripts : public CommandScript
{
public:
    custom_command_reload_smart_scripts() : CommandScript("custom_command_reload_smart_scripts") { }

    std::span<ChatCommandBuilder const> GetCommands() const override
    {
        static ChatCommandTable commandTable =
        {
            { "rss", HandleReloadSmartScriptsShortcut, rbac::RBAC_PERM_COMMAND_RELOAD_SMART_SCRIPTS, Console::No }
        };

        return commandTable;
    }

    static bool RebuildSelectedSmartAI(ChatHandler* handler, Creature* creature)
    {
        if (!creature)
            return true;

        if (!dynamic_cast<SmartAI*>(creature->AI()) && creature->GetAIName() != "SmartAI")
        {
            handler->PSendSysMessage("Selected creature %s (entry %u) is not using SmartAI.", creature->GetName().c_str(), creature->GetEntry());
            handler->SetSentErrorMessage(true);
            return false;
        }

        // Mirror Trinity's AI hot-swap flow so we do not leave stale events or script state behind.
        creature->m_Events.KillAllEvents(false);

        if (creature->IsCharmed())
            creature->RemoveCharmedBy(nullptr);

        if (creature->IsAlive() && creature->AI())
            creature->AI()->EnterEvadeMode(EvadeReason::Other);

        if (!creature->AIM_Destroy())
        {
            handler->PSendSysMessage("Failed to destroy the current AI for %s (entry %u).", creature->GetName().c_str(), creature->GetEntry());
            handler->SetSentErrorMessage(true);
            return false;
        }

        if (!creature->AIM_Initialize() || !creature->AI())
        {
            handler->PSendSysMessage("Failed to recreate SmartAI for %s (entry %u).", creature->GetName().c_str(), creature->GetEntry());
            handler->SetSentErrorMessage(true);
            return false;
        }

        if (creature->IsAlive())
            creature->AI()->EnterEvadeMode(EvadeReason::Other);

        handler->PSendSysMessage("Rebuilt SmartAI for %s (entry %u).", creature->GetName().c_str(), creature->GetEntry());
        return true;
    }

    static bool HandleReloadSmartScriptsShortcut(ChatHandler* handler)
    {
        TC_LOG_INFO("misc", "Re-Loading Smart Scripts...");
        sSmartScriptMgr->LoadSmartAIFromDB();

        Creature* target = handler->getSelectedCreature();
        if (!target)
        {
            handler->SendSysMessage("Smart Scripts reloaded. No creature selected, so no live SmartAI was rebuilt.");
            return true;
        }

        if (!RebuildSelectedSmartAI(handler, target))
            return false;

        handler->PSendSysMessage("Smart Scripts reloaded and applied to %s.", target->GetName().c_str());
        return true;
    }
};

void AddSC_custom_command_reload_smart_scripts()
{
    new custom_command_reload_smart_scripts();
}
