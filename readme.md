# reactive-q
*An experimental library for signal-based reactivity in Q-SYS Lua*

[Download](https://github.com/locimation/reactive-q/archive/refs/heads/main.zip) and install as a [design resource](https://q-syshelp.qsc.com/#Control_Scripting/External_Lua_Modules.htm).


## Usage

When this library is loaded, Q-SYS controls are turned into signals.

You can then use them via the `q()` function like so:

```lua
q(function()
  Controls.LED.Value = Controls.Button.Value;
end);
```
whereby the *LED* control will now always get the value of *Button*.

Named components are also supported:
```lua
local my_external_component = Component.New('test');
q(function()
  print(my_external_component['text.1'].String);
end)
```
or
```lua
q(function()
  print(Component.New('test')['text.1'].String);
end)
```

## How it works
When a function is passed to `q()`, that function is stored in a `functions` table. The function is then executed.

**reactive-q** intercepts reads and writes to all controls in the `Controls` table, and all controls returned by `Component.New()`. As the function is executed, **reactive-q**  adds the function to the `listeners` table for each control that is read from.

The first time that a control is accessed by a `q(function)`, the control's `EventHandler` is overwritten. The new event handler first iterates through the `listeners` table for the control and calls those functions, before checking for the existence of a manually defined `EventHandler` function, and calling it too.

Additionally, any time a new value is written to a control, all the listener functions associated with that control will also be executed. This allows user-defined code to set control states in response to events such as user input, and have the `q(function)` declarations respond to the change.

All of the above tables are stored in a global table called `_reactive_q_data`.

## TODO
 - Add support for user-defined signals
 - Error handling