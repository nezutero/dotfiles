/* dwl 0.8 config.h - a port of your Hyprland setup.
 *
 * Every Super+<key> binding you had in Hyprland is on the same key here.
 * dwl's own window management was moved onto keys you weren't using
 * (Super+Shift+arrows, Super+t/y/u) so nothing of yours had to be given up.
 *
 * Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const uint32_t cursor_hide_timeout = 3000;

/* appearance */
static const int sloppyfocus               = 1;  /* = your follow_mouse = 1 */
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 0;  /* = your border_size = 0.
                                                    Set 1 or 2 if you want to
                                                    see which window is focused;
                                                    with 0 the only focus hint
                                                    is dwlb's title area. */
/* kanagawa, from your waybar style.css */
static const float rootcolor[]     = COLOR(0x000000ff);
static const float bordercolor[]   = COLOR(0x3c3836ff);
static const float focuscolor[]    = COLOR(0x76946aff);
static const float urgentcolor[]   = COLOR(0xc34043ff);
static const float fullscreen_bg[] = {0.0f, 0.0f, 0.0f, 1.0f};

/* tagging - TAGCOUNT must be no greater than 31.
 * Your Hyprland had 10 workspaces; dwl tags are capped per the bitmask and 9
 * is the conventional count. Super+0 shows all tags at once instead of a
 * tenth workspace. */
#define TAGCOUNT (10)

/* logging */
static int log_level = WLR_ERROR;

static const Rule rules[] = {
	/* app_id       title   tags mask   isfloating   monitor */
	{ "pavucontrol", NULL,  0,          1,           -1 },
	/* at least one rule must exist */
};

/* layout(s) - dwl has no dwindle; tile is the closest equivalent */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "",         tile },
	{ "",         NULL },    /* no layout function means floating behavior */
	{ "",         monocle },
};

/* monitors
 * = your monitor = eDP-1,1920x1080@60,0x0,1.2
 * dwl always picks the output's preferred mode, so only the scale is set here.
 * If 1920x1080@60 is not the preferred mode, set it at runtime with wlr-randr. */
static const MonitorRule monrules[] = {
	/* name     mfact  nmaster scale layout       rotate/reflect                x    y */
	{ "eDP-1",  0.55f, 1,      1.2f, &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
	{ NULL,     0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
	/* the NULL rule must stay last */
};

/* keyboard = your kb_layout / kb_options.
 * Note the options string has no space after the comma - xkbcommon is stricter
 * about that than hyprland was. */
static const struct xkb_rule_names xkb_rules = {
	.layout  = "us,ca",
	.options = "caps:escape,grp:alt_space_toggle",
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 1;   /* = your touchpad.natural_scroll */
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;

static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = -0.1;   /* = your input.sensitivity */
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* = your $mainMod = SUPER */
#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands - your hyprland $variables.
 * Anything with a ~, a pipe or an env var goes through SHCMD instead, because
 * a bare argv array gets no shell and so no expansion. */
static const char *termcmd[]     = { "foot", NULL };
static const char *menucmd[]     = { "rofi", "-show", "drun", NULL };
static const char *browsercmd[]  = { "zen-beta", NULL };
static const char *filemgrcmd[]  = { "foot", "-e", "yazi", NULL };
static const char *btcmd[]       = { "rofi-bluetooth", NULL };
static const char *ytcmd[]       = { "youtube-mpv", NULL };
static const char *pdfcmd[]      = { "zathura-rofi", NULL };
static const char *passcmd[]     = { "rofipass", NULL };
static const char *discordcmd[]  = { "vesktop", NULL };
static const char *signalcmd[]   = { "signal-desktop", NULL };
static const char *lockcmd[]     = { "swaylock", "-f", NULL };
static const char *powercmd[]    = { "rofi", "-show", "power-menu",
                                     "-modi", "power-menu:rofi-power-menu", NULL };
/* was: waybar / pkill waybar. dwlb stays running and just hides. */
static const char *barshowcmd[]  = { "dwlb", "-show", "all", NULL };
static const char *barhidecmd[]  = { "dwlb", "-hide", "all", NULL };
/* your existing dotfiles scripts, unchanged */
static const char *volupcmd[]    = { "volume", "up", NULL };
static const char *voldncmd[]    = { "volume", "down", NULL };
static const char *volmutecmd[]  = { "volume", "mute", NULL };
static const char *micmutecmd[]  = { "wpctl", "set-mute", "@DEFAULT_SOURCE@", "toggle", NULL };
static const char *blupcmd[]     = { "backlight", "up", NULL };
static const char *bldncmd[]     = { "backlight", "down", NULL };
static const char *blmaxcmd[]    = { "backlight", "max", NULL };
static const char *blmincmd[]    = { "backlight", "min", NULL };
static const char *tempupcmd[]   = { "temperature", "up", NULL };
static const char *tempdncmd[]   = { "temperature", "down", NULL };

static const Key keys[] = {
	/* Note that Shift changes certain key codes: 2 -> at, etc. */
	/* modifier                  key                  function          argument */

	/* ---------------- your hyprland binds, same keys ---------------- */
	{ MODKEY,                    XKB_KEY_Return,      spawn,            {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_space,       spawn,            {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_f,           spawn,            {.v = browsercmd} },
	{ MODKEY,                    XKB_KEY_w,           killclient,       {0} },
	{ MODKEY,                    XKB_KEY_e,           spawn,            {.v = filemgrcmd} },
	{ MODKEY,                    XKB_KEY_b,           spawn,            {.v = btcmd} },
	{ MODKEY,                    XKB_KEY_h,           spawn,            {.v = ytcmd} },
	{ MODKEY,                    XKB_KEY_r,           spawn,            {.v = pdfcmd} },
	{ MODKEY,                    XKB_KEY_p,           spawn,            {.v = passcmd} },
	{ MODKEY,                    XKB_KEY_d,           spawn,            {.v = discordcmd} },
	{ MODKEY,                    XKB_KEY_g,           spawn,            {.v = signalcmd} },
	{ MODKEY,                    XKB_KEY_l,           spawn,            {.v = lockcmd} },
	{ MODKEY,                    XKB_KEY_m,           spawn,            {.v = barshowcmd} },
	{ MODKEY,                    XKB_KEY_k,           spawn,            {.v = barhidecmd} },
	{ MODKEY,                    XKB_KEY_n,           spawn,            SHCMD("foot -D ~/notes -e nvim .") },
	{ MODKEY,                    XKB_KEY_s,           spawn,            SHCMD("foot --title rmpc -e sh -c 'rmpc update && rmpc'") },
	{ MODKEY,                    XKB_KEY_a,           spawn,            SHCMD("GDK_BACKEND=x11 audacity") },
	{ MODKEY,                    XKB_KEY_c,           spawn,            SHCMD("cliphist list | rofi -dmenu | cliphist decode | wl-copy") },

	/* focus. dwl has no directional focus, so left/up step back through the
	 * stack and right/down step forward. */
	{ MODKEY,                    XKB_KEY_Left,        focusstack,       {.i = -1} },
	{ MODKEY,                    XKB_KEY_Up,          focusstack,       {.i = -1} },
	{ MODKEY,                    XKB_KEY_Right,       focusstack,       {.i = +1} },
	{ MODKEY,                    XKB_KEY_Down,        focusstack,       {.i = +1} },

	/* = your Super+TAB, workspace prev */
	{ MODKEY,                    XKB_KEY_Tab,         view,             {0} },

	/* screenshots, unchanged apart from dropping the hyprctl focus hack */
	{ 0,                         XKB_KEY_Print,       spawn,            SHCMD("grim -g \"$(slurp)\" - | wl-copy -t image/png && dunstify -a Screenshot -u low -r 9001 -t 1500 'Screenshot' 'Copied to clipboard'") },
	{ MODKEY,                    XKB_KEY_Print,       spawn,            SHCMD("mkdir -p ~/Pictures/Screenshots && F=~/Pictures/Screenshots/$(date +%Y-%m-%d-%H-%M-%S).png && grim -g \"$(slurp)\" \"$F\" && dunstify -a Screenshot -u low -r 9002 -t 1500 'Screenshot Saved' \"$F\"") },

	/* media and function keys */
	{ 0,                         XKB_KEY_XF86AudioRaiseVolume,  spawn,  {.v = volupcmd} },
	{ 0,                         XKB_KEY_XF86AudioLowerVolume,  spawn,  {.v = voldncmd} },
	{ 0,                         XKB_KEY_XF86AudioMute,         spawn,  {.v = volmutecmd} },
	{ 0,                         XKB_KEY_XF86AudioMicMute,      spawn,  {.v = micmutecmd} },
	{ 0,                         XKB_KEY_XF86MonBrightnessUp,   spawn,  {.v = blupcmd} },
	{ 0,                         XKB_KEY_XF86MonBrightnessDown, spawn,  {.v = bldncmd} },
	{ MODKEY,                    XKB_KEY_XF86MonBrightnessUp,   spawn,  {.v = blmaxcmd} },
	{ MODKEY,                    XKB_KEY_XF86MonBrightnessDown, spawn,  {.v = blmincmd} },
	{ WLR_MODIFIER_CTRL,         XKB_KEY_XF86MonBrightnessUp,   spawn,  {.v = tempupcmd} },
	{ WLR_MODIFIER_CTRL,         XKB_KEY_XF86MonBrightnessDown, spawn,  {.v = tempdncmd} },
	{ 0,                         XKB_KEY_XF86Favorites,         spawn,  {.v = powercmd} },
	{ 0,                         XKB_KEY_XF86Tools,             spawn,  SHCMD("foot -D ~/dotfiles -e nvim .") },

	/* ---------------- dwl window management ----------------
	 * Moved onto keys your hyprland config left free. */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,      zoom,             {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,       togglefloating,   {0} },
	{ MODKEY,                    XKB_KEY_t,           setlayout,        {.v = &layouts[0]} },  /* tile */
	{ MODKEY,                    XKB_KEY_u,           setlayout,        {.v = &layouts[1]} },  /* floating */
	{ MODKEY,                    XKB_KEY_y,           setlayout,        {.v = &layouts[2]} },  /* monocle */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Left,        setmfact,         {.f = -0.05f} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Right,       setmfact,         {.f = +0.05f} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Up,          incnmaster,       {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Down,        incnmaster,       {.i = -1} },

	/* Fullscreen. Both spellings are listed on purpose: dwl 0.8 is
	 * inconsistent about whether a Shift binding wants the plain or the
	 * shifted keysym (compare Shift+c below with the shifted TAGKEYS). Only
	 * the first match ever fires, so the spare line costs nothing. Use the
	 * same trick for any Shift+letter binding you add. */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_f,           togglefullscreen, {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_F,           togglefullscreen, {0} },

	/* dwl defaults kept as upstream wrote them */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_c,           killclient,       {0} },
    // { MODKEY,                    XKB_KEY_0,           view,             {.ui = ~0} },
	// { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright,  tag,              {.ui = ~0} },
	{ MODKEY,                    XKB_KEY_comma,       focusmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_period,      focusmon,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,        tagmon,           {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,     tagmon,           {.i = WLR_DIRECTION_RIGHT} },

	/* = your Super+1..9 and Super+Shift+1..9 */
	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                        0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                            1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                    2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                        3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                       4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                   5),
	TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                     6),
	TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                      7),
	TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                     8),
    TAGKEYS(          XKB_KEY_0, XKB_KEY_parenright,                    9),

	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q,           quit,             {0} },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

/* = your bindm: Super+left-drag moves, Super+right-drag resizes */
static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
