//! A service: what this plugin offers other plugins. One that lists `SERVICE` in its `requires` is installed after
//! this one, and asks for it with `services::service::<Greeting>(cx, SERVICE)`.

use artoo_plugin_sdk::gpui::App;
use artoo_plugin_sdk::services;
use std::rc::Rc;

/// Its name and major version: a change that breaks those who use it is a new major.
pub const SERVICE: &str = "my-artoo-plugin.greeting@1";

pub type Greeting = Rc<dyn Fn() -> String>;

pub fn text() -> &'static str {
    "Hello from a plugin"
}

pub fn offer(cx: &mut App) {
    let greeting: Greeting = Rc::new(|| text().to_owned());
    services::offer(cx, SERVICE, greeting);
}
