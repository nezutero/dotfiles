{ pkgs, ... }:

# modules/home/dwl/default.nix
#
# Replaces both modules/home/hyprland and modules/home/waybar.
# Home-manager options only.
#
# NOTE: the dwl patch below references `cursor_hide_timeout`, which must exist
# in config.h or the build fails with an undeclared-identifier error. Add:
#     static const uint32_t cursor_hide_timeout = 3000;

let
  # ------------------------------------------------------------------ dwlb --
  # 1. Tighter horizontal padding around tags. Stock is font->height / 2,
  #    applied on BOTH sides of every element, which makes tag cells chunky.
  # 2. A 1px top border in #3c3836 with a 1px gap below it. The gap cannot
  #    come from -vertical-padding: dwlb draws every text background with
  #    .y1 = 0, .y2 = buf_height, so the tag highlight runs edge to edge no
  #    matter how much padding you add. So paint over the top 2 logical
  #    pixels instead - black for the gap, border colour on top of that.
  #    Pair this with -vertical-padding 2 in dwl-start, or the painted band
  #    clips the tops of the glyphs.
  dwlb = pkgs.dwlb.overrideAttrs (old: {
    postPatch = ''
      ${old.postPatch or ""}
      substituteInPlace dwlb.c \
        --replace-fail 'textpadding = font->height / 2;' \
                       'textpadding = font->height / 3;'

      substituteInPlace dwlb.c \
        --replace-fail 'pixman_image_composite32(PIXMAN_OP_OVER, foreground, foreground_mask, final, 0, 0, 0, 0, 0, 0, bar->width, bar->height);' \
                       'pixman_image_composite32(PIXMAN_OP_OVER, foreground, foreground_mask, final, 0, 0, 0, 0, 0, 0, bar->width, bar->height);
    pixman_image_fill_boxes(PIXMAN_OP_SRC, final,
        &(pixman_color_t){ 0x0000, 0x0000, 0x0000, 0xffff }, 1,
        &(pixman_box32_t){ .x1 = 0, .x2 = bar->width,
                           .y1 = 0, .y2 = buffer_scale * 2 });
    pixman_image_fill_boxes(PIXMAN_OP_SRC, final,
        &(pixman_color_t){ 0x3c3c, 0x3838, 0x3636, 0xffff }, 1,
        &(pixman_box32_t){ .x1 = 0, .x2 = bar->width,
                           .y1 = 0, .y2 = buffer_scale });'
    '';
  });

  # ------------------------------------------------------------------- dwl --
  # Three edits, none of which upstream supports:
  #
  # 1. Keyboard layout indicator. dwl 0.8 exposes the active xkb group through
  #    no protocol, so write it to $XDG_RUNTIME_DIR/dwl-layout for the bar to
  #    read. keypressmod fires on layout-group changes as well as modifiers;
  #    the static guard keeps this to one write per real change rather than
  #    one per keystroke.
  #
  # 2 & 3. Cursor autohide (= hyprland's cursor { inactive_timeout }). The
  #    timer rearms from inside `if (time)`, so only real pointer motion
  #    counts - dwl calls motionnotify with time = 0 to restore focus after
  #    tag switches and window maps. Hiding uses wlr_cursor_set_surface(NULL),
  #    which dwl already uses elsewhere. The clear_focus on unhide makes the
  #    client re-request its cursor image (dwl's own comment in setcursor
  #    explains the leave/enter idiom) - without it, unhiding over a terminal
  #    would show the default arrow instead of the I-beam.
  #
  # All three anchors are free of leading whitespace, so tabs mangled on paste
  # cannot break them.
  dwl = (pkgs.dwl.override { configH = ./config.h; }).overrideAttrs (old: {
    postPatch = ''
      ${old.postPatch or ""}
      substituteInPlace dwl.c \
        --replace-fail '&group->wlr_group->keyboard.modifiers);' \
                       '&group->wlr_group->keyboard.modifiers);
	{
		static int32_t lastlayout = -1;
		struct xkb_keymap *km = group->wlr_group->keyboard.keymap;
		xkb_layout_index_t idx = xkb_state_serialize_layout(
				group->wlr_group->keyboard.xkb_state,
				XKB_STATE_LAYOUT_EFFECTIVE);
		if (km && (int32_t)idx != lastlayout) {
			const char *nm = xkb_keymap_layout_get_name(km, idx);
			const char *rt = getenv("XDG_RUNTIME_DIR");
			char path[512];
			FILE *fp;
			lastlayout = (int32_t)idx;
			if (rt) {
				snprintf(path, sizeof path, "%s/dwl-layout", rt);
				if ((fp = fopen(path, "w"))) {
					fprintf(fp, "%u %s\n", idx, nm ? nm : "");
					fclose(fp);
				}
			}
		}
	}'

      substituteInPlace dwl.c \
        --replace-fail 'void
motionnotify(uint32_t time, struct wlr_input_device *device, double dx, double dy,' \
                       'static struct wl_event_source *cursor_hide_source;
static int cursor_hidden;

int
hidecursor(void *data)
{
	wlr_cursor_set_surface(cursor, NULL, 0, 0);
	cursor_hidden = 1;
	return 1;
}

void
motionnotify(uint32_t time, struct wlr_input_device *device, double dx, double dy,'

      substituteInPlace dwl.c \
        --replace-fail 'wlr_cursor_move(cursor, device, dx, dy);' \
                       'wlr_cursor_move(cursor, device, dx, dy);
		if (cursor_hide_timeout) {
			if (cursor_hidden) {
				cursor_hidden = 0;
				wlr_cursor_set_xcursor(cursor, cursor_mgr, "default");
				wlr_seat_pointer_notify_clear_focus(seat);
			}
			if (!cursor_hide_source)
				cursor_hide_source = wl_event_loop_add_timer(
						event_loop, hidecursor, NULL);
			wl_event_source_timer_update(cursor_hide_source,
					(int)cursor_hide_timeout);
		}'
    '';
  });

  # --------------------------------------------------------------- scripts --
  dwl-status = pkgs.writeShellApplication {
    name = "dwl-status";
    runtimeInputs = with pkgs; [ coreutils gawk wireplumber ];
    text = builtins.readFile ../../../scripts/dwl-status.sh;
  };

  # dwlb and dwl-status are let bindings, not pkgs names, so dwl-start is
  # pinned to the PATCHED dwlb and does not depend on greetd's PATH.
  dwl-start = pkgs.writeShellApplication {
    name = "dwl-start";
    runtimeInputs = (with pkgs; [
      coreutils
      wbg
      dunst
      swayidle
      swaylock
      wlr-randr
      cliphist
      wl-clipboard
      wlsunset
    ]) ++ [ dwlb dwl-status ];
    text = builtins.readFile ../../../scripts/dwl-start.sh;
  };
in
{
  # Plain list, no `with pkgs;` - that is what stops a stray
  # (dwl.override { configH = ...; }) from reappearing here and silently
  # installing an unpatched build.
  home.packages = [
    dwl
    dwlb
    pkgs.wlr-randr
    dwl-status
    dwl-start
  ];
}
