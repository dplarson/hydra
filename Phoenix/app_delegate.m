#import <Cocoa/Cocoa.h>

#import "lua/lauxlib.h"
#import "lua/lualib.h"

int hotkey_setup(lua_State *L);
int hotkey_register(lua_State *L);
int hotkey_unregister(lua_State *L);

int app_running_apps(lua_State* L);
int app_get_windows(lua_State* L);
int app_title(lua_State* L);
int app_show(lua_State* L);
int app_hide(lua_State* L);
int app_kill(lua_State* L);
int app_kill9(lua_State* L);
int app_is_hidden(lua_State* L);

int mouse_get(lua_State* L);
int mouse_set(lua_State* L);

int open_at_login_get(lua_State* L);
int open_at_login_set(lua_State* L);

int alert_show(lua_State* L);

int menu_icon_show(lua_State* L);
int menu_icon_hide(lua_State* L);

int path_watcher_stop(lua_State* L);
int path_watcher_start(lua_State* L);

static const luaL_Reg phoenix_lib[] = {
    {"hotkey_setup", hotkey_setup},
    {"hotkey_register", hotkey_register},
    {"hotkey_unregister", hotkey_unregister},
    
    {"app_running_apps", app_running_apps},
    {"app_get_windows", app_get_windows},
    {"app_title", app_title},
    {"app_show", app_show},
    {"app_hide", app_hide},
    {"app_kill", app_kill},
    {"app_kill9", app_kill9},
    {"app_is_hidden", app_is_hidden},
    
    {"mouse_get", mouse_get},
    {"mouse_set", mouse_set},
    
    {"open_at_login_get", open_at_login_get},
    {"open_at_login_set", open_at_login_set},
    
    {"alert_show", alert_show},
    
    {"menu_icon_show", menu_icon_show},
    {"menu_icon_hide", menu_icon_hide},
    
    {"path_watcher_stop", path_watcher_stop},
    {"path_watcher_start", path_watcher_start},
    
    {NULL, NULL}
};


@interface PHAppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation PHAppDelegate

- (void) complainIfNeeded {
    BOOL enabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)@{(__bridge id)kAXTrustedCheckOptionPrompt: @(YES)});
    
    if (!enabled) {
        NSRunAlertPanel(@"Enable Accessibility First",
                        @"Find the little popup right behind this one, click \"Open System Preferences\" and enable Phoenix. Then launch Phoenix again.",
                        @"Quit",
                        nil,
                        nil);
        [NSApp terminate:self];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self complainIfNeeded];
    
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    luaL_newlib(L, phoenix_lib);
    lua_setglobal(L, "__api");
    
    NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
    NSString* initFile = [bundlePath stringByAppendingPathComponent:@"phoenix_init.lua"];
    
    luaL_loadfile(L, [initFile fileSystemRepresentation]);
    lua_pushstring(L, [bundlePath fileSystemRepresentation]);
    lua_pcall(L, 1, LUA_MULTRET, 0);
}

@end