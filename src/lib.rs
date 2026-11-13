//! An example plugin: a tool window beside Artoo's own, and a service other plugins can ask for.
//!
//! Everything comes from the SDK: GPUI, Artoo's design kit, and the contracts of its features.

mod greeting;

use artoo_plugin_sdk::gpui::{App, Context, Render, Window, div, prelude::*};
use artoo_plugin_sdk::kit::{px, theme};
use artoo_plugin_sdk::shell::{Parts, Tool, add_parts};
use artoo_plugin_sdk::{self as sdk, Meta};
use std::cell::Cell;
use std::rc::Rc;

sdk::plugin!(
    Meta {
        id: env!("CARGO_PKG_NAME"),
        name: "My plugin",
        version: env!("CARGO_PKG_VERSION"),
        repository: env!("CARGO_PKG_REPOSITORY"),
        // What it offers other plugins, and what it needs of them, as `name@major`. One that needs what no plugin
        // offers is not loaded, and Settings → Plugins says why.
        provides: &[greeting::SERVICE],
        requires: &[],
    },
    install
);

/// Runs once, as Artoo starts. Add what the plugin brings here; anything it does later happens through what it adds.
fn install(cx: &mut App) {
    greeting::offer(cx);
    add_parts(cx, |_frame, _window, cx| {
        let view = cx.new(|_| Panel { clicks: 0 });
        Parts {
            tool: Some(Tool {
                id: env!("CARGO_PKG_NAME"),
                icon: "layers",
                tip: "My plugin",
                title: "My plugin",
                heading: None,
                spaces: &[],
                not_in: &[],
                on_pages: false,
                stripe: true,
                order: 50,
                badge: None,
                count: None,
                view: view.into(),
                opened: Rc::new(|_| {}),
                closed: Rc::new(|_| {}),
                typing: Rc::new(Cell::new(false)),
                key: Rc::new(|_, _, _| {}),
                list_key: None,
            }),
            ..Default::default()
        }
    });
}

struct Panel {
    clicks: usize,
}

impl Render for Panel {
    fn render(&mut self, _: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        div()
            .id("my-plugin-panel")
            .p(px(14.))
            .text_color(theme::text())
            .cursor_pointer()
            .child(format!("{} — clicked {} times", greeting::text(), self.clicks))
            .on_click(cx.listener(|this, _, _, cx| {
                this.clicks += 1;
                cx.notify();
            }))
    }
}
